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

def choosetable(tablesummary, options, cursetting)
	ret = <<HEAD 
<table summary='#{tablesummary}'>
	<tr>
		<th>Current Setting</th>
		<th>Description</th>
	</tr>
HEAD
	options.each{|description,href,title|
		selected = href == cursetting
		ret += "<tr><td>"
		ret += CROSS if selected
		ret += "</td><td class='settingstable' title='#{title}'>"
		ret += "<a href='?#{href}'>" unless selected
		ret += description
		ret += "</a>" unless selected
		ret += "</td></tr>"
	}
	ret += "</table>"
	ret
end


a = [["Use normal strings","ascii"], 
     ["Use special characters (#{UTFCHARS})","utf", "Use this options if you see the characters in the parenthesis."]]
$html << <<CHARSET
<div id='charset'>
<h2>Charset</h2>
#{choosetable("Charset settings",a,USEUTF ? "utf" : "ascii")}
</div>
CHARSET


a = [["default","css=dudle.css"],
     ["Print","css=print.css"],
     ["PrimeLife","css=primelife.css"],
     ["TU Dresden","css=tud.css"]]
css = $cgi.cookies["css"][0]
css = $cgi["css"] if $cgi.include?("css")
css ||= "dudle.css"
$html.add_cookie("css",css,"/",Time.now + (1*60*60*24*365 * (css == "dudle.css" ? -1 : 1 )))
$html << <<CSS
<div id='config_stylesheet'>
<h2>Stylesheet</h2>
#{choosetable("Stylesheet settings",a,"css=#{css}")}
</div>
CSS


username = $cgi.cookies["username"][0]
if $cgi.include?("delete_username")
	$html.add_cookie("username","","/",Time.now - 1*60*60*24*365)
	username = nil
elsif $cgi.include?("username") 
	username = $cgi["username"]
	$html.add_cookie("username",username,"/",Time.now + 1*60*60*24*365)
end


$html << <<CHARSET
<div id='config_user'>
<h2>Default Username</h2>
<form method='get' action=''>
	<table summary="Set default username">
		<tr>
			<td>
				<label for='username'>Username: </label>
			</td>
			<td class='settingstable'>
CHARSET

if username && !$cgi.include?("edit")
	$html << <<CHARSET
				<span>#{username}</span>
				<input type='hidden' value="#{username}" name='username' />
				<input type='hidden' value="true" name='edit' />
			</td>
		</tr>
		<tr>
			<td></td>
			<td class='settingstable'>
				<input id='username' type='submit' value='Edit' />
CHARSET
else
	$html << <<CHARSET
				<input id='username' type='text' value="#{username}" name='username' />
			</td>
		</tr>
		<tr>
			<td></td>
			<td class='settingstable'>
				<input type='submit' value='Save' />
CHARSET
end

$html << "<input type='submit' name='delete_username' value='Delete' />" if username

$html << <<CHARSET
			</td>
		</tr>
	</table>
</form>
</div>
CHARSET

$html << "</div>"
$html << "</body>"

$html.out($cgi)
end


