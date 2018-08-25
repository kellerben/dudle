############################################################################
# Copyright 2009,2010 Benjamin Kellermann                                  #
#                                                                          #
# This file is part of Dudle.                                              #
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

if __FILE__ == $0
require "test/unit"
require "pp"
unless ARGV[0]
	puts "Usage: ruby #{$0} git" 
	exit
end
require "vcs_#{ARGV[0]}"
require "benchmark"

class VCS_test < Test::Unit::TestCase
	def setup
		@data = ["foo","bar","baz","spam","ham","egg"]
		@history = ["aaa","bbb","ccc","ddd","eee","fff"]
		@repo = "/tmp/vcs_test_#{rand(10000)}"
		Dir.mkdir(@repo)
		Dir.chdir(@repo)
		VCS.init
		File.open("data.txt","w").close
		VCS.add("data.txt")
		@data.each_index{|i|
			File.open("data.txt","w"){|f| f << @data[i] }
			VCS.commit(@history[i])
		}
		@b = 0
		@t = ""
	end
	def teardown
		puts @repo
#		Dir.chdir("/")
#		%x{rm -rf #{@repo}}
		puts "#{@t}: #{@b}"
	end
	def test_cat
		@data.each_with_index{|item,revnominusone|
			result = ""
			@b += Benchmark.measure{
				result = VCS.cat(revnominusone+1,"data.txt")
			}.total
			assert_equal(item,result,"revno: #{revnominusone+1}")
		}
		@t = "cat"
	end
	def test_revno
		r = -1
		@b += Benchmark.measure{
			r = VCS.revno
		}.total
		assert_equal(@data.size,r)
		@t = "revno"
	end
	def test_history
		l = nil
		@b += Benchmark.measure{
			l = VCS.history
		}.total
		pp l
		exit
		assert_equal(@data.size,l.size)
		@history.each_with_index{|h,revminusone|
			assert_equal(h,l[revminusone+1].comment)
		}

		@t = "history"
	end
end 
end
