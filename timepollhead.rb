############################################################################
# Copyright 2009,2010 Benjamin Kellermann                                  #
#                                                                          #
# This file is part of dudle.                                              #
#                                                                          #
# Dudle is free software: you can redistribute it and/or modify it under   #
# the terms of the GNU Affero General Public License as published by       #
# the Free Software Foundation, either version 3 of the License, or        #
# (at your option) any later version.                                      #
#                                                                          #
# Dudle is distributed in the hope that it will be useful, but WITHOUT ANY #
# WARRANTY; without even the implied warranty of MERCHANTABILITY or        #
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public     #
# License for more details.                                                #
#                                                                          #
# You should have received a copy of the GNU Affero General Public License #
# along with dudle.  If not, see <http://www.gnu.org/licenses/>.           #
############################################################################

# BUGFIX for Time.parse, which handles the zone indeterministically
class << Time
	alias_method :old_parse, :parse
	def Time.parse(date, now=self.now)
		Time.old_parse("2009-10-25 00:30")
		Time.old_parse(date)
	end
end

require "timestring"

class TimePollHead 
	def initialize
		@data = []
	end
	def col_size
		@data.size
	end

	# returns a sorted array of all columns
	#	column should be the internal representation
	#	column.to_s should deliver humanreadable form
	def columns
		@data.sort.each.collect{|day| day.to_s}
	end

	def concrete_times
		h = {}
		@data.each{|ds| h[ds.time_to_s] = true }
		h.keys
	end
	def date_included?(date)
		ret = false
		@data.each{|ds|
			ret = ret || ds.date == date
		}
		ret
	end

	# column is in human readable form
	# returns true if deletion sucessfull
	def delete_column(column)
		col = TimeString.from_s(column)
		if col.time 
			ret = @data.delete(TimeString.from_s(column)) != nil
			@data << TimeString.new(col.date,nil) unless date_included?(col.date)
			return ret
		else
			deldata = []
			@data.each{|ts|
				deldata << ts if ts.date == col.date
			}
			deldata.each{|ts|
				@data.delete(ts)
			}
			return !deldata.empty?
		end
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

	# returns parsed title or nil in case of colum not changed
	def edit_column(column, newtitle, cgi)
		if cgi.include?("columntime") && cgi["columntime"] == ""
			@edit_column_error = _("To add some time different to the default ones, please enter some string here (e.&thinsp;g., 09:30, morning, afternoon).")
			return nil
		end
		delete_column(column) if column != ""
		parsed_date = TimeString.new(newtitle, cgi["columntime"] != "" ? cgi["columntime"] : nil)
		if @data.include?(parsed_date)
			@edit_column_error = _("This Time was already choosen.")
			return nil
		else
			@data << parsed_date
			parsed_date.to_s
		end
	end

	# returns a sorted array, containing the big units and how often each small is in the big one
	# small and big must be formated for strftime
	# ex: head_count("%Y-%m") returns an array like [["2009-03",2],["2009-04",3]]
	# if notime = true, the time field is stripped out before counting
	def head_count(elem, notime)
		data = @data.collect{|day| day.date}
		data.uniq! if notime
		ret = Hash.new(0)
		data.each{|day|
			ret[day.strftime(elem)] += 1
		}
		ret.sort
	end
	def to_html(scols,config = false,activecolumn = nil)
		ret = "<tr><th class='invisible'></th>"
		head_count("%Y-%m",false).each{|title,count|
			year, month = title.split("-").collect{|e| e.to_i}
			ret += "<th colspan='#{count}'>#{Date.parse("#{year}-#{month}-01").strftime("%b %Y")}</th>\n"
		}

		ret += "<th class='invisible'></th></tr><tr><th class='invisible'></th>"
		head_count("%Y-%m-%d",false).each{|title,count|
			ret += "<th colspan='#{count}'>#{Date.parse(title).strftime('%a, %d')}</th>\n"
		}

		def sortsymb(scols,col)
			return <<SORTSYMBOL
<span class='sortsymb'> #{scols.include?(col) ? SORT : NOSORT}</span>
SORTSYMBOL
		end

		ret += "<th class='invisible'></th></tr><tr><th><a href='?sort=name'>" + _("Name") + " #{sortsymb(scols,"name")}</a></th>"
		@data.sort.each{|date|
			ret += "<th><a title='#{date}' href='?sort=#{CGI.escape(date.to_s)}'>#{date.time_to_s} #{sortsymb(scols,date.to_s)}</a></th>\n"
		}
		ret += "<th><a href='?'>" + _("Last Edit") + " #{sortsymb(scols,"timestamp")}</a></th>\n</tr>\n"
		ret
	end
	
	def datenavi val,revision
		case val
		when MONTHBACK
			navimonth = Date.parse("#{@startdate.strftime('%Y-%m')}-1")-1
		when MONTHFORWARD
			navimonth = Date.parse("#{@startdate.strftime('%Y-%m')}-1")+31
		else
			raise "Unknown navi value #{val}"
		end
		return <<END
		<th colspan='2' style='padding:0px'>
			<form method='post' action=''>
				<div>
					<input class='navigation' type='submit' value='#{val}' />
					<input type='hidden' name='add_remove_column_month' value='#{navimonth.strftime("%Y-%m")}' />
					<input type='hidden' name='firsttime' value='#{@firsttime.to_s.rjust(2,"0")}:00' />
					<input type='hidden' name='lasttime' value='#{@lasttime.to_s.rjust(2,"0")}:00' />
					<input type='hidden' name='undo_revision' value='#{revision}' />
				</div>
			</form>
		</th>
END
	end
	def timenavi val,revision
		case val
		when EARLIER
			return "" if @firsttime == 0 
			str = EARLIER + " " + _("Earlier")
			firsttime = [@firsttime-2,0].max
			lasttime = @lasttime
		when LATER
			return "" if @lasttime == 23
			str = LATER + " " + _("Later")
			firsttime = @firsttime
			lasttime = [@lasttime+2,23].min
		else
			raise "Unknown navi value #{val}"
		end
		return <<END
<tr>
	<td style='padding:0px'>
		<form method='post' action=''>
			<div>
				<input class='navigation' type='submit' value='#{str}' />
				<input type='hidden' name='firsttime' value='#{firsttime.to_s.rjust(2,"0")}:00' />
				<input type='hidden' name='lasttime' value='#{lasttime.to_s.rjust(2,"0")}:00' />
				<input type='hidden' name='add_remove_column_month' value='#{@startdate.strftime("%Y-%m")}' />
				<input type='hidden' name='undo_revision' value='#{revision}' />
			</div>
		</form>
	</td>
</tr>
END
	end

	
	def edit_column_htmlform(activecolumn, revision)
		# calculate start date, first and last time to show
		if $cgi.include?("add_remove_column_month")
			@startdate = Date.parse("#{$cgi["add_remove_column_month"]}-1")
		else
			@startdate = Date.parse("#{Date.today.year}-#{Date.today.month}-1")
		end

		times = concrete_times
		realtimes = times.collect{|t|
			begin
				Time.parse(t) if t =~ /^\d\d:\d\d$/
			rescue ArgumentError
			end
		}.compact
		[9,16].each{|i| realtimes << Time.parse("#{i.to_s.rjust(2,"0")}:00")}

		["firsttime","lasttime"].each{|t|
			realtimes << Time.parse($cgi[t]) if $cgi.include?(t)
		}

		@firsttime = realtimes.min.strftime("%H").to_i
		@lasttime  = realtimes.max.strftime("%H").to_i
	
		def add_remove_button(klasse, buttonlabel, action, columnstring, revision, pretext = "")
			titlestr = _("Delete Column")
			return <<FORM
<form method='post' action=''>
	<div>
		#{pretext}<input title='#{titlestr}' class='#{klasse}' type='submit' value='#{buttonlabel}' />
		<input type='hidden' name='#{action}' value='#{columnstring}' />
		<input type='hidden' name='firsttime' value='#{@firsttime.to_s.rjust(2,"0")}:00' />
		<input type='hidden' name='lasttime' value='#{@lasttime.to_s.rjust(2,"0")}:00' />
		<input type='hidden' name='add_remove_column_month' value='#{@startdate.strftime("%Y-%m")}' />
		<input type='hidden' name='undo_revision' value='#{revision}' />
	</div>
</form>
FORM
		end
		

		hintstr = _("Click on the dates to add or remove columns.")
		ret = <<END
<table style='width:100%'><tr><td style="vertical-align:top">
<div id='AddRemoveColumndaysDescription' class='shorttextcolumn'>
#{hintstr}
</div>
<table class='calendarday'><tr>
END
		ret += datenavi(MONTHBACK,revision)
		ret += "<th colspan='3'>#{@startdate.strftime('%b %Y')}</th>"
		ret += datenavi(MONTHFORWARD,revision)
		 
		ret += "</tr><tr>\n"

		7.times{|i|
			# 2010-03-01 was a Monday, so we can use this month for a dirty hack
			ret += "<th class='weekday'>#{Date.parse("2010-03-0#{i+1}").strftime("%a")}</th>" 
		}
		ret += "</tr><tr>\n"
		
		((@startdate.wday+7-1)%7).times{
			ret += "<td></td>"
		}
		d = @startdate
		while true do
			klasse = "notchosen"
			varname = "new_columnname"
			klasse = "disabled" if d < Date.today
			if date_included?(d)
				klasse = "chosen"
				varname = "deletecolumn"
			end
			ret += "<td class='calendarday'>#{add_remove_button(klasse, d.day, varname, d.strftime('%Y-%m-%d'),revision)}</td>"
			d = d.next
			break if d.month != @startdate.month
			ret += "</tr><tr>\n" if d.wday == 1
		end
		ret += <<END
</tr></table>
</td>
END
		

		###########################
		# starting hour input
		###########################
		ret += "<td style='vertical-align:top'>"
		if col_size > 0
			optstr = _("Optional:")
			hintstr = _("Enter a concrete value as start time.")
			ret += <<END
<div id='ConcreteColumndaysDescription' class='shorttextcolumn'>
#{optstr}<br/>
#{hintstr}
</div>
<table class='calendarday'>
<tr>
END

		ret += "<th class='invisible'></th>"
		head_count("%Y-%m",true).each{|title,count|
			year,month = title.split("-").collect{|e| e.to_i}
			ret += "<th colspan='#{count}'>#{Date.parse("#{year}-#{month}-01").strftime("%b %Y")}</th>\n"
		}

		ret += "</tr><tr><th>" + _("Time") + "</th>"

		head_count("%Y-%m-%d",true).each{|title,count|
			coltime = Date.parse(title)
			ret += "<th>" + add_remove_button("delete",DELETE, "deletecolumn", coltime.strftime("%Y-%m-%d"), revision, "#{coltime.strftime('%a, %d')}&nbsp;") + "</th>"
		}

		ret += "</tr>"


		days = @data.sort.collect{|date| date.date }.uniq
		
		chosenstr = {
			"chosen" => _("Chosen"),
			"notchosen" => _("Not Chosen"),
			"disabled" => _("Past")
		}


		ret += timenavi(EARLIER,revision)

		(@firsttime..@lasttime).each{|i| times << "#{i.to_s.rjust(2,"0")}:00" }
		times.flatten.compact.uniq.sort{|a,b|
			if a =~ /^\d\d:\d\d$/ && !(b =~ /^\d\d:\d\d$/)
				-1
			elsif !(a =~ /^\d\d:\d\d$/) && b =~ /^\d\d:\d\d$/
				1
			else
				a.to_i == b.to_i ? a <=> b : a.to_i <=> b.to_i
			end
		}.each{|time|
			ret +="<tr>\n<td class='navigation'>#{time}</td>"
			days.each{|day|
				timestamp = TimeString.new(day,time)
				klasse = "notchosen"
				klasse = "disabled" if timestamp < TimeString.now

				if @data.include?(timestamp)
					klasse = "chosen" 
					hiddenvars = "<input type='hidden' name='deletecolumn' value='#{timestamp}' />"
				else
					hiddenvars = "<input type='hidden' name='new_columnname' value='#{timestamp.date}' />"
					if @data.include?(TimeString.new(day,nil)) # change day instead of removing it if no specific hour exists for this day
						hiddenvars += "<input type='hidden' name='columnid' value='#{TimeString.new(day,nil)}' />"
					end
				end
				ret += "<td>" + add_remove_button(klasse, chosenstr[klasse], "columntime", timestamp.time_to_s, revision, hiddenvars) + "</td>"

			}
			ret += "</tr>\n"
		}
		ret += timenavi(LATER,revision)

		ret += "<tr><td></td>"
		days.each{|d|
			ret += <<END
	<td>
		<form method='post' action='' accept-charset='utf-8'>
			<div>
				<input type='hidden' name='new_columnname' value='#{d.strftime("%Y-%m-%d")}' />
				<input type='hidden' name='add_remove_column_month' value='#{d.strftime("%Y-%m")}' />
				<input type='hidden' name='firsttime' value='#{@firsttime.to_s.rjust(2,"0")}:00' />
				<input type='hidden' name='lasttime' value='#{@lasttime.to_s.rjust(2,"0")}:00' />
				<input type='hidden' name='undo_revision' value='#{revision}' />
END
			if @data.include?(TimeString.new(d,nil))
				ret += "<input type='hidden' name='columnid' value='#{TimeString.new(d,nil).to_s}' />"
			end
			addstr = _("Add")
			hintstr = _("e.&thinsp;g., 09:30, morning, afternoon")
			ret += <<END
				<input type="text" name='columntime' title='#{hintstr}' style="max-width: 10ex" /><br />
				<input type="submit" value="#{addstr}" style="width: 100%" />
			</div>
		</form>
	</td>
END
		}

		ret += "</tr><tr><td colspan='#{days.size+1}' class='error'>#{@edit_column_error}</td>" if @edit_column_error
		ret += "</tr></table>"
		end
		ret += "</td></tr></table>"
		ret
	end
end
