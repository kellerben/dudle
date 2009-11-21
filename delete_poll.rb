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

QUESTIONS = ["Yes, I know what I am doing!",
             "I hate these stupid entry fields.",
             "I am aware of the consequences.",
             "Please delete this poll."]

CONFIRM = rand(QUESTIONS.size)

require "cgi"
require "ftools"

if __FILE__ == $0

POLL = File.basename(File.expand_path("."))
$cgi = CGI.new
load "../html.rb"
$html = HTML.new("dudle - #{POLL} - Delete")

$html.header["Cache-Control"] = "no-cache"

$html.add_css("../dudle.css")

$html << "<body>"
$html << Dudle::tabs("Delete Poll")
$html << "<div id='main'>"

if $cgi.include?("confirmnumber")
	if $cgi["confirm"] == QUESTIONS[$cgi["confirmnumber"].to_i]
		Dir.chdir("..")
		File.move(POLL, "/tmp/#{POLL}.#{rand(9999999)}")
		$html << <<SUCCESS
	The poll was deleted successfully!
	<br />
	If this was done by accident, please contact the administrator of the system.
	The poll can be recovered for an indeterministic amount of time, maybe it is already to late. <br />
	<a href='../'>home</a>
SUCCESS
	else
		$html << <<CANCEL
	You canceld the deletion!
CANCEL
	end

else
$html << <<TABLE
	<h1>#{POLL}</h1>
	<h2>Delete this Poll</h2>
	You want to delete the poll named <b>#{POLL}</b>.<br />
	This is an irreversible action!<br />
	If you are sure in what you are doing, please type into the form “#{QUESTIONS[CONFIRM]}”
	<form method='post' action=''>
		<div>
			<input type='hidden' name='confirmnumber' value='#{CONFIRM}' />
			<input size='30' type='text' name='confirm' />
			<input type='submit' value='delete' />
		</div>
	</form>
TABLE
end
$html << "</div>"

$html << "</body>"

$html.out($cgi)
end

