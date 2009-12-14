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
	attr_reader :html, :table, :urlsuffix, :css, :title
	def tabs(active_tab)
		ret = "<div id='tabs'><ul>"
		tabs = []
		tabs << ["Home",@basedir]
		if @is_poll
			tabs << ["",""]
			tabs += @usertabs
			tabs << ["",""]
			tabs += @configtabs
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

	def initialize(tabtitle, revision=nil)
		@cgi = $cgi
		@tabtitle = tabtitle
		if File.exists?("data.yaml") && !File.stat("data.yaml").directory?
			@is_poll = true
			@basedir = ".." 
			@revision = revision || VCS.revno
			@table = YAML::load(VCS.cat(@revision, "data.yaml"))
			@urlsuffix = File.basename(File.expand_path("."))
			@title = @table.name
			@html = HTML.new("dudle - #{@title} - #{@tabtitle}")
			@html.header["Cache-Control"] = "no-cache"
			# set-up tabs
			@usertabs = [
				["Poll","."],
				["History","history.cgi"]
			]
			@configtabs = [
				["Edit Columns","edit_columns.cgi"],
				["Invite Participants","invite_participants.cgi"],
				["Access Control","access_control.cgi"],
				["Overview","overview.cgi"]
			]
			confignames = @configtabs.collect{|name,file| name}
			@is_config = confignames.include?(@tabtitle)
			@wizzardindex = confignames.index(@tabtitle) if @is_config
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
<div id='main'>
#{tabs(@tabtitle)}
<div id='content'>
	<h1>#{@title}</h1>
HEAD
	end

	def wizzard_nav
		ret = "<div id='wizzard_navigation'><table><tr>"
		[["Previous",@wizzardindex == 0],
		 ["Next",@wizzardindex >= @configtabs.size()-2],
		 ["Finish",@wizzardindex == @configtabs.size()-1]].each{|button,disabled|
			ret += <<READY
				<td>
					<form method='post' action=''>
						<div>
							<input type='hidden' name='undo_revision' value='#{@revision}' />
							<input type='submit' #{disabled ? "disabled='disabled'" : ""} name='#{button}' value='#{button}' />
						</div>
					</form>
				</td>
READY
		}
		ret += "</tr></table></div>"
	end

	def wizzard_redirect
		[["Previous",@wizzardindex-1],
		 ["Next",@wizzardindex+1],
		 ["Finish",@configtabs.size()-1]].each{|action,linkindex|
			if $cgi.include?(action)
				@html.header["status"] = "REDIRECT"
				@html.header["Cache-Control"] = "no-cache"
				@html.header["Location"] = @configtabs[linkindex][1]
				@html << "All changes were saved sucessfully. <a href=\"#{@configtabs[linkindex][1]}\">Proceed!</a>"
				out
				exit
			end
		}
	end

	def out
		@html << wizzard_nav if @is_config && @wizzardindex != @configtabs.size() -1
		@html << "</div>"
		@html << "</div></body>"
		@html.out(@cgi)
	end

	def <<(htmlbodytext)
		@html << htmlbodytext
	end

end
