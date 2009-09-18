################################
# Author:  Benjamin Kellermann #
# License: CC-by-sa 3.0        #
#          see License         #
################################

require "date"
require "poll"
require "time"

class TimePoll < Poll
	def sort_data fields
		datefields = fields.collect{|field| 
			field == "timestamp" || field == "name" ? field : Time.parse(field) 
		}
		super datefields
	end 
	# returns a sorted array, containing the big units and how often each small is in the big one
	# small and big must be formated for strftime
	# ex: head_count("%Y-%m", "-%d") returns an array like [["2009-03",2],["2009-04",3]]
	def head_count(big,small)
		ret = Hash.new(0)
		@head.keys.collect{|curdate|
			Time.parse(curdate.strftime(big + small))
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
			ret += "<th colspan='#{count}'>#{Date.parse(title).strftime("%a, %d")}</th>\n"
		}
		ret += "</tr><tr><th><a href='?sort=name'>Name</a></th>"
		@head.keys.sort.each{|curdate|
			ret += "<th><a title='#{curdate}' href='?sort=#{CGI.escapeHTML(CGI.escape(curdate.to_s))}'>#{curdate.strftime("%H:%M")}</a></th>\n"
		}
		ret += "<th><a href='.'>Last Edit</a></th></tr>\n"
		ret
	end

	def add_remove_column_htmlform
		if $cgi.include?("add_remove_column_month")
			if $cgi.params["add_remove_column_month"].size == 1
				startdate = Date.parse("#{$cgi["add_remove_column_month"]}-1")
			else
				olddate = $cgi.params["add_remove_column_month"][1]
				case $cgi.params["add_remove_column_month"][0]
				when CGI.unescapeHTML(YEARBACK)
					startdate = Date.parse("#{olddate}-1")-365
				when CGI.unescapeHTML(MONTHBACK)
					startdate = Date.parse("#{olddate}-1")-1
				when CGI.unescapeHTML(MONTHFORWARD)
					startdate = Date.parse("#{olddate}-1")+31
				when CGI.unescapeHTML(YEARFORWARD)
					startdate = Date.parse("#{olddate}-1")+366
				else
					exit
				end
				startdate = Date.parse("#{startdate.year}-#{startdate.month}-1")
			end
		else
			startdate = Date.parse("#{Date.today.year}-#{Date.today.month}-1")
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
			klasse = "choosen" if @head.keys.collect{|t|t.strftime("%Y-%m-%d")}.include?(d.strftime("%Y-%m-%d"))
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
			ret += "<th>#{Date.parse(title).strftime("%a, %d")}</th>\n"
		}

		ret += "</tr>"


		days = @head.sort.collect{|day,descr| 
				Date.parse(day.strftime("%Y-%m-%d"))
			}.uniq
		
		@head.keys.collect{|time|
			time.strftime("%H:%M")
		}.uniq.sort.each{|time|
			ret +="<tr>\n"
			days.each{|date|
				timestamp = Time.parse("#{date} #{time}")
				klasse = "notchoosen"
				klasse = "disabled" if timestamp < Time.now
				klasse = "choosen" if @head.include?(timestamp)
				ret += <<END
<td class='calendarday'>
	<form method='post' action="config.cgi">
		<div>
			<!--Timestamp: #{timestamp} -->
			<input title='#{timestamp}' class='#{klasse}' type='submit' name='add_remove_column' value='#{time}' />
			<input type='hidden' name='add_remove_column_day' value='#{timestamp.day}' />
			<input type='hidden' name='add_remove_column_month' value='#{timestamp.strftime("%Y-%m")}' />
		</div>
	</form>
</td>
END
			}
			ret += "</tr>\n"
		}

		ret += "<tr>"
		days.each{|d|
			ret += <<END
	<td>
		<form method='post' action='config.cgi'>
			<div>
				<input type='hidden' name='add_remove_column_day' value='#{d.day}' />
				<input type='hidden' name='add_remove_column_month' value='#{d.strftime("%Y-%m")}' />
				<input name='add_remove_column' type="text" maxlength="7" style="width: 5ex" /><br />
				<input name="add_remove_column" type="submit" value="Add" style="width: 100%" />
			</div>
		</form>
	</td>
END
		}

		ret += <<END
		</tr>
	</table>
</div>
END
		ret
	end
	def add_remove_column col,description
		if $cgi.include?("add_remove_column_day")
			begin
				parsed_date = YAML::load(Time.parse("#{$cgi["add_remove_column_month"]}-#{$cgi["add_remove_column_day"]} #{col}").to_yaml)
			rescue ArgumentError
				return false
			end
		else
			begin
				earlytime = @head.keys.collect{|t|t.strftime("%H:%M")}.sort[0]
				parsed_date = YAML::load(Time.parse("#{$cgi["add_remove_column_month"]}-#{col} #{earlytime}").to_yaml)
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
class TimePoll
	def store comment
	end
end

SITE="gbfuaibe"

require "cgi"
CGI_PARAMS={"add_remove_column_month" => ["2008-02"]}
CGI_COOKIES={}	
$cgi = CGI.new

class TimePollTest < Test::Unit::TestCase
	def setup
		@poll = TimePoll.new(SITE)
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
