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
	revno=$cgi["revision"].to_i
	versiontitle = "Poll of Version #{revno}"
	table = YAML::load(VCS.cat(revno, "data.yaml"))
else
	revno = VCS.revno
	versiontitle = "Current Poll (Version #{revno})"
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
	<h1>#{table.name}</h1>
TABLE



$html << "<h2>#{versiontitle}</h2>"
$html << table.to_html("",false)

$html << "<h2>History</h2>"
$html << "<div id='history'>"
$html << table.history_selectform($cgi.include?("revision") ? revno : nil, $cgi["history"])

$html << table.history_to_html(revno, $cgi["history"])
$html << "</div>"

$html << "</div></body>"

$html.out($cgi)
end
