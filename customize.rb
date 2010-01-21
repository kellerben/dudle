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


if __FILE__ == $0

$:.push("..")
require "dudle"

$d = Dudle.new


$d << "<h2>" + _("Customize Personal Settings") + "</h2>"
$d << _("You need cookies enabled in order to personalize your settings.")

def choosetable(options, cursetting)
	ret = <<HEAD 
<table>
	<tr>
HEAD
	ret += "<th>" + _("Current Setting") + "</th>"
	ret += "<th>" + _("Description") + "</th>"
	ret += "</tr>"
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


a = [[_("Use special characters") + " (#{UTFCHARS})","utf", _("Use this option if you see the characters in the parenthesis.")],
     [_("Use only normal strings"),"ascii",_("Use this option if you have problems with some characters.")]]
$d.html.add_cookie("ascii","true","/",Time.now + (1*60*60*24*365 * ($USEUTF ? -1 : 1 )))
$d << "<div id='charset'>"
$d << "<h3>" + _("Charset")+ "</h3>"
$d << choosetable(a,$USEUTF ? "utf" : "ascii")
$d << "</div>"

css = $cgi.cookies["css"][0]
css = $cgi["css"] if $cgi.include?("css")
css ||= "default.css"
$d.html.add_cookie("css",css,"/",Time.now + (1*60*60*24*365 * (css == "dudle.css" ? -1 : 1 )))
$d << "<div id='config_stylesheet'>"
$d << "<h3>" + _("Stylesheet") + "</h3>"
$d << choosetable($d.css.collect{|href| [href.scan(/([^\/]*)\.css/).flatten[0],"css=#{href}"]},"css=#{css}")
$d << "</div>"


username = $cgi.cookies["username"][0]
if $cgi.include?("delete_username")
	$d.html.add_cookie("username","","/",Time.now - 1*60*60*24*365)
	username = nil
elsif $cgi.include?("username") 
	username = $cgi["username"]
	$d.html.add_cookie("username",username,"/",Time.now + 1*60*60*24*365)
end



defaultuserstr = _("Default Username")
usernamestr = _("Username:")
$d << <<CHARSET
<div id='config_user'>
<h3>#{defaultuserstr}</h3>
<form method='get' action=''>
	<table>
		<tr id='usernamesetting'>
			<td>
				<label for='username'>#{usernamestr} </label>
			</td>
			<td class='settingstable'>
CHARSET

if username && !$cgi.include?("edit")
	$d << <<CHARSET
				<span>#{username}</span>
				<input type='hidden' value="#{username}" name='username' />
				<input type='hidden' value="true" name='edit' />
			</td>
		</tr>
		<tr>
			<td></td>
			<td class='settingstable'>
CHARSET
	$d << "<input id='username' type='submit' value='" + _("Edit") + "' />"
else
	$d << <<CHARSET
				<input id='username' type='text' value="#{username}" name='username' />
			</td>
		</tr>
		<tr>
			<td></td>
			<td class='settingstable'>
CHARSET
	$d << "<input type='submit' value='" + _("Save") + "' />"
end

$d.html << "<input type='submit' name='delete_username' value='" + _("Delete") + "' />" if username

$d << <<CHARSET
			</td>
		</tr>
	</table>
</form>
</div>
CHARSET

$d.out
end


