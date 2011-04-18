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

require "dudle"

if $cgi.include?("poll")
	if File.directory?($cgi["poll"])
		Dir.chdir($cgi["poll"])
		$is_poll = true

		# check for trailing slash
		if ENV["REDIRECT_URL"] =~ /#{$cgi["poll"]}$/
			$d = Dudle.new(:hide_lang_chooser => true, :relative_dir => "#{$cgi["poll"]}/")
		else
			$d = Dudle.new(:hide_lang_chooser => true)
		end

		$d << "<h2>" + _("Authorization Required") + "</h2>"
		case $cgi["user"]
		when "admin"
			$d << _("The configuration of this Poll is protected by password!")
		when "participant"
			$d << _("This Poll is protected by password!")
		end
		$d << _("In order to proceed, you have to give the password for user %{user}.") % {:user => "<code>#{$cgi["user"]}</code>"}

		$d.out

	else
		$cgi = CGI.new
		$cgi.out({"status" => "BAD_REQUEST"}){""}
	end

else
	$d = Dudle.new(:title => _("Authorization Required"), :hide_lang_chooser => true)
	returnstr = _("Return to dudle home and Schedule a new Poll")
	authstr = _("You have to authorize in order to request this page!")
	$d << <<END
	<p>#{authstr}</p>
	<ul>
		<li><a href='#{$conf.siteurl}'>#{returnstr}</a></li>
	</ul>
	</p>
END

	$d.out

end


