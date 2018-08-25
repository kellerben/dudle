#!/usr/bin/env ruby

############################################################################
# Copyright 2016 Benjamin Kellermann                                       #
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

require_relative "dudle"
# check for trailing slash
if ENV["REDIRECT_URL"] =~ /#{$cgi["poll"]}$/
	$d = Dudle.new(:title => _("Maintenance"), :hide_lang_chooser => true, :relative_dir => "#{$cgi["poll"]}/")
else
	$d = Dudle.new(:title => _("Maintenance"), :hide_lang_chooser => true)
end

def urlescape(str)
	CGI.escapeHTML(CGI.escape(str).gsub("+","%20"))
end


if File.exists?("maintenance.html")
	$d << _("This site is currently undergoing maintenance!")
	$d << File.open("maintenance.html","r").read
else
	$d << _('You should not browse to this file directly. Please create a file named "maintenance.html" to enable the maintenance mode.')
end

$d.out
