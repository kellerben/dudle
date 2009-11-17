#!/usr/bin/env ruby

################################
# Author:  Benjamin Kellermann #
# License: CC-by-sa 3.0        #
#          see License         #
################################

require "yaml"
require "cgi"


if __FILE__ == $0

$cgi = CGI.new
$header = {}

$header["type"] = "text/html"
#$header["type"] = "application/xhtml+xml"
$header["charset"] = "utf-8"

$htmlout = <<HEAD
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
HEAD

olddir = File.expand_path(".")
Dir.chdir("..")
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

$htmlout += <<HEAD
<head>
	<meta http-equiv="Content-Type" content="#{$header["type"]}; charset=#{$header["charset"]}" /> 
	<meta http-equiv="Content-Style-Type" content="text/css" />
	<title>dudle - #{table.name}</title>
	<link rel="stylesheet" type="text/css" href="../dudle.css" title="default"/>
	<link rel="stylesheet" type="text/css" href="../print.css" title="print" media="print" />
	<link rel="stylesheet" type="text/css" href="../print.css" title="print" />
HEAD

$htmlout += '<link rel="alternate"  type="application/atom+xml" href="atom.cgi" />' if File.exists?("../atom_single.rb")

$htmlout += <<HEAD
</head>
<body>
	<div id='tabs'>
			<ul>
				<li id='active_tab' >&nbsp;poll&nbsp;</li>
				<li class='nonactive_tab'><a href='config.cgi'>&nbsp;config&nbsp;</a></li>
			</ul>
	</div>
	<div id='main'>
HEAD

# TABLE
if VCS.revno == 1
	$htmlout += <<HINT
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
	$htmlout += <<TABLE
<p id='history'>history:#{table.history_to_html}</p>
<h1>#{table.name}</h1>
<div id='polltable'>
	<form method='post' action='.'>
		#{table.to_html($cgi['edituser'])}
	</form>
</div>
TABLE

	$htmlout += table.comment_to_html
end

$htmlout += "</div></body>"

$htmlout += "</html>"

$header["Cache-Control"] = "no-cache"
$cgi.out($header){$htmlout}
end
