############################################################################
# Copyright 2009 Benjamin Kellermann                                       #
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

require "hash"
require "yaml"
require "time"
require "pollhead"
require "timepollhead"

class Poll
	attr_reader :head, :name
	YESVAL   = "ayes"
	MAYBEVAL = "bmaybe"
	NOVAL    = "cno"
	def initialize name,type
		@name = name

		case type
		when "normal"
			@head = PollHead.new
		when "time"
			@head = TimePollHead.new
		else
			raise("unknown poll type: #{type}")
		end
		@data = {}
		@comment = []
		store "Poll #{name} created"
	end

	def sort_data fields
		parsedfields = fields.collect{|field| 
			field == "timestamp" || field == "name" ? field : @head.cgi_to_id(field) 
		}
		if parsedfields.include?("name")
			until parsedfields.pop == "name"
			end
			@data.sort{|x,y|
				cmp = x[1].compare_by_values(y[1],parsedfields) 
				cmp == 0 ? x[0] <=> y[0] : cmp
			}
		else
			@data.sort{|x,y| x[1].compare_by_values(y[1],parsedfields) }
		end
	end

	def to_html(edituser = "", activecolumn = nil, participation = true)
		ret = "<table border='1'>\n"

		ret += @head.to_html(activecolumn)
		sort_data($cgi.include?("sort") ? $cgi.params["sort"] : ["timestamp"]).each{|participant,poll|
			if edituser == participant
				ret += participate_to_html(edituser)
			else
				ret += "<tr class='participantrow'>\n"
				ret += "<td class='name' #{edituser == participant ? "id='active'":""}>"
				ret += participant
				ret += "<span class='edituser'> <sup><a href=\"?edituser=#{CGI.escapeHTML(CGI.escape(participant))}\">#{EDIT}</a></sup></span>"
				ret += "</td>\n"
				@head.each_column{|columnid,columntitle|
					klasse = poll[columnid]
					case klasse
					when nil
						value = UNKNOWN
						klasse = "undecided"
					when YESVAL
						value = YES
					when NOVAL
						value = NO
					when MAYBEVAL
						value = MAYBE
					end
					ret += "<td class='#{klasse}' title=\"#{CGI.escapeHTML(participant)}: #{CGI.escapeHTML(columntitle.to_s)}\">#{value}</td>\n"
				}
				ret += "<td class='date'>#{poll['timestamp'].strftime('%d.%m,&nbsp;%H:%M')}</td>"
				ret += "</tr>\n"
			end
		}

		# PARTICIPATE
		ret += participate_to_html(edituser) unless @data.keys.include?(edituser)

		# SUMMARY
		ret += "<tr id='summary'><td class='name'>total</td>\n"
		@head.each_columnid{|columnid|
			yes = 0
			undecided = 0
			@data.each_value{|participant|
				if participant[columnid] == YESVAL
					yes += 1
				elsif !participant.has_key?(columnid) or participant[columnid] == MAYBEVAL
					undecided += 1
				end
			}

			if @data.empty?
				percent_f = 0
			else
				percent_f = 100*yes/@data.size
			end
			percent = "#{percent_f}%" unless @data.empty?
			if undecided > 0
				percent += "-#{(100.0*(undecided+yes)/@data.size).round}%"
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
		ret
	end

	def participate_to_html(edituser)
		checked = {}
		if @data.include?(edituser)
			@head.each_columnid{|k| checked[k] = @data[edituser][k]}
		else
			@head.each_columnid{|k| checked[k] = NOVAL}
		end
		ret = "<tr id='add_participant'>\n"
		ret += "<td class='name'>
			<input type='hidden' name='olduser' value=\"#{edituser}\" />
			<input size='16' 
				type='text' 
				name='add_participant'
				value=\"#{edituser}\"/>"
		ret += "</td>\n"
		@head.each_column{|columnid,columntitle|
			ret += "<td class='checkboxes'><table class='checkboxes'>"
			[[YES, YESVAL],[NO, NOVAL],[MAYBE, MAYBEVAL]].each{|valhuman, valbinary|
				ret += "<tr class='input-#{valbinary}'>
					<td class='input-#{valbinary}'>
						<input type='radio' 
							value='#{valbinary}' 
							id=\"add_participant_checked_#{CGI.escapeHTML(columnid.to_s.gsub(" ","_").gsub("+","_"))}_#{valbinary}\" 
							name=\"add_participant_checked_#{CGI.escapeHTML(columnid.to_s)}\" 
							title=\"#{CGI.escapeHTML(columntitle.to_s)}\" #{checked[columnid] == valbinary ? "checked='checked'":""}/>
					</td>
					<td class='input-#{valbinary}'>
						<label for=\"add_participant_checked_#{CGI.escapeHTML(columnid.to_s.gsub(" ","_").gsub("+","_"))}_#{valbinary}\">#{valhuman}</label>
					</td>
			</tr>"
			}
			ret += "</table></td>"
		}
		ret += "<td class='date'>"
		if @data.include?(edituser)
			ret += "<input type='submit' value='Save Changes' />"
			ret += "<br /><input style='margin-top:1ex' type='submit' name='delete_participant' value='Delete User' />"
		else
			ret += "<input type='submit' value='Add User' />"
		end
		ret += "</td>\n"

		ret += "</tr>\n"

		ret
	end

	def comment_to_html
		ret = "<div id='comments'>"
		ret	+= "<h2>Comments</h2>"

		unless @comment.empty?
			@comment.each_with_index{|c,i|
				time,name,comment = c
				ret += <<COMMENT
<form method='post' action='.'>
<div class='comment'>
	<fieldset>
		<legend>#{name} said on #{time.strftime("%d.%m, %H:%M")}
			<input type='hidden' name='delete_comment' value='#{i}' />
			&nbsp;
			<input class='delete_comment_button' type='submit' value='delete' />
		</legend>
		#{comment}
	</fieldset>
</div>
</form>
COMMENT
			}
		end
		
		# ADD COMMENT
		ret += <<ADDCOMMENT
		<form method='post' action='.'>
			<div class='comment' id='add_comment'>
				<fieldset>
					<legend>
						<input value='Anonymous' type='text' name='commentname' size='9' /> says&nbsp;
					</legend>
					<textarea cols='50' rows='7' name='comment' ></textarea>
					<br /><input type='submit' value='Submit Comment' />
				</fieldset>
			</div>
		</form>
ADDCOMMENT

		ret += "</div>\n"
		ret
	end

	def history_to_html
		ret = "<table><tr><th>Version</th><th>Date</th><th>Comment</th></tr>"
		maxrev=VCS.revno
		revision= defined?(REVISION) ? REVISION : maxrev
		log = VCS.history
		log.shift
		log.collect!{|s| s.scan(/\nrevno:.*\ncommitter.*\n.*\ntimestamp: (.*)\nmessage:\n  (.*)/).flatten}
		log.collect!{|t,c| [Time.parse(t),c]}

		((revision-5)..(revision+5)).each do |i|
			if i >0 && i<=maxrev
				ret += "<tr><td>"
				ret += "<a href='?revision=#{i}' >" if revision != i
				ret += "#{i}"
				ret += "</a></td>" if revision != i
				ret += "<td>#{log[i-1][0].strftime('%d.%m, %H:%M')}</td><td>#{CGI.escapeHTML(log[i-1][1])}</td>"
				ret += "</tr>"
			end
		end
		ret += "</table>"
		ret
	end

	def add_participant(olduser, name, agreed)
		name.strip!
		if name == ""
			maximum = @data.keys.collect{|e| e.scan(/^Anonymous #(\d*)/).flatten[0]}.compact.collect{|i| i.to_i}.max
			maximum ||= 0
			name = "Anonymous ##{maximum + 1}"
		end
		htmlname = CGI.escapeHTML(name)
		@data.delete(CGI.escapeHTML(olduser))
		@data[htmlname] = {"timestamp" => Time.now }
		@head.each_columnid{|columnid|
			@data[htmlname][columnid] = agreed[columnid.to_s]
		}
		store "Participant #{name.strip} edited"
	end

	def delete(name)
		htmlname = CGI.escapeHTML(name.strip)
		if @data.has_key?(htmlname)
			@data.delete(htmlname)
			store "Participant #{name.strip} deleted"
		end
	end

	def store comment
		File.open("data.yaml", 'w') do |out|
			out << "# This is a dudle poll file\n"
			out << self.to_yaml
			out.chmod(0660)
		end
		VCS.commit(CGI.escapeHTML(comment))
	end

	###############################
	# comment related functions 
	###############################
	def add_comment name, comment
		@comment << [Time.now, CGI.escapeHTML(name.strip), CGI.escapeHTML(comment.strip).gsub("\r\n","<br />")]
		store "Comment added by #{name}"
	end

	def delete_comment index
		store "Comment from #{@comment.delete_at(index)[1]} deleted"
	end

	###############################
	# column related functions
	###############################
	def delete_column columnid
		title = @head.get_title(columnid)
		if @head.delete_column(columnid)
			store "Column #{title} deleted"
			return true
		else
			return false
		end
	end

	def edit_column(oldcolumnid, newtitle, cgi)
		parsedtitle = @head.edit_column(oldcolumnid, newtitle, cgi)
		store "Column #{parsedtitle} edited" if parsedtitle
	end

	def edit_column_htmlform(activecolumn)
		@head.edit_column_htmlform(activecolumn)
	end
end

