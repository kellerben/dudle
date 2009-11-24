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

acusers = {}

revbeforeedit = VCS.revno

if $cgi.include?("undo_revision") && $cgi["undo_revision"].to_i < revbeforeedit
	undorevision = $cgi["undo_revision"].to_i
	table = YAML::load(VCS.cat(undorevision, "data.yaml"))
	comment = "Reverted Poll" 
	comment = "Redo changes" if $cgi.include?("redo")
	table.store("#{comment} to version #{undorevision}")
else
	table = YAML::load_file("data.yaml")
end

# TODO: move to own tab
#if $cgi.include?("add_participant")
#	if $cgi.include?("delete_participant")
#		table.delete($cgi["olduser"])
#	else
#		table.add_participant($cgi["olduser"],$cgi["add_participant"],{})
#	end
#end
table.edit_column($cgi["columnid"],$cgi["new_columnname"],$cgi) if $cgi.include?("new_columnname")
table.delete_column($cgi["deletecolumn"]) if $cgi.include?("deletecolumn")

revno = VCS.revno

$html = HTML.new("dudle - #{table.name} - Edit Columns")
$html.header["Cache-Control"] = "no-cache"
load "../charset.rb"
$html.add_css("../dudle.css")

$html << "<body>"
$html << Dudle::tabs("Edit Columns")

$html << <<TABLE
	<div id='main'>
	<h1>#{table.name}</h1>
	<h2>Add and Remove Columns</h2>
TABLE

# ADD/REMOVE COLUMN
$html << table.edit_column_htmlform($cgi["editcolumn"],revno)

$html << "<div class='undo'>"
h = VCS.history
urevs = h.undorevisions
rrevs = h.redorevisions

hidden = "<input type='hidden' name='add_remove_column_month' value='#{$cgi["add_remove_column_month"]}' />" if $cgi.include?("add_remove_column_month")
if urevs.max
	urhist = urevs
	coltitle,action = urevs.max.comment.scan(/^Column (.*) (added|deleted|edited)$/).flatten
	case action
	when "added"
		title = "Delete column #{coltitle}"
	when "deleted"
		title = "Add column #{coltitle}"
	when "edited"
		title = "Column #{coltitle} edit"
	end
	$html << "<table summary='Undo/Redo functionallity'><tr>"
	unless urevs.size == 1
		$html << <<UNDO
		<td>
<form method='post' action=''>
	<div>
		<input type='submit' title='#{title}' value='Undo' />
		<input type='hidden' name='undo_revision' value='#{urevs.max.rev() -1}' />
		#{hidden}
	</div>
</form>
</td>
UNDO
	end
		$html << <<REDO
<td>
<form method='post' action=''>
	<div>
		<input type='submit' title='#{title}' value='Redo' #{rrevs.min ? "" : "disabled='disabled'"}/>
REDO
	if rrevs.min
		$html << <<REDO
		<input type='hidden' name='redo'/>
		<input type='hidden' name='undo_revision' value='#{rrevs.min.rev()}' />
		#{hidden}
REDO
	end
		$html << <<REDO
	</div>
</form>
</td>
REDO
	urhist += rrevs
	
	$html << <<READY
<td>
<form method='get' action='.'>
	<div>
		<input type='submit' value='Ready' />
	</div>
</form>
</td>
READY

	$html << "</tr></table>"
	$html << (urhist).to_html(urevs.max.rev,"")
end

$html << "</div>" #undo


$html << "</div></body>"

$html.out($cgi)
end

