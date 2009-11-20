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

require "cgi"

if __FILE__ == $0

$cgi = CGI.new
load "../html.rb"
$html = HTML.new("dudle - Customize")
load "../charset.rb"

$html.header["Cache-Control"] = "no-cache"

$html.add_css("../dudle.css")

$html << "<body>"
$html << Dudle::tabs("Customize")
$html << "<div id='main'>"
$html << "<h1>Customize Personal Settings</h1>"

$html << <<CHARSET
<div id='charset'>
<h2>Charset</h2>
<ul>
<li><a href='?utf' style='text-decoration:none'>If you see all these characters: #{UTFCHARS} you can safely change the charset to UTF-8</a></li>
<li><a href='?ascii' style='text-decoration:none'>Change Charset to plain ASCII</a></li>
</ul>
</div>
CHARSET

$html << <<CHARSET
<div id='config_stylesheet'>
<h2>Stylesheet</h2>
<ul>
CHARSET
[["default","dudle.css"],
 ["PrimeLife","primelife.css"],
 ["TU Dresden","tud.css"]].each{|descr,cssfile|
	$html << "<li><a href='?css=#{cssfile}'>#{descr}</a></li>"
}
$html << <<CHARSET
</ul>
</div>
CHARSET

$html << <<CHARSET
<div id='config_user'>
<h2>Default Username</h2>
<form method='post' action=''>
	<div>
			<label for=''>Username: </label>
			<input  id='' size='16' type='text' value="" name='default_username' />
			<input type='submit' value='Save' />
	</div>
</form>
</div>
CHARSET

$html << "</div>"
$html << "</body>"

$html.out($cgi)
end


