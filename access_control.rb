#!/usr/bin/env ruby

############################################################################
# Copyright 2009,2010 Benjamin Kellermann                                  #
#                                                                          #
# This file is part of dudle.                                              #
#                                                                          #
# Dudle is free software: you can redistribute it and/or modify it under   #
# the terms of the GNU Affero General Public License as published by       #
# the Free Software Foundation, either version 3 of the License, or        #
# (at your option) any later version.                                      #
#                                                                          #
# Dudle is distributed in the hope that it will be useful, but WITHOUT ANY #
# WARRANTY; without even the implied warranty of MERCHANTABILITY or        #
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public     #
# License for more details.                                                #
#                                                                          #
# You should have received a copy of the GNU Affero General Public License #
# along with dudle.  If not, see <http://www.gnu.org/licenses/>.           #
############################################################################

if __FILE__ == $0

load "../dudle.rb"

$d = Dudle.new

acusers = {}

File.open(".htdigest","r").each_line{|l| 
	user,realm = l.scan(/^(.*):(.*):.*$/).flatten
	acusers[user] = realm
}

def write_htaccess(acusers)
	File.open(".htaccess","w"){|htaccess|
		if acusers.include?("admin")
			htaccess << <<HTACCESS
<Files ~ "^(edit_columns|invite_participants|access_control|delete_poll).cgi$">
AuthType digest
AuthName "dudle"
AuthUserFile "#{File.expand_path(".").gsub('"','\\\\"')}/.htdigest"
Require user admin
ErrorDocument 401 #{$cgi.script_name.gsub(/[^\/]*\/[^\/]*$/,"")}authorization_required.cgi?user=admin&poll=#{CGI.escape($d.urlsuffix)}
</Files>
HTACCESS
		end
		if acusers.include?("participant")
			htaccess << <<HTACCESS
AuthType digest
AuthName "dudle"
AuthUserFile "#{File.expand_path(".").gsub('"','\\\\"')}/.htdigest"
Require valid-user
ErrorDocument 401 #{$cgi.script_name.gsub(/[^\/]*\/[^\/]*$/,"")}authorization_required.cgi?user=participant&poll=#{CGI.escape($d.urlsuffix)}
HTACCESS
		end
	}
	VCS.commit("Access Control changed")
	unless acusers.empty?
		$d.html.header["status"] = "REDIRECT"
		$d.html.header["Cache-Control"] = "no-cache"
		$d.html.header["Location"] = "access_control.cgi"
	end
end
def add_to_htdigest(user,password)
	fork {
		IO.popen("htdigest .htdigest dudle #{user} 2>/dev/null","w+"){|htdigest|
			htdigest.sync
			htdigest.puts(password)
			htdigest.puts(password)
		}
	}
end

def createform(userarray,hint,acusers)
	usernamestr = _("Username:")
	ret = <<FORM
<form id='ac_#{userarray[0]}' method='post' action='' >
	<table class='settingstable'>
		<tr>
			<td class='label'>#{usernamestr}</td>
			<td title="#{userarray[1]}">
				#{userarray[0]}
				<input type='hidden' name='ac_user' value='#{userarray[0]}' />
			</td>
		</tr>
FORM

	passwdstr = _("Password")
	repeatstr = _("repeat")
	2.times{|i|
		ret += <<PASS
		<tr>
			<td class='label'><label for='password#{i}'>#{passwdstr}#{i == 1 ? " (#{repeatstr})" : ""}:</label></td>
			<td>
PASS
		if acusers.include?(userarray[0])
			ret += PASSWORDSTAR*14
		else
			ret += "<input id='password#{i}' size='6' value='' type='password' name='ac_password#{i}' />"
		end
		ret += "</td></tr>"
	}

	ret += <<FORM
	<tr>
		<td></td>
		<td id='#{userarray[0]}hint' class='shorttextcolumn'>#{acusers.include?(userarray[0]) ? "" : hint}</td>
	</tr>
	<tr>
		<td></td>
		<td>
FORM
	if acusers.include?(userarray[0])
		if userarray[0] == "admin" && acusers.include?("participant")
			ret += "<div class='shorttextcolumn'>" + _("You have to remove the participant user before you can remove the administrator.") + "</div>"
		else
			ret += "<input type='hidden' name='ac_delete_#{userarray[0]}' value='Delete' />"
			ret += "<input type='submit' value='" + _("Delete") + "' />"
		end
	else
		ret += "<input type='hidden' name='ac_create' value='Save' />"
		ret += "<input type='submit' value='" + _("Save") + "' />"
	end

	ret += <<FORM
				<input type='hidden' name='ac_activate' value='Activate' />
			</td>
		</tr>
	</table>
</form>
FORM
	ret
end


if $cgi.include?("ac_user")
	user = $cgi["ac_user"]
	if !(user =~ /^[\w]*$/)
		# add user
		usercreatenotice = "<div class='error'>" + _("Only letters and digits are allowed in the username.") + "</div>"
	elsif $cgi["ac_password0"] != $cgi["ac_password1"]
		usercreatenotice = "<div class='error'>" + _("Passwords did not match.") + "</div>"
	else
		if $cgi.include?("ac_create")
			add_to_htdigest(user,$cgi["ac_password0"])
			acusers[user] = true 
			write_htaccess(acusers)
		end

		# delete user
		deleteuser = ""
		acusers.each{|user,action|
			if $cgi.include?("ac_delete_#{user}")
				deleteuser = user
			end
		}
		acusers.delete(deleteuser)
		htdigest = []
		File.open(".htdigest","r"){|file|
			htdigest = file.readlines
		}
		File.open(".htdigest","w"){|f|
			htdigest.each{|line|
				f << line unless line =~ /^#{deleteuser}:/
			}
		}
		write_htaccess(acusers)
	end
end

$d.wizzard_redirect

if $d.html.header["status"] != "REDIRECT"

$d.html << "<h2>" + _("Change Access Control Settings") + "</h2>"

if acusers.empty? && $cgi["ac_activate"] != "Activate"

	acstatus = ["red",_("not activated")]
	acswitchbutton = "<input type='hidden' name='ac_activate' value='Activate' />"
	acswitchbutton += "<input type='submit' value='" + _("Activate") + "' />"
else
	if acusers.empty?
		acstatus = ["blue",_("will be activated when at least an admin user is configured")]
		acswitchbutton = "<input type='hidden' name='ac_activate' value='Deactivate' />"
		acswitchbutton += "<input type='submit' value='" + _("Deactivate") + "' />"
	else
		acstatus = ["green", _("activated")]
		acswitchbutton = "<div class='shorttextcolumn'>" + _("You have to remove all users before you can deactivate the access control settings.") + "</div>"
	end


	admincreatenotice = usercreatenotice || _("You will be asked for the password you entered here after pressing save!")

	user = ["admin",
	        _("The user ‘admin’ has access to the vote as well as the configuration interface.")]

	createform = createform(user,admincreatenotice,acusers)
	if acusers.include?("admin")
		participantcreatenotice = usercreatenotice || ""
		user = ["participant",
	          _("The user ‘participant’ has only access to the vote interface.")]
	  createform += createform(user,participantcreatenotice,acusers)
	end

end

acstr = _("Access control:")
$d.html << <<AC
<form id='ac' method='post' action='' >
<table class='settingstable'>
	<tr>
		<td>
			#{acstr}
		</td>
		<td style='color: #{acstatus[0]}'>
			#{acstatus[1]}
		</td>
	</tr>
	<tr>
		<td></td>
		<td>
			#{acswitchbutton}	
		</td>
	</tr>
</table>
</form>

#{createform}
AC

end

$d.out
end
