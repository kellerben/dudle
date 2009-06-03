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
<small>
	<a href='..' style='text-decoration:none'>#{BACK}</a>
	<a href='config.cgi' style='text-decoration:none'>config</a>
HEAD
	
# HISTORY
MAXREV=VCS.revno
REVISION=MAXREV unless defined?(REVISION)
log = VCS.history
log.collect!{|s| s.scan(/\nrevno:.*\ncommitter.*\n.*\ntimestamp: (.*)\nmessage:\n  (.*)/).flatten}
log.shift
log.collect!{|t,c| [DateTime.parse(t),c]}

$htmlout +=" history:"

((REVISION-2)..(REVISION+2)).each do |i|
	if i >0 && i<=MAXREV
		$htmlout += " "
		$htmlout += "<a href='?revision=#{i}' title='#{log[i-1][0].strftime('%d.%m, %H:%M')}: #{log[i-1][1]}'>" if REVISION != i
		$htmlout += "#{i}"
		$htmlout += "</a>" if REVISION != i
	end
end
$htmlout += "</small>"


# TABLE
$htmlout += "<h1>#{table.name}</h1>"
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


$htmlout += "</body>"

