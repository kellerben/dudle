################################
# Author:  Benjamin Kellermann #
# Licence: CC-by-sa 3.0        #
#          see Licence         #
################################

olddir = File.expand_path(".")
Dir.chdir("..")
require "poll"
require "datepoll"
Dir.chdir(olddir)

if $cgi.include?("revision")
	REVISION=$cgi["revision"].to_i
	table = YAML::load(VCS.cat(REVISION, "data.yaml"))
else
	table = YAML::load_file("data.yaml")
end

$htmlout += <<HEAD
<head>
	<meta http-equiv="Content-Type" content="#{TYPE}; charset=#{CHARSET}" /> 
	<meta http-equiv="Content-Style-Type" content="text/css" />
	<title>dudle - #{table.name}</title>
	<link rel="stylesheet" type="text/css" href="../dudle.css" title="default"/>
	<link rel="stylesheet" type="text/css" href="../print.css" title="print" media="print" />
	<link rel="stylesheet" type="text/css" href="../print.css" title="print" />
	<link rel="alternate"  type="application/atom+xml" href="atom.cgi" />
</head>
<body>
	<div id='backlink'>
	<a href='..' style='text-decoration:none'>#{BACK}</a>
	</div>
	<h1>#{table.name}</h1>
HEAD

if $cgi.include?("add_participant")
	agreed = {}
	$cgi.params.each{|k,v|
		if k =~ /^add_participant_checked_/
			agreed[k.gsub(/^add_participant_checked_/,"")] = v[0]
		end
	}

	table.add_participant($cgi["add_participant"],agreed)
end

table.add_comment($cgi["commentname"],$cgi["comment"]) if $cgi.include?("comment")
table.delete_comment($cgi["delete_comment"].to_i) if $cgi.include?("delete_comment")

# POLL
$htmlout += <<POLLTABLE
<div id='polltable'>
<form method='post' action='.'>
#{table.to_html}
</form>
</div>
POLLTABLE

$htmlout += table.comment_to_html


# ADD COMMENT
$htmlout += <<ADDCOMMENT
<div id='add_comment'>
	<fieldset>
		<legend>Comment</legend>
		<form method='post' action='.'>
			<div>
				<label for='Commentname'>Name: </label>
				<input id='Commentname' value='anonymous' type='text' name='commentname' />
				<br />
				<textarea cols='50' rows='7' name='comment' ></textarea>
				<br />
				<input type='submit' value='Submit' />
			</div>
		</form>
	</fieldset>
</div>
ADDCOMMENT

# HISTORY
MAXREV=VCS.revno
REVISION=MAXREV unless defined?(REVISION)
log = VCS.history
log.collect!{|s| s.scan(/\nrevno:.*\ncommitter.*\n.*\ntimestamp: (.*)\nmessage:\n  (.*)/).flatten}
log.shift
log.collect!{|t,c| [DateTime.parse(t),c]}
$htmlout += <<HISTORY
<div id='history'>
	<fieldset><legend>browse history</legend>
	<table>
		<tr>
			<th>rev</th>
			<th>time</th>
			<th>description of change</th>
		</tr>
HISTORY

((REVISION-2)..(REVISION+2)).each do |i|
	if i >0 && i<=MAXREV
		if REVISION == i
			$htmlout += "<tr id='displayed_revision'><td>#{i}"
		else
			$htmlout += "<tr><td>"
			$htmlout += "<a href='?revision=#{i}'>#{i}</a>"
		end
		$htmlout += "</td>"
		$htmlout += "<td>#{log[i-1][0].strftime('%d.%m, %H:%M')}</td>"
		$htmlout += "<td>#{log[i-1][1]}</td>"
		$htmlout += "</tr>"
	end
end
$htmlout += "</table>"
$htmlout += "</fieldset>"
$htmlout += "</div>"


$htmlout +=<<CONFIG
<div id='configlink'>
	<fieldset>
		<legend>Configure the Poll</legend>
		<a href='config.cgi' style='text-decoration:none'>config</a>
	</fieldset>
</div>
CONFIG

$htmlout += "</body>"

