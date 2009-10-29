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
$header = {}

$header["type"] = "text/html"
#$header["type"] = "application/xhtml+xml"
$header["charset"] = "utf-8"

$htmlout = <<HEAD
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
HEAD

olddir = File.expand_path(".")
Dir.chdir("..")
load "charset.rb"
load "config.rb"
require "poll"
require "datepoll"
require "timepoll"
Dir.chdir(olddir)
# BUGFIX for Time.parse, which handles the zone indeterministically
class << Time
	alias_method :old_parse, :parse
	def Time.parse(date, now=self.now)
		Time.old_parse("2009-10-25 00:30")
		Time.old_parse(date)
	end
end

acusers = {}

if $cgi.include?("revision")
	REVISION=$cgi["revision"].to_i
	table = YAML::load(VCS.cat(REVISION, "data.yaml"))
	VCS.cat(REVISION,".htdigest").each_line{|l| 
		v,k = l.scan(/^(.*):(.*):.*$/).flatten
		acusers[k] = v
	}
else
	table = YAML::load_file("data.yaml")
	File.open(".htdigest","r").each_line{|l| 
		v,k = l.scan(/^(.*):(.*):.*$/).flatten
		acusers[k] = v
	}

	if $cgi.include?("add_participant")
		if $cgi.include?("delete_participant")
			table.delete($cgi["olduser"])
		else
			table.add_participant($cgi["olduser"],$cgi["add_participant"],{})
		end
	end
	table.edit_column($cgi["new_columnname"],$cgi["columndescription"],$cgi["old_columnname"]) if $cgi.include?("new_columnname")
	table.delete_column($cgi["delete_column"]) if $cgi.include?("delete_column")

	def writehtaccess(acusers)
		File.open(".htaccess","w"){|htaccess|
			if acusers["admin"]
				htaccess << <<HTACCESS
<Files ~ "^(config|remove).cgi$">
	AuthType digest
	AuthName "admin"
	AuthUserFile "#{File.expand_path(".").gsub('"','\\\\"')}/.htdigest"
	Require valid-user
</Files>
HTACCESS
			end
			if acusers["participant"]
				htaccess << <<HTACCESS
AuthType digest
AuthName "participant"
AuthUserFile "#{File.expand_path(".").gsub('"','\\\\"')}/.htdigest"
Require valid-user
HTACCESS
				VCS.commit("Access Control changed")
			end
		}
	end

	if $cgi.include?("ac_create")
		user = $cgi["ac_name"]
		# only admin and participant is allowed 
		if user == "admin" || user == "participant"
			fork {
				IO.popen("htdigest .htdigest #{user} #{user}","w+"){|htdigest|
					htdigest.sync
					2.times{ 
						htdigest.puts($cgi["ac_password"])
					}
				}
			}
			acusers[user] = user
			writehtaccess(acusers)
		end
	elsif $cgi.include?("ac_delete_admin") || $cgi.include?("ac_delete_participant")
		["admin", "participant"].each{|u| user = u if $cgi.include?("ac_delete_#{u}") }
		htdigest = []
		File.open(".htdigest","r").each_line{|line|
			htdigest << line
		}
		File.open(".htdigest","w"){|f|
			htdigest.each{|line|
				f << line if line.scan(/^#{user}:#{user}:/).empty?
			}
		}
		acusers.delete(user)
		writehtaccess(acusers)
	end
end

$htmlout += <<HTMLHEAD
<head>
	<meta http-equiv="Content-Type" content="#{$header["type"]}; charset=#{$header["charset"]}" /> 
	<meta http-equiv="Content-Style-Type" content="text/css" />
	<title>dudle - config - #{table.name}</title>
	<link rel="stylesheet" type="text/css" href="../dudle.css" title="default"/>
</head>
<body>
	<div id='tabs'>
		<ul>
			<li class='nonactive_tab'><a href='.'>&nbsp;poll&nbsp;</a></li>
			<li id='active_tab'>&nbsp;config&nbsp;</li>
		</ul>
	</div>
HTMLHEAD

$htmlout += <<TABLE
	<div id='main'>
	<h1>#{table.name}</h1>
		<form method='post' action='config.cgi'>
			#{table.to_html($cgi["edituser"],true,$cgi["editcolumn"])}
		</form>
TABLE

# ADD/REMOVE COLUMN
$htmlout +=<<ADD_EDIT
<div id='edit_column'>
#{table.edit_column_htmlform($cgi["editcolumn"])}
</div>
ADD_EDIT

$htmlout +=<<ACL
<div id='access_control'>
	<fieldset>
		<legend>Change Access Control settings</legend>
		If you want to restrict the access to the poll, add the user “participant”.<br />
		If you want to restrict the access to the configuration interface seperately, add the user “admin”.
		<form method='post' action=''>
			<table>
				<tr>
					<th>User</th><th>Password</th>
				</tr>
ACL
acusers.each{|action,user|
		$htmlout += <<USER
<tr>
	<td>#{user}</td>
	<td>*****************</td>
	<td>
		<input type='submit' name='ac_delete_#{user}' value='delete' />
	</td>
</tr>
USER
}

remainder = ["admin","participant"] - acusers.keys
unless remainder.empty?
	$htmlout += <<ACL
<tr>
	<td>
		<select name='ac_name'>
ACL
	remainder.each{|user|	$htmlout += "<option value='#{user}'>#{user}</option>"}
	$htmlout += <<ACL
		</select>
	</td>
	<td>
		<input size='16' value="" type='password' name='ac_password' />
	</td>
	<td>
		<input type='submit' name='ac_create' value='add' />
	</td>
</tr>
ACL
end

$htmlout += <<ACL
			</table>
		</form>
	</fieldset>
</div>
ACL

$htmlout +=<<REMOVE
<div id='delete_poll'>
	<fieldset>
		<legend>Delete the Whole Poll</legend>
		<form method='post' action='remove.cgi'>
			<div>
				Warning: This is an irreversible action!<br />
				<input type='submit' value='delete' />
			</div>
		</form>
	</fieldset>
</div>
REMOVE

$htmlout += "</div></body>"

$htmlout += "</html>"

$header["Cache-Control"] = "no-cache"
$cgi.out($header){$htmlout}
end

