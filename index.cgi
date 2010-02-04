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


if File.exists?("config.rb")
	require "dudle"
else
	puts "\nPlease configure me in the file config.rb"
	exit
end

$d = Dudle.new

if $cgi.include?("create_poll") && $cgi.include?("poll_url")
	POLLTITLE=$cgi["create_poll"]
	if POLLTITLE == ""
		createnotice = _("Please enter a descriptive title.")
	else
		if $cgi["poll_url"] == ""
			if POLLTITLE =~ /^[\w\-_]*$/ && !File.exist?(POLLTITLE)
				POLLURL = POLLTITLE
			else
				POLLURL = `pwgen -1`.chomp
			end
		else
			POLLURL=$cgi["poll_url"]
		end


		if !(POLLURL =~ /^[\w\-_]*$/)
			createnotice = _("Custom address may only contain letters, numbers, and dashes.")
		elsif File.exist?(POLLURL)
			createnotice = _("A Poll with this address already exists.")
		else Dir.mkdir(POLLURL)
			Dir.chdir(POLLURL)
			VCS.init
			File.symlink("../participate.rb","index.cgi")
			VCS.add("index.cgi")
			["atom","customize", "history", "overview", "edit_columns","access_control", "delete_poll", "invite_participants"].each{|f|
				File.symlink("../#{f}.rb","#{f}.cgi")
				VCS.add("#{f}.cgi")
			}
			["data.yaml",".htaccess",".htdigest"].each{|f|
				File.open(f,"w").close
				VCS.add(f)
			}
			Poll.new(POLLTITLE,$cgi["poll_type"])
			Dir.chdir("..")
			$d.html.header["status"] = "REDIRECT"
			$d.html.header["Cache-Control"] = "no-cache"
			$d.html.header["Location"] = SITEURL + POLLURL+ "/edit_columns.cgi"
			$d << _("The poll was created successfully. The link to your new poll is:") + "<br /><a href=\"#{POLLURL}\">#{POLLURL}</a>"
		end
	end
end

unless $d.html.header["status"] == "REDIRECT"

	$d << "<h2>"+ _("Create New Poll") + "</h2>"

	titlestr = _("Title")
	typestr = _("Type")
	timepollstr = _("Event Schedule Poll (e.g. schedule a meeting)")
	normalpollstr = _("Normal Poll (e.g. vote for what is the best coffee)")
	customaddrstr = _("Custom address (optional)")
	customaddrhintstr = _("May contain letters, numbers, and dashes.")

	createstr = _("Create")
	$d << <<CREATE
<form method='post' action='.'>
<table  class='settingstable'>
<tr>
	<td class='label'><label for="poll_name">#{titlestr}:</label></td>
	<td><input id="poll_name" size='40' type='text' name='create_poll' value="#{CGI.escapeHTML($cgi["create_poll"])}" /></td>
</tr>
<tr>
	<td class='label'>#{typestr}:</td>
	<td>
		<input id='chooseTime' type='radio' value='time' name='poll_type' checked='checked' />
		<label for='chooseTime'>#{timepollstr}</label>
		<br />
		<input id='chooseNormal' type='radio' value='normal' name='poll_type' />
		<label for='chooseNormal'>#{normalpollstr}</label>
	</td>
</tr>
<tr>
	<td></td>
	<td class='separator_bottom'><input type='submit' value='#{createstr}' /></td>
</tr>
<tr>
	<td colspan='2' class='separator_top'>#{customaddrstr}:
	<span class='hint'>#{customaddrhintstr}</span></td>
</tr>
<tr>
	<td colspan='2'><label for="poll_url">#{SITEURL}</label><input id="poll_url" size='16' type='text' name='poll_url' value="#{CGI.escapeHTML($cgi["poll_url"])}" />
	</td>
</tr>
CREATE
	if defined?(createnotice)
		$d << <<NOTICE
<tr>
	<td colspan='2' class='error'>
		#{createnotice}
	</td>
</tr>
NOTICE
	end
	$d << <<CREATE
</table>
</form>
CREATE

	if defined?(EXAMPLES)
		$d << "<div><h2>" + _("Examples") + "</h2>"
		$d << _("If you want to play around with the Tool, you may want to take a look at these Example Polls:") + "<br />"
		$d << "<a href='#{EXAMPLES["event_schedule_example"]}'>" + _("Event Schedule Poll") + "</a><br />" if EXAMPLES["event_schedule_example"]
		$d << "<a href='#{EXAMPLES["normal_example"]}'>" + _("Normal Poll") + "</a></div>" if EXAMPLES["normal_example"]
	end

	$d << NOTICE
end

$d.out
end

