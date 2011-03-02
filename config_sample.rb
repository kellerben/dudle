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

# Change the SITEURL if the url is not determined correctly
case $cgi.server_port
when 80
	protocol = "http"
	port = ""
when 443
	protocol = "https"
	port = ""
else
	protocol = "http"
	port = ":#{$cgi.server_port}"
end
SITEURL = "#{protocol}://#{$cgi.server_name}#{port}#{$cgi.script_name.gsub(/[^\/]*$/,"")}"

# You may insert some sites, which are under your site
# A breadcrumb will be generated in the way:
# TUD -> ... -> Fakultät Informatik -> Professur DuD -> dudle -> poll
BREADCRUMBS = [
	"<a href='http://tu-dresden.de'>TUD</a>",
	"...",
	"<a href='http://www.inf.tu-dresden.de'>Fakultät Informatik</a>",
	"<a href='http://dud.inf.tu-dresden.de'>Professur Datenschutz und Datensicherheit</a>"
]

# If you want to encourage the user to send bug reports, state the errorlog,
# which you have configured in your apache conf with the ErrorLog directive.
# In addition, you can change the email address to yours, if you want to
# receive the mails instead of me (the developer).
# You would do me a favor, if you configure this with my address, however,
# if you do not want people to read parts of your error log, leave the 
# ERRORLOG variable unset!
# Make sure, that your apache can read this file 
# (which usually is not the case for /var/log/apache2/*)
# You have 2 Options: 
#   1. change logrotate to allow /var/log/apache2/* to be read by apache
#      (=> change the line »create 640 root adm«)
#   2. change ERRORLOG to another file and creat a new rule for logrotate.
#      DO NOT FORGET TO ADD THE ERROR LOG TO LOGROTATE IF YOU CHANGE THE PATH
#      TO OTHER THAN /var/log/apache2/* !
# If you do not know what to do what I am speaking about, just do not uncomment
# the next line
#ERRORLOG = "/var/log/dudle_error.log"
BUGREPORTMAIL = "Benjamin.Kellermann@tu-dresden.de"

# Send bug reports automatically with the programm “mail”
AUTO_SEND_REPORT = false

# add the htmlcode in the Variable INDEXNOTICE to the startpage
# Example: displays all available Polls
indexnotice = <<INDEXNOTICE
<h2>Available Polls</h2>
<table>
	<tr>
		<th>Poll</th><th>Last change</th>
	</tr>
INDEXNOTICE
Dir.glob("*/data.yaml").sort_by{|f|
	File.new(f).mtime
}.reverse.collect{|f| f.gsub(/\/data\.yaml$/,'') }.each{|site|
	indexnotice += <<INDEXNOTICE
<tr class='participantrow'>
	<td class='polls'><a href='./#{CGI.escapeHTML(site).gsub("'","%27")}/'>#{CGI.escapeHTML(site)}</a></td>
	<td class='mtime'>#{File.new(site + "/data.yaml").mtime.strftime('%d.%m, %H:%M')}</td>
</tr>
INDEXNOTICE
}
indexnotice += "</table>"
INDEXNOTICE = indexnotice

# Add some Example Polls to the example page
# you may create those using the normal interface
# and make them password protected afterwards
# .htaccess and .htdigest are deleted after 
# example creation (defining password protected 
# examples is not possible therefore)
EXAMPLES = [
	{
		:url => "coffeebreak",
		:description => _("Event Schedule Poll"),
		:new_environment => true,
	},{
		:url => "coffee",
		:description => _("Normal Poll"),
		:revno => 34
	},{
		:url => "Cheater",
		:description => "Cheater",
		:hidden => true
	}
]

# add the htmlcode in the Variable EXAMPLENOTICE to the example page
examplenotice = <<EXAMPLENOTICE
	<h2>Screencasts</h2>
	<ol>
		<li><a href="0-register.ogv">Register a new user</a></li>
		<li><a href="1-setup.ogv">Setup a new poll</a></li>
		<li><a href="2-participate.ogv">Participate in a poll</a></li>
	</ol>
EXAMPLENOTICE
EXAMPLENOTICE = examplenotice

# add the htmlcode in the Variable ABOUTNOTICE to the about page
aboutnotice = <<ABOUTNOTICE
<div class='textcolumn'>
	<h2>Bugs/Features</h2>
	<ul>
		<li><a href="Bugs">Report a Bug</a></li>
		<li><a href="Features">Request a Feature</a></li>
	</ul>
</div>
ABOUTNOTICE
ABOUTNOTICE = aboutnotice

# choose a default stylesheet
# e.g., "classic.css", "css/foobar.css", ...
DEFAULT_CSS = "default.css"
