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

$cgi = CGI.new
$header = {}

$header["type"] = "text/html"
#$header["type"] = "application/xhtml+xml"
$header["charset"] = "utf-8"

POLL = File.basename(File.expand_path("."))

$htmlout = <<HEAD
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
	<meta http-equiv="Content-Type" content="#{$header["type"]}; charset=#{$header["charset"]}" /> 
	<meta http-equiv="Content-Style-Type" content="text/css" />
	<title>dudle - delete - #{POLL}</title>
	<link rel="stylesheet" type="text/css" href="../dudle.css" title="default"/>
</head>
<body id='main'>
HEAD

if $cgi.include?("confirmnumber")
	if $cgi["confirm"] == QUESTIONS[$cgi["confirmnumber"].to_i]
		Dir.chdir("..")
		File.move(POLL, "/tmp/#{POLL}.#{rand(9999999)}")
		$htmlout += <<SUCCESS
<div>
	The poll was deleted successfully!
	<br />
	If this was done by accident, please contact the administrator of the system.
	The poll can be recovered for an indeterministic amount of time, maybe it is already to late. <br />
	<a href='../'>home</a>
</div>
SUCCESS
	else
		$htmlout += <<CANCEL
<div>
	You canceld the deletion!
	<br />
	<a href='config.cgi'>config</a>
	<a href='remove.cgi'>delete</a>
</div>
CANCEL
	end

else

$htmlout += <<TABLE
<div>
	<h1>Delete a Poll</h1>
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

$htmlout += "</body>"

$htmlout += "</html>"

$header["Cache-Control"] = "no-cache"
$cgi.out($header){$htmlout}
end

