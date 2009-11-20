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

$html << <<END
<body>
#{Dudle::tabs("Customize")}
<div id='main'>
<h1>Customize Personal Settings</h1>
You need cookies enabled in order to personalize your settings.
END

$html << <<CHARSET
<div id='charset'>
<h2>Charset</h2>
<table>
	<tr>
		<th>Current Setting</th>
		<th>Description</th>
	</tr>
CHARSET
[["Use normal strings","ascii"],
 ["Use special characters (#{UTFCHARS})","utf"]].each{|description,href|
 	 selected = href == (USEUTF ? "utf" : "ascii")
 	 $html << "<tr><td>"
 	 $html << CROSS if selected
 	 $html << "</td><td class='charset'>"
 	 $html << "<a href='?#{href}'>" unless selected
 	 $html << description
 	 $html << "</a>" unless selected
 	 $html << "</td></tr>"
 }
$html << <<CHARSET
</table>
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


username = $cgi.cookies["username"][0]
if $cgi.include?("username") 
	username = $cgi["username"]
	$html.add_cookie("username",username,"/",Time.now + 1*60*60*24*365)
end


$html << <<CHARSET
<div id='config_user'>
<h2>Default Username</h2>
<form method='GET' action=''>
	<div>
			<label for=''>Username: </label>
			<input  id='' size='16' type='text' value="#{username}" name='username' />
			<input type='submit' value='Save' />
	</div>
</form>
</div>
CHARSET

$html << "</div>"
$html << "</body>"

$html.out($cgi)
end


