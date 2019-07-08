# coding: utf-8
############################################################################
# Copyright 2009,2010 Benjamin Kellermann                                  #
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

$conf.random_chars = 7

$conf.breadcrumbs = []
$conf.header = []
$conf.footer = []
6.times{|i|
	$conf.header << "<div id='header#{i}'></div>"
	$conf.footer << "<div id='footer#{i}'></div>"
}

$conf.errorlog = ""
$conf.bugreportmail = "webmaster@#{$cgi.server_name}"
$conf.auto_send_report = false
$conf.known_errors = []

$conf.indexnotice = ""

$conf.examples = []

$conf.examplenotice = ""

$conf.aboutnotice = ""

$conf.default_css = "default.css"

$conf.dudle_src = "https://github.com/kellerben/dudle/"

$conf.bots = /bot/i

if File.exists?("config.rb") || File.exists?("../config.rb")
	require_relative "config"
end

require_relative "vcs_#{$conf.vcs}"

