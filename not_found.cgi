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

if(ENV["REDIRECT_URL"])
require_relative "dudle"
if File.exists?(Dir.pwd + File.dirname(ENV["REDIRECT_URL"]))
	$d = Dudle.new(:hide_lang_chooser => true, :load_extensions => false)
else
	$d = Dudle.new(:hide_lang_chooser => true, :load_extensions => false, :relative_dir => "../")
end

title = _("Poll not found")

str = [_("The requested poll was not found."),
       _("There are several reasons why a poll may have been deleted:"),
       _("Somebody clicked on “Delete poll” and deleted the poll manually."),
       _("The poll was deleted by the administrator because it was not accessed for a long time."),
       _("If you think that the deletion was done in error, please contact the administrator of the system."),
       _("Return to Dudle home and schedule a new poll")]

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

else
	puts
	puts "Not Found"
end
