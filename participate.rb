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
$html = HTML.new
require "poll"
load "charset.rb"
load "config.rb"
Dir.chdir(olddir)

if $cgi.include?("revision")
	REVISION=$cgi["revision"].to_i
	table = YAML::load(VCS.cat(REVISION, "data.yaml"))
else
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
end
$html.add_css("../dudle.css")
$html.add_css("../print.css","print")

$html.add_atom("atom.cgi") if File.exists?("../atom.rb")
$html.add_head("dudle - #{table.name}")

$html.htmlout += "<body>"

$html.add_tabs

$html.htmlout += <<HEAD
	<div id='main'>
HEAD

# TABLE
if VCS.revno == 1
	$html.htmlout += <<HINT
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
	$html.htmlout += <<TABLE
<p id='history'>history:#{table.history_to_html}</p>
<h1>#{table.name}</h1>
<div id='polltable'>
	<form method='post' action='.'>
		#{table.to_html($cgi['edituser'])}
	</form>
</div>
TABLE

	$html.htmlout += table.comment_to_html
end

$html.htmlout += "</div></body>"

$html.htmlout += "</html>"

$html.header["Cache-Control"] = "no-cache"
$cgi.out($html.header){$html.htmlout}
end
