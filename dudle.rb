############################################################################
# Copyright 2009-2019 Benjamin Kellermann                                  #
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

$KCODE = 'u' if RUBY_VERSION < '1.9.0'
require 'yaml'
require 'cgi'

$cgi ||= CGI.new

require 'gettext'
require 'gettext/cgi'
include GetText
GetText.cgi = $cgi
GetText.output_charset = 'utf-8'
require 'locale'

if File.exist?('data.yaml') && !File.stat('data.yaml').directory?
	$is_poll = true
	GetText.bindtextdomain('dudle', path: Dir.pwd + '/../locale/')
else
	$is_poll = false
	GetText.bindtextdomain('dudle', path: Dir.pwd + '/locale/')
end

$:.push('..')
require_relative 'date_locale'

require_relative 'html'
require_relative 'poll'
require_relative 'config_defaults'
require_relative 'charset'

class Dudle
	attr_reader :html, :table, :urlsuffix, :css, :user_css, :title, :tab

	def is_poll?
		$is_poll
	end

	def tabs_to_html(active_tab)
		ret = "<div id='tabs' role='navigation'><ul id='tablist'>"
		@tabs.each { |tab, file|
			case file
			when _(active_tab)
				ret += "<li id='active_tab' class='active_tab' >&nbsp;#{tab}&nbsp;</li> "
			when ''
				ret += "<li class='separator_tab'></li>"
			else
				ret += "<li class='nonactive_tab' ><a href='#{@html.relative_dir}#{file}'>&nbsp;#{tab}&nbsp;</a></li> "
			end
		}
		ret += '</ul></div>'
		ret
	end

	def inittabs
		@tabs = []
		@tabs << [_('Home'), @basedir]
		if is_poll?
			@tabs << ['', '']
			@tabs << [_('Poll'), '.']
			@tabs << [_('History'), 'history.cgi']
			@tabs << ['', '']
			@configtabs = [
				[_('Edit Columns'), 'edit_columns.cgi'],
				[_('Invite Participants'), 'invite_participants.cgi'],
				[_('Access Control'), 'access_control.cgi'],
				[_('Overview'), 'overview.cgi']
			]
			@tabs += @configtabs
			@tabs << [_('Delete Poll'), 'delete_poll.cgi']
			@tabs << ['', '']
		else
			@tabs << [_('Examples'), 'example.cgi']
			@tabs << [_('About'), 'about.cgi']
		end
		@tabs << [_('Customize'), 'customize.cgi']
		@tabtitle = @tabs.collect { |title, file| title if file == @tab }.compact[0]
	end

	def revision
		@requested_revision || VCS.revno
	end

	def breadcrumbs
		crumbs = $conf.breadcrumbs
		crumbs << ("<a href='#{@basedir}'>" + _('DuD-Poll Home') + '</a>')
		if is_poll?
			if @tab == '.'
				crumbs << CGI.escapeHTML(@title)
			else
				crumbs << "<a href='.'>#{CGI.escapeHTML(@title)}</a>"
				crumbs << @tabtitle
			end
		elsif @tab != '.'
			crumbs << @tabtitle
		end
		"<div id='breadcrumbs'><ul><li class='breadcrumb'>#{crumbs.join("</li><li class='breadcrumb'>")}</li></ul></div>"
	end

	def polltypespan
		return unless is_poll?

		"<div tabindex='0'><span id='polltypespan' class='visually-hidden'>#{CGI.escapeHTML(@polltype)}</span></div>"
	end

	def initialize(params = { revision: nil, title: nil, hide_lang_chooser: nil, relative_dir: '', load_extensions: true })
		@requested_revision = params[:revision]
		@hide_lang_chooser = params[:hide_lang_chooser]
		@cgi = $cgi
		@tab = File.basename($0)
		@tab = '.' if @tab == 'index.cgi'

		if is_poll?
			# log last read access manually (no need to grep server logfiles)
			File.open('last_read_access', 'w').close unless @cgi.user_agent =~ $conf.bots
			@basedir = '..'
			inittabs
		 if params[:revision]
				@table = YAML.safe_load(VCS.cat(revision, 'data.yaml'), permitted_classes: [Poll, TimePollHead])
			else
				@table = YAML.load_file('data.yaml')
   end
			@urlsuffix = File.basename(File.expand_path('.'))
			@title = @table.name

			if @table.head.to_s.include? 'TimePollHead'
				@polltype = _('This is a Event-scheduling poll.')
			else @table.head.to_s.include? 'PollHead'
				    @polltype = _('This is a Normal poll.')
			end

			configfiles = @configtabs.collect { |_name, file| file }
			@is_config = configfiles.include?(@tab)
			@wizzardindex = configfiles.index(@tab) if @is_config

			@html = HTML.new("DuD-Poll - #{@title} - #{@tabtitle}", params[:relative_dir])
			@html.add_html_head('<meta name="robots" content="noindex, nofollow" />')
			@html.header['Cache-Control'] = 'no-cache'
		else
			@basedir = '.'
			inittabs
			@title = params[:title] || "DuD-Poll - #{@tabtitle}"
			@html = HTML.new(@title, params[:relative_dir])
		end

		@css = %w[default classic print].collect { |f| f + '.css' }
		if Dir.exist?("#{@basedir}/css/")
			Dir.open("#{@basedir}/css/").each { |f|
				if f =~ /\.css$/
					@css << "css/#{f}"
				end
			}
		end
		if $cgi.include?('css')
			@user_css = $cgi['css']
			@html.add_cookie('css', @user_css, '/', Time.now + (1 * 60 * 60 * 24 * 365 * (@user_css == $conf.default_css ? -1 : 1)))
		else
			@user_css = $cgi.cookies['css'][0]
			@user_css ||= $conf.default_css
		end

		if $cgi.user_agent =~ /.*MSIE [567]\..*/
			css = [@user_css]
		else
			css = @css
		end
		@html.add_css("#{@basedir}/accessibility.css")
		css.each { |href|
			@html.add_css("#{@basedir}/#{href}", href.scan(%r{([^/]*)\.css}).flatten[0], href == @user_css)
		}

		@html << <<HEAD
<body><div id="top"></div>
HEAD
		$conf.header.each { |h| @html << h }

		@html << <<HEAD
#{breadcrumbs}
<div id='main'>
#{tabs_to_html(@tab)}
<div id='content' role='content'>
	<h1 id='polltitle'>#{CGI.escapeHTML(@title)}
	</h1>
	#{polltypespan}
HEAD

		###################
		# init extenisons #
		###################
		@extensions = []
		$d = self # FIXME: this is dirty, but extensions need to know table elem
		return unless Dir.exist?("#{@basedir}/extensions/") && params[:load_extensions]

		Dir.open("#{@basedir}/extensions/").sort.each { |f|
				next unless File.exist?("#{@basedir}/extensions/#{f}/main.rb")

				@extensions << f
				if File.exist?("#{@basedir}/extensions/#{f}/preload.rb")
					$current_ext_dir = f
					require "#{@basedir}/extensions/#{f}/preload"
				end
		}
	end

	def wizzard_nav
		ret = "<div id='wizzard_navigation'><table><tr>"
		[[_('Previous'), @wizzardindex == 0],
		 [_('Next'), @wizzardindex >= @configtabs.size - 2],
		 [_('Finish'), @wizzardindex == @configtabs.size - 1]].each { |button, disabled|
			ret += <<READY
				<td>
					<form method='post' action=''>
						<div>
							<input type='hidden' name='undo_revision' value='#{revision}' />
							<input type='submit' #{disabled ? "disabled='disabled'" : ''} name='#{button}' value='#{button}' />
						</div>
					</form>
				</td>
READY
		}
		ret += '</tr></table></div>'
	end

	def wizzard_redirect
		[[_('Previous'), @wizzardindex - 1],
		 [_('Next'), @wizzardindex + 1],
		 [_('Finish'), @configtabs.size - 1]].each { |action, linkindex|
			next unless $cgi.include?(action)

			@html.header['status'] = 'REDIRECT'
			@html.header['Cache-Control'] = 'no-cache'
			@html.header['Location'] = @configtabs[linkindex][1]
			@html << (_('All changes were saved successfully.') + " <a href=\"#{@configtabs[linkindex][1]}\">" + _('Proceed!') + '</a>')
			out
			exit
		}
	end

	def out
		@html << wizzard_nav if @is_config

		@html.add_cookie('lang', @cgi['lang'], '/', Time.now + (1 * 60 * 60 * 24 * 365)) if @cgi.include?('lang')
		@html << '</div>' # content
		@html << "<form action=''><div id='languageChooser'><select aria-label='#{CGI.escapeHTML(_('Select Language'))}' name='lang'>"
		lang = [ # sorted by native speakers according to English Wikipedia
			['es', 'Español'],  # 480 million native speakers (2018)
			['en', 'English'],  # 360–400 million (2006)
			['ar', 'اَلْعَرَبِيَّة'], # 310 million, all varieties (2011–2016)
			['pt_BR', 'Português brasileiro'], # 205 million (2011)
			['ru', 'русский'],  # 150 million (2012)
			['de', 'Deutsch'],  # 95 million (2014)
			['it', 'Italiano'], # 90 million (2012)
			['tr', 'Türkçe'], # 80 million (2021)
			['fr', 'Français'], # 76.8 million (2014)
			['pl', 'Polski'], # 45 million
			['es_AR', 'Español Argentino'], # 25–30 million
			['nl', 'Nederlands'], # 24 million (2016)
			['ln', 'Lingála'], # 21 million (2021)
			['sw', 'Kiswahili'], # 15 million (2012)
			['hu', 'Magyar'], # 13 million (2002–2012)
			['sv', 'Svenska'], # 10 million (2018)
			['cs', 'Česky'], # 10.7 million (2015)
			['bg', 'български'], # 8 million
			['da', 'Dansk'], # 5.5 million (2012)
			['fi', 'Finnish'], # 5.4 million (2009–2012)
			['he', 'עִבְרִית'], # 5 million (2017)
			['no', 'Norsk'], # 4.32 million (2012)
			['ca', 'Català'],  # 4.1 million (2012)
			['gl', 'Galego'],  # 2.4 million (2012)
			['et', 'Eesti'], # 1.1 million (2012)
			['eo', 'Esperanto'] # estimated 1000 to several thousand (2016)
		]
		unless @hide_lang_chooser
			lang.each { |short, long|
				if short == GetText.locale.to_s
					@html << "<option class='lang' value='#{short}' selected='selected'>#{long}</option>"
				else
					@html << "<option class='lang' value='#{short}'>#{long}</option>"
				end
			}
		end
		@html << "</select><input type='submit' value='#{CGI.escapeHTML(_('Select Language'))}' /></div></form>" # languageChooser

		@html << '</div>' # main
		$conf.footer.each { |f| @html << f }
		@extensions.each { |e|
			if File.exist?("#{@basedir}/extensions/#{e}/main.rb")
				$current_ext_dir = e
				require "#{@basedir}/extensions/#{e}/main"
			end
		}

		@html << '</body>'
		@html.out(@cgi)
	end

	def <<(htmlbodytext)
		@html << htmlbodytext
	end
end
