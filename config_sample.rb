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

# Choose your favorite version control system
load "bzr.rb"

# Change this if the url is not determined correctly
SITEURL = "http://#{$cgi.server_name}#{$cgi.script_name.gsub(/[^\/]*$/,"")}"

# add the htmlcode in the Variable NOTICE to the startpage
# Example 1: displays all available Polls
notice = <<NOTICE
<h2>Available Polls</h2>
<table summary='Available Polls'>
	<tr>
		<th>Poll</th><th>Last change</th>
	</tr>
NOTICE
Dir.glob("*/data.yaml").sort_by{|f|
	File.new(f).mtime
}.reverse.collect{|f| f.gsub(/\/data\.yaml$/,'') }.each{|site|
	notice += <<NOTICE
<tr>
	<td class='polls'><a href='./#{CGI.escapeHTML(site).gsub("'","%27")}/'>#{CGI.escapeHTML(site)}</a></td>
	<td class='mtime'>#{File.new(site + "/data.yaml").mtime.strftime('%d.%m, %H:%M')}</td>
</tr>
NOTICE
}
notice += "</table>"
# Example 2: displays a static text
notice += <<NOTICE
<h2>Examples</h2>
	If you want to play around with the Tool, you may want to take a look at these two Example Polls:<br />
	<a href='coffeebreak'>Event Schedule Poll</a><br />
	<a href='coffee'>Normal Poll</a>
NOTICE
NOTICE = notice


