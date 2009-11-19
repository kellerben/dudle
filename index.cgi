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

if File.exists?("config.rb")
	load "config.rb"
else
	puts "\nPlease configure me in the file config.rb"
	exit
end

require "poll"
require "html"
$html = HTML.new("dudle")
load "charset.rb"
$html.add_css("dudle.css")
$htlm.add_atom("atom.cgi") if File.exists?("atom.cgi")

	$html << "<body id='main'><h1>dudle</h1>"

if $cgi.include?("create_poll")
	SITE=$cgi["create_poll"]
	if SITE.include?("/") 
		createnotice = "<div class='error'>Error: The character '/' is not allowed.</div>"
	elsif File.exist?(SITE)
		createnotice = "<div class='error'>Error: This poll already exists!</div>"
	else Dir.mkdir(SITE)
		Dir.chdir(SITE)
		VCS.init
		File.symlink("../participate.rb","index.cgi")
		File.symlink("../atom.rb","atom.cgi")
		File.symlink("../config_poll.rb","config.cgi")
		File.symlink("../remove_poll.rb","remove.cgi")
		["index.cgi","atom.cgi","config.cgi","remove.cgi"].each{|f|
			VCS.add(f)
		}
		["data.yaml",".htaccess",".htdigest"].each{|f|
			File.open(f,"w").close
			VCS.add(f)
		}
		Poll.new(SITE,$cgi["poll_type"])
		Dir.chdir("..")
		escapedsite = SITEURL + CGI.escapeHTML(CGI.escape(SITE)) + "/"
		escapedsite.gsub!("+"," ")
		$html.header["status"] = "REDIRECT"
		$html.header["Location"] = escapedsite
		$html << "The poll was created successfully. The link to your new poll is:<br /><a href=\"#{escapedsite}\">#{escapedsite}</a>"
	end
end

unless $html.header["status"] == "REDIRECT"
	$html << <<CHARSET
<div id='config'>
<fieldset><legend>Config</legend>
#{UTFASCII}
</fieldset>
</div>
CHARSET

	$html << <<CREATE
<fieldset><legend>Create New Poll</legend>
<form method='post' action='.'>
<table>
<tr>
	<td class='create_poll'><label title="#{poll_name_tip = "the name equals the link under which you receive the poll"}" for="poll_name">Name:</label></td>
	<td class='create_poll'><input title="#{poll_name_tip}" id="poll_name" size='16' type='text' name='create_poll' value="#{CGI.escapeHTML($cgi["create_poll"])}" /></td>
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
</fieldset>
CREATE

	$html << NOTICE
end

$html.out($cgi)
end

