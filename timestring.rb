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

require "date"
require "time"

class TimeString
	attr_reader :date, :time
	def initialize(date,time)
		@date = date.class == Date ? date : Date.parse(date)
		if time =~ /^\d[\d]?:\d[\d]?$/
			begin
#TODO: what to do with 24:00 ???
#					if time == "24:00"
#						@date += 1
#						time = "00:00"
#					end
					@time = Time.parse("#{@date} #{time}")
			rescue ArgumentError
				@time = time
			end
		else
			@time = time
		end
	end
	def TimeString.from_s(string)
		date = string.scan(/^(\d\d\d\d-\d\d-\d\d).*$/).flatten[0]
		time = string.scan(/^\d\d\d\d-\d\d-\d\d (.*)$/).flatten[0]
		TimeString.new(date,time)
	end
	def TimeString.now
		TimeString.new(Date.today,Time.now)
	end
	include Comparable
	def equal?(other)
		self <=> other
	end
	def eql?(other)
		self <=> other
	end
	def <=>(other)
		return -1 if other.class != TimeString
		if self.date == other.date
			if self.time.class == String && other.time.class == String
				self.time.to_i == other.time.to_i ? self.time <=> other.time : self.time.to_i <=> other.time.to_i
			elsif self.time.class == Time && other.time.class == Time
				self.time <=> other.time
			elsif self.time.class == NilClass && other.time.class == NilClass
				0
			else
				self.time.class == String ? 1 : -1
			end
		else
			self.date <=> other.date
		end
	end
	def to_s
		if @time
			"#{@date} #{time_to_s}"
		else
			CGI.escapeHTML(@date.to_s)
		end
	end
	def inspect
		"TS: date: #{@date} time: #{@time ? time_to_s : "nil"}"
	end
	def time_to_s
		if @time.class == Time
			return time.strftime("%H:%M")
		else
			return @time.to_s
		end
	end
end


if __FILE__ == $0
require 'test/unit'
require 'pp'


class TimeStringTest < Test::Unit::TestCase
	def test_uniq
		a = TimeString.new("2010-01-22","1:00")
		b = TimeString.new("2010-01-22","1:00")
		assert(a == b)
		assert(a === b)
		assert(a.equal?(b))
		assert(a.eql?(b))
		assert([a].include?(b))
		assert_equal([a],[a,b].uniq)
	end
end

end
