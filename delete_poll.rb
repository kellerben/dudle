#!/usr/bin/env ruby

################################
# Author:  Benjamin Kellermann #
# License: CC-by-sa 3.0        #
#          see License         #
################################

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
$html = HTML.new("dudle - Delete - #{POLL}")

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
</div>
SUCCESS
	else
		$html << <<CANCEL
	You canceld the deletion!
</div>
CANCEL
	end

else

$html << <<TABLE
<div>
	<h1>Delete this Poll</h1>
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
</div>
TABLE
end

$html << "</body>"

$html.out($cgi)
end

