#!/usr/bin/env ruby

################################
# Author:  Benjamin Kellermann #
# Licence: CC-by-sa 3.0        #
#          see Licence         #
################################

require "yaml"
require "cgi"

load "config.rb"

if __FILE__ == $0

$cgi = CGI.new

utfcookie = CGI::Cookie.new("utf", "true")
utfcookie.path = "/"
if ($cgi.include?("utf") || $cgi.cookies["utf"][0]) && !$cgi.include?("ascii")
	utfcookie.expires = Time.now+1*60*60*24*365
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
else
	utfcookie.expires = Time.now-1*60*60*24*36
	UTFASCII = "<a href='?utf' style='text-decoration:none'>#{CGI.escapeHTML('↩✔✘?–↞←→↠')}</a>"
	BACK     = CGI.escapeHTML("<-")
	
	YES      = CGI.escapeHTML('OK')
	NO       = CGI.escapeHTML('NO')
	MAYBE    = CGI.escapeHTML('?')
	UNKNOWN  = CGI.escapeHTML("-")

	YEARBACK     = CGI.escapeHTML("<<")
	MONTHBACK    = CGI.escapeHTML("<")
	MONTHFORWARD = CGI.escapeHTML(">")
	YEARFORWARD  = CGI.escapeHTML(">>")
end

$htmlout = <<HEAD
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
HEAD

if File.exist?("data.yaml") 
	load "../participate.rb"
else
	load "overview.rb"
end

TYPE = "text/html"
#TYPE = "application/xhtml+xml"
CHARSET = "utf-8"
$cgi.out("type" => TYPE ,"charset" => CHARSET,"cookie" => utfcookie, "Cache-Control" => "no-cache"){$htmlout}
end

