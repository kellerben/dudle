
class HTML
	attr_accessor :title, :htmlout, :header
	def initialize
		@header = {}
		@header["type"] = "text/html"
#		@header["type"] = "application/xhtml+xml"
		@header["charset"] = "utf-8"

		@htmlout = <<HEAD
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
HEAD
		@css = {}
		@atom = []
	end
	def add_head(title)
		@htmlout += <<HEAD
<head>
	<meta http-equiv="Content-Type" content="#{@header["type"]}; charset=#{@header["charset"]}" /> 
	<meta http-equiv="Content-Style-Type" content="text/css" />
	<title>#{title}</title>
HEAD
		@css.each{|title,href|
			@htmlout += "<link rel='stylesheet' type='text/css' href='#{href}' title='#{title}'/>"
			@htmlout += "<link rel='stylesheet' type='text/css' href='#{href}' title='print' media='print' />" if title == "print"
		}

		@atom.each{|href|
			@htmlout += "<link rel='alternate'  type='application/atom+xml' href='#{href}' />"
		}

		@htmlout += "</head>"
	end
	def add_css(href, title = "default")
		@css[title] ||= []
		@css[title] << href
	end
	def add_atom(href)
		@atom << href
	end
	def add_tabs
		@htmlout += <<HEAD
		<div id='tabs'>
				<ul>
					<li id='active_tab' >&nbsp;poll&nbsp;</li>
					<li class='nonactive_tab'><a href='config.cgi'>&nbsp;admin&nbsp;</a></li>
				</ul>
		</div>
HEAD
	end
end
