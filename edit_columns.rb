#!/usr/bin/env ruby

############################################################################
# Copyright 2009,2010 Benjamin Kellermann                                  #
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

if __FILE__ == $0
	
load "../dudle.rb"

revbeforeedit = VCS.revno

if $cgi.include?("undo_revision") && $cgi["undo_revision"].to_i < revbeforeedit
	undorevision = $cgi["undo_revision"].to_i
	$d = Dudle.new(:revision => undorevision)
	comment = $cgi.include?("redo") ? "Redo changes" : "Reverted Poll" 
	$d.table.store("#{comment} to version #{undorevision}")
else
	$d = Dudle.new
end

$d.table.edit_column($cgi["columnid"],$cgi["new_columnname"],$cgi) if $cgi.include?("new_columnname")
$d.table.delete_column($cgi["deletecolumn"]) if $cgi.include?("deletecolumn")

$d.wizzard_redirect

revno = VCS.revno

$d << "<h2>" + _("Add and Remove Columns") + "</h2>"
$d << $d.table.edit_column_htmlform($cgi["editcolumn"],revno)

h = VCS.history
urevs = h.undorevisions
rrevs = h.redorevisions

disabled, title, undorevision, hidden = {},{},{},{}
hidden["common"] = ""
["add_remove_column_month","firsttime","lasttime"].each{|v|
	hidden["common"] += "<input type='hidden' name='#{v}' value='#{$cgi[v]}' />" if $cgi.include?(v)
}
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
		title["Undo"] = _("Delete column") + " #{coltitle}"
	when "deleted"
		title["Undo"] = _("Add column") + " #{coltitle}"
	when "edited"
		title["Undo"] = _("Edit column") + " #{coltitle}"
	end

	curundorev = urevs.max.rev() +1 if rrevs.min
end
if rrevs.min
	# enable redo
	disabled["Redo"] = ""
	undorevision["Redo"] = rrevs.min.rev()

	coltitle,action = rrevs.min.comment.scan(/^Column (.*) (added|deleted|edited)$/).flatten
	case action
	when "added"
		title["Redo"] = _("Add column") + " #{coltitle}"
	when "deleted"      
		title["Redo"] = _("Delete column") + " #{coltitle}"
	when "edited"       
		title["Redo"] = _("Edit column") + " #{coltitle}"
	end

	hidden["Redo"] = "<input type='hidden' name='redo'/>"
end

	$d << <<UNDOREDOREADY
<div class='undo'>
	<table>
		<tr>
UNDOREDOREADY
	localstr = {"Undo" => _("Undo"), "Redo" => _("Redo")}
	["Undo","Redo"].each{|button|
		$d << <<TD
			<td>
				<form method='post' action=''>
					<div>
						<input type='submit' title="#{CGI.escapeHTML(title[button].to_s)}" value='#{localstr[button]}' #{disabled[button]} />
						<input type='hidden' name='undo_revision' value='#{undorevision[button]}' />
						#{hidden["common"]}
						#{hidden[button]}
					</div>
				</form>
			</td>
TD
	}
	$d << <<END
		</tr>
	</table>
</div>
END

#$d << (urevs + rrevs).to_html(curundorev,"")

$d.out
end

