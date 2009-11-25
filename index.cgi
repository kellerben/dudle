#!/usr/bin/env ruby

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

require "yaml"
require "cgi"


if __FILE__ == $0

$cgi = CGI.new

if File.exists?("config.rb")
	load "config.rb"
else
	puts "\nPlease configure me in the file config.rb"
	exit
end

require "poll"
require "html"
$html = HTML.new("dudle")
load "charset.rb"
$html.add_css("dudle.css")
$htlm.add_atom("atom.cgi") if File.exists?("atom.cgi")

	$html << "<body id='main'><h1>dudle</h1>"

if $cgi.include?("create_poll") && $cgi.include?("poll_url")
	POLLNAME=$cgi["create_poll"]
	if $cgi["poll_url"] == ""
		POLLURL = `pwgen -1`.chomp
	else
		POLLURL=$cgi["poll_url"]
	end


	if !(POLLURL =~ /^[\w\-_]*$/)
		createnotice = "Custom address may only contain letters, numbers, and dashes."
	elsif File.exist?(POLLURL)
		createnotice = "A Poll with this address already exists."
	else Dir.mkdir(POLLURL)
		Dir.chdir(POLLURL)
		VCS.init
		File.symlink("../participate.rb","index.cgi")
		VCS.add("index.cgi")
		["atom","customize", "history", "edit_columns","access_control", "delete_poll", "invite_participants"].each{|f|
			File.symlink("../#{f}.rb","#{f}.cgi")
			VCS.add("#{f}.cgi")
		}
		["data.yaml",".htaccess",".htdigest"].each{|f|
			File.open(f,"w").close
			VCS.add(f)
		}
		Poll.new(POLLNAME,$cgi["poll_type"])
		Dir.chdir("..")
		escapedsite = SITEURL + CGI.escapeHTML(CGI.escape(POLLURL)) + "/edit_columns.cgi"
		escapedsite.gsub!("+"," ")
		$html.header["status"] = "REDIRECT"
		$html.header["Cache-Control"] = "no-cache"
		$html.header["Location"] = escapedsite
		$html << "The poll was created successfully. The link to your new poll is:<br /><a href=\"#{escapedsite}\">#{escapedsite}</a>"
	end
end

unless $html.header["status"] == "REDIRECT"

	$html << <<CREATE
<h2>Create New Poll</h2>
<form method='post' action='.'>
<table  class='settingstable' summary='Create a new Poll'>
<tr>
	<td class='label'><label for="poll_name">Name:</label></td>
	<td><input id="poll_name" size='40' type='text' name='create_poll' value="#{CGI.escapeHTML($cgi["create_poll"])}" /></td>
</tr>
<tr>
	<td class='label'>Type:</td>
	<td>
		<input id='chooseTime' type='radio' value='time' name='poll_type' checked='checked' />
		<label for='chooseTime'>Event Schedule Poll (e.g. schedule a meeting)</label>
		<br />
		<input id='chooseNormal' type='radio' value='normal' name='poll_type' />
		<label for='chooseNormal'>Normal Poll (e.g. vote for what is the best coffee)</label>
	</td>
</tr>
<tr>
	<td></td>
	<td style='padding-bottom:0.7ex'><input type='submit' value='create' /></td>
</tr>
<tr>
	<td colspan='2' style='border-top:solid thin;padding-top:0.7ex;'>Custom address (optional):
	<span class='hint'>May contain letters, numbers, and dashes.</span></td>
</tr>
<tr>
	<td colspan='2'><label for="poll_url"><span class='hint'>#{SITEURL}</span></label><input id="poll_url" size='16' type='text' name='poll_url' value="#{CGI.escapeHTML($cgi["poll_url"])}" />
	</td>
</tr>
CREATE
	if defined?(createnotice)
		$html << <<NOTICE
<tr>
	<td colspan='2' class='error'>
		#{createnotice}
	</td>
</tr>
NOTICE
	end
	$html << <<CREATE
</table>
</form>
CREATE

	$html << NOTICE
	$html << "</body>"
end

$html.out($cgi)
end

