#!/usr/bin/env ruby

################################
# Author:  Benjamin Kellermann #
# License: CC-by-sa 3.0        #
#          see License         #
################################

require "cgi"

if __FILE__ == $0

$cgi = CGI.new

load "../html.rb"

acusers = {}

File.open(".htdigest","r").each_line{|l| 
	user,realm = l.scan(/^(.*):(.*):.*$/).flatten
	acusers[user] = realm
}

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

$html = HTML.new("dudle - Access Control Settings")
$html.header["Cache-Control"] = "no-cache"
load "../charset.rb"
$html.add_css("../dudle.css")

$html << "<body>"
$html << Dudle::tabs("Access Control")

$html << <<TABLE
	<div id='main'>
TABLE

# ACCESS CONTROL
$accesslevels = { "vote" => "Vote Interface", "config" => "Config Interface" }
$html << <<ACL
<div id='access_control'>
		<h1>Change Access Control Settings</h1>
		<form method='post' action=''>
			<table>
				<tr>
					<th>Access to</th><th>Username</th><th>Password</th><th>Password (repeat)</th>
				</tr>
ACL
acusers.each{|user,action|
		$html << <<USER
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

$html << <<ACL
<tr>
	<td>
		<select name='ac_type'>
ACL
	$accesslevels.each{|action,description| 
		$html << "<option value='#{action}'>#{description}</option>"
	}
	$html << <<ACL
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

$html << <<ACL
			</table>
		</form>
		#{usercreatenotice}
</div>
ACL

$html << "</div></body>"

$html.out($cgi)
end

