#!/usr/bin/env ruby

############################################################################
# Copyright 2009-2019 Benjamin Kellermann                                  #
#                                                                          #
# This file is part of Dudle.                                              #
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

edit = false
unless $cgi.include?("cancel")
	if $cgi.include?("delete_participant_confirm")
		$d.table.delete($cgi["delete_participant_confirm"])
		edit = true
	elsif $cgi.include?("add_participant")
		agreed = {}
		$cgi.params.each{|k,v|
			if k =~ /^add_participant_checked_/
				agreed[k.gsub(/^add_participant_checked_/,"")] = v[0]
			end
		}

		$d.table.add_participant($cgi["olduser"],$cgi["add_participant"],agreed)
		edit = true
	end
end

if $cgi["comment"] != ""
	$d.table.add_comment($cgi["commentname"],$cgi["comment"])
	edit = true
end

if $cgi.include?("delete_comment")
	$d.table.delete_comment($cgi["delete_comment"])
	edit = true
end

if edit
	$d.html.header["status"] = "REDIRECT"
	$d.html.header["Cache-Control"] = "no-cache"
	$d.html.header["Location"] = $conf.siteurl
	$d << _("The changes were saved, you should be redirected to %{link}.") % {:link => "<a href=\"#{$conf.siteurl}\">#{$conf.siteurl}</a>"}

else

$d.html.add_atom("atom.cgi") if File.exist?("../atom.rb")

# TABLE
$d << <<HTML
<div id='polltable'>
	<form method='post' action='.' accept-charset='utf-8'>
		#{$d.table.to_html}
	</form>
</div>

#{$d.table.comment_to_html}
HTML

end

$d.out
end
