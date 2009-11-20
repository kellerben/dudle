################################
# Author:  Benjamin Kellermann #
# License: CC-by-sa 3.0        #
#          see License         #
################################

class HTML
	attr_accessor :body, :header
	def initialize(title)
		@title = title
		@header = {}
		@header["type"] = "text/html"
#		@header["type"] = "application/xhtml+xml"
		@header["charset"] = "utf-8"

		@body = ""
		@css = {}
		@atom = []
	end
	def head
		ret = <<HEAD
<head>
	<meta http-equiv="Content-Type" content="#{@header["type"]}; charset=#{@header["charset"]}" /> 
	<meta http-equiv="Content-Style-Type" content="text/css" />
	<title>#{@title}</title>
HEAD
		@css.each{|title,href|
			ret += "<link rel='stylesheet' type='text/css' href='#{href}' title='#{title}'/>"
			ret += "<link rel='stylesheet' type='text/css' href='#{href}' title='print' media='print' />" if title == "print"
		}

		@atom.each{|href|
			ret += "<link rel='alternate'  type='application/atom+xml' href='#{href}' />"
		}

		ret += "</head>"
		ret
	end
	def add_css(href, title = "default")
		@css[title] ||= []
		@css[title] << href
	end
	def add_atom(href)
		@atom << href
	end
	def add_cookie(key,value,path,expiretime)
		c = CGI::Cookie.new(key, value)
		c.path = path
		c.expires = expiretime
		@header["cookie"] = c
	end
	def << (bodycontent)
		@body += bodycontent
	end
	def out(cgi)
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

module Dudle
	def Dudle.tabs(active_tab)
		ret = "<div id='tabs'><ul>"
		[["Home",".."],
		 ["Customize","customize.cgi"],
		 ["Poll","."],
		 ["History","history.cgi"],
		 ["Edit Columns","edit_columns.cgi"],
		 ["Access Control","access_control.cgi"],
		 ["Delete Poll","delete_poll.cgi"]
		].each{|tab,file|
			if tab == active_tab
				ret += "<li id='active_tab' >&nbsp;#{tab}&nbsp;</li> "
			else
				ret += "<li class='nonactive_tab' ><a href='#{file}'>&nbsp;#{tab}&nbsp;</a></li> "
			end
		}
		ret += "</ul></div>"
		ret
	end
end
