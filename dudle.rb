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

$KCODE = "u"
require "yaml"
require "cgi"

$cgi = CGI.new

require 'gettext'
require 'gettext/cgi'
include GetText
GetText.cgi=$cgi
GetText.output_charset = 'utf-8'

$:.push("..")
require "html"
require "poll"
require "config"
require "charset"

class Dudle
	attr_reader :html, :table, :urlsuffix, :css, :title, :tab
	def is_poll?
		@is_poll
	end
	def tabs(active_tab)
		ret = "<div id='tabs'><ul id='tablist'>"
		tabs = []
		tabs << [_("Home"),@basedir]
		if @is_poll
			tabs << ["",""]
			tabs += @usertabs
			tabs << ["",""]
			tabs += @configtabs
			tabs << @deletetab
			tabs << ["",""]
		else
			tabs << [_("About"),"about.cgi"]
		end
		tabs << @customizetab
		tabs.each{|tab,file|
			case file
			when _(active_tab)
				ret += "<li id='active_tab' class='active_tab' >&nbsp;#{tab}&nbsp;</li> "
			when ""
				ret += "<li class='separator_tab'></li>"
			else
				ret += "<li class='nonactive_tab' ><a href='#{file}'>&nbsp;#{tab}&nbsp;</a></li> "
			end
		}
		ret += "</ul></div>"
		ret
	end

	def inittabs
		@customizetab = [_("Customize"),"customize.cgi"]
		if @is_poll
			# set-up tabs
			@usertabs = [
				[_("Poll"),"."],
				[_("History"),"history.cgi"]
			]
			@configtabs = [
				[_("Edit Columns"),"edit_columns.cgi"],
				[_("Invite Participants"),"invite_participants.cgi"],
				[_("Access Control"),"access_control.cgi"],
				[_("Overview"),"overview.cgi"]
			]
			@deletetab = [_("Delete Poll"),"delete_poll.cgi"]
		end
	end
	def revision
		@requested_revision || VCS.revno
	end

	def initialize(revision=nil)
		@requested_revision = revision 
		@cgi = $cgi
		@tab = File.basename($0)
		@tab = "." if @tab == "index.cgi"

		if File.exists?("data.yaml") && !File.stat("data.yaml").directory?
			# log last read acces manually (no need to grep server logfiles)
			File.open("last_read_access","w").close
			@is_poll = true
			@basedir = ".." 
			GetText.bindtextdomain("dudle",:path => "#{@basedir}/locale/")
			@table = YAML::load(VCS.cat(self.revision, "data.yaml"))
			@urlsuffix = File.basename(File.expand_path("."))
			@title = @table.name
			
			inittabs
			
			configfiles = @configtabs.collect{|name,file| file}
			@is_config = configfiles.include?(@tab)
			@wizzardindex = configfiles.index(@tab) if @is_config

			@tabtitle = (@usertabs + @configtabs + [@deletetab] + [@customizetab]).collect{|title,file| title if file == @tab}.compact[0]
			@html = HTML.new("dudle - #{@title} - #{@tabtitle}")
			@html.header["Cache-Control"] = "no-cache"
		else
			@is_poll = false
			@basedir = "."
			GetText.bindtextdomain("dudle",:path => "#{@basedir}/locale/")
			inittabs
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
		if $cgi.user_agent =~ /.*MSIE [567]\..*/
			css = [default ? default : "default.css"]
		else
			css = @css
		end
		css.each{|href|
			@html.add_css("#{@basedir}/#{href}",href.scan(/([^\/]*)\.css/).flatten[0] ,href == default)
		}

		@html << <<HEAD
<body>
<div id='header1'></div>
<div id='header2'></div>
<div id='header3'></div>
<div id='main'>
#{tabs(@tab)}
<div id='content'>
	<h1 id='polltitle'>#{@title}</h1>
HEAD


		###################
		# init extenisons #
		###################
		@extensions = []
		Dir.open("#{@basedir}/extensions/").each{|f|
			@extensions << f if File.exists?("#{@basedir}/extensions/#{f}/main.rb")
		}
	end

	def wizzard_nav
		ret = "<div id='wizzard_navigation'><table><tr>"
		[[_("Previous"),@wizzardindex == 0],
		 [_("Next"),@wizzardindex >= @configtabs.size()-2],
		 [_("Finish"),@wizzardindex == @configtabs.size()-1]].each{|button,disabled|
			ret += <<READY
				<td>
					<form method='post' action=''>
						<div>
							<input type='hidden' name='undo_revision' value='#{self.revision}' />
							<input type='submit' #{disabled ? "disabled='disabled'" : ""} name='#{button}' value='#{button}' />
						</div>
					</form>
				</td>
READY
		}
		ret += "</tr></table></div>"
	end

	def wizzard_redirect
		[[_("Previous"),@wizzardindex-1],
		 [_("Next"),@wizzardindex+1],
		 [_("Finish"),@configtabs.size()-1]].each{|action,linkindex|
			if $cgi.include?(action)
				@html.header["status"] = "REDIRECT"
				@html.header["Cache-Control"] = "no-cache"
				@html.header["Location"] = @configtabs[linkindex][1]
				@html << _("All changes were saved sucessfully.") + " <a href=\"#{@configtabs[linkindex][1]}\">" + _("Proceed!") + "</a>"
				out
				exit
			end
		}
	end

	def out
		@html << wizzard_nav if @is_config

		@html.add_cookie("lang",@cgi["lang"],"/",Time.now + (1*60*60*24*365)) if @cgi.include?("lang")
		@html << "<div id='languageChooser'>"
		lang = [
			["en", "English"],
			["de", "Deutsch"],
			["sv", "Svenska"]
			]
		lang.each{|short,long|
			@html << "<a href='?lang=#{short}'>" unless short == GetText.locale.language
			@html << long
			@html << "</a>" unless short == GetText.locale.language
		}
		@html << "</div>" # languageChooser

		@html << "</div>" # content
		@html << "</div>" # main

		if File.exists?("#{@basedir}/extensions/")
			@extensions.each{|e|
				require "#{@basedir}/extensions/#{e}/main" 
			}
		end

		@html << "</body>"
		@html.out(@cgi)
	end

	def <<(htmlbodytext)
		@html << htmlbodytext
	end

end
