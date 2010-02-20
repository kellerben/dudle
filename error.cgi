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
require "html"

$h = HTML.new("Error")
$h.add_css("/default.css","default",true)
$h << <<END
<div id='main'>
<div id='content'>
<h1>Error</h1>
END

def urlescape(str)
	CGI.escapeHTML(CGI.escape(str).gsub("+","%20"))
end

errormessagebody = <<MESSAGE
Hi!

I found a bug in your application at #{SITEURL}.
I did the following:

<please describe what you did>
<e.g., I wanted to sent a comment to the poll.>

I am using <please state your browser and operating system>
MESSAGE

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

	errormessagebody += <<MESSAGE

The following error was printed:
#{errorstr}
MESSAGE

end
errormessagebody += <<MESSAGE

Yours,

MESSAGE

	$h << <<ERROR
An error occured while executing dudle.<br/>
Please report your browser, operating system, and what you did to
<a href='mailto:#{BUGREPORTMAIL}?subject=#{urlescape("Bug in dudle")}&amp;body=#{urlescape(errormessagebody)}'>#{BUGREPORTMAIL}</a>. 
ERROR

if (errorstr)
	
	$h << <<ERROR
<br/>
Please include the following as well:
<pre style='background:#DDD;padding : 1em'>#{CGI.escapeHTML(errorstr)}</pre>
ERROR
end

$h << "</div></div>"
$h.out($cgi)


tmpfile = "/tmp/error.#{rand(10000)}"
File.open(tmpfile,"w"){|f| 
	f << errorstr
}

`mail -s "Bug in dudle" #{BUGREPORTMAIL} < #{tmpfile}`

File.delete(tmpfile)

