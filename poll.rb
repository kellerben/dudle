################################
# Author:  Benjamin Kellermann #
# License: CC-by-sa 3.0        #
#          see License         #
################################

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

	def to_html(edituser = "", config = false,activecolumn = nil)
		ret = "<table border='1'>\n"

		ret += @head.to_html(config, activecolumn)
		sort_data($cgi.include?("sort") ? $cgi.params["sort"] : ["timestamp"]).each{|participant,poll|
			if edituser == participant
				ret += participate_to_html(edituser, config)
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
		ret += participate_to_html(edituser, config) unless @data.keys.include?(edituser)

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

	def participate_to_html(edituser, config)
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
		unless config
			@head.each_column{|columnid,columntitle|
				ret += "<td class='checkboxes'><table>"
				[[YES, YESVAL],[NO, NOVAL],[MAYBE, MAYBEVAL]].each{|valhuman, valbinary|
					ret += "<tr>
						<td>
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
			ret += "<td class='checkboxes'>"
		else
			ret += "<td class='checkboxes' colspan='#{@head.col_size + 1}'>"
		end
		if @data.include?(edituser)
			ret += "<input type='submit' value='edit user' />"
			ret += "<br /><input style='margin-top:1ex' type='submit' name='delete_participant' value='delete user' />"
		else
			ret += "<input type='submit' value='add user' />"
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
					<br /><input type='submit' value='Submit comment' />
				</fieldset>
			</div>
		</form>
ADDCOMMENT

		ret += "</div>\n"
		ret
	end

	def history_to_html
		ret = ""
		maxrev=VCS.revno
		revision= defined?(REVISION) ? REVISION : maxrev
		log = VCS.history
		log.shift
		log.collect!{|s| s.scan(/\nrevno:.*\ncommitter.*\n.*\ntimestamp: (.*)\nmessage:\n  (.*)/).flatten}
		log.collect!{|t,c| [Time.parse(t),c]}

		((revision-2)..(revision+2)).each do |i|
			if i >0 && i<=maxrev
				ret += " "
				ret += "<a href='?revision=#{i}' >" if revision != i
				ret += "<span title=\"#{log[i-1][0].strftime('%d.%m, %H:%M')}: #{CGI.escapeHTML(log[i-1][1])}\">#{i}</span>"
				ret += "</a>" if revision != i
			end
		end
		ret += " <a href='.' >last</a>" if defined?(REVISION)
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

