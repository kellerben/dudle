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

if __FILE__ == $0
load "../dudle.rb"

if $cgi.include?("revision")
	revno=$cgi["revision"].to_i
	versiontitle = "Poll of Version #{revno}"
	$d = Dudle.new("History",revno)
else
	revno = VCS.revno
	versiontitle = "Current Poll (Version #{revno})"
	$d = Dudle.new("History")
end

$d << "<h2>#{versiontitle}</h2>"
$d << $d.table.to_html("",false)

$d << "<h2>History</h2>"
$d << "<div id='history'>"
$d << $d.table.history_selectform($cgi.include?("revision") ? revno : nil, $cgi["history"])

$d << $d.table.history_to_html(revno, $cgi["history"])
$d << "</div>"

$d.out($cgi)
end
