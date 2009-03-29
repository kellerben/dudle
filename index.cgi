#!/usr/bin/env ruby

################################
# Author:  Benjamin Kellermann #
# Licence: CC-by-sa 3.0        #
#          see Licence         #
################################

require "yaml"
require "cgi"


if __FILE__ == $0

$cgi = CGI.new

TYPE = "text/html"
#TYPE = "application/xhtml+xml"
CHARSET = "utf-8"

$htmlout = <<HEAD
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
HEAD

if File.exist?("data.yaml")
	olddir = File.expand_path(".")
	Dir.chdir("..")
	load "charset.rb"
	load "config.rb"
	Dir.chdir(olddir)
	
	load "../participate.rb"
else
	load "charset.rb"
	load "config.rb"
	load "overview.rb"
end

$htmlout += "</html>"

$cgi.out("type" => TYPE ,"charset" => CHARSET,"cookie" => $utfcookie, "Cache-Control" => "no-cache"){$htmlout}
end

