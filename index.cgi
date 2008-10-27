#!/usr/bin/env ruby
load "/home/ben/src/lib.rb/pphtml.rb"
require "pp"
require "yaml"
require "cgi"

if __FILE__ == $0

$cgi = CGI.new

CONTENTTYPE = "text/html; charset=utf-8"
#CONTENTTYPE = "application/xhtml+xml; charset=utf-8"

puts "Content-type: #{CONTENTTYPE}"

if ($cgi.include?("utf") || $cgi.cookies["utf"][0]) && !$cgi.include?("ascii")
	puts "Set-Cookie: utf=true; path=/; expires=#{(Time.now+1*60*60*24*365).getgm.strftime("%a, %d %b %Y %H:%M:%S %Z")}"
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
	puts "Set-Cookie: utf=true; path=/; expires=#{(Time.now-1*60*60*24*365).getgm.strftime("%a, %d %b %Y %H:%M:%S %Z")}"
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

puts <<HEAD

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
HEAD

if File.exist?("data.yaml") 
	load "../participate.rb"
else
	load "overview.rb"
end
end
