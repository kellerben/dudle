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

require "yaml"
require "cgi"


if __FILE__ == $0

$cgi = CGI.new

olddir = File.expand_path(".")
Dir.chdir("..")
require "html"
load "config.rb"
require "poll"
Dir.chdir(olddir)


table = YAML::load_file("data.yaml")

if $cgi.include?("add_participant")
	table.add_participant("",$cgi["add_participant"],{})
end

$html = HTML.new("dudle - #{table.name} - Invite Participants")
$html.header["Cache-Control"] = "no-cache"
load "../charset.rb"
$html.add_css("../dudle.css")

$html << "<body>"
$html << Dudle::tabs("Invite Participants")

$html << <<TABLE
	<div id='main'>
	<h1>#{table.name}</h1>
	<h2>Invite Participants</h2>
	<form method='post' action=''>
		#{table.to_html("","invite")}
	</form>
TABLE

$html << "</div></body>"

$html.out($cgi)
end

