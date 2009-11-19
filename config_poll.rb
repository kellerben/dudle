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
		user,realm = l.scan(/^(.*):(.*):.*$/).flatten
		acusers[user] = realm
	}

	if $cgi.include?("add_participant")
		if $cgi.include?("delete_participant")
			table.delete($cgi["olduser"])
		else
			table.add_participant($cgi["olduser"],$cgi["add_participant"],{})
		end
	end
	table.edit_column($cgi["columnid"],$cgi["new_columnname"],$cgi) if $cgi.include?("new_columnname")
	table.delete_column($cgi["deletecolumn"]) if $cgi.include?("deletecolumn")

	def writehtaccess(acusers)
		File.open(".htaccess","w"){|htaccess|
			if acusers.values.include?("config")
				htaccess << <<HTACCESS
<Files ~ "^(config|remove).cgi$">
	AuthType digest
	AuthName "config"
	AuthUserFile "#{File.expand_path(".").gsub('"','\\\\"')}/.htdigest"
	Require valid-user
</Files>
HTACCESS
			end
			if acusers.values.include?("vote")
				htaccess << <<HTACCESS
AuthType digest
AuthName "vote"
AuthUserFile "#{File.expand_path(".").gsub('"','\\\\"')}/.htdigest"
Require valid-user
HTACCESS
				VCS.commit("Access Control changed")
			end
		}
	end

	if $cgi.include?("ac_user")
		user = $cgi["ac_user"]
		type = $cgi["ac_type"]
		if !(user =~ /^[\w]*$/)
			# add user

			usercreatenotice = "<div class='error'>Only uppercase, lowercase, digits are allowed in the username.</div>"
		elsif $cgi["ac_password1"] != $cgi["ac_password2"]
			usercreatenotice = "<div class='error'>Passwords do not match.</div>"
		else
			if $cgi.include?("ac_create")
				if type == "config" || type == "vote"
					fork {
						IO.popen("htdigest .htdigest #{type} #{user}","w+"){|htdigest|
							htdigest.sync
							htdigest.puts($cgi["ac_password1"])
							htdigest.puts($cgi["ac_password2"])
						}
					}
					acusers[user] = type 
					writehtaccess(acusers)
				end
			end

			# delete user
			deleteuser = ""
			deleteaction = ""
			acusers.each{|user,action|
				if $cgi.include?("ac_delete_#{user}_#{action}")
					deleteuser = user
					deleteaction = action
				end
			}
			acusers.delete(deleteuser)
			htdigest = []
			File.open(".htdigest","r"){|file|
				htdigest = file.readlines
			}
			File.open(".htdigest","w"){|f|
				htdigest.each{|line|
					f << line unless line =~ /^#{deleteuser}:#{deleteaction}:/
				}
			}
			writehtaccess(acusers)
		end
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

# ACCESS CONTROL
$accesslevels = { "vote" => "Vote Interface", "config" => "Config Interface" }
$htmlout +=<<ACL
<div id='access_control'>
	<fieldset>
		<legend>Change Access Control Settings</legend>
		<form method='post' action=''>
			<table>
				<tr>
					<th>Access to</th><th>Username</th><th>Password</th><th>Password (repeat)</th>
				</tr>
ACL
acusers.each{|user,action|
		$htmlout += <<USER
<tr>
	<td>#{$accesslevels[action]}</td>
	<td>#{user}</td>
	<td>*****************</td>
	<td>*****************</td>
	<td>
		<input type='submit' name='ac_delete_#{user}_#{action}' value='delete' />
	</td>
</tr>
USER
}

$htmlout += <<ACL
<tr>
	<td>
		<select name='ac_type'>
ACL
	$accesslevels.each{|action,description| 
		$htmlout += "<option value='#{action}'>#{description}</option>"
	}
	$htmlout += <<ACL
		</select>
	</td>
	<td><input size='6' value="" type='text' name='ac_user' /></td>
	<td><input size='6' value="" type='password' name='ac_password1' /></td>
	<td><input size='6' value="" type='password' name='ac_password2' /></td>
	<td>
		<input type='submit' name='ac_create' value='Add' />
	</td>
</tr>
ACL

$htmlout += <<ACL
			</table>
		</form>
		#{usercreatenotice}
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
				<input type='submit' value='Delete' />
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

