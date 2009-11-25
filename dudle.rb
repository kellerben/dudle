############################################################################
# Copyright 2009 Benjamin Kellermann                                       #
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

require "yaml"
require "cgi"

$cgi = CGI.new

olddir = File.expand_path(".")
Dir.chdir("..")
require "html"
require "poll"
require "config"
require "charset"
Dir.chdir(olddir)

class Dudle
	attr_reader :html, :table, :urlsuffix
	def Dudle.tabs(active_tab)
		ret = "<div id='tabs'><ul>"
		[["Home",".."],
		 ["",""],
		 ["Poll","."],
		 ["History","history.cgi"],
		 ["Help","help.cgi"],
		 ["",""],
		 ["Edit Columns","edit_columns.cgi"],
		 ["Invite Participants","invite_participants.cgi"],
		 ["Access Control","access_control.cgi"],
		 ["Delete Poll","delete_poll.cgi"],
		 ["",""],
		 ["Customize","customize.cgi"]
		].each{|tab,file|
			case tab
			when active_tab
				ret += "<li id='active_tab' >&nbsp;#{tab}&nbsp;</li> "
			when ""
				ret += "<li class='separator_tab' />"
			else
				ret += "<li class='nonactive_tab' ><a href='#{file}'>&nbsp;#{tab}&nbsp;</a></li> "
			end
		}
		ret += "</ul></div>"
		ret
	end
	def initialize(htmltitle, revision=nil)
		if revision
			@table = YAML::load(VCS.cat(revision, "data.yaml"))
		else
			@table = YAML::load_file("data.yaml")
		end
		@urlsuffix = File.basename(File.expand_path("."))

		@html = HTML.new("dudle - #{@table.name} - #{htmltitle}")
		@html.header["Cache-Control"] = "no-cache"
		@html.add_css("../dudle.css")

		@html << <<HEAD
<body>
<div id='header' />
#{Dudle.tabs(htmltitle)}
<div id='main'>
	<h1>#{@table.name}</h1>
HEAD
	end
	def out(cgi)
		@html << "</div></body>"
		@html.out(cgi)
	end
	def <<(htmlbodytext)
		@html << htmlbodytext
	end

end

