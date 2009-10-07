################################
# Author:  Benjamin Kellermann #
# License: CC-by-sa 3.0        #
#          see License         #
################################

require "hash"
require "yaml"
require "time"

class Poll
	attr_reader :head, :name, :hidden
	YESVAL   = "ayes"
	MAYBEVAL = "bmaybe"
	NOVAL    = "cno"
	def initialize name
		@name = name
		@hidden = false
		@head = {}
		@data = {}
		@comment = []
		store "Poll #{name} created"
	end
	def init
	end
	def sort_data fields
		if fields.include?("name")
			until fields.pop == "name"
			end
			@data.sort{|x,y|
				cmp = x[1].compare_by_values(y[1],fields) 
				cmp == 0 ? x[0] <=> y[0] : cmp
			}
		else
			@data.sort{|x,y| x[1].compare_by_values(y[1],fields) }
		end
	end
	def head_to_html(config = false)
		ret = "<tr><th><a href='?sort=name'>Name</a></th>\n"
		@head.sort.each{|columntitle,columndescription|
			ret += "<th"
			ret += " id='active' " if $cgi["editcolumn"] == columntitle
			ret += "><a title=\"#{columndescription}\" href=\"?sort=#{CGI.escapeHTML(CGI.escape(columntitle))}\">#{CGI.escapeHTML(columntitle)}</a>"
			ret += "<br/>\n<small><a href=\"?editcolumn=#{CGI.escapeHTML(CGI.escape(columntitle))}#add_remove_column\">#{EDIT}</a></small>" if config
			ret += "</th>"
		}
		ret += "<th><a href='.'>Last Edit</a></th>\n"
		ret += "</tr>\n"
		ret
	end
	def to_html(config = false)
		ret = "<table border='1'>\n"

		ret += head_to_html(config)
		sort_data($cgi.include?("sort") ? $cgi.params["sort"] : ["timestamp"]).each{|participant,poll|
			ret += "<tr class='participantrow'>\n"
			ret += "<td class='name' #{$edituser == participant ? "id='active'":""}>"
			ret += participant
			ret += " <sup><a href=\"?edituser=#{CGI.escapeHTML(CGI.escape(participant))}\" style='text-decoration: none' >#{EDIT}</a></sup>" unless config
			ret += "</td>\n"
			@head.sort.each{|columntitle,columndescription|
				klasse = poll[columntitle]
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
			ret += "<td class='date'>#{poll['timestamp'].strftime('%d.%m, %H:%M')}</td>"
			ret += "</tr>\n"
		}

		# PARTICIPATE
		ret += participate_to_html unless config

		# SUMMARY
		ret += "<tr id='summary'><td class='name'>total</td>\n"
		@head.sort.each{|columntitle,columndescription|
			yes = 0
			undecided = 0
			@data.each_value{|participant|
				if participant[columntitle] == YESVAL
					yes += 1
				elsif !participant.has_key?(columntitle) or participant[columntitle] == MAYBEVAL
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
		ret
	end
	def participate_to_html
		checked = {}
		if $edituser && @data.include?($edituser)
			participant = $edituser
			@head.each_key{|k| checked[k] = @data[participant][k]}
		else
			participant = ""
			@head.each_key{|k| checked[k] = NOVAL}
		end
		ret = "<tr id='add_participant'>\n"
		ret += "<td class='name'>
			<input type='hidden' name='edituser' value=\"#{participant}\" />
			<input size='16' 
				type='text' 
				name='add_participant'
				value=\"#{participant}\"
				title='To change a line, add a new person with the same name!' />"
		ret += "</td>\n"
		@head.sort.each{|columntitle,columndescription|
			ret += "<td class='checkboxes'><table>"
			[[YES, YESVAL],[NO, NOVAL],[MAYBE, MAYBEVAL]].each{|valhuman, valbinary|
				ret += "<tr>
					<td class='input-#{valbinary}'>
						<label for=\"add_participant_checked_#{CGI.escapeHTML(columntitle.to_s.gsub(" ","_").gsub("+","_"))}_#{valbinary}\">#{valhuman}</label>
					</td>
					<td>
						<input type='radio' 
							value='#{valbinary}' 
							id=\"add_participant_checked_#{CGI.escapeHTML(columntitle.to_s.gsub(" ","_").gsub("+","_"))}_#{valbinary}\" 
							name=\"add_participant_checked_#{CGI.escapeHTML(columntitle.to_s)}\" 
							title=\"#{CGI.escapeHTML(columntitle.to_s)}\" #{checked[columntitle] == valbinary ? "checked='checked'":""}/>
					</td>
			</tr>"
			}
			ret += "</table></td>"
		}
		ret += "<td class='checkboxes'><input type='submit' value='add/edit' />"
		ret += "<br /><input type='submit' name='delete_participant' value='delete user' />" if $edituser
		ret += "</td>\n"

		ret += "</tr>\n"

		ret
	end
	def comment_to_html
		ret = "<div id='comments'>"
		ret	+= "<fieldset><legend>Comments</legend>"

		unless @comment.empty?
			@comment.each_with_index{|c,i|
				time,name,comment = c
				ret += <<COMMENT
<form method='post' action='.'>
<div>
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
			<div>
				<fieldset>
					<legend>
						<input value='anonymous' type='text' name='commentname' size='9' /> says&nbsp;
					</legend>
					<textarea cols='50' rows='7' name='comment' ></textarea>
					<br /><input type='submit' value='Submit comment' />
				</fieldset>
			</div>
		</form>
ADDCOMMENT
			ret += "</fieldset>"

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
	def add_remove_column_htmlform
		if $cgi.include?("editcolumn")
			title = $cgi["editcolumn"]
			description = @head[title]
			title = CGI.escapeHTML(title)
		else
			title = CGI.escapeHTML($cgi["add_remove_column"])
			description = CGI.escapeHTML($cgi["columndescription"])
		end
		return <<END
<form method='post' action=''>
	<div>
			<label for='columntitle'>Columntitle: </label>
			<input id='columntitle' size='16' type='text' value="#{title}" name='add_remove_column' />
			<label for='columndescription'>Description: </label>
			<input id='columndescription' size='30' type='text' value="#{description}" name='columndescription' />
			<input type='submit' value='add/remove column' />
	</div>
</form>
END
	end
	def add_participant(name, agreed)
		name.strip!
		if name == ""
			maximum = @data.keys.collect{|e| e.scan(/^Anonymous #(\d*)/).flatten[0]}.compact.collect{|i| i.to_i}.max
			maximum ||= 0
			name = "Anonymous ##{maximum + 1}"
		end
		htmlname = CGI.escapeHTML(name)
		@data.delete(CGI.escapeHTML($edituser)) if $edituser
		$edituser = htmlname
		@data[htmlname] = {"timestamp" => Time.now }
		@head.each_key{|columntitle|
			@data[htmlname][columntitle] = agreed[columntitle.to_s]
		}
		store "Participant #{name.strip} edited"
	end
	def invite_delete(name)
		htmlname = CGI.escapeHTML(name.strip)
		if @data.has_key?(htmlname)
			@data.delete(htmlname)
			store "Participant #{name.strip} deleted"
		else
			add_participant(name,{})
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
	def add_comment name, comment
		@comment << [Time.now, CGI.escapeHTML(name.strip), CGI.escapeHTML(comment.strip).gsub("\r\n","<br />")]
		store "Comment added by #{name}"
	end
	def delete_comment index
		store "Comment from #{@comment.delete_at(index)[1]} deleted"
	end
	def add_remove_column name, description
		add_remove_parsed_column name.strip, CGI.escapeHTML(description.strip)
	end
	def add_remove_parsed_column columntitle, description
		if @head.include?(columntitle)
			@head.delete(columntitle)
			action = "deleted"
		else
			@head[columntitle] = description
			action = "added"
		end
		store "Column #{columntitle} #{action}"
		true
	end

	def toggle_hidden
		@hidden = !@hidden
		store "Hidden status changed!"
	end

end

