#!/usr/bin/env ruby

################################
# Author:  Benjamin Kellermann #
# License: CC-by-sa 3.0        #
#          see License         #
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

load "charset.rb"
if File.exists?("config.rb")
	load "config.rb"
else
	puts "\nPlease configure me in the file config.rb"
	exit
end

require "poll"
require "datepoll"
require "timepoll"

$htmlout += <<HEAD
<head>
	<title>dudle</title>
	<meta http-equiv="Content-Type" content="#{TYPE}; charset=#{CHARSET}" /> 
	<meta http-equiv="Content-Style-Type" content="text/css" />
	<link rel="stylesheet" type="text/css" href="dudle.css" title="default"/>
HEAD
	
	$htmlout += '<link rel="alternate"  type="application/atom+xml" href="atom.cgi" />' if File.exists?("atom.cgi")

	$htmlout += "</head><body id='main'><h1>dudle</h1>"

if $cgi.include?("create_poll")
	SITE=$cgi["create_poll"].gsub(/^\//,"")
	unless File.exist?(SITE)
		Dir.mkdir(SITE)
		Dir.chdir(SITE)
		VCS.init
		File.symlink("../participate.rb","index.cgi")
		File.symlink("../atom_single.rb","atom.cgi")
		File.symlink("../config_poll.rb","config.cgi")
		File.symlink("../remove_poll.rb","remove.cgi")
		["index.cgi","atom.cgi","config.cgi","remove.cgi"].each{|f|
			VCS.add(f)
		}
		["data.yaml",".htaccess",".htdigest"].each{|f|
			File.open(f,"w").close
			VCS.add(f)
		}
		case $cgi["poll_type"]
		when "normal"
			Poll.new SITE
		when "time"
			TimePoll.new SITE
		end
		Dir.chdir("..")
		$cgi.out("status" => "REDIRECT",
		         "Location" => "#{SITEURL}#{SITE}/",
		         "type" => TYPE,
		         "charset" => CHARSET,
		         "cookie" => $utfcookie,
		         "Cache-Control" => "no-cache"){ 
			"The poll was created successfully. The link to your new poll is:<br /><a href='#{SITEURL}#{SITE}'>#{SITEURL}#{SITE}</a>"
		}
		exit
	else
		createnotice = "<div class='error'>Error: This poll already exists!</div>"
	end
end

$htmlout += <<CHARSET
<div id='config'>
<fieldset><legend>Config</legend>
#{UTFASCII}
</fieldset>
</div>
CHARSET

$htmlout += <<CREATE
<fieldset><legend>Create New Poll</legend>
<form method='post' action='.'>
<table>
<tr>
	<td class='create_poll'><label title="#{poll_name_tip = "the name equals the link under which you receive the poll"}" for="poll_name">Name:</label></td>
	<td class='create_poll'><input title="#{poll_name_tip}" id="poll_name" size='16' type='text' name='create_poll' /></td>
</tr>
<tr>
	<td>Type:</td>
	<td class='create_poll'>
		<input id='chooseTime' type='radio' value='time' name='poll_type' checked='checked' />
		<label for='chooseTime'>Event Schedule Poll (e.g. schedule a meeting)</label>
		<br />
		<input id='chooseNormal' type='radio' value='normal' name='poll_type' />
		<label for='chooseNormal'>Normal Poll (e.g. vote for what is the best coffee)</label>
	</td>
</tr>
<tr>
	<td></td>
	<td class='create_poll'><input type='submit' value='create' /></td>
</tr>
</table>
</form>
#{createnotice}
</fieldset>
CREATE

$htmlout += NOTICE
$htmlout += "</body>"

$htmlout += "</html>"

$cgi.out("type" => TYPE ,"charset" => CHARSET,"cookie" => $utfcookie, "Cache-Control" => "no-cache"){$htmlout}
end

