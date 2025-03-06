#!/usr/bin/env ruby

############################################################################
# Copyright 2009-2019 Benjamin Kellermann                                  #
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
load '../dudle.rb'

if $cgi.include?('revision')
	revno = $cgi['revision'].to_i
	$d = Dudle.new(revision: revno)
	versiontitle = format(_('Poll of version %<revisionnumber>s'), revisionnumber: revno)
else
	revno = VCS.revno
	$d = Dudle.new
	versiontitle = format(_('Current poll (version %<revisionnumber>s)'), revisionnumber: revno)
end

historystr = _('History')
$d << <<HTML
<h2>#{versiontitle}</h2>
#{$d.table.to_html(false)}

#{$d.table.comment_to_html(false)}
<h2>#{historystr}</h2>
<div id='history'>
#{$d.table.history_selectform($cgi.include?('revision') ? revno : nil, $cgi['history'])}

#{$d.table.history_to_html(revno, $cgi['history'])}
</div>
HTML

$d.out
end
