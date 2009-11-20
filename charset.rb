################################
# Author:  Benjamin Kellermann #
# License: CC-by-sa 3.0        #
#          see License         #
################################

if ($cgi.include?("utf") || $cgi.cookies["utf"][0]) && !$cgi.include?("ascii")
	expiretime = Time.now+1*60*60*24*365
	
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
	expiretime = Time.now-1*60*60*24*36
	
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

UTFCHARS = [YES,NO,MAYBE,UNKNOWN,YEARBACK,MONTHBACK,MONTHFORWARD,YEARFORWARD,EDIT,DELETE]

$html.add_cookie("utf","true","/",expiretime)
