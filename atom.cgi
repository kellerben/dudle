#!/usr/bin/env ruby

################################
# Author:  Benjamin Kellermann #
# Licence: CC-by-sa 3.0        #
#          see Licence         #
################################

require "rubygems"
require "atom"
require "yaml"
require "cgi"
require "time"
load "config.rb"

$cgi = CGI.new

feed = Atom::Feed.new 
load "config.rb"
require "poll"
require "datepoll"
require "timepoll"
feed.title = "dudle"
feed.id = "urn:dudle:main"
feed.authors << Atom::Person.new(:name => 'dudle automatic notificator')
feed.links << Atom::Link.new(:href => SITEURL + "atom.cgi", :rel => "self")

Dir.glob("*/data.yaml").sort_by{|f|
	File.new(f).mtime
}.reverse.collect{|f|
	f.gsub(/\/data\.yaml$/,'')
}.each{|site|
	unless YAML::load_file("#{site}/data.yaml" ).hidden
		unless defined?(firstround)
			firstround = false
			feed.updated = File.new("#{site}/data.yaml").mtime
		end
		
		log = VCS.longhistory(site)
		log.each {|rev,time,comment|
			feed.entries << Atom::Entry.new do |e|
				e.title = site
				e.summary = comment
				e.links << Atom::Link.new(:href => "#{SITEURL}#{site}/?revision=#{rev}")
				e.id = "urn:dudle:main:#{site}:rev=#{rev}"
				e.updated = time
			end
		}
	end
}

$cgi.out("type" => "application/atom+xml"){ feed.to_xml }
