################################
# Author:  Benjamin Kellermann #
# License: CC-by-sa 3.0        #
#          see License         #
################################

$utfcookie = CGI::Cookie.new("utf", "true")
$utfcookie.path = "/"
if ($cgi.include?("utf") || $cgi.cookies["utf"][0]) && !$cgi.include?("ascii")
	$utfcookie.expires = Time.now+1*60*60*24*365
	UTFASCII = "<a href='?ascii' style='text-decoration:none'>ASCII</a>"
	BACK     = CGI.escapeHTML("↩")
	
	YES      = CGI.escapeHTML('✔')
	NO       = CGI.escapeHTML('✘')
	MAYBE    = CGI.escapeHTML('?')
	UNKNOWN  = CGI.escapeHTML("–")
	
	YEARBACK     = CGI.escapeHTML("↞")
	MONTHBACK    = CGI.escapeHTML("←")
	MONTHFORWARD = CGI.escapeHTML("→")
	YEARFORWARD  = CGI.escapeHTML("↠")

	EDIT = CGI.escapeHTML("✍")
	DELETE = CGI.escapeHTML("⌧")
else
	$utfcookie.expires = Time.now-1*60*60*24*36
	UTFASCII = "<a href='?utf' style='text-decoration:none'>UTF-8 (#{CGI.escapeHTML('↩✔✘?–↞←→↠✍⌧')})</a>"
	BACK     = CGI.escapeHTML("back")
	
	YES      = CGI.escapeHTML('OK')
	NO       = CGI.escapeHTML('NO')
	MAYBE    = CGI.escapeHTML('?')
	UNKNOWN  = CGI.escapeHTML("-")

	YEARBACK     = CGI.escapeHTML("<<")
	MONTHBACK    = CGI.escapeHTML("<")
	MONTHFORWARD = CGI.escapeHTML(">")
	YEARFORWARD  = CGI.escapeHTML(">>")

	EDIT = CGI.escapeHTML("edit")
	DELETE = CGI.escapeHTML("delete")
end

