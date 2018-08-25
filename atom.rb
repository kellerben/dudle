#!/usr/bin/env ruby

############################################################################
# Copyright 2009,2010 Benjamin Kellermann                                  #
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

require "rubygems"
require "atom"
require "yaml"
require "cgi"
require "time"

$cgi = CGI.new


feed = Atom::Feed.new 
olddir = File.expand_path(".")
Dir.chdir("..")
def _(string)
	string
end
require_relative "config_defaults"
require_relative "poll"
Dir.chdir(olddir)

poll = YAML::load_file("data.yaml")

feed.title = poll.name
feed.id = "urn:dudle:#{poll.class}:#{poll.name}"
feed.updated = File.new("data.yaml").mtime
feed.authors << Atom::Person.new(:name => 'dudle automatic notificator')
feed.links << Atom::Link.new(:href => $conf.siteurl + "atom.cgi", :rel => "self")

log = VCS.history
log.reverse_each {|l|	
	feed.entries << Atom::Entry.new do |e|	
		e.title = l.comment
#		e.content = Atom::Content::Xhtml.new("<p><a href=\"#{$conf.siteurl}history.cgi?revision=#{l.rev}\">permalink</a>, <a href='#{$conf.siteurl}' >current version</a></p>")
		e.links << Atom::Link.new(:href => "#{$conf.siteurl}history.cgi?revision=#{l.rev}")
		e.id = "urn:#{poll.class}:#{poll.name}:rev=#{l.rev}"
		e.updated = l.timestamp
	end
}


$cgi.out("type" => "application/atom+xml"){ feed.to_xml }
