#!/usr/bin/env ruby

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

require "cgi"
$cgi = CGI.new
require "config"
require 'gettext'
require 'gettext/cgi'
include GetText
GetText.cgi=$cgi
GetText.output_charset = 'utf-8'
require "locale"

GetText.bindtextdomain("dudle",:path => "./locale/")

require "html"

title = _("Error")
$h = HTML.new(title)
$h.add_css("/#{DEFAULT_CSS}","default",true)
$h << <<END
<div id='header1'></div>
<div id='header2'></div>
<div id='header3'></div>
<div id='main'>
<div id='content'>
<h1>#{title}</h1>
END

def urlescape(str)
	CGI.escapeHTML(CGI.escape(str).gsub("+","%20"))
end


if defined?(ERRORLOG)
	begin
		a = File.open(ERRORLOG,"r").to_a
	rescue Exception => e
		errorstr = "Exception while opening #{ERRORLOG}:\n#{e}"
	else
		s = [a.pop]
		s << a.pop while s.last.scan(/^\[([^\]]*)\] \[/).flatten[0] == a.last.scan(/^\[([^\]]*)\] \[/).flatten[0] || a.last =~ /^[^\[]/
		errorstr = s.reverse.join
	end

	errormessage = "\n" + _("The following error was printed:") + "\n" + errorstr

end

	errormessagebody = _("Hi!\n\nI found a bug in your application at %{urlofsite}.\nI did the following:\n\n<please describe what you did>\n<e.g., I wanted to sent a comment to the poll.>\n\nI am using <please state your browser and operating system>\n%{errormessage}\nYours,\n") % {:errormessage => errormessage, :urlofsite => SITEURL}
	subject = _("Bug in dudle")

	$h << _("An error occured while executing dudle.<br/>Please send an error report, including your browser, operating system, and what you did to %{admin}.") % {:admin => "<a href='mailto:#{BUGREPORTMAIL}?subject=#{urlescape(subject)}&amp;body=#{urlescape(errormessagebody)}'>#{BUGREPORTMAIL}</a>"}

if (errorstr)
	errorheadstr = _("Please include the following as well:")
	$h << <<ERROR
<br/>
#{errorheadstr}
<pre style='background:#DDD;padding : 1em'>#{CGI.escapeHTML(errorstr)}</pre>
ERROR
end

$h << "</div></div>"
$h.out($cgi)


if AUTO_SEND_REPORT
	tmpfile = "/tmp/error.#{rand(10000)}"
	File.open(tmpfile,"w"){|f| 
		f << errorstr
	}

	`mail -s "Bug in dudle" #{BUGREPORTMAIL} < #{tmpfile}`

	File.delete(tmpfile)

end

