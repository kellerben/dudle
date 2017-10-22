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

require_relative "dudle"

$d = Dudle.new

$d << "<div>"
$d << _('This Application is powered by %{Dudle}.') % {:Dudle => "<a href='https://dudle.inf.tu-dresden.de' />dudle</a>"}
$d << "</div>"
$d << "<div><h2>" + _("License") + "</h2>"
$d << _("The sourcecode of this application is available under the terms of <a href='http://www.fsf.org/licensing/licenses/agpl-3.0.html'>AGPL Version 3</a>")
$d << _("The Sourcecode of this application can be found %{a_start}here%{a_end}.") % { :a_start => "<a href=\"#{$conf.dudle_src}\">", :a_end => "</a>"}
$d << '<a href="mailto:Benjamin_dot_Kellermann@gmx_in_germany?subject=Feedback%20to%20dudle">'
$d << _('Write me an e-mail if you found a bug, have something which disturbes you or any other feedback.')
$d << '</a>'
$d << "<br />"
$d << "</div>"

$d << $conf.aboutnotice

$d.out
end


