################################
# Author:  Benjamin Kellermann #
# Licence: CC-by-sa 3.0        #
#          see Licence         #
################################

require "poll"
require "datepoll"
require "datetimepoll"

$htmlout += <<HEAD
<head>
	<title>dudle</title>
	<meta http-equiv="Content-Type" content="#{TYPE}; charset=#{CHARSET}" /> 
	<meta http-equiv="Content-Style-Type" content="text/css" />
	<link rel="alternate"  type="application/atom+xml" href="atom.cgi" />
</head>
<body>
HEAD

if $cgi.include?("create_poll")
	SITE=$cgi["create_poll"]
	unless File.exist?(SITE)
		Dir.mkdir(SITE)
		Dir.chdir(SITE)
		VCS.init
		File.symlink("../index.cgi","index.cgi")
		File.symlink("../atom.cgi","atom.cgi")
		File.symlink("../config.cgi","config.cgi")
		File.open("data.yaml","w").close
		VCS.add("data.yaml")
		case $cgi["poll_type"]
		when "Poll"
			Poll.new SITE
		when "DatePoll"
			DatePoll.new SITE
		end
		Dir.chdir("..")
	else
		$htmlout += "<fieldset><legend>Error</legend>This poll already exists!</fieldset>"
	end
end

$htmlout += "<fieldset><legend>Available Polls</legend>"
$htmlout += "<table><tr><th>Poll</th><th>Last change</th></tr>"
Dir.glob("*/data.yaml").sort_by{|f|
	File.new(f).mtime
}.reverse.collect{|f| 
	f.gsub(/\/data\.yaml$/,'')
}.each{|site|
	unless YAML::load_file("#{site}/data.yaml").hidden
		$htmlout += "<tr>"
		$htmlout += "<td class='site'><a href='#{site}'>#{site}</a></td>"
		$htmlout += "<td class='mtime'>#{File.new(site + "/data.yaml").mtime.strftime('%d.%m, %H:%M')}</td>"
		$htmlout += "</tr>"
	end
}
$htmlout += "</table>"
$htmlout += "</fieldset>"

$htmlout += <<CHARSET
<fieldset><legend>change charset</legend>
#{UTFASCII}
</fieldset>
CHARSET

$htmlout += <<CREATE
<fieldset><legend>Create new Poll</legend>
<form method='post' action='.'>
<table>
<tr>
	<td><label title="#{poll_name_tip = "the name equals the link under which you receive the poll"}" for="poll_name">Name:</label></td>
	<td><input title="#{poll_name_tip}" id="poll_name" size='16' type='text' name='create_poll' value='#{$cgi["create_poll"]}' /></td>
</tr>
<tr>
	<td><label for="poll_type">Type:</label></td>
	<td>
		<select id="poll_type" name="poll_type">
			<option value="Poll" selected="selected">normal</option>
			<option value="DatePoll">date</option>
		</select>
	</td>
</tr>
<tr>
	<td colspan='2'><input type='submit' value='create' /></td>
</tr>
</table>
</form>
</fieldset>
CREATE

$htmlout += NOTICE
$htmlout += "</body>"


