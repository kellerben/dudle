#!/usr/bin/env ruby

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


if __FILE__ == $0
	require "pp"
	puts "Content-type: text/plain\n"
	puts

problems = []
hints = []

begin
	
	hints << "You might want to config your environment within the file 'config.rb' (see 'config_sample.rb' for a starting point)" unless File.exists?("config.rb")

begin
	require_relative "dudle"
	#require "rubygems"
	#require "atom" FIXME: rename atom.rb
rescue LoadError => e
	problems << ["Some Library is missing:", e.message]
end



unless File.exists?("locale/de/dudle.mo")
	problems << ["If you want a language other than English, you will need a localization and therefore need ot build the .mo files. Refer the README for details."]
end

unless File.writable?(".")
	problems << ["Your webserver needs write access to #{File.expand_path(".")}"]
end

rescue Exception => e
	puts "Some problem occured. Please contact the developer:"
	pp e
else
	if problems.empty?
		puts "Your environment seems to be installed correctly!"
		unless hints.empty?
			print "Some hints are following:\n - "
			puts hints.join("\n - ")
		end

	else
		puts "Some problem occured:"
		print " - "
		puts problems.collect{|a|
			a.join("\n   ")
		}.join("\n - ")
	end
end
#4. You have to build a .mo file from the .po file in order to use the 
   #localization. Type:
      #make
   #This requires libgettext-ruby-util, potool, and make to be installed.
     #sudo aptitude install libgettext-ruby-util potool make


end

