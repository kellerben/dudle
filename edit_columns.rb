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

h = VCS.history
urevs = h.undorevisions
rrevs = h.redorevisions

disabled, title, undorevision, hidden = {},{},{},{}
hidden["common"] = "<input type='hidden' name='add_remove_column_month' value='#{$cgi["add_remove_column_month"]}' />" if $cgi.include?("add_remove_column_month")
["Undo","Redo"].each{|button|
	disabled[button] = "disabled='disabled'"
}
if urevs.max
	# enable undo
	disabled["Undo"] = ""
	undorevision["Undo"] = urevs.max.rev() -1

	coltitle,action = urevs.max.comment.scan(/^Column (.*) (added|deleted|edited)$/).flatten
	case action
	when "added"
		title["Undo"] = "Delete column #{coltitle}"
	when "deleted"
		title["Undo"] = "Add column #{coltitle}"
	when "edited"
		title["Undo"] = "Column #{coltitle} edit"
	end
	curundorev = urevs.max.rev if rrevs.min
end
if rrevs.min
	# enable redo
	disabled["Redo"] = ""
	undorevision["Redo"] = rrevs.min.rev()
	hidden["Redo"] = "<input type='hidden' name='redo'/>"
end

	$html << <<UNDOREDOREADY
<div class='undo'>
	<table summary='Undo/Redo functionallity'>
		<tr>
UNDOREDOREADY
	["Undo","Redo"].each{|button|
		$html << <<TD
			<td>
				<form method='post' action=''>
					<div>
						<input type='submit' title='#{title[button]}' value='#{button}' #{disabled[button]} />
						<input type='hidden' name='undo_revision' value='#{undorevision[button]}' />
						#{hidden["common"]}
						#{hidden[button]}
					</div>
				</form>
			</td>
TD
	}
	$html << <<READY
			<td>
				<form method='get' action='.'>
					<div>
						<input type='submit' value='Ready' />
					</div>
				</form>
			</td>
		</tr>
	</table>
</div>
READY

$html << (urevs + rrevs).to_html(curundorev,"")

$html << "</div></body>"

$html.out($cgi)
end

