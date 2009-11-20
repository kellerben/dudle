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

acusers = {}

if $cgi.include?("revision")
	REVISION=$cgi["revision"].to_i
	table = YAML::load(VCS.cat(REVISION, "data.yaml"))
else
	table = YAML::load_file("data.yaml")

	if $cgi.include?("add_participant")
		if $cgi.include?("delete_participant")
			table.delete($cgi["olduser"])
		else
			table.add_participant($cgi["olduser"],$cgi["add_participant"],{})
		end
	end
	table.edit_column($cgi["columnid"],$cgi["new_columnname"],$cgi) if $cgi.include?("new_columnname")
	table.delete_column($cgi["deletecolumn"]) if $cgi.include?("deletecolumn")

end

$html = HTML.new("dudle - Edit Columns - #{table.name}")
$html.header["Cache-Control"] = "no-cache"
load "../charset.rb"
$html.add_css("../dudle.css")

$html << "<body>"
$html << Dudle::tabs("Edit Columns")

$html << <<TABLE
	<div id='main'>
	<h1>Add and Remove Columns</h1>
TABLE

# ADD/REMOVE COLUMN
$html << <<ADD_EDIT
	<div id='edit_column'>
	#{table.edit_column_htmlform($cgi["editcolumn"])}
	</div>
ADD_EDIT

$html << "</body>"

$html.out($cgi)
end

