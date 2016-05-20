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

if __FILE__ == $0

require_relative "dudle"

$d = Dudle.new

if $cgi.include?("poll")

	poll = nil
	$conf.examples.each{|p|
		poll = p if $cgi["poll"] == p[:url]
	}

	if poll

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

		$d.html.header["status"] = "REDIRECT"
		$d.html.header["Cache-Control"] = "no-cache"
		$d.html.header["Location"] = $conf.siteurl + targeturl

	else
		$d << "<div class='error'>"
		$d << _("Example not found: %{example}") % { :example => CGI.escapeHTML($cgi["poll"])}
		$d << "</div>" 
	end
end

unless $d.html.header["status"] == "REDIRECT"
	unless $conf.examples.empty?
		$d << "<div class='textcolumn'><h2>" + _("Examples") + "</h2>"
		$d << _("If you want to play with the application, you may want to take a look at these example polls:") 
		$d << "<ul>"
		$conf.examples.each{|poll|
			$d << "<li><a href='example.cgi?poll=#{poll[:url]}'>#{poll[:description]}</a></li>" unless poll[:hidden]
		}
		$d << "</ul></div>"
	end

	$d << $conf.examplenotice
end


$d.out


end
