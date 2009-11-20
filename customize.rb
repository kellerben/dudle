#!/usr/bin/env ruby

################################
# Author:  Benjamin Kellermann #
# License: CC-by-sa 3.0        #
#          see License         #
################################

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


