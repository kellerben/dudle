################################
# Author:  Benjamin Kellermann #
# Licence: CC-by-sa 3.0        #
#          see Licence         #
################################

require "date"
require "poll"
load "time.rb"

class DatePoll < Poll
	def init
		#FIXME: quick 'n' dirty hack, because Time <=> Date is not possible and yaml loads Time instead of DateTime!
		#better solution would be to overwrite <=>
		@head.each{|k,v| 
			if k.class == Time
				@head.delete(k)
				@head[DateTime.parse(k.to_s)]=v
			end
		}
	end
	def sort_data fields
		datefields = fields.collect{|field| 
			field == "timestamp" || field == "name" ? field : DateTime.parse(field) 
		}
		super datefields
	end 
	# returns a sorted array, containing the big units and how often each small is in the big one
	# small and big must be formated for strftime
	# ex: head_count("%Y-%m", "-%d") returns an array like [["2009-03",2],["2009-04",3]]
	def head_count(big,small)
		ret = Hash.new(0)
		@head.keys.collect{|curdate|
			DateTime.parse(curdate.strftime(big + small))
		}.uniq.each{|day|
			ret[day.strftime(big)] += 1
		}
		ret.sort
	end

	def head_to_html(config = false)
		ret = "<tr><td></td>"
		head_count("%Y-%m","-%d %H:%M%Z").each{|title,count|
			year, month = title.split("-").collect{|e| e.to_i}
			ret += "<th colspan='#{count}'>#{Date::ABBR_MONTHNAMES[month]} #{year}</th>\n"
		}
		ret += "</tr><tr><td></td>"
		head_count("%Y-%m-%d", " %H:%M%Z").each{|title,count|
			curdate = Date.parse(title)
			ret += "<th colspan='#{count}'>#{curdate.strftime("%a, %d")}</th>\n"
		}
		ret += "</tr><tr><th><a href='?sort=name'>Name</a></th>"
		@head.keys.sort.each{|curdate|
			if curdate.class == Date
				ret += "<th><a href='?sort=#{curdate.to_s}'>---</a></th>\n"
			else
				ret += "<th><a href='?sort=#{curdate.to_s}'>#{curdate.strftime("%H:%M")}</a></th>\n"
			end
		}
		ret += "<th><a href='.'>Last Edit</a></th></tr>"
		ret
	end
	def add_remove_column_htmlform
		if $cgi.include?("add_remove_column_month")
			begin
				startdate = DateTime.parse("#{$cgi["add_remove_column_month"]}-1")
			rescue ArgumentError
				olddate = $cgi.params["add_remove_column_month"][1]
				case $cgi["add_remove_column_month"]
				when CGI.unescapeHTML(YEARBACK)
					startdate = DateTime.parse("#{olddate}-1")-365
				when CGI.unescapeHTML(MONTHBACK)
					startdate = DateTime.parse("#{olddate}-1")-1
				when CGI.unescapeHTML(MONTHFORWARD)
					startdate = DateTime.parse("#{olddate}-1")+31
				when CGI.unescapeHTML(YEARFORWARD)
					startdate = DateTime.parse("#{olddate}-1")+366
				else
					exit
				end
				startdate = DateTime.parse(startdate.strftime("%Y-%m-1"))
			end
		else
			startdate = DateTime.parse(Date.today.strftime("%Y-%m-1"))
		end
		ret = <<END
<form method='post' action=''>
<div style="float: left; margin-right: 20px">
<table><tr>
END
		def navi val
			"<th style='padding:0px'>" +
				"<input class='navigation' type='submit' name='add_remove_column_month' value='#{val}' />" +
				"</th>"
		end
		[YEARBACK,MONTHBACK].each{|val| ret += navi(val)}
		ret += "<th colspan='3'>#{Date::ABBR_MONTHNAMES[startdate.month]} #{startdate.year}</th>"
		[MONTHFORWARD, YEARFORWARD].each{|val| ret += navi(val)}
		 
		ret += "</tr><tr>\n"

		7.times{|i| ret += "<th class='weekday'>#{Date::ABBR_DAYNAMES[(i+1)%7]}</th>" }
		ret += "</tr><tr>\n"
		
		((startdate.wday+7-1)%7).times{
			ret += "<td></td>"
		}
		d = startdate
		while (d.month == startdate.month) do
			klasse = "notchoosen"
			klasse = "disabled" if d < Date.today
			klasse = "choosen" if @head.include?(d)
			ret += "<td class='calendarday'><input class='#{klasse}' type='submit' name='add_remove_column' value='#{d.day}' /></td>\n"
			ret += "</tr><tr>\n" if d.wday == 0
			d = d.next
		end
		ret += <<END
</tr></table>
<input type='hidden' name='add_remove_column_month' value='#{startdate.strftime("%Y-%m")}' />
</div>
</form>
END
		
		ret += "<div><table><tr>"

		head_count("%Y-%m", "-%d").each{|title,count|
			year,month = title.split("-").collect{|e| e.to_i}
			ret += "<th colspan='#{count}'>#{Date::ABBR_MONTHNAMES[month]} #{year}</th>\n"
		}

		ret += "</tr><tr>"

		head_count("%Y-%m-%d","").each{|title,count|
			curdate = Date.parse(title)
			ret += "<th>#{curdate.strftime("%a, %d")}</th>\n"
		}

		ret += "</tr>"

		["00:00", "10:00","13:00","14:00","20:00"].each{|time|
			ret +="<tr>\n"
			@head.sort.collect{|day,descr| 
				Date.parse(day.strftime("%Y-%m-%d"))
			}.uniq.each{|date|
				timestamp = DateTime.parse("#{date} #{time} #{Time.now.zone}")
				klasse = "notchoosen"
				klasse = "disabled" if timestamp < DateTime.now
				klasse = "choosen" if @head.include?(timestamp)
				ret += <<END
<td class='calendarday'>
	<form method='post' action="config.cgi">
		<div>
			<!--Timestamp: #{timestamp.to_s} -->
			<input class='#{klasse}' type='submit' name='add_remove_column' value='#{time}' />
			<input type='hidden' name='add_remove_column_day' value='#{timestamp.day}' />
			<input type='hidden' name='add_remove_column_month' value='#{timestamp.strftime("%Y-%m")}' />
		</div>
	</form>
</td>
END
			}
			ret += "</tr>\n"
		}
		ret += <<END
	</table>
	<form method='post' action='config.cgi'>
	<div>
		<input name='add_remove_column' size='1' />
		<input name="add_remove_column" type="submit" value="Add Time" />
	</div>
	</form>
</div>
END
		ret
	end
	def add_remove_column col,description
		if $cgi.include?("add_remove_column_day")
			begin
				parsed_date = YAML::load(DateTime.parse("#{$cgi["add_remove_column_month"]}-#{$cgi["add_remove_column_day"]} #{col} #{Time.now.zone}").to_yaml)
				day = Date.parse(parsed_date.to_s)
				@head.delete(day) if @head.include?(day)
			rescue ArgumentError
				return false
			end
		else
			begin
				parsed_date = YAML::load(Date.parse("#{$cgi["add_remove_column_month"]}-#{col}").to_yaml)
			rescue ArgumentError
				return false
			end
		end
		add_remove_parsed_column(parsed_date,CGI.escapeHTML(description))
	end
end

if __FILE__ == $0
require 'test/unit'
require 'pp'
class DatePoll
	def store comment
	end
end

SITE="gbfuaibe"

require "cgi"
CGI_PARAMS={"add_remove_column_month" => ["2008-02"]}
CGI_COOKIES={}	
$cgi = CGI.new

class DatePollTest < Test::Unit::TestCase
	def setup
		@poll = DatePoll.new(SITE)
	end
	#TODO
	def test_add_remove_column
		assert(!@poll.add_remove_column("foo", "bar"))
		assert(!@poll.add_remove_column("31", "31.02.2008 ;--)"))
		assert(@poll.add_remove_column("20", "correct date"))
		assert_equal("correct date",@poll.head[Date.parse("2008-02-20")])
		assert(@poll.add_remove_column("20", "foobar"))
		assert(@poll.head.empty?)
	end

end
end
