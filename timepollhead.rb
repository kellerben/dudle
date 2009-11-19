################################
# Author:  Benjamin Kellermann #
# License: CC-by-sa 3.0        #
#          see License         #
################################

class TimePollHead 
	class TimeString
		attr_reader :date, :time
		def initialize(date,time)
			@date = date.class == Date ? date : Date.parse(date)
			if time =~ /^\d[\d]?:\d[\d]?$/
				@time = Time.parse("#{@date} #{time}")
			else
				@time = time
			end
		end
		def TimeString.now
			TimeString.new(Date.today,Time.now)
		end
		include Comparable
		def <=>(other)
			if self.date == other.date
				if self.time.class == String && other.time.class == String || self.time.class == Time && other.time.class == Time
					self.time <=> other.time
				elsif self.time.class == NilClass && other.time.class == NilClass
					0
				else
					self.time.class == String ? -1 : 1
				end
			else
				self.date <=> other.date
			end
		end
		def to_s
			if @time
				"#{@date} #{time_to_s}"
			else
				@date.to_s
			end
		end
		def inspect
			"TS: date: #{@date} time: #{@time ? time_to_s : "nil"}"
		end
		def time_to_s
			if @time.class == Time
				return time.strftime("%H:%M")
			else
				return @time
			end
		end
	end
	def initialize
		@data = []
	end
	def col_size
		@data.size
	end
	def get_id(columntitle)
		columntitle
	end
	def get_title(columnid)
		columnid
	end
	def each_columntitle
		@data.sort.each{|day,time|
			yield("#{day} #{time}")
		}
	end
	def each_columnid
		@data.sort.each{|day,time|
			yield("#{day} #{time}")
		}
	end
	def each_column
		@data.sort.each{|day,time|
			yield("#{day} #{time}","#{day} #{time}")
		}
	end
	def each_time
		h = {}
		@data.each{|ds| h[ds.time_to_s] = true }
		h.keys.compact.sort{|a,b|
			TimeString.new(Date.today,a) <=> TimeString.new(Date.today,b)
		}.each{|k| yield(k)}
	end
	def date_included?(date)
		ret = false
		@data.each{|ds|
			ret = ret || ds.date == date
		}
		ret
	end

	# returns internal representation of cgi-string
	def cgi_to_id(field)
		date = field.scan(/^(\d\d\d\d-\d\d-\d\d).*$/).flatten[0]
		time = field.scan(/^\d\d\d\d-\d\d-\d\d (.*)$/).flatten[0]
		TimeString.new(date,time)
	end

	# returns true if deletion sucessfull
	def delete_column(columnid)
		@data.delete(cgi_to_id(columnid)) != nil
	end

	def parsecolumntitle(title)
		if $cgi.include?("add_remove_column_day")
			parsed_date = YAML::load(Time.parse("#{$cgi["add_remove_column_month"]}-#{$cgi["add_remove_column_day"]} #{title}").to_yaml)
		else
			earlytime = @head.keys.collect{|t|t.strftime("%H:%M")}.sort[0]
			parsed_date = YAML::load(Time.parse("#{$cgi["add_remove_column_month"]}-#{title} #{earlytime}").to_yaml)
		end
		parsed_date
	end

	# returns parsed title
	def edit_column(columnid, newtitle, cgi)
		delete_column(columnid) if columnid != ""
		parsed_date = TimeString.new(newtitle, cgi.include?("columntime") ? cgi["columntime"] : nil)
		@data << parsed_date
		@data.uniq!
		parsed_date.to_s
	end

	def to_html(config = false,activecolumn = nil)
		# returns a sorted array, containing the big units and how often each small is in the big one
		# small and big must be formated for strftime
		# ex: head_count("%Y-%m") returns an array like [["2009-03",2],["2009-04",3]]
		def head_count(elem)
			ret = Hash.new(0)
			@data.each{|day|
				ret[day.date.strftime(elem)] += 1
			}
			ret.sort
		end
		ret = "<tr><td></td>"
		head_count("%Y-%m").each{|title,count|
			year, month = title.split("-").collect{|e| e.to_i}
			ret += "<th colspan='#{count}'>#{Date::ABBR_MONTHNAMES[month]} #{year}</th>\n"
		}

		ret += "</tr><tr><td></td>"
		head_count("%Y-%m-%d").each{|title,count|
			ret += "<th colspan='#{count}'>#{Date.parse(title).strftime("%a, %d")}</th>\n"
		}
		ret += "</tr><tr><th><a href='?sort=name'>Name</a></th>"
		@data.sort.each{|date|
			ret += "<th><a title='#{date}' href='?sort=#{date}'>#{date.time_to_s}</a></th>\n"
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
			if date_included?(d)
				klasse = "choosen"
				varname = "deletecolumn"
			end
			ret += <<TD
<td class='calendarday'>
	<form method='post' action=''>
		<div>
			<input class='#{klasse}' type='submit' value='#{d.day}' />
			<input type='hidden' name='#{varname}' value='#{startdate.strftime("%Y-%m")}-#{d.day}' />
			<input type='hidden' name='add_remove_column_month' value='#{startdate.strftime("%Y-%m")}' />
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
END
		

		###########################
		# starting hour input
		###########################
		ret += "<div><table><tr>"

		head_count("%Y-%m").each{|title,count|
			year,month = title.split("-").collect{|e| e.to_i}
			ret += "<th colspan='#{count}'>#{Date::ABBR_MONTHNAMES[month]} #{year}</th>\n"
		}

		ret += "</tr><tr>"

		head_count("%Y-%m-%d").each{|title,count|
			ret += "<th>#{Date.parse(title).strftime("%a, %d")}</th>\n"
		}

		ret += "</tr>"


		days = @data.sort.collect{|date| date.date }.uniq
		
		each_time{|time|
			ret +="<tr>\n"
			days.each{|day|
				timestamp = TimeString.new(day,time)
				klasse = "notchoosen"
				klasse = "disabled" if timestamp < TimeString.now
				klasse = "choosen" if @data.include?(timestamp)
				ret += <<END
<td class='calendarday'>
	<form method='post' action="">
		<div>
			<!--Timestamp: #{timestamp} -->
END
				if klasse == "choosen"
					ret += "<input type='hidden' name='deletecolumn' value='#{timestamp.to_s}' />"
				else
					ret += "<input type='hidden' name='new_columnname' value='#{timestamp.date}' />"
					if @data.include?(TimeString.new(day,nil))
						ret += "<input type='hidden' name='columnid' value='#{TimeString.new(day,nil).to_s}' />"
					end
				end

				ret += <<END
			<input title='#{timestamp}' class='#{klasse}' type='submit' name='columntime' value='#{timestamp.time_to_s}' />
			<input type='hidden' name='add_remove_column_month' value='#{timestamp.date.strftime("%Y-%m")}' />
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
		<form method='post' action=''>
			<div>
				<input type='hidden' name='new_columnname' value='#{d.strftime("%Y-%m-%d")}' />
				<input type='hidden' name='add_remove_column_month' value='#{d.strftime("%Y-%m")}' />
				<input type="text" name='columntime' title='e.g.: 09:30, morning, afternoon' maxlength="7" style="width: 7ex" /><br />
				<input type="submit" value="Add" style="width: 100%" />
			</div>
		</form>
	</td>
END
		}

		ret += <<END
		</tr>
	</table>
</div>
</fieldset>
END
		ret
	end
end
