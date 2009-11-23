############################################################################
# Copyright 2009 Benjamin Kellermann                                       #
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
	def to_html(link = true)
		ret = "<tr><td>"
		ret += "<a href='?revision=#{@rev}' >" if link
		ret += "#{@rev}"
		ret += "</a>" if link
		ret += "</td>"
		ret += "<td>#{@timestamp.strftime('%d.%m, %H:%M')}</td>"
		ret += "<td class='historycomment'>#{CGI.escapeHTML(@comment)}</td>"
		ret += "</tr>"
		ret
	end
end

class Log
	def initialize(a = [])
		@log = a
	end
	def min
		ret = @log[0]
		@log.each{|l|
			ret.rev = l if l.rev < ret.rev
		}
		ret
	end
	def max
		ret = @log[-1]
		@log.each{|l|
			ret.rev = l if l.rev > ret.rev
		}
		ret
	end
	def [](revision)
		if revision.class == Fixnum
			@log.each{|l|
				return l if l.rev == revision
			}
			raise "No such revision found #{revision}"
		else
			min_r, max_r = "",""
			@log.each_with_index{|l,i|
				min_r = i if l.rev == revision.min
				max_r = i if l.rev == revision.max
			}
			min_r = @log.index(min) if min_r == ""
			max_r = @log.index(max) if max_r == ""
			return Log.new(@log[min_r..max_r])
		end
	end
	def add(revision,timestamp,comment)
		@log << LogEntry.new(revision,timestamp,comment)
		@log.sort!{|a,b| a.rev <=> b.rev}
	end
	def to_html(notlinkrevision)
		ret = "<table><tr><th>Version</th><th>Date</th><th>Comment</th></tr>"
		self.each do |l|
			ret += l.to_html(notlinkrevision != l.rev)
		end
		ret += "</table>"
		ret
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
	def flatten
		h = []
		minrev = min.rev
		rev = max.rev
		while rev > minrev
			elem = self[rev]
			prevrev = elem.comment.scan(/^Reverted Poll to revision (\d*)$/).flatten[0]
			if prevrev
				rev = prevrev.to_i	
			else
				h << elem
				rev += -1
			end
		end
		h.sort!{|a,b| a.rev <=> b.rev}
		Log.new(h)
	end
end

if __FILE__ == $0
require "test/unit"
  class Log_test < Test::Unit::TestCase
    def test_indexes

			l = Log.new
			l.add(10,Time.now,"baz 10")
			20.times{|i|
				l.add(i,Time.now,"foo #{i}") unless i == 10
			}

			assert_equal(0,l.min.rev)
			assert_equal(19,l.max.rev)
      assert_equal("baz 10",l[10].comment)

			p = l[9..11]
      assert_equal([9,10,11],[p[9].rev,p[10].rev,p[11].rev])
      
      assert_equal([10],l.comment_matches(/^baz \d*$/).collect{|e| e.rev})
    end
  end 
end
