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

if __FILE__ == $0

load "../dudle.rb"
$d = Dudle.new("Delete Poll")
require "ftools"

QUESTIONS = ["Yes, I know what I am doing!",
             "I hate these stupid entry fields.",
             "I am aware of the consequences.",
             "Please delete this poll."]

if $cgi.include?("confirmnumber")
 CONFIRM = $cgi["confirmnumber"].to_i
	if $cgi["confirm"] == QUESTIONS[CONFIRM]
		Dir.chdir("..")
		File.move($d.urlsuffix, "/tmp/#{$d.urlsuffix}.#{rand(9999999)}")
		$d.html << <<SUCCESS
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
SUCCESS
		$d.out
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
$d.html << <<TABLE
	<h2>Delete this Poll</h2>
	You want to delete the poll named <b>#{$d.table.name}</b>.<br />
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
TABLE

$d.out

end
