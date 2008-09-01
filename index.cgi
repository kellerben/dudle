#!/usr/bin/env ruby
load "/home/ben/src/lib.rb/pphtml.rb"
require "yaml"
require "cgi"
require "pp"
require "date"

class Poll
	attr_reader :head
	def initialize 
		@head = []
		@data = {}
		@comment = []
	end
	def head_to_html
		ret = "<tr><td></td>\n"
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
		ret += "</tr>\n"
		ret
	end
	def add_remove_column_htmlform
		return <<END
<div id='add_remove_column'>
<fieldset><legend>add/remove column</legend>
<form method='post' action=''>
<div>
<input size='16' type='text' value='#{$cgi["__add_remove_column"]}' name='__add_remove_column' />
<input type='hidden' name='#{SITE}' />
<input type='submit' value='add/remove column' />
</div>
</form>
</fieldset>
</div>
END
	end
	def to_html
		ret = "<div id='polltable'>\n"
		ret += "<form method='post' action=''>\n"
		ret += "<table border='1'>\n"

		ret += head_to_html

		@data.sort{|x,y| x[1]["timestamp"] <=> y[1]["timestamp"]}.each{|participant,poll|
			ret += "<tr>\n"
			ret += "<td class='name'>#{participant}</td>\n"
			@head.each{|columntitle|
				klasse = poll[columntitle].nil? ? "undecided" : poll[columntitle]
				value = poll[columntitle].nil? ? "?" : ( poll[columntitle] ? CGI.escapeHTML('✔') : CGI.escapeHTML('✘')) 
				ret += "<td class='#{klasse}' title='#{participant}: #{columntitle}'>#{value}</td>\n"
			}
			ret += "<td class='date'>#{poll['timestamp'].strftime('%d.%m, %H:%M')}</td>"
			ret += "</tr>\n"
		}
		
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
			@data[name][columntitle] = agreed.include?(columntitle.to_s)
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
		true
	end
end
class DatePoll < Poll
	def head_to_html
		ret = "<tr><td></td>\n"
		monthhead = Hash.new(0)
		@head.each{|curdate|
			monthhead["#{curdate.year}-#{curdate.mon.to_s.rjust(2,"0")} "] += 1
		}
		monthhead.sort.each{|title,count|
			year, month = title.split("-").collect{|e| e.to_i}
			ret += "<th colspan='#{count}'>#{Date::ABBR_MONTHNAMES[month]} #{year}</th>\n"
		}
		ret += "</tr><tr><td></td>\n"
		@head.each{|curdate|
			ret += "<th>#{Date::ABBR_DAYNAMES[curdate.wday]}, #{curdate.day}</th>\n"
		}
		ret += "<th>Last Edit</th>\n"
		ret += "</tr>\n"
		ret	
	end
	def add_remove_column_htmlform
		if $cgi.include?("__add_remove_column_month")
			begin
				startdate = Date.parse("#{$cgi["__add_remove_column_month"]}-1")
			rescue ArgumentError
				olddate =  $cgi.params["__add_remove_column_month"][1]
				case $cgi["__add_remove_column_month"]
				when "<<"
					startdate = Date.parse("#{olddate}-1")-365
				when "<"
					startdate = Date.parse("#{olddate}-1")-1
				when ">"
					startdate = Date.parse("#{olddate}-1")+31
				when ">>"
					startdate = Date.parse("#{olddate}-1")+366
				end
				startdate = Date.parse("#{startdate.year}-#{startdate.month}-1")
			end
		else
			startdate = Date.parse("#{Date.today.year}-#{Date.today.month}-1")
		end
		ret = <<END
<div id='add_remove_column'>
<fieldset><legend>add/remove column</legend>
<form method='post' action=''>
<div>
<input type='hidden' name='#{SITE}' />
<table><tr>
END
		def navi val
			"<th style='padding:0px'>" +
				"<input class='navigation' type='submit' name='__add_remove_column_month' value='#{val}' /></th>"
		end
		["&lt;&lt;","&lt;"].each{|val| ret += navi(val)}
		ret += "<th colspan=3>#{Date::ABBR_MONTHNAMES[startdate.month]} #{startdate.year}</th>"
		["&gt;","&gt;&gt;"].each{|val| ret += navi(val)}
		
		ret += "</tr><tr>\n"

		7.times{|i| ret += "<th>#{Date::ABBR_DAYNAMES[(i+1)%7]}</th>" }
		ret += "</tr><tr>\n"
		
		(startdate.wday-1).times{
			ret += "<td></td>"
		}
		d = startdate
		while (d.month == startdate.month) do
			klasse = "notchoosen"
			klasse = "disabled" if d < Date.today
			klasse = "choosen" if @head.include?(d)
			ret += "<td class='calendarday'><input class='#{klasse}' type='submit' name='__add_remove_column' value='#{d.day}' /></td>\n"
			ret += "<tr></tr>\n" if d.wday == 0
			d = d.next
		end
		ret += <<END
</tr></table>
<input type='hidden' name='__add_remove_column_month' value='#{startdate.strftime("%Y-%m")}' />
</div>
</form>
</fieldset>
</div>
END
		ret
	end
	def add_remove_column name
		begin
			parsed_name = Date.parse("#{$cgi["__add_remove_column_month"]}-#{name}")
		rescue ArgumentError
			return false
		end
		add_remove_parsed_column parsed_name
	end
end

if __FILE__ == $0

#Content-type: application/xhtml+xml; charset=utf-8
puts <<HEAD
Content-type: text/html; charset=utf-8

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
HEAD

$cgi = CGI.new
$cgi.params.each_pair{|k,v|
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
 <meta http-equiv="Content-Style-Type" content="text/css" />
 <title>dudle - #{SITE}</title>
	<link rel="stylesheet" type="text/css" href="dudle.css" />
</head>
<body>
<h1>#{SITE}</h1>
HEAD
	unless File.exist?(SITE + ".yaml" ) and table = YAML::load_file(SITE + ".yaml")
		if $cgi["__type"] == "date"
			table = DatePoll.new
		else
			table = Poll.new
		end
	end

	table.add_participant($cgi["__add_participant"],$cgi.params["__add_participant_checked"]) if $cgi.include?("__add_participant")

	table.delete($cgi["__delete"])	if $cgi.include?("__delete")
	
	if $cgi.include?("__add_remove_column")
		puts "Could not add/remove column #{$cgi["__add_remove_column"]}" unless table.add_remove_column($cgi["__add_remove_column"])
	end

	table.add_comment($cgi["__commentname"],$cgi.params["__comment"][0]) if $cgi.include?("__comment")

	puts table.to_html
	
	puts "<fieldset><legend>Hint</legend>"
	puts "To change a line, add a new person with the same name!"
	puts "</fieldset>"

	puts "<div id='delete'>"
	puts "<fieldset><legend>delete</legend>"
	puts "<form method='post' action=''>\n"
	puts "<div>"
	puts "<input size='16' value='#{$cgi["__delete"]}' type='text' name='__delete' />"
	puts "<input type='hidden' name='#{SITE}' />"
	puts "<input type='submit' value='delete' />"
	puts "</div>"
	puts "</form>"
	puts "</fieldset>"
	puts "</div>"
	
	puts table.add_remove_column_htmlform
	
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
