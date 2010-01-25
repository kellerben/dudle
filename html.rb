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

class HTML
	attr_accessor :body, :header
	def initialize(title)
		@title = title
		@header = {}
		@header["type"] = "text/html"
#		@header["type"] = "application/xhtml+xml"
		if $cgi.accept_charset =~ /utf-8/ || $cgi.accept_charset =~ /\*/
			@header["charset"] = "utf-8"
		else
			@header["charset"] = "iso-8859-1"
		end

		@body = ""
		@htmlheader = ''
		@css = []
		@atom = []
	end
	def head
		ret = <<HEAD
<head>
	<meta http-equiv="Content-Type" content="#{@header["type"]}; charset=#{@header["charset"]}" /> 
	<meta http-equiv="Content-Style-Type" content="text/css" />
	<title>#{@title}</title>
HEAD

		@css = [@css[0]] + @css[1..-1].sort unless @css.empty?
		@css.each{|title,href|
			ret += "<link rel='stylesheet' type='text/css' href='#{href}' title='#{title}'/>\n"
			ret += "<link rel='stylesheet' type='text/css' href='#{href}' title='print' media='print' />\n" if title == "print"
		}

		@atom.each{|href|
			ret += "<link rel='alternate'  type='application/atom+xml' href='#{href}' />\n"
		}

		ret += @htmlheader

		ret += "</head>"
		ret
	end
	def add_css(href, title, default = false)
		if default
			@css.unshift([title,href])
		else
			@css << [title,href]
		end
	end
	def add_atom(href)
		@atom << href
	end
	def add_cookie(key,value,path,expiretime)
		c = CGI::Cookie.new(key, value)
		c.path = path
		c.expires = expiretime
		@header["cookie"] ||= []
		@header["cookie"] << c
	end
	def add_head_script(file)
		add_html_head("<script type='text/javascript' src='#{file}'></script>")
	end
	def add_script(file)
		self << "<script type='text/javascript' src='#{file}'></script>"
	end
	def << (bodycontent)
		@body += bodycontent.chomp + "\n"
	end
	def add_html_head(headercontent)
		@htmlheader += headercontent.chomp + "\n"
	end

	def out(cgi)
		#FIXME: quick and dirty fix for encoding problem
		{ 
			"ö" => "&ouml;",
			"ü" => "&uuml;",
			"ä" => "&auml;",
			"Ö" => "&Ouml;",
			"Ü" => "&Uuml;",
			"Ä" => "&Auml;",
			"ß" => "&szlig;",
			"–" => "&#8211;",
			"„" => "&#8222;",
			"“" => "&#8220;",
			"”" => "&#8221;",
			"✔" => "&#10004;",
			"✘" => "&#10008;",
			"◀" => "&#9664;",
			"▶" => "&#9654;",
			"✍" => "&#9997;",
			"✖" => "&#10006;",
			"•" => "&#8226;",
			"▾" => "&#9662;",
			"▴" => "&#9652;"
		}.each{|from,to|
			@body.gsub!(from,to)
		}
#		@body.gsub!(/./){|char|
#			 code = char[0]
#			 code > 127 ? "&##{code};" : char
#		}
		cgi.out(@header){
			<<HEAD
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
#{head}
#{@body}
</html>
HEAD
		}
	end
end

