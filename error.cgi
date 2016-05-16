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

require_relative "dudle"
# check for trailing slash
if ENV["REDIRECT_URL"] =~ /#{$cgi["poll"]}$/
	$d = Dudle.new(:title => _("Error"), :hide_lang_chooser => true, :relative_dir => "#{$cgi["poll"]}/")
else
	$d = Dudle.new(:title => _("Error"), :hide_lang_chooser => true)
end

def urlescape(str)
	CGI.escapeHTML(CGI.escape(str).gsub("+","%20"))
end


if File.exists?($conf.errorlog)
	begin
		a = File.open($conf.errorlog,"r").to_a
	rescue Exception => e
		errorstr = "Exception while opening #{$conf.errorlog}:\n#{e}"
	else
		s = [a.pop]
		s << a.pop while s.last.scan(/^\[([^\]]*)\] \[/).flatten[0] == a.last.scan(/^\[([^\]]*)\] \[/).flatten[0] || a.last =~ /^[^\[]/
		errorstr = s.reverse.join
	end

	errormessage = "\n" + _("The following error was printed:") + "\n" + errorstr

end

	errormessagebody = _("Hi!\n\nI found a bug in your application at %{urlofsite}.\nI did the following:\n\n<please describe what you did>\n<e.g., I wanted to sent a comment to the poll.>\n\nI am using <please state your browser and operating system>\n%{errormessage}\nYours,\n") % {:errormessage => errormessage, :urlofsite => $conf.siteurl}
	subject = _("Bug in dudle")

	$d << _("An error occured while executing dudle.<br/>Please send an error report, including your browser, operating system, and what you did to %{admin}.") % {:admin => "<a href='mailto:#{$conf.bugreportmail}?subject=#{urlescape(subject)}&amp;body=#{urlescape(errormessagebody)}'>#{$conf.bugreportmail}</a>"}

if (errorstr)
	errorheadstr = _("Please include the following as well:")
	$d << <<ERROR
<br/>
#{errorheadstr}
<pre style='background:#DDD;padding : 1em'>#{CGI.escapeHTML(errorstr)}</pre>
ERROR
end

$d.out

known = false
if (errorstr)
	$conf.known_errors.each{|err|
		known = true if errorstr.index(err)
	}
end

if $conf.auto_send_report && !known
	tmpfile = "/tmp/error.#{rand(10000)}"
	File.open(tmpfile,"w"){|f| 
		f << errorstr
	}

	%x{mail -s "Bug in dudle" #{$conf.bugreportmail} < #{tmpfile}}

	File.delete(tmpfile)

end

