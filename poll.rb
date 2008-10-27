#!/usr/bin/env ruby
load "/home/ben/src/lib.rb/pphtml.rb"
require "pp"
require "yaml"

class Poll
	attr_reader :head, :name, :hidden
	def initialize name,hidden
		@name = name
		@hidden = hidden
		@head = {}
		@data = {}
		@comment = []
		store "Poll #{name} created"
	end
	def head_to_html
		ret = "<tr><td></td>\n"
		@head.sort.each{|columntitle,columndescription|
			ret += "<th title='#{columndescription}'>#{columntitle}</th>\n"
		}
		ret += "<th>Last Edit</th>\n"
		ret += "</tr>\n"
		ret
	end
	def add_remove_column_htmlform
		return <<END
<div id='add_remove_column'>
<fieldset><legend>add/remove column</legend>
<form method='post' action='.'>
<div>
		<label for='columntitle'>Columntitle: </label>
		<input id='columntitle' size='16' type='text' value='#{$cgi["add_remove_column"]}' name='add_remove_column' />
		<label for='columndescription'>Description: </label>
		<input id='columndescription' size='30' type='text' value='#{$cgi["columndescription"]}' name='columndescription' />
		<input type='submit' value='add/remove column' />
</div>
</form>
</fieldset>
</div>
END
	end
	def to_html
		ret = "<div id='polltable'>\n"
		ret += "<form method='post' action='.'>\n"
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
		
		ret += "<tr id='add_participant'>\n"
		ret += "<td class='name'><input size='16' type='text' name='add_participant' /></td>\n"
		@head.sort.each{|columntitle,columndescription|
			ret += "<td class='checkboxes'>
			<table><tr>
			<td class='input-yes'>#{YES}</td>
			<td><input type='radio' value='yes' name='add_participant_checked_#{columntitle}' title='#{columntitle}' /></td>
			</tr><tr>
			<td class='input-no'>#{NO}</td>
			<td><input type='radio' value='no' name='add_participant_checked_#{columntitle}' title='#{columntitle}' checked='checked' /></td>
			</tr><tr>
			<td class='input-maybe'>#{MAYBE}</td>
			<td><input type='radio' value='maybe' name='add_participant_checked_#{columntitle}' title='#{columntitle}' /></td>
			</tr></table>
			</td>\n"
		}
		ret += "<td class='checkboxes'><input type='submit' value='add/edit' /></td>\n"

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
			@comment.each_with_index{|c,i|
				time,name,comment = c
				ret += "<form method='post' action='.'>\n"
				ret += "<div>"
				ret	+= "<fieldset><legend>#{name} said on #{time.strftime("%d.%m, %H:%M")} "
				ret += "<input type='hidden' name='delete_comment' value='#{i}' />"
				ret += "<input class='delete_comment_button' type='submit' value='delete' style='position: absolute; margin-left: 20px;' />"
				ret += "</legend>"
				ret += comment
				ret += "</fieldset>"
				ret += "</div>"
				ret += "</form>"
			}
			ret += "</fieldset>"
		end

		ret += "</div>\n"
		ret
	end
	def add_participant(name, agreed)
		htmlname = CGI.escapeHTML(name.strip)
		@data[htmlname] = {"timestamp" => Time.now}
		@head.each_key{|columntitle|
			@data[htmlname][columntitle] = agreed[columntitle.to_s]
		}
		store "Participant #{name} edited"
	end
	def invite_delete(name)
		if @data.has_key?(name)
			@data.delete(CGI.escapeHTML(name.strip))
			store "Participant #{name} deleted"
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
		`export LC_ALL=de_DE.UTF-8; bzr commit -m '#{CGI.escapeHTML(comment)}'`
	end
	def add_comment name, comment
		@comment << [Time.now, CGI.escapeHTML(name), CGI.escapeHTML(comment.strip).gsub("\r\n","<br />")]
		store "Comment added by #{name}"
	end
	def delete_comment index
		store "Comment from #{@comment.delete_at(index)[1]} deleted"
	end
	def add_remove_column name, description
		add_remove_parsed_column CGI.escapeHTML(name.strip), CGI.escapeHTML(description.strip)
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
end

if __FILE__ == $0
require 'test/unit'

SITE = "glvhc_8nuv_8fchi09bb12a-23_uvc"
class Poll
	attr_accessor :head, :data, :comment
end

class PollTest < Test::Unit::TestCase
	def setup
		@poll = Poll.new
	end
	def teardown
		File.delete("#{SITE}.yaml") if File.exists?("#{SITE}.yaml")
	end
	def test_init
		assert(@poll.head.empty?)
	end
	def test_add_participant
		@poll.head["Item 2"] = ""
		@poll.add_participant("bla",{"Item 2" => true})
		assert_equal(Time, @poll.data["bla"]["timestamp"].class)
		assert(@poll.data["bla"]["Item 2"])
	end
	def test_delete
		@poll.data["bla"] = {}
		@poll.delete(" bla ")
		assert(@poll.data.empty?)
	end
	def test_store
		@poll.add_remove_column("uaie","descriptionfoobar")
		@poll.add_remove_column("gfia","")
		@poll.add_participant("bla",{"uaie"=>"maybe", "gfia"=>"yes"})
		@poll.add_comment("blabla","commentblubb")
		@poll.store
		assert_equal(@poll.data,YAML::load_file("#{SITE}.yaml").data)
		assert_equal(@poll.head,YAML::load_file("#{SITE}.yaml").head)
		assert_equal(@poll.comment,YAML::load_file("#{SITE}.yaml").comment)
	end
	def test_add_comment
		@poll.add_comment("blabla","commentblubb")
		assert_equal(Time, @poll.comment[0][0].class)
		assert_equal("blabla", @poll.comment[0][1])
	end
	def test_add_remove_column
		assert(@poll.add_remove_column(" bla  ", ""))
		assert(@poll.head.include?("bla"))
		assert(@poll.add_remove_column("   bla ", ""))
		assert(@poll.head.empty?)
	end
end

end
