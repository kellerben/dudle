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
$html << <<TABLE
<h1>#{table.name}</h1>
<div id='polltable'>
	<form method='post' action='.'>
		#{table.to_html($cgi.include?('edituser') ? $cgi['edituser'] : $cgi.cookies["username"][0] )}
	</form>
</div>
TABLE

$html << table.comment_to_html

$html << "</div></body>"

$html.out($cgi)
end
