#!/usr/bin/env ruby
load "/home/ben/src/lib.rb/pphtml.rb"
require "yaml"
require "cgi"
require "pp"
require "date"

class Poll
	attr_reader :head
	def initialize 
		@head = {}
		@data = {}
		@comment = []
		store
	end
	def head_to_html
		ret = "<tr><td></td>\n"
		@head.sort.each{|columntitle,columndescription|
			ret += "<th title='#{columndescription}'>#{columntitle}</th>\n"
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
		<label for='columntitle'>Columntitle: </label>
		<input id='columntitle' size='16' type='text' value='#{$cgi["__add_remove_column"]}' name='__add_remove_column' />
		<label for='columndescription'>Description: </label>
		<input id='columndescription' size='30' type='text' value='#{$cgi["__columndescription"]}' name='__columndescription' />
		<input type='hidden' name='#{SITE}' /><input type='submit' value='add/remove column' />
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
			@head.sort.each{|columntitle,columndescription|
				klasse = poll[columntitle].nil? ? "undecided" : poll[columntitle]
				case poll[columntitle]
				when nil
					value = UNKNOWN
				when "yes"
					value = YES
				when "no"
					value = NO
				when "maybe"
					value = MAYBE
				end
				ret += "<td class='#{klasse}' title='#{participant}: #{columntitle}'>#{value}</td>\n"
			}
			ret += "<td class='date'>#{poll['timestamp'].strftime('%d.%m, %H:%M')}</td>"
			ret += "</tr>\n"
		}
		
		ret += "<tr>\n"
		ret += "<td class='name'><input size='16' type='text' name='__add_participant' /></td>\n"
		@head.sort.each{|columntitle,columndescription|
			ret += "<td class='checkboxes'>
			<table><tr>
			<td class='input-yes'>#{YES}</td>
			<td><input type='radio' value='yes' name='__add_participant_checked_#{columntitle}' title='#{columntitle}' /></td>
			</tr><tr>
			<td class='input-no'>#{NO}</td>
			<td><input type='radio' value='no' name='__add_participant_checked_#{columntitle}' title='#{columntitle}' checked='checked' /></td>
			</tr><tr>
			<td class='input-maybe'>#{MAYBE}</td>
			<td><input type='radio' value='maybe' name='__add_participant_checked_#{columntitle}' title='#{columntitle}' /></td>
			</tr></table>
			</td>\n"
		}
		ret += "<td class='checkboxes'><input type='hidden' name='#{SITE}' /><input type='submit' value='add/edit' /></td>\n"

		ret += "</tr>\n"

		ret += "<tr><td class='name'>total</td>\n"
		@head.sort.each{|columntitle,columndescription|
			yes = 0
			undecided = 0
			@data.each_value{|participant|
				if participant[columntitle] == "yes"
					yes += 1
				elsif !participant.has_key?(columntitle) or participant[columntitle] == "maybe"
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
		@head.each_key{|columntitle|
			@data[name][columntitle] = agreed[columntitle.to_s]
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
			out.chmod(0660)
		end
	end
	def add_comment name, comment
		@comment << [Time.now, CGI.escapeHTML(name), CGI.escapeHTML(comment.strip).gsub("\r\n","<br />")]
		store
	end
	def add_remove_column name, description
		add_remove_parsed_column CGI.escapeHTML(name.strip), CGI.escapeHTML(description.strip)
	end
	def add_remove_parsed_column columntitle, description
		if @head.include?(columntitle)
			@head.delete(columntitle)
		else
			@head[columntitle] = description
		end
		store
		true
	end
end
class DatePoll < Poll
	def head_to_html
		ret = "<tr><td></td>\n"
		monthhead = Hash.new(0)
		@head.sort.each{|curdate,curdescription|
			monthhead["#{curdate.year}-#{curdate.mon.to_s.rjust(2,"0")} "] += 1
		}
		monthhead.sort.each{|title,count|
			year, month = title.split("-").collect{|e| e.to_i}
			ret += "<th colspan='#{count}'>#{Date::ABBR_MONTHNAMES[month]} #{year}</th>\n"
		}
		ret += "</tr><tr><td></td>\n"
		@head.sort.each{|curdate,curdescription|
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
		ret += "<th colspan='3'>#{Date::ABBR_MONTHNAMES[startdate.month]} #{startdate.year}</th>"
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
			ret += "</tr><tr>\n" if d.wday == 0
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
	def add_remove_column name,description
		begin
			parsed_name = Date.parse("#{$cgi["__add_remove_column_month"]}-#{name}")
		rescue ArgumentError
			return false
		end
		add_remove_parsed_column(parsed_name,CGI.escapeHTML(description))
	end
end

if __FILE__ == $0

$cgi = CGI.new

CONTENTTYPE = "text/html; charset=utf-8"
#CONTENTTYPE = "application/xhtml+xml; charset=utf-8"

puts "Content-type: #{CONTENTTYPE}"

if $cgi.include?("__utf") || $cgi.cookies["utf"][0]
	puts "Set-Cookie: utf=true; path=; expires=#{(Time.now+1*60*60*24*365).getgm.strftime("%a, %d %b %Y %H:%M:%S %Z")}"
	YES     = CGI.escapeHTML('✔')
	NO      = CGI.escapeHTML('✘')
	MAYBE   = CGI.escapeHTML('?')
	UNKNOWN = CGI.escapeHTML("-")
	BACK    = CGI.escapeHTML("↩")
else
	YES     = CGI.escapeHTML('OK')
	NO      = CGI.escapeHTML('NO')
	MAYBE   = CGI.escapeHTML('?')
	UNKNOWN = CGI.escapeHTML("-")
	BACK    = CGI.escapeHTML("<-")
end

puts <<HEAD

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
HEAD

$cgi.params.each{|k,v|
	if "" == v[0].to_s && !(k =~ /^__/)
		if defined?(SITE)
			puts "FEHLER, meld dich bei Ben!"
			exit
		else
			SITE = k
		end
	end
}



if defined?(SITE) and File.exist?(SITE + ".yaml" ) and table = YAML::load_file(SITE + ".yaml")
	puts <<HEAD
<head>
	<meta http-equiv="Content-Type" content="#{CONTENTTYPE}" /> 
	<meta http-equiv="Content-Style-Type" content="text/css" />
 <title>dudle - #{SITE}</title>
	<link rel="stylesheet" type="text/css" href="dudle.css" />
</head>
<body>
<div>
	<a href='.' style='text-decoration:none'>#{BACK}</a>
</div>
<h1>#{SITE}</h1>
HEAD
	
	if $cgi.include?("__add_participant")
		agreed = {}
		$cgi.params.each{|k,v|
			if k =~ /^__add_participant_checked_/
				agreed[k.gsub(/^__add_participant_checked_/,"")] = v[0]
			end
		}

		table.add_participant($cgi["__add_participant"],agreed)
	end

	table.delete($cgi["__delete"])	if $cgi.include?("__delete")
	
	if $cgi.include?("__add_remove_column")
		puts "Could not add/remove column #{$cgi["__add_remove_column"]}" unless table.add_remove_column($cgi["__add_remove_column"],$cgi["__columndescription"])
	end

	table.add_comment($cgi["__commentname"],$cgi.params["__comment"][0]) if $cgi.include?("__comment")

	puts table.to_html
	
	puts "<fieldset><legend>Hint</legend>"
	puts "To change a line, add a new person with the same name!"
	puts "</fieldset>"

	puts "<div id='delete'>"
	puts "<fieldset><legend>delete participant</legend>"
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
	
	if defined?($cgi["__create_poll"])
		SITE=$cgi["__create_poll"]
		case $cgi["__poll_type"]
		when "Poll"
			Poll.new
		when "DatePoll"
			DatePoll.new
		end
	end

	puts <<HEAD
<head>
	<title>dudle</title>
</head>
<body>
HEAD
	puts "<fieldset><legend>Available Polls</legend>"
	puts "<table><tr><th>Poll</th><th>Last change</th></tr>"
	Dir.glob("*.yaml").sort_by{|f|
		File.new(f).mtime
	}.reverse.collect{|f| 
		f.gsub(/\.yaml$/,'')
	}.each{|site|
		puts "<tr>"
		puts "<td class='site'><a href='?#{site}'>#{site}</a></td>"
		puts "<td class='mtime'>#{File.new(site + ".yaml").mtime.strftime('%d.%m, %H:%M')}</td>"
		puts "</tr>"
	}
	puts "</table>"
	puts "</fieldset>"

	puts <<CREATE
<fieldset><legend>Create new Poll</legend>
<form method='post' action=''><div>
	<input size='16' type='text' name='__create_poll' value='#{$cgi["__create_poll"]}' />
	<select name="__poll_type">
	<option value="Poll" selected="selected">normal</option>
	<option value="DatePoll">date</option>
	</select>
<input type='submit' value='create' />
</div></form>
</fieldset>
CREATE

end

puts "</body></html>"

end
