# coding: utf-8
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

require "ostruct"
$conf = OpenStruct.new

$conf.vcs = "git"

case $cgi.server_port
when 80
	protocol = "http"
	port = ""
when 443
	protocol = "https"
	port = ""
else
	protocol = "http"
	port = ":#{$cgi.server_port}"
end
$conf.siteurl = "#{protocol}://#{$cgi.server_name}#{port}#{$cgi.script_name.gsub(/[^\/]*$/,"")}"

$conf.breadcrumbs = []

$conf.errorlog = ""
$conf.bugreportmail = "Benjamin.Kellermann@tu-dresden.de"
$conf.auto_send_report = false

$conf.indexnotice = <<INDEXNOTICE
<h2>Available Polls</h2>
<table>
	<tr>
		<th>Poll</th><th>Last change</th>
	</tr>
INDEXNOTICE
Dir.glob("*/data.yaml").sort_by{|f|
	File.new(f).mtime
}.reverse.collect{|f| f.gsub(/\/data\.yaml$/,'') }.each{|site|
	$conf.indexnotice += <<INDEXNOTICE
<tr class='participantrow'>
	<td class='polls'><a href='./#{CGI.escapeHTML(site).gsub("'","%27")}/'>#{CGI.escapeHTML(site)}</a></td>
	<td class='mtime'>#{File.new(site + "/data.yaml").mtime.strftime('%d.%m, %H:%M')}</td>
</tr>
INDEXNOTICE
}
$conf.indexnotice += "</table>"

$conf.examples = []

$conf.examplenotice = ""

$conf.aboutnotice = ""

$conf.default_css = "default.css"


if File.exists?("config.rb") || File.exists?("../config.rb")
	require "config"
end

require "vcs_#{$conf.vcs}"

