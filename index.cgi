#!/usr/bin/env ruby
require "yaml"
require "cgi"
require "pp"

class Poll
	attr_reader :head
	def initialize 
		@head = []
		@data = {}
		@comment = []
	end
	def head_to_html
		ret = "<td></td>\n"
		@head.each{|columntitle|
			ret += "<th>#{columntitle}</th>\n"
		}
		ret += "<th>Last Edit</th>\n"
#		ret += "<th>"
#		ret += "<form method='post' action=''>\n"
#		ret += "<div>"
#		ret += "<input size='16' type='text' name='__add_participant' />\n"
#		ret += "<input type='hidden' name='#{SITE}' /><input type='submit' value='add/edit' />\n"
#		ret += "</div>"
#		ret += "</form>\n"
#		ret += "</th>\n"
		ret
	end
	def to_html
		ret = "<div id='polltable'>\n"
		ret += "<form method='post' action=''>\n"
		ret += "<table border='1'><tr>\n"

		ret += head_to_html

		@data.sort{|x,y| x[1]["timestamp"] <=> y[1]["timestamp"]}.each{|participant,poll|
			ret += "</tr><tr>\n"
			ret += "<td class='name'>#{participant}</td>\n"
			@head.each{|columntitle|
				klasse = poll[columntitle].nil? ? "undecided" : poll[columntitle]
				value = poll[columntitle].nil? ? "?" : ( poll[columntitle] ? CGI.escapeHTML('✔') : CGI.escapeHTML('✘')) 
				ret += "<td class='#{klasse}' title='#{participant}: #{columntitle}'>#{value}</td>\n"
			}
			ret += "<td class='date'>#{poll['timestamp'].strftime('%d.%m, %H:%M')}</td>"
		}
		
		ret += "</tr>\n"
		ret += "<tr>\n"
		ret += "<td class='name'><input size='16' type='text' name='__add_participant' /></td>\n"
		@head.each{|columntitle|
			ret += "<td class='checkboxes'><input type='checkbox' value='#{columntitle}' name='__add_participant_checked' title='#{columntitle}' /></td>\n"
		}
		ret += "<td class='checkboxes'><input type='hidden' name='#{SITE}' /><input type='submit' value='add/edit' /></td>\n"

		ret += "</tr>\n"
		ret += "<tr><td class='name'>total</td>\n"
		@head.each{|columntitle|
			yes = 0
			undecided = 0
			@data.each_value{|participant|
				if participant[columntitle]
					yes += 1
				elsif !participant.has_key?(columntitle)
					undecided += 1
				end
			}

			if @data.empty?
				percent_f = 0
			else
				percent_f = 100*yes/@data.size
			end
			percent = "#{percent_f}#{CGI.escapeHTML("%")}" unless @data.empty?
			if undecided > 0
				percent += "-#{(100.0*(undecided+yes)/@data.size).round}#{CGI.escapeHTML("%")}"
			end

			ret += "<td class='sum' title='#{percent}' style='"
			["","background-"].each {|c|
				ret += "#{c}color: rgb("
				3.times{ 
					ret += (c == "" ? "#{155+percent_f}" : "#{100-percent_f}")
					ret += ","
				}
				ret.chop!
				ret += ");"
			}
			ret += "'>#{yes}</td>\n"
		}

		ret += "</tr>"
		ret += "</table>\n"
		ret += "</form>\n"
		ret += "</div>"
		
		ret += "<div id='comments'>"
		unless @comment.empty?
			ret	+= "<fieldset><legend>Comments</legend>"
			@comment.each{|time,name,comment|
				ret	+= "<fieldset><legend>#{name} said on #{time.strftime("%d.%m, %H:%M")}</legend>"
				ret += comment
				ret += "</fieldset>"
			}
			ret += "</fieldset>"
		end

		ret += "</div>\n"
		ret
	end
	def add_participant(name, agreed)
		name = CGI.escapeHTML(name.strip)
		@data[name] = {"timestamp" => Time.now}
		@head.each{|columntitle|
			@data[name][columntitle] = agreed.include?(columntitle)
		}
		store
	end
	def delete(name)
		@data.delete(CGI.escapeHTML(name.strip))
		store
	end
	def store
		File.open("#{SITE}.yaml", 'w') do |out|
			out << "# This is a dudle poll file\n"
			out << self.to_yaml
		end
	end
	def add_comment name, comment
		@comment << [Time.now, CGI.escapeHTML(name), CGI.escapeHTML(comment)]
		store
	end
	def add_remove_column name
		add_remove_parsed_column CGI.escapeHTML(name.strip)
	end
	def add_remove_parsed_column name
		columntitle = name
		if @head.include?(columntitle)
			@head.delete(columntitle)
		else
			@head << columntitle
			@head.sort!
		end
		store
	end
end
class DatePoll < Poll
end

if __FILE__ == $0

#Content-type: application/xhtml+xml; charset=utf-8
puts <<HEAD
Content-type: text/html; charset=utf-8

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
HEAD

cgi = CGI.new
cgi.params.each_pair{|k,v|
	if "" == v[0].to_s && !(k =~ /^__/)
		if defined?(SITE)
			puts "FEHLER, meld dich bei Ben!"
			exit
		else
			SITE = k
		end
	end
}

if defined?(SITE)
	puts <<HEAD
<head>
	<title>dudle - #{SITE}</title>
	<link rel="stylesheet" type="text/css" href="dudle.css" />
</head>
<body>
<h1>#{SITE}</h1>
HEAD
	unless File.exist?(SITE + ".yaml" ) and table = YAML::load_file(SITE + ".yaml")
		table = Poll.new 
	end

	table.add_participant(cgi["__add_participant"],cgi.params["__add_participant_checked"]) if cgi.include?("__add_participant")

	table.delete(cgi["__delete"])	if cgi.include?("__delete")
	
	table.add_remove_column(cgi["__add_remove_column"])	if cgi.include?("__add_remove_column")

	table.add_comment(cgi["__commentname"],cgi.params["__comment"][0]) if cgi.include?("__comment")

	puts table.to_html
	
	puts "<fieldset><legend>Hint</legend>"
	puts "To change a line, add a new person with the same name!"
	puts "</fieldset>"

	puts "<div id='delete'>"
	puts "<fieldset><legend>delete</legend>"
	puts "<form method='post' action=''>\n"
	puts "<div>"
	puts "<input size='16' type='text' name='__delete' />"
	puts "<input type='hidden' name='#{SITE}' />"
	puts "<input type='submit' value='delete' />"
	puts "</div>"
	puts "</form>"
	puts "</fieldset>"
	puts "</div>"
	
	puts "<div id='add_remove_column'>"
	puts "<fieldset><legend>add/remove column</legend>"
	puts "<form method='post' action=''>\n"
	puts "<div>"
	puts "<input size='16' type='text' name='__add_remove_column' />"
	puts "<input type='hidden' name='#{SITE}' />"
	puts "<input type='submit' value='add/remove column' />"
	puts "</div>"
	puts "</form>"
	puts "</fieldset>"
	puts "</div>"
	
	puts "<div id='add_comment'>"
	puts "<fieldset><legend>Comment</legend>"
	puts "<form method='post' action=''>\n"
	puts "<div>"
	puts "<label for='Commentname'>Name: </label><input id='Commentname' value='anonymous' type='text' name='__commentname' /><br />"
	puts "<textarea cols='50' rows='10' name='__comment' ></textarea><br />"
	puts "<input type='hidden' name='#{SITE}' />"
	puts "<input type='submit' value='Submit' />"
	puts "</div>"
	puts "</form>"
	puts "</fieldset>"
	puts "</div>"
else
	
	puts <<HEAD
<head>
	<title>dudle</title>
</head>
<body>
HEAD
	puts "<fieldset><legend>Available Polls</legend>"
	Dir.new(".").collect{|f| 
		f.gsub(/\.yaml$/,'')	if f =~ /\.yaml$/
	}.compact.each{|site|
		puts "<a href='?#{site}'>#{site}</a><br />"
	}
	puts "</fieldset>"
	
	puts "<fieldset><legend>Hint</legend>"
	puts CGI.escapeHTML("To add a poll, go to example.org/?<pollname>")
	puts "</fieldset>"

end

puts "</body></html>"

end
