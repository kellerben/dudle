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

$d = Dudle.new

$d.wizzard_redirect

$d << _('The next steps are:')

sendlink = _('Send the link to all participants:')
mailstr = _('Send this link via email...')
nextstr = _('Visit the poll yourself:')
subjectstr = format(_('Link to DuD-Poll about %<polltitle>s'), polltitle: $d.title)
$d << <<END
<ol>
	<li>
		#{sendlink}
		<ul>
			<li><input id="humanReadableURL" value="#{$conf.siteurl}" type="text" size="80" readonly="readonly" /></li>
			<li><a id="mailtoURL" href='mailto:?subject=#{CGI.escape(subjectstr).gsub('+', '%20')}&amp;body=#{$conf.siteurl}'>#{mailstr}</a></li>
		</ul>
	</li>
	<li>
		#{nextstr}
		<ul>
			<li><a href="#{$conf.siteurl}">#{$conf.siteurl}</a></li>
		</ul>
	</li>
</ol>
END

$d.out
end
