# coding: utf-8
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

$USEUTF = true
$USEUTF = false if $cgi.user_agent =~ /.*MSIE [56]\..*/
$USEUTF = false if $cgi.cookies["ascii"][0]
$USEUTF = true  if $cgi.include?("utf")
$USEUTF = false if $cgi.include?("ascii") 

if $USEUTF
	NOSORT      = CGI.escapeHTML('▾▴')
	SORT        = CGI.escapeHTML('▴')
	REVERSESORT = CGI.escapeHTML('▾')
	GODOWN      = CGI.escapeHTML('⇩')
	GOUP        = CGI.escapeHTML('⇧')

	YES      = CGI.escapeHTML('✔')
	NO       = CGI.escapeHTML('✘')
	MAYBE    = CGI.escapeHTML('?')
	UNKNOWN  = CGI.escapeHTML("–")
	CROSS    = CGI.escapeHTML('✘')

	# Thanks to Antje for the symbols
	MONTHBACK    = CGI.escapeHTML("◀")
	MONTHFORWARD = CGI.escapeHTML("▶")
	EARLIER = CGI.escapeHTML("▴")
	LATER = CGI.escapeHTML("▾")

	EDIT = CGI.escapeHTML("✎")
	DELETE = CGI.escapeHTML("✖")

	PASSWORDSTAR = CGI.escapeHTML("•")
else
	NOSORT      = ''
	SORT        = CGI.escapeHTML('^')
	REVERSESORT = CGI.escapeHTML('reverse')
	GODOWN      = CGI.escapeHTML('down')
	GOUP        = CGI.escapeHTML('up')

	YES      = CGI.escapeHTML('OK')
	NO       = CGI.escapeHTML('NO')
	MAYBE    = CGI.escapeHTML('?')
	UNKNOWN  = CGI.escapeHTML("-")
	CROSS    = CGI.escapeHTML('X')

	MONTHBACK    = CGI.escapeHTML("<")
	MONTHFORWARD = CGI.escapeHTML(">")
	EARLIER = CGI.escapeHTML("")
	LATER = CGI.escapeHTML("")

	EDIT = CGI.escapeHTML("edit")
	DELETE = CGI.escapeHTML("delete")

	PASSWORDSTAR = CGI.escapeHTML("*")
end

UTFCHARS = CGI.escapeHTML("✔✘◀▶✍✖•▾▴")
