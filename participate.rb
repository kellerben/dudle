#!/usr/bin/env ruby

################################
# Author:  Benjamin Kellermann #
# License: CC-by-sa 3.0        #
#          see License         #
################################

require "yaml"

if __FILE__ == $0

require "cgi"

$cgi = CGI.new

olddir = File.expand_path(".")
Dir.chdir("..")
require "html"
require "poll"
load "config.rb"
Dir.chdir(olddir)

table = YAML::load_file("data.yaml")

if $cgi.include?("add_participant")
	if $cgi.include?("delete_participant")
		table.delete($cgi["olduser"])
	else
		agreed = {}
		$cgi.params.each{|k,v|
			if k =~ /^add_participant_checked_/
				agreed[k.gsub(/^add_participant_checked_/,"")] = v[0]
			end
		}

		table.add_participant($cgi["olduser"],$cgi["add_participant"],agreed)
	end
end

table.add_comment($cgi["commentname"],$cgi["comment"]) if $cgi["comment"] != ""
table.delete_comment($cgi["delete_comment"].to_i) if $cgi.include?("delete_comment")

$html = HTML.new("dudle - #{table.name}")
$html.header["Cache-Control"] = "no-cache"
load "../charset.rb"
$html.add_css("../dudle.css")
$html.add_css("../print.css","print")

$html.add_atom("atom.cgi") if File.exists?("../atom.rb")


$html << "<body>"

$html << Dudle::tabs("Poll")

$html << <<HEAD
	<div id='main'>
HEAD

# TABLE
if VCS.revno == 1
	$html << <<HINT
<h1>#{table.name}</h1>
<pre id='configwarning'>
    .
  .:;:.
.:;;;;;:.
  ;;;;;
  ;;;;;
  ;;;;;
  ;;;;;      Please configure this poll
  ;:;;;      within the config tab!
  ;;; :
  ;:;
  ;.: .
  : .
  .   .

   .
</pre>
HINT
else
	$html << <<TABLE
<h1>#{table.name}</h1>
<div id='polltable'>
	<form method='post' action='.'>
		#{table.to_html($cgi['edituser'])}
	</form>
</div>
TABLE

	$html << table.comment_to_html
end

$html << "</div></body>"

$html.out($cgi)
end
