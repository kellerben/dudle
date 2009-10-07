################################
# Author:  Benjamin Kellermann #
# License: CC-by-sa 3.0        #
#          see License         #
################################

require "date"
require "poll"

class DatePoll < Poll
	def sort_data fields
		datefields = fields.collect{|field| 
			field == "timestamp" || field == "name" ? field : Date.parse(field) 
		}
		super datefields
	end 
	def head_to_html(config = false, activecolumn = nil)
		ret = "<tr><td></td>\n"
		monthhead = Hash.new(0)
		@head.sort.each{|curdate,curdescription|
			monthhead["#{curdate.year}-#{curdate.mon.to_s.rjust(2,"0")} "] += 1
		}
		monthhead.sort.each{|title,count|
			year, month = title.split("-").collect{|e| e.to_i}
			ret += "<th colspan='#{count}'>#{Date::ABBR_MONTHNAMES[month]} #{year}</th>\n"
		}
		ret += "</tr><tr><th><a href='?sort=name'>Name</a></th>\n"
		@head.sort.each{|curdate,curdescription|
			ret += "<th><a href='?sort=#{curdate.to_s}'>#{Date::ABBR_DAYNAMES[curdate.wday]}, #{curdate.day}</a></th>\n"
		}
		ret += "<th><a href='.'>Last Edit</a></th>\n</tr>\n"
		ret
	end

	def edit_column_htmlform(activecolumn)
		if $cgi.include?("add_remove_column_month")
			if $cgi.params["add_remove_column_month"].size == 1
				startdate = Date.parse("#{$cgi["add_remove_column_month"]}-1")
			else
				olddate = $cgi.params["add_remove_column_month"][1]
				case $cgi["add_remove_column_month"]
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
<fieldset><legend>add/remove column</legend>
<form method='post' action=''>
<div>
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

		7.times{|i| ret += "<th>#{Date::ABBR_DAYNAMES[(i+1)%7]}</th>" }
		ret += "</tr><tr>\n"
		
		((startdate.wday+7-1)%7).times{
			ret += "<td></td>"
		}
		d = startdate
		while (d.month == startdate.month) do
			klasse = "notchoosen"
			klasse = "disabled" if d < Date.today
			klasse = "choosen" if @head.include?(d)
			ret += "<td class='calendarday'><input class='#{klasse}' type='submit' name='edit_column' value='#{d.day}' /></td>\n"
			ret += "</tr><tr>\n" if d.wday == 0
			d = d.next
		end
		ret += <<END
</tr></table>
<input type='hidden' name='add_remove_column_month' value='#{startdate.strftime("%Y-%m")}' />
</div>
</form>
</fieldset>
END
		ret
	end
	def parsecolumntitle(title)
		Date.parse("#{$cgi["add_remove_column_month"]}-#{title}")
	end
	def edit_column(newtitle, description, oldtitle = nil)
		parsed_date = parsecolumntitle(newtitle)
		if @head.include?(parsed_date)
			delete_column(newtitle)
		else
			@head[parsed_date] = ""
			store "Column #{parsed_date} added"
		end
		true
	end
end

