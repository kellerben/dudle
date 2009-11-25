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


require "cgi"
require "ftools"

if __FILE__ == $0

$cgi = CGI.new

olddir = File.expand_path(".")
Dir.chdir("..")
load "html.rb"
load "config.rb"
require "poll"
require "yaml"
Dir.chdir(olddir)

POLLNAME = YAML::load_file("data.yaml").name
POLL = File.basename(File.expand_path("."))
$html = HTML.new("dudle - #{POLLNAME} - Delete")

$html.header["Cache-Control"] = "no-cache"

$html.add_css("../dudle.css")

$html << "<body>"

if $cgi.include?("confirmnumber")
 CONFIRM = $cgi["confirmnumber"].to_i
	if $cgi["confirm"] == QUESTIONS[CONFIRM]
		Dir.chdir("..")
		File.move(POLL, "/tmp/#{POLL}.#{rand(9999999)}")
		$html << <<SUCCESS
<div id='main'>
<p class='textcolumn'>
	The poll was deleted successfully!
</p>
<p class='textcolumn'>
	If this was done by accident, please contact the administrator of the system.
	The poll can be recovered for an indeterministic amount of time, maybe it is already to late. </p>
<div class='textcolumn'>
	Things you can do now are
	<ul>
		<li><a href='../'>Return to dudle home and Schedule a new Poll</a></li>
		<li><a href='http://wikipedia.org'>Browse Wikipedia</a></li>
		<li><a href='http://www.google.de'>Search something with Google</a></li>
	</ul>
</div>
</div>
</body>
SUCCESS
		$html.out($cgi)
		exit
	else
		hint = <<HINT
<table style='background:lightgray' summary='Error about wrong confirmation string'>
	<tr>
		<td style='text-align:right'>
			To delete the poll, you have to type:
		</td>
		<td class='warning' style='text-align:left'>
			#{QUESTIONS[CONFIRM]}
		</td>
	</tr>
	<tr>
		<td style='text-align:right'>
			but you typed:
		</td>
		<td class='warning' style='text-align:left'>
			#{$cgi["confirm"]}
		</td>
	</tr>
</table>
HINT
	end
else
	CONFIRM = rand(QUESTIONS.size)
end
$html << <<TABLE
#{Dudle::tabs("Delete Poll")}
<div id='main'>
	<h1>#{POLLNAME}</h1>
	<h2>Delete this Poll</h2>
	You want to delete the poll named <b>#{POLLNAME}</b>.<br />
	This is an irreversible action!<br />
	If you are sure in what you are doing, please type into the form “#{QUESTIONS[CONFIRM]}”
	#{hint}
	<form method='post' action=''>
		<div>
			<input type='hidden' name='confirmnumber' value='#{CONFIRM}' />
			<input size='30' type='text' name='confirm' value='#{$cgi["confirm"]}' />
			<input type='submit' value='Delete' />
		</div>
	</form>
</div>
</body>
TABLE

$html.out($cgi)

end
