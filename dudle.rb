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

$:.push("..")
require "html"
require "poll"
require "config"
require "charset"

class Dudle
	attr_reader :html, :table, :urlsuffix, :css
	def tabs(active_tab)
		ret = "<div id='tabs'><ul>"
		tabs = []
		tabs << ["Home",@basedir]
		if @is_poll
			tabs << ["",""]
			tabs << ["Poll","."]
			tabs << ["History","history.cgi"]
			tabs << ["Help","help.cgi"]
			tabs << ["",""]
			tabs << ["Edit Columns","edit_columns.cgi"]
			tabs << ["Invite Participants","invite_participants.cgi"]
			tabs << ["Access Control","access_control.cgi"]
			tabs << ["Delete Poll","delete_poll.cgi"]
			tabs << ["",""]
		end
		tabs << ["Customize","customize.cgi"]
		tabs.each{|tab,file|
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
		if File.exists?("data.yaml") && !File.stat("data.yaml").directory?
			@is_poll = true
			@basedir = ".." 
			if revision
				@table = YAML::load(VCS.cat(revision, "data.yaml"))
			else
				@table = YAML::load_file("data.yaml")
			end
			@urlsuffix = File.basename(File.expand_path("."))
			@title = @table.name
			@html = HTML.new("dudle - #{@title} - #{htmltitle}")
			@html.header["Cache-Control"] = "no-cache"
		else
			@is_poll = false
			@basedir = "."
			@title = "dudle"
			@html = HTML.new(@title)
		end

		
		@css = ["default", "classic", "print"].collect{|f| f + ".css"}
		Dir.open("#{@basedir}/css/").each{|f|
			if f =~ /\.css$/ 
				@css << "css/#{f}"
			end
		}
		default = $cgi["css"]
		default = $cgi.cookies["css"][0] if default == ""
		@css.each{|href|
			@html.add_css("#{@basedir}/#{href}",href.scan(/([^\/]*)\.css/).flatten[0] ,href == default)
		}

		@html << <<HEAD
<body>
<div id='header1'></div>
<div id='header2'></div>
<div id='header3'></div>
#{tabs(htmltitle)}
<div id='main'>
	<h1>#{@title}</h1>
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
