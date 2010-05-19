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

# Choose your favorite version control system
# bzr and git is implemented
# Warning: bzr is slow!
# Warning: git needs git >=1.6.5
require "git"

# Change this if the url is not determined correctly
SITEURL = "http://#{$cgi.server_name}#{$cgi.script_name.gsub(/[^\/]*$/,"")}"

# If you want to encourage the user to send bug reports, state the errorlog,
# which you have configured in your apache conf with the ErrorLog directive.
# In addition, you can change the email address to yours, if you want to
# receive the mails instead of me (the developer).
# You would do me a favor, if you configure this with my address, however,
# if you do not want people to read parts of your error log, leave the 
# ERRORLOG variable unset!
# Make sure, that your apache can read this file 
# (which usually is not the case for /var/log/apache2/*)
#ERRORLOG = "/var/log/dudle_error.log"
BUGREPORTMAIL = "Benjamin.Kellermann@tu-dresden.de"

# Send bug reports automatically with the programm “mail”
AUTO_SEND_REPORT = false

# Add some Example Polls to the start page
EXAMPLES = {
	"event_schedule_example" => "coffeebreak",
	"normal_example" => "coffee"
}

# add the htmlcode in the Variable NOTICE to the startpage
# Example: displays all available Polls
notice = <<NOTICE
<h2>Available Polls</h2>
<table>
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
NOTICE = notice
