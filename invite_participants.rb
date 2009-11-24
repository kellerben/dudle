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
# BUGFIX for Time.parse, which handles the zone indeterministically
class << Time
	alias_method :old_parse, :parse
	def Time.parse(date, now=self.now)
		Time.old_parse("2009-10-25 00:30")
		Time.old_parse(date)
	end
end


table = YAML::load_file("data.yaml")

# TODO: move to own tab
#if $cgi.include?("add_participant")
#	if $cgi.include?("delete_participant")
#		table.delete($cgi["olduser"])
#	else
#		table.add_participant($cgi["olduser"],$cgi["add_participant"],{})
#	end
#end

$html = HTML.new("dudle - #{table.name} - Invite Participants")
$html.header["Cache-Control"] = "no-cache"
load "../charset.rb"
$html.add_css("../dudle.css")

$html << "<body>"
$html << Dudle::tabs("Invite Participants")

$html << <<TABLE
	<div id='main'>
	<h1>#{table.name}</h1>
	<h2>Invite or Delete Participants</h2>
	#{table.to_html}
TABLE

$html << "</div></body>"

$html.out($cgi)
end

