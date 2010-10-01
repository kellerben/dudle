#!/usr/bin/env ruby

############################################################################
# Copyright 2010 Benjamin Kellermann                                       #
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

require "cgi"
$cgi = CGI.new
def _(string)
	string
end
require "config"

poll = nil
EXAMPLES.each{|p|
	poll = p if $cgi["poll"] == p[:url]
}

raise "Example not found: '#{$cgi["poll"]}'" unless poll

targeturl = poll[:url]

if poll[:new_environment]
	targeturl += "_#{Time.now.to_i}"

	while (File.exists?(targeturl))
		targeturl += "I"
	end
	VCS.branch(poll[:url],targeturl)
end

if poll[:revno]
	Dir.chdir(targeturl)
	VCS.revert(poll[:revno])
	Dir.chdir("..")
end

$cgi.out({
	"status" => "REDIRECT",
	"Cache-Control" => "no-cache",
	"Location" => SITEURL + targeturl
}){""}
