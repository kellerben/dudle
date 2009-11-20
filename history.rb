#!/usr/bin/env ruby

################################
# Author:  Benjamin Kellermann #
# License: CC-by-sa 3.0        #
#          see License         #
################################

require "cgi"
require "yaml"

if __FILE__ == $0

$cgi = CGI.new

olddir = File.expand_path(".")
Dir.chdir("..")
require "html"
require "poll"
load "config.rb"
Dir.chdir(olddir)

if $cgi.include?("revision")
	REVISION=$cgi["revision"].to_i
	table = YAML::load(VCS.cat(REVISION, "data.yaml"))
else
	table = YAML::load_file("data.yaml")
end

$html = HTML.new("dudle - #{table.name} - History")
$html.header["Cache-Control"] = "no-cache"
load "../charset.rb"
$html.add_css("../dudle.css")

$html << "<body>"
$html << Dudle::tabs("Access Control")

$html << <<TABLE
	<div id='main'>
	<h1>History</h1>
TABLE


$html << "<p id='history'>history:#{table.history_to_html}</p>"
$html << table.to_html
$html << "</div></body>"

$html.out($cgi)
end
