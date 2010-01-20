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

$d = Dudle.new

$d.wizzard_redirect


$d << _("The link to your poll is:")

mailstr = _("Send this link via email...")
nextstr = _("To the Vote interface")
subjectstr = _("Link to dudle poll about") + " " + $d.title

$d << <<END
<pre>#{SITEURL}</pre>
<a href='mailto:?subject=#{CGI.escapeHTML(CGI.escape(subjectstr).gsub("+","%20"))}&amp;body=#{SITEURL}'>#{mailstr}</a>
<form method='get' action='.'>
	<div style='margin-top:1ex'>
		<input type='submit' value='#{nextstr}' />
	</div>
</form>
END

$d.out
end


