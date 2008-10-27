#!/usr/bin/env ruby
require "rubygems"
require "atom"
require "yaml"
require "cgi"

cgi = CGI.new

feed = Atom::Feed.new 
if File.exist?("data.yaml")
	olddir = File.expand_path(".")
	Dir.chdir("..")
	require "poll"
	require "datepoll"
	Dir.chdir(olddir)

	poll = YAML::load_file("data.yaml")


	feed.title = poll.name
	feed.id = "urn:dudle:#{poll.class}:#{poll.name}"
	feed.updated = File.new("data.yaml").mtime

	feed.authors << Atom::Person.new(:name => 'dudle automatic notificator')

	log = `export LC_ALL=de_DE.UTF-8; bzr log --forward`.split("-"*60)
	log.collect!{|s| s.scan(/\nrevno:.*\ncommitter.*\n.*\ntimestamp: (.*)\nmessage:\n  (.*)/).flatten}
	log.shift
	log.collect!{|t,c| [DateTime.parse(t),c]}

	log.each_with_index {|l,i|	
		feed.entries << Atom::Entry.new do |e|	
			e.title = l[1]
			e.links << Atom::Link.new(:href => "http://#{cgi.server_name}#{cgi.script_name.gsub(/atom.cgi$/,"")}?revision=#{i+1}")
			e.id = "urn:#{poll.class}:#{poll.name}:rev:#{i+1}"
			e.updated = l[0]
		end
	}

else
	require "poll"
	require "datepoll"
	feed.title = "dudle"
	feed.id = "urn:dudle:main"
	feed.authors << Atom::Person.new(:name => 'dudle automatic notificator')

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
			feed.entries << Atom::Entry.new do |e|	
				e.title = site
				e.links << Atom::Link.new(:href => site)
				e.id = "urn:dudle:main:#{site}"
				e.updated = File.new("#{site}/data.yaml").mtime
			end
		end
	}

end

puts "Content-type: application/atom+xml\n\n" 
puts feed.to_xml
