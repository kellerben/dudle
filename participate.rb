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

unless $cgi.include?("cancel")
	if $cgi.include?("delete_participant_confirm")
		$d.table.delete($cgi["delete_participant_confirm"])
	elsif $cgi.include?("add_participant")
		agreed = {}
		$cgi.params.each{|k,v|
			if k =~ /^add_participant_checked_/
				agreed[k.gsub(/^add_participant_checked_/,"")] = v[0]
			end
		}

		$d.table.add_participant($cgi["olduser"],$cgi["add_participant"],agreed)
	end
end

$d.table.add_comment($cgi["commentname"],$cgi["comment"]) if $cgi["comment"] != ""
$d.table.delete_comment($cgi["delete_comment"].to_i) if $cgi.include?("delete_comment")


$d.html.add_atom("atom.cgi") if File.exists?("../atom.rb")

reloadstr = _("Reload")
$d << <<END
<form method='get' action='.'>
<div>
<input value='#{reloadstr}' type='submit'/>
</div>
</form>
END

# TABLE
$d << <<HTML
<div id='polltable'>
	<form method='post' action='.' accept-charset='utf-8'>
		#{$d.table.to_html}
	</form>
</div>

#{$d.table.comment_to_html}
HTML

$d.out
end
