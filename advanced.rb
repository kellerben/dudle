#!/usr/bin/env ruby

############################################################################
# Copyright 2017-2019 Benjamin Kellermann                                  #
#                                                                          #
# This file is part of Dudle.                                              #
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

hintstr = ""
if $cgi.include?("undo_revision") && $cgi["undo_revision"].to_i < VCS.revno
	undorevision = $cgi["undo_revision"].to_i
	$d = Dudle.new(:revision => undorevision)
	comment = $cgi.include?("redo") ? "Redo changes" : "Reverted Poll"
	$d.table.store("#{comment} to version #{undorevision}")
	$d << "<h2>" + _("Revert poll") + "</h2>"
	$d <<  _("Poll was reverted to Version %{version}!") % {:version => undorevision}
else
	$d = Dudle.new
	$d << "<h2>" + _("Revert poll") + "</h2>"
	$d << "<form method='POST'><div>"
	$d <<  _("Revert poll to version (see ‘History’ tab for revision numbers): ")
	$d << "<input type='text' name='undo_revision' />"
	$d << "<input type='submit' value='#{_('Revert')}' />"
	$d << "</div>"
end

$d.out
end
