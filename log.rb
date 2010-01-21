############################################################################
# Copyright 2009,2010 Benjamin Kellermann                                  #
#                                                                          #
# This file is part of dudle.                                              #
#                                                                          #
# Dudle is free software: you can redistribute it and/or modify it under   #
# the terms of the GNU Affero General Public License as published by       #
# the Free Software Foundation, either version 3 of the License, or        #
# (at your option) any later version.                                      #
#                                                                          #
# Dudle is distributed in the hope that it will be useful, but WITHOUT ANY #
# WARRANTY; without even the implied warranty of MERCHANTABILITY or        #
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public     #
# License for more details.                                                #
#                                                                          #
# You should have received a copy of the GNU Affero General Public License #
# along with dudle.  If not, see <http://www.gnu.org/licenses/>.           #
############################################################################

require "time"

class LogEntry
	attr_accessor :rev, :timestamp, :comment
	def initialize(rev,timestamp,comment)
		@rev = rev
		@timestamp = timestamp
		@comment = comment
	end
	def to_html(link = true,history = "")
		ret = "<tr><td>"
		if link
			ret += "<a href='?revision=#{@rev}"
			ret += "&amp;history=#{history}" if history != ""
			ret += "'>"
		end
		ret += "#{@rev}"
		ret += "</a>" if link
		ret += "</td>"
		ret += "<td>#{@timestamp.strftime('%d.%m, %H:%M')}</td>"
		ret += "<td class='historycomment'>#{CGI.escapeHTML(@comment)}</td>"
		ret += "</tr>"
		ret
	end
	include Comparable
	def <=>(other)
		self.rev <=> other.rev
	end
	def inspect
		"#{@rev}: #{@comment}"
	end
end

class Log
	attr_reader :log
	def initialize(a = [])
		@log = a.compact.sort
	end
	def min
		@log.sort!
		@log[0]
	end
	def max
		@log.sort!
		@log[-1]
	end
	def revisions
		@log.collect{|e| e.rev }
	end
	def [](revision)
		i = revisions.index(revision)
		if i
			return @log[i]
		else # no revision found, search the nearest
			dist = revisions.collect{|e| (e - revision).abs }.sort[0]
			return nil unless dist
			i = revisions.index(revision + dist) || revisions.index(revision - dist)
			return @log[i]
		end
	end
	
	def size
		@log.size
	end
	def around_rev(rev,number)
		ret = [self[rev]]
		midindex = @log.index(ret[0])
		counter = 1
		while ret.size < number && counter < @log.size
			ret << @log[midindex + counter]
			counter *= -1 if counter <= midindex
			if counter > 0
				counter += 1
			end
			ret.compact!
		end
		ret.sort!
		Log.new(ret)
	end

	def +(other)
		a = @log + other.log
		Log.new(a.sort)
	end

	def add(revision,timestamp,comment)
		@log << LogEntry.new(revision,timestamp,comment)
		@log.sort!
	end
	def to_html(unlinkedrevision,history)
		ret = "<table><tr><th>"
		ret += _("Version") + "</th><th>" + _("Date") + "</th><th>" + _("Comment") + "</th></tr>"
		self.reverse_each{|l|
			ret += l.to_html(unlinkedrevision != l.rev,history)
		}
		ret += "</table>"
		ret
	end
	def reverse_each
		@log.reverse.each{|e| yield(e)}
	end
	def each
		@log.each{|e| yield(e)}
	end
	def collect
		@log.collect{|e| yield(e)}
	end
	def comment_matches(regex)
		Log.new(@log.collect{|e| e if e.comment =~ regex}.compact)
	end
	def undorevisions
		h = []
		minrev = min.rev
		rev = max.rev
		while rev > minrev
			elem = self[rev]
			prevrev = elem.comment.scan(/^.* to version (\d*)$/).flatten[0]
			if prevrev
				rev = prevrev.to_i	
			else
				h << elem
				rev -= 1
			end
		end
		h.sort!
		a = []
		begin 
			a << h.pop
		end while a.last && a.last.comment =~ /^Column .*$/
		a.pop	
		a.sort!
		Log.new(a)
	end
	def redorevisions
		@log.sort!
		revertrevs = []
		redone = []
		minrev = min.rev
		(minrev..max.rev).reverse_each{|rev|
			action,r = self[rev].comment.scan(/^(.*) to version (\d*)$/).flatten
			break unless r
			if action =~ /^Redo changes/
				break unless revertrevs.empty?
				redone << r.to_i() -1
			else
				revertrevs << r.to_i 
			end
		}
		revertrevs = revertrevs - redone
		Log.new(revertrevs.collect{|e| self[e+1]})
	end
end

if __FILE__ == $0
require "test/unit"
require "pp"
  class Log_test < Test::Unit::TestCase
    def test_indexes

			l = Log.new

			l.each{flunk("this should not happen")}
			assert_equal(nil,l[2])

			l.add(10,Time.now,"baz 10")
			20.times{|i|
				l.add(i,Time.now,"foo #{i}") unless i == 10
			}

			assert_equal(0,l.min.rev)
			assert_equal(19,l.max.rev)
      assert_equal("baz 10",l[10].comment)

      assert_equal([10],l.comment_matches(/^baz \d*$/).revisions)

			[42,23].each{|i|
				l.add(i,Time.now,"foo #{i}")
			}
			assert_equal(l[42],l[37])

			assert_equal([16,17,18,19,23,42],l.around_rev(23,6).revisions)
			assert_equal([0,1,2,3,4,5,6,7,8,9,10,11],l.around_rev(2,12).revisions)
			assert_equal(l.revisions,l.around_rev(0,99).revisions)

    end
    def test_undoredo

    	#       15  16  17
    	#       |   |   |
    	#       11  10  |
    	#     14|   |   |
    	#   13| 7---8---9
    	#   | 12| 6
    	#   | | | |
    	# 0-1-2-3-4-5
    	#   p
    	
    	def dummy_add(log,comment)
				log.add(log.max.rev+1,Time.now,comment)
			end
    	l = Log.new
			l.add(1,Time.now,"Participant Spamham added")
			6.times{|i|
				l.add(i,Time.now,"Column Foo#{i} added") unless i == 1
			}

			assert_equal([2,3,4,5],l.undorevisions.revisions)
			assert_equal([],l.redorevisions.revisions)

			dummy_add(l,"Reverted Poll to version 4")
			assert_equal([2,3,4],l.undorevisions.revisions)
			assert_equal([5],l.redorevisions.revisions)

			dummy_add(l,"Reverted Poll to version 3")
			assert_equal([2,3],l.undorevisions.revisions)
			assert_equal([4,5],l.redorevisions.revisions)

			dummy_add(l,"Column Foo added")
			assert_equal([2,3,8],l.undorevisions.revisions)
			assert_equal([],l.redorevisions.revisions)

			dummy_add(l,"Column Foo added")

			assert_equal([2,3,8,9],l.undorevisions.revisions)
			assert_equal([],l.redorevisions.revisions)
			
			dummy_add(l,"Reverted Poll to version 8")
			dummy_add(l,"Reverted Poll to version 7")
			dummy_add(l,"Reverted Poll to version 2")
			dummy_add(l,"Reverted Poll to version 1")
			assert_equal([],l.undorevisions.revisions)
			assert_equal([2,3,8,9],l.redorevisions.revisions)

			dummy_add(l,"Redo changes to version 2")
			dummy_add(l,"Redo changes to version 3")
			assert_equal([2,3],l.undorevisions.revisions)
			assert_equal([8,9],l.redorevisions.revisions)
			
			dummy_add(l,"Redo changes to version 8")
			dummy_add(l,"Redo changes to version 9")
			assert_equal([2,3,8,9],l.undorevisions.revisions)
			assert_equal([],l.redorevisions.revisions)

			# second time should be the same
			dummy_add(l,"Reverted Poll to version 8")
			assert_equal([2,3,8],l.undorevisions.revisions)
			assert_equal([9],l.redorevisions.revisions)
			dummy_add(l,"Reverted Poll to version 7")
			assert_equal([2,3],l.undorevisions.revisions)
			assert_equal([8,9],l.redorevisions.revisions)
			dummy_add(l,"Reverted Poll to version 2")
			assert_equal([2],l.undorevisions.revisions)
			assert_equal([3,8,9],l.redorevisions.revisions)
			dummy_add(l,"Reverted Poll to version 1")
			assert_equal([],l.undorevisions.revisions)
			assert_equal([2,3,8,9],l.redorevisions.revisions)

			dummy_add(l,"Redo changes to version 2")
			dummy_add(l,"Redo changes to version 3")
			assert_equal([2,3],l.undorevisions.revisions)
			assert_equal([8,9],l.redorevisions.revisions)
			
			dummy_add(l,"Redo changes to version 8")
			dummy_add(l,"Redo changes to version 9")
			assert_equal([2,3,8,9],l.undorevisions.revisions)
			assert_equal([],l.redorevisions.revisions)
		end
  end 
end
