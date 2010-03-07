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

require "cgi"
$cgi = CGI.new
require "config"
require "html"

$h = HTML.new("Error")
$h.add_css("/default.css","default",true)
$h << <<END
<div id='main'>
	<div id='content'>
		<h1>Not Found</h1>
		<p>
		The requested Document was not found.
		</p>
		<p>
		There are several reasons, why a Poll is deleted:
		<ul>
			<li>Somebody klicked on “Delete Poll” and deleted the poll manually.</li>
			<li>The Poll was deleted by some cleanup-roundtrip.</li>
		</ul>
		If you think, the deletion was done by error, please contact the adminsistrator of the system.
		<ul>
			<li><a href='#{SITEURL}'>Return to dudle home and Schedule a new Poll.</a></li>
		</ul>
		</p>
	</div>
</div>
END

$h.out($cgi)

