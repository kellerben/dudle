################################
# Author:  Benjamin Kellermann #
# License: CC-by-sa 3.0        #
#          see License         #
################################

class TimePollHead 
	def initialize
		@data = {}
	end
	def col_size
		@data.size
	end

	def get_id(columntitle)
		return columntitle.to_s if @data.include?(columntitle)
		raise("no such column found: #{columntitle}")
	end
	def get_title(columnid)
		return columnid if @data.include?(Date.parse(columnid))
		raise("no such id found: #{columnid}")
	end
	def each_columntitle
		@data.sort.each{|k,v|
			yield(k)
		}
	end
	def each_columnid
		@data.sort.each{|k,v|
			yield(get_id(k))
		}
	end
	def each_column
		@data.sort.each{|k,v|
			yield(get_id(k),k)
		}
	end

	# returns internal representation of cgi-string
	def cgi_to_id(field)
		Date.parse(field)
	end

	# returns true if deletion sucessfull
	def delete_column(columnid)
		@data.delete(cgi_to_id(columnid)) != nil
	end

	# columnid should be never used as changing title is not usefull here
	# returns parsed title
	def edit_column(columnid, newtitle, cgi)
		parsed_date = Date.parse(newtitle)
		if @data.include?(parsed_date)
			@data.delete(parsed_date)
		else
			@data[parsed_date] = ""
		end
		parsed_date.to_s
	end

	def to_html(config = false,activecolumn = nil)
		# returns a sorted array, containing the big units and how often each small is in the big one
		# small and big must be formated for strftime
		# ex: head_count("%Y-%m", "-%d") returns an array like [["2009-03",2],["2009-04",3]]
		def head_count(big,small)
			ret = Hash.new(0)
			@data.keys.collect{|curdate|
				Time.parse(curdate.strftime(big + small))
			}.uniq.each{|day|
				ret[day.strftime(big)] += 1
			}
			ret.sort
		end
		ret = "<tr><td></td>"
		head_count("%Y-%m","-%d %H:%M%Z").each{|title,count|
			year, month = title.split("-").collect{|e| e.to_i}
			ret += "<th colspan='#{count}'>#{Date::ABBR_MONTHNAMES[month]} #{year}</th>\n"
		}

		ret += "</tr><tr><th><a href='?sort=name'>Name</a></th>"
		@data.keys.sort.each{|curdate|
			ret += "<th><a title='#{curdate}' href='?sort=#{curdate.to_s}'>#{curdate.strftime("%a, %d")}</a></th>\n"
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
<fieldset><legend>Add/Remove Column</legend>
<div style="float: left; margin-right: 20px">
<table><tr>
END
		def navi val,curmonth
			return <<END
			<th style='padding:0px'>
				<form method='post' action=''>
					<div>
						<input class='navigation' type='submit' name='add_remove_column_month' value='#{val}' />
						<input type='hidden' name='add_remove_column_month' value='#{curmonth.strftime("%Y-%m")}' />
					</div>
				</form>
			</th>
END
		end
		[YEARBACK,MONTHBACK].each{|val| ret += navi(val,startdate)}
		ret += "<th colspan='3'>#{startdate.strftime("%b %Y")}</th>"
		[MONTHFORWARD, YEARFORWARD].each{|val| ret += navi(val,startdate)}
		 
		ret += "</tr><tr>\n"

		7.times{|i| ret += "<th class='weekday'>#{Date::ABBR_DAYNAMES[(i+1)%7]}</th>" }
		ret += "</tr><tr>\n"
		
		((startdate.wday+7-1)%7).times{
			ret += "<td></td>"
		}
		d = startdate
		while (d.month == startdate.month) do
			klasse = "notchoosen"
			varname = "new_columnname"
			klasse = "disabled" if d < Date.today
			if @data.include?(d)
				klasse = "choosen"
				varname = "deletecolumn"
			end
			ret += <<TD
<td class='calendarday'>
	<form method='post' action=''>
		<div>
			<input class='#{klasse}' type='submit' value='#{d.day}' />
			<input type='hidden' name='#{varname}' value='#{startdate.strftime("%Y-%m")}-#{d.day}' />
		</div>
	</form>
</td>
TD
			ret += "</tr><tr>\n" if d.wday == 0
			d = d.next
		end
		ret += <<END
</tr></table>
</div>
</fieldset>
END
		ret
	end
end
