############################################################################
# Copyright 2009-2019 Benjamin Kellermann                                  #
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

require 'date'
require 'time'

class TimeString
	attr_reader :date, :time

	def initialize(date, time)
		@date = date.class == Date ? date : Date.parse(date)
		if time =~ /^\d[\d]?:\d[\d]?$/
			begin
				# TODO: what to do with 24:00 ???
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

	def self.from_s(string)
		date = string.scan(/^(\d\d\d\d-\d\d-\d\d).*$/).flatten[0]
		time = string.scan(/^\d\d\d\d-\d\d-\d\d (.*)$/).flatten[0]
		TimeString.new(date, time)
	end

	def self.now
		TimeString.new(Date.today, Time.now)
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

		if date == other.date
			if time.class == String && other.time.class == String
				time.to_i == other.time.to_i ? time <=> other.time : time.to_i <=> other.time.to_i
			elsif time.class == Time && other.time.class == Time
				time <=> other.time
			elsif time.class == NilClass && other.time.class == NilClass
				0
			else
				time.class == String ? 1 : -1
			end
		else
			date <=> other.date
		end
	end

	def to_s
		if @time
			"#{CGI.escapeHTML(@date.to_s)} #{time_to_s}"
		else
			CGI.escapeHTML(@date.to_s)
		end
	end

	def inspect
		"TS: date: #{@date} time: #{@time ? time_to_s : 'nil'}"
	end

	def time_to_s
		return time.strftime('%H:%M') if @time.class == Time

		@time.to_s
	end
end

if __FILE__ == $0
	require 'test/unit'
	require 'pp'

	class TimeStringTest < Test::Unit::TestCase
		def test_uniq
			a = TimeString.new('2010-01-22', '1:00')
			b = TimeString.new('2010-01-22', '1:00')
			assert(a == b)
			assert(a === b)
			assert(a.equal?(b))
			assert(a.eql?(b))
			assert([a].include?(b))
			assert_equal([a], [a, b].uniq)
		end
	end

end
