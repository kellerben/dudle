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

require_relative "dudle"
if File.exists?(Dir.pwd + File.dirname(ENV["REDIRECT_URL"]))
	$d = Dudle.new(:hide_lang_chooser => true)
else
	$d = Dudle.new(:hide_lang_chooser => true, :relative_dir => "../")
end

title = _("Poll Not Found")

str = [_("The requested Poll was not found."),
       _("There are several reasons, why a Poll is deleted:"),
       _("Somebody clicked on “Delete Poll” and deleted the poll manually."),
       _("The Poll was deleted by the administrator because it was not accessed for a long time."),
       _("If you think, the deletion was done by error, please contact the adminsistrator of the system."),
       _("Return to dudle home and Schedule a new Poll")]

$d << <<END
		<p>
		#{str[0]}
		</p>
		<p>
		#{str[1]}
		<ul>
			<li>#{str[2]}</li>
			<li>#{str[3]}</li>
		</ul>
		#{str[4]}
		<ul>
			<li><a href='#{$conf.siteurl}'>#{str[5]}</a></li>
		</ul>
		</p>
END

$d.out#($cgi)

