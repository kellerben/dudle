# coding: utf-8
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

# The license terms (AGPL) demands you to publish your sourcecode if you made
# any modifications to the server side code. The following URL will be visible
# at the about page.
# $conf.dudle_src = "https://github.com/kellerben/dudle/"

# Only git is supported currently
# $conf.vcs = "git"

# Change only if the url is not determined correctly (e.g. at the start page)
# $conf.siteurl = "http://example.org:9999/exampledir"

# You may insert some sites, which are under your site
# A breadcrumb will be generated in the way:
# TUD -> ... -> Fakultät Informatik -> Professur DuD -> dudle -> poll
#$conf.breadcrumbs = [
#	"<a href='http://tu-dresden.de'>TUD</a>",
#	"...",
#	"<a href='http://www.inf.tu-dresden.de'>Fakultät Informatik</a>",
#	"<a href='http://dud.inf.tu-dresden.de'>Professur Datenschutz und Datensicherheit</a>"
#]

# If you want to encourage the user to send bug reports, state the errorlog,
# which you have configured in your apache conf with the ErrorLog directive.
# In addition, you can change the email address to yours, if you want to
# receive the mails instead of me (the developer).
# You would do me a favor, if you configure this with my address, however,
# if you do not want people to read parts of your error log, leave the 
# $conf.errorlog unset!
# Make sure, that your apache can read this file 
# (which usually is not the case for /var/log/apache2/*)
# You have 2 Options: 
#   1. change logrotate to allow /var/log/apache2/* to be read by apache
#      (=> change the line »create 640 root adm«)
#   2. change $conf.errorlog to another file and create a new rule for logrotate.
#      DO NOT FORGET TO ADD THE ERROR LOG TO LOGROTATE IF YOU CHANGE THE PATH
#      TO OTHER THAN /var/log/apache2/* !
# If you do not know what to do what I am speaking about, just do not uncomment
# the next line
#$conf.errorlog = "/var/log/dudle_error.log"
#$conf.bugreportmail = "webmaster@yoursite.example.org"

# Send bug reports automatically with the program “mail”
#$conf.auto_send_report = false

# Add the following htmlcode to the startpage.
# Example: displays all available Polls
#$conf.indexnotice = <<INDEXNOTICE
#<h2>Available Polls</h2>
#<table>
#	<tr>
#		<th>Poll</th><th>Last change</th>
#	</tr>
#INDEXNOTICE
#Dir.glob("*/data.yaml").sort_by{|f|
#	File.new(f).mtime
#}.reverse.collect{|f| f.gsub(/\/data\.yaml$/,'') }.each{|site|
#	$conf.indexnotice += <<INDEXNOTICE
#<tr class='participantrow'>
#	<td class='polls'><a href='./#{CGI.escapeHTML(site).gsub("'","%27")}/'>#{CGI.escapeHTML(site)}</a></td>
#	<td class='mtime'>#{File.new(site + "/data.yaml").mtime.strftime('%d.%m, %H:%M')}</td>
#</tr>
#INDEXNOTICE
#}
#$conf.indexnotice += "</table>"


# Add some Example Polls to the example page.
# You may create those using the normal interface
# and make them password protected afterwards
# .htaccess and .htdigest are deleted after 
# example creation (defining password protected 
# examples is not possible therefore)
#$conf.examples = [
#	{
#		:url => "coffeebreak",
#		:description => _("Event-scheduling poll"),
#		:new_environment => true,
#	},{
#		:url => "coffee",
#		:description => _("Normal poll"),
#		:revno => 34
#	},{
#		:url => "Cheater",
#		:description => "Cheater",
#		:hidden => true
#	}
#]

# Add the following htmlcode to the example page.
#$conf.examplenotice = <<EXAMPLENOTICE
#	<h2>Screencasts</h2>
#	<ol>
#		<li><a href="0-register.ogv">Register a new user</a></li>
#		<li><a href="1-setup.ogv">Setup a new poll</a></li>
#		<li><a href="2-participate.ogv">Participate in a poll</a></li>
#	</ol>
#EXAMPLENOTICE

# Add the following htmlcode to the about page.
#$conf.aboutnotice = <<ABOUTNOTICE
#<div class='textcolumn'>
#	<h2>Bugs/Features</h2>
#	<ul>
#		<li><a href="Bugs">Report a Bug</a></li>
#		<li><a href="Features">Request a Feature</a></li>
#	</ul>
#</div>
#ABOUTNOTICE


# choose a default stylesheet
# e.g., "classic.css", "css/foobar.css", ...
#$conf.default_css = "default.css"
