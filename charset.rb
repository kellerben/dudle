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

if ($cgi.include?("utf") || $cgi.cookies["utf"][0]) && !$cgi.include?("ascii")
	USEUTF = true
	
	NOSORT      = CGI.escapeHTML('▾▴')
	SORT        = CGI.escapeHTML('▴')
	REVERSESORT = CGI.escapeHTML('▾')

	YES      = CGI.escapeHTML('✔')
	NO       = CGI.escapeHTML('✘')
	MAYBE    = CGI.escapeHTML('?')
	UNKNOWN  = CGI.escapeHTML("–")
	CROSS    = CGI.escapeHTML('✘')
	
	YEARBACK     = CGI.escapeHTML("↞")
	MONTHBACK    = CGI.escapeHTML("←")
	MONTHFORWARD = CGI.escapeHTML("→")
	YEARFORWARD  = CGI.escapeHTML("↠")

	EDIT = CGI.escapeHTML("✍")
	DELETE = CGI.escapeHTML("⌧")

	PASSWORDSTAR = CGI.escapeHTML("•")
else
	USEUTF = false
	
	NOSORT      = CGI.escapeHTML('sort')
	SORT        = CGI.escapeHTML('^')
	REVERSESORT = CGI.escapeHTML('reverse')

	YES      = CGI.escapeHTML('OK')
	NO       = CGI.escapeHTML('NO')
	MAYBE    = CGI.escapeHTML('?')
	UNKNOWN  = CGI.escapeHTML("-")
	CROSS    = CGI.escapeHTML('X')

	YEARBACK     = CGI.escapeHTML("<<")
	MONTHBACK    = CGI.escapeHTML("<")
	MONTHFORWARD = CGI.escapeHTML(">")
	YEARFORWARD  = CGI.escapeHTML(">>")

	EDIT = CGI.escapeHTML("edit")
	DELETE = CGI.escapeHTML("delete")

	PASSWORDSTAR = CGI.escapeHTML("*")
end

UTFCHARS = CGI.escapeHTML("✔✘↞←→↠✍⌧•▾▴")
$html.add_cookie("utf","true","/",Time.now + (1*60*60*24*365 * (USEUTF ? 1 : -1 )))
