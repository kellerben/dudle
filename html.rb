# coding: utf-8
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

class HTML
	attr_accessor :body, :header
	attr_reader :relative_dir
	def initialize(title, relative_dir = "")
		@title = title
		@relative_dir = relative_dir
		@header = {}
		@header["type"] = "text/html"
#		@header["type"] = "application/xhtml+xml"
		@header["charset"] = "utf-8"

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
	<link rel="shortcut icon" href="/favicon.ico" type="image/vnd.microsoft.icon" />
HEAD

		@css = [@css[0]] + @css[1..-1].sort unless @css.empty?
		@css.each{|title,href|
			titleattr = "title='#{title}'" if title != ""
			ret += "<link rel='stylesheet' type='text/css' href='#{@relative_dir}#{href}' #{titleattr} media='screen, projection, tv, handheld'/>\n"
			ret += "<link rel='stylesheet' type='text/css' href='#{@relative_dir}#{href}' media='print' />\n" if title == "print"
		}

		@atom.each{|href|
			ret += "<link rel='alternate'  type='application/atom+xml' href='#{@relative_dir}#{href}' />\n"
		}

		ret += @htmlheader
		ret +="<script>window.onload = function() {
			var no_sort_selector = '.header:not(.headerSort):not(.headerSortReverse)';
			var sort_selector = '.headerSort';
			var reverse_sort_selector = '.headerSortReverse';
            var all_header_elements = document.querySelectorAll('.header');
			var removed_symbols = [];

			var all_table_cells = document.querySelectorAll('td');
			var all_table_header = document.querySelectorAll('th');
			console.log(document.querySelectorAll('td'));
			for (var i = 0, len = all_table_cells.length; i < len; i++) {
				all_table_cells[i].setAttribute('tabindex', 0);
                all_table_cells[i].onfocus = (function() {
					var headerElements = document.querySelectorAll('.headerSymbol');
					for (var i = 0; i < headerElements.length; i++) {
						headerElements[i].setAttribute('aria-hidden','true');
					}
                });
            }

			for (var i = 0, len = all_table_header.length; i < len; i++) {
				all_table_header[i].setAttribute('tabindex', 0);
                all_table_header[i].onfocus = (function() {
					var headerElements = document.querySelectorAll('.headerSymbol');
					for (var i = 0; i < headerElements.length; i++) {
						headerElements[i].setAttribute('aria-hidden','false');
					}
                });
            }

            function addAccessibilitySpans(type){
                if (type === 'no_sort'){
                    var selector = no_sort_selector;
                    var string = '"+_("No Sort")+"';
					var sortsymb_element = '<span aria-hidden=\"true\">" + NOSORT + "</span>';
                } else if (type === 'sort'){
                    var string = '"+_("Sort")+"';
                    var selector = sort_selector;
					var sortsymb_element = '<span aria-hidden=\"true\">" + SORT + "</span>';;
                } else {
                    var string = '"+_("Reverse Sort")+"';
                    var selector = reverse_sort_selector;
					var sortsymb_element = '<span aria-hidden=\"true\">" + REVERSESORT + "</span>';;
                }
				var elements = document.querySelectorAll(selector);
                if (document.querySelector(selector) !== null){
					var sortsymb = window.getComputedStyle(document.querySelector(selector), ':after').getPropertyValue('content');
                    sortsymb = sortsymb.substr(1);
                    sortsymb = sortsymb.slice(0, -1);
					if (!removed_symbols.includes(sortsymb)){
						document.styleSheets[0].addRule(selector + ':after', 'content: \"\" !important;');
						removed_symbols.push(sortsymb);
					}
                    for (var i = 0, len = elements.length; i < len; i++) {
                        if (elements[i].parentNode.childNodes.length === 1){
                            var visually_hidden_span = document.createElement('span');
                            visually_hidden_span.className += 'visually-hidden headerSymbol';
                            visually_hidden_span.innerText = string;
                            elements[i].after(visually_hidden_span)
                        } else {
                            elements[i].nextSibling.innerText = string;
                        }
                        if (elements[i].getElementsByTagName('span').length === 0){
							elements[i].insertAdjacentHTML('beforeend', sortsymb_element);
                        } else {
                            elements[i].getElementsByTagName('span')[0].remove();
							elements[i].insertAdjacentHTML('beforeend', sortsymb_element);
                        }

                    }
                }
            }

            function addAll(){
                addAccessibilitySpans('no_sort');
                addAccessibilitySpans('sort');
                addAccessibilitySpans('reverse_sort');
            }

            for (var i = 0, len = all_header_elements.length; i < len; i++) {
                all_header_elements[i].onclick = (function() {
                    addAll();
                });
            }

            addAll();

			if(Array.prototype.slice.call(document.getElementById('tablist').children).indexOf(active_tab)!=2){
				if(document.getElementById('polltypespan')!=null){
					document.getElementById('polltypespan').remove();
				}
			}

        }
        </script>"
		ret += "</head>"
		ret
	end
	def add_css(href, title = "", default = false)
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
		add_html_head("<script type='text/javascript' src='#{@relative_dir}#{file}'></script>")
	end
	def add_script_file(file)
		self << "<script type='text/javascript' src='#{@relative_dir}#{file}'></script>"
	end
	def add_script(script)
		self << <<SCRIPT
<script type="text/javascript">
// <![CDATA[
#{script}
// ]]>
</script>
SCRIPT
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
		xmllang = _("xml:lang='en' lang='en' dir='ltr'")
		cgi.out(@header){
			<<HEAD
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" #{xmllang}>
#{head}
#{@body}
</html>
HEAD
		}
	end
end

