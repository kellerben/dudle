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
$html << Dudle::tabs("History")

$html << <<TABLE
	<div id='main'>
	<h1>History of #{table.name}</h1>
TABLE



if defined?(REVISION)
	$html << "<h2>Poll of Version #{REVISION}</h2>"
else
	$html << "<h2>Current Poll</h2>"
end
$html << table.to_html("",false)

$html << "<h2>History</h2>"
$html << "<div id='history'>#{table.history_to_html}</div>"

$html << "</div></body>"

$html.out($cgi)
end
