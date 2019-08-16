#!/usr/bin/env ruby
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

if __FILE__ == $0

load "../dudle.rb"
$d = Dudle.new
require "fileutils"

QUESTIONS = [ "phahqu3Uib4neiRi",
             _("Yes, I know what I am doing!"),
             _("I hate these stupid entry fields."),
             _("I am aware of the consequences."),
             _("Please delete this poll.")]

userconfirm = CGI.escapeHTML($cgi["confirm"].strip)
if $cgi.include?("confirmnumber")
 confirm = $cgi["confirmnumber"].to_i
	if userconfirm == QUESTIONS[confirm]
		Dir.chdir("..")

		if $conf.examples.collect{|e| e[:url] }.include?($d.urlsuffix)
			deleteconfirmstr =  _("Example polls cannot be deleted.")
			accidentstr = _("You should never see this text.")
		else
			FileUtils.cp_r($d.urlsuffix, "/tmp/#{$d.urlsuffix}.#{rand(9999999)}")
			FileUtils.rm_r($d.urlsuffix)

			if $cgi.include?("return")
				$d.html.header["status"] = "REDIRECT"
				$d.html.header["Cache-Control"] = "no-cache"
				$d.html.header["Location"] = $conf.siteurl + $cgi["return"]
				$d.out
				exit
			end

			deleteconfirmstr = _("The poll was deleted successfully!")
			accidentstr = _("If this was done by accident, please contact the administrator of the system. The poll can be recovered for an indeterminate amount of time; it could already be too late.")
		end
		nextthingsstr = _("You can now")
		homepagestr = _("Return to Dudle home and schedule a new poll")
		wikipediastr = _("Browse Wikipedia")
		searchstr = _("Search for something on the Internet")

		$d.html << %{
<p class='textcolumn'>
	#{deleteconfirmstr}
</p>
<p class='textcolumn'>
	#{accidentstr}
</p>
<div class='textcolumn'>
	#{nextthingsstr}
	<ul>
		<li><a href='../'>#{homepagestr}</a></li>
		<li><a href='http://wikipedia.org'>#{wikipediastr}</a></li>
		<li><a href='https://duckduckgo.com'>#{searchstr}</a></li>
	</ul>
</div>
		}
		$d.out
		exit
	else
		hint = %{
<table style='background:lightgray'>
	<tr>
		<td style='text-align:right'>
}
		hint += _("To delete the poll, you have to type:")
		hint += %{
		</td>
		<td class='warning' style='text-align:left'>#{QUESTIONS[confirm]}</td>
	</tr>
	<tr>
		<td style='text-align:right'>
}
		hint += _("but you typed:")
		hint += %{
		</td>
		<td class='warning' style='text-align:left'>#{userconfirm}</td>
	</tr>
</table>
}
	end
else
	confirm = rand(QUESTIONS.size()-1) +1
end

$d.html << "<h2>" + _("Delete this poll") + "</h2>"
$d.html << _("You want to delete the poll named") + " <b>#{CGI.escapeHTML($d.table.name)}</b>.<br />"
$d.html << _("This is an irreversible action!") + "<br />"
$d.html << _("If you are sure that you want to permanently remove this poll, please type “%{question}” into the form.") % {:question => QUESTIONS[confirm]}
deletestr = _("Delete")
$d.html << %{
	#{hint}
	<form method='post' action='' accept-charset='utf-8'>
		<div>
			<input type='hidden' name='confirmnumber' value="#{confirm}" />
			<input size='30' type='text' name='confirm' value="#{userconfirm}" />
			<input type='submit' value="#{deletestr}" />
		</div>
	</form>
}

$d.out

end
