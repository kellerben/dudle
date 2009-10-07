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

	table.invite_delete($cgi["invite_delete"])	if $cgi.include?("invite_delete") and $cgi["invite_delete"] != ""
	table.edit_column($cgi["edit_column"],$cgi["columndescription"],$cgi["editcolumn"]) if $cgi.include?("edit_column")
	table.toggle_hidden if $cgi.include?("toggle_hidden")

	def writehtaccess(acusers)
		File.open(".htaccess","w"){|htaccess|
			if acusers["admin"]
				htaccess << <<HTACCESS
<Files ~ "^(config|remove).cgi$">
	AuthType digest
	AuthName "admin"
	AuthUserFile #{File.expand_path(".")}/.htdigest
	Require valid-user
</Files>
HTACCESS
			end
			if acusers["participant"]
				htaccess << <<HTACCESS
AuthType digest
AuthName "participant"
AuthUserFile #{File.expand_path(".")}/.htdigest
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
	<meta http-equiv="Content-Type" content="#{TYPE}; charset=#{CHARSET}" /> 
	<meta http-equiv="Content-Style-Type" content="text/css" />
	<title>dudle - config - #{table.name}</title>
	<link rel="stylesheet" type="text/css" href="../dudle.css" title="default"/>
</head>
<body>
	<div>
		<small>
			<a href='.' style='text-decoration:none'>#{BACK}</a>
			history:#{table.history_to_html}
		</small>
	</div>
HTMLHEAD

activecolumn = $cgi.include?("edit_column") ? $cgi["edit_column"] : $cgi["editcolumn"]
$htmlout += <<TABLE
	<h1>#{table.name}</h1>
#{table.to_html(config = true,activecolumn = activecolumn)}
TABLE

$htmlout += <<INVITEDELETE
<div id='invite_delete'>
	<fieldset>
		<legend>invite/delete participant</legend>
		<form method='post' action='config.cgi'>
			<div>
				<input size='16' value="#{CGI.escapeHTML($cgi["invite_delete"])}" type='text' name='invite_delete' />
				<input type='submit' value='invite/delete' />
			</div>
		</form>
	</fieldset>
</div>
INVITEDELETE

# ADD/REMOVE COLUMN
$htmlout +=<<ADD_EDIT
<div id='edit_column'>
#{table.edit_column_htmlform(activecolumn)}
</div>
ADD_EDIT

$htmlout +=<<ACL
<div id='access_control'>
	<fieldset>
		<legend>Change Access Control settings</legend>
		If you want to restrict the poll, add the participant user.
		If you want to restrict the configuration interface seperately, please add an admin user!
		<form method='post' action=''>
			<table>
				<tr>
					<th>Name</th><th>Password</th>
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
$htmlout += <<ACL
				<tr>
					<td>
						<select name='ac_name'>
							<option value='participant'>participant</option>
							<option value='admin'>admin</option>
						</select>
					</td>
					<td>
						<input size='16' value="" type='password' name='ac_password' />
					</td>
					<td>
						<input type='submit' name='ac_create' value='add' />
					</td>
				</tr>
			</table>
		</form>
	</fieldset>
</div>
ACL

$htmlout +=<<HIDDEN
<div id='toggle_hidden'>
	<fieldset>
		<legend>Toggle Hidden flag</legend>
		<form method='post' action=''>
			<div>
				<input type='hidden' name='toggle_hidden' value='toggle' />
				<input type='submit' value='#{table.hidden ? "unhide" : "hide"}' />
			</div>
		</form>
	</fieldset>
</div>
HIDDEN

$htmlout +=<<REMOVE
<div id='remove_poll'>
	<fieldset>
		<legend>Remove the whole poll</legend>
		<form method='post' action='remove.cgi'>
			<div>
				Warning: This is an irreversible action!<br />
				<input type='submit' value='remove' />
			</div>
		</form>
	</fieldset>
</div>
REMOVE

$htmlout += "</body>"

$htmlout += "</html>"

$cgi.out("type" => TYPE ,"charset" => CHARSET,"cookie" => $utfcookie, "Cache-Control" => "no-cache"){$htmlout}
end

