#!/usr/bin/env ruby

################################
# Author:  Benjamin Kellermann #
# License: CC-by-sa 3.0        #
#          see License         #
################################

require "rubygems"
require "atom"
require "yaml"
require "cgi"
require "time"

$cgi = CGI.new


feed = Atom::Feed.new 
olddir = File.expand_path(".")
Dir.chdir("..")
load "config.rb"
require "poll"
Dir.chdir(olddir)

poll = YAML::load_file("data.yaml")

feed.title = poll.name
feed.id = "urn:dudle:#{poll.class}:#{poll.name}"
feed.updated = File.new("data.yaml").mtime
feed.authors << Atom::Person.new(:name => 'dudle automatic notificator')
feed.links << Atom::Link.new(:href => SITEURL + "atom.cgi", :rel => "self")

log = VCS.longhistory "."
log.each {|rev,time,comment|	
	feed.entries << Atom::Entry.new do |e|	
		e.title = comment
		e.links << Atom::Link.new(:href => "#{SITEURL}?revision=#{rev}")
		e.id = "urn:#{poll.class}:#{poll.name}:rev=#{rev}"
		e.updated = time
	end
}


$cgi.out("type" => "application/atom+xml"){ feed.to_xml }
