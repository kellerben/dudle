################################
# Author:  Benjamin Kellermann #
# License: CC-by-sa 3.0        #
#          see License         #
################################
require "digest/sha2"

class PollHead
	def initialize
		@data = {}
	end
	def col_size
		@data.size
	end

	def get_id(columntitle)
		if @data.include?(columntitle)
			return Digest::SHA2.hexdigest("#{columntitle}#{@data[columntitle]}" + columntitle)
		else
			raise("no such column found: #{columntitle}")
		end
	end
	def get_title(columnid)
		@data.each_key{|k| return k if get_id(k) == columnid}
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
		field
	end

	# returns true if deletion sucessfull
	def delete_column(columnid)
		@data.delete(get_title(columnid)) != nil
	end

	# add new column if columnid = ""
	# returns parsed title or false if parsed title == ""
	def edit_column(columnid, newtitle, cgi)
		delete_column(columnid) if columnid != ""
		parsedtitle = newtitle.strip

		if parsedtitle != ""
			@data[parsedtitle] = CGI.escapeHTML(cgi["columndescription"].strip)
			return parsedtitle
		else 
			return false
		end
	end

	def to_html(config = false,activecolumn = nil)
		ret = "<tr><th><a href='?sort=name'>Name</a></th>\n"
		@data.each{|columntitle,columndescription|
			ret += "<th"
			ret += " id='active' " if activecolumn == columntitle
			ret += "><a title=\"#{columndescription}\" href=\"?sort=#{CGI.escapeHTML(CGI.escape(columntitle))}\">#{CGI.escapeHTML(columntitle)}</a>"
			if config
				ret += <<EDITDELETE
	<div>
		<small>
			<a href="?editcolumn=#{CGI.escapeHTML(CGI.escape(columntitle))}" title="edit">
				#{EDIT}
			</a>|
			<a href="?deletecolumn=#{CGI.escapeHTML(CGI.escape(get_id(columntitle)))}" title="delete">
				#{DELETE}
			</a>
		</small>
	</div>
EDITDELETE
			end
			ret += "</th>"
		}
		ret += "<th><a href='.'>Last Edit</a></th>\n"
		ret += "</tr>\n"
		ret
	end
	
	def edit_column_htmlform(activecolumn)
		if activecolumn != ""
			title = activecolumn
			description = @data[title]
			title = CGI.escapeHTML(title)
			hiddeninput = "<input type='hidden' name='columnid' value=\"#{get_id(title)}\" />"
		end
		return <<END
<form method='post' action=''>
	<div>
			<label for='columntitle'>Columntitle: </label>
			<input id='columntitle' size='16' type='text' value="#{title}" name='new_columnname' />
			<label for='columndescription'>Description: </label>
			<input id='columndescription' size='30' type='text' value="#{description}" name='columndescription' />
			#{hiddeninput}
			<input type='submit' value='Add/Edit Column' />
	</div>
</form>
<fieldset><legend>Preview</legend>
<table>
#{to_html(true)}
</table>
</fieldset>
END
	end
end
