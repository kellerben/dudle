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

class PollHead
	def initialize
		@data = {}
	end
	def col_size
		@data.size
	end

	#	iterates over each column
	#	column should be the internal representation
	#	column.to_s should deliver humanreadable form
	def each_column
		@data.sort.each{|k,v|
			yield(k)
		}
	end

	# column is in human readable form
	# returns true if deletion sucessfull
	def delete_column(column)
		@data.delete(column) != nil
	end

	# add new column if columnid = ""
	# returns parsed title or false if parsed title == ""
	def edit_column(column, newtitle, cgi)
		delete_column(column) if column != ""
		parsedtitle = newtitle.strip

		if parsedtitle != ""
			@data[parsedtitle] = CGI.escapeHTML(cgi["columndescription"].strip)
			return parsedtitle
		else 
			return false
		end
	end

	def to_html(scols, showeditbuttons = false,activecolumn = nil)
		def sortsymb(scols,col)
			scols.include?(col) ? SORT : NOSORT
		end
		ret = "<tr>"
		ret += "<th><a href='?sort=name'>Name #{sortsymb(scols,"name")}</a></th>\n" unless showeditbuttons
		@data.each{|columntitle,columndescription|
			ret += "<th"
			ret += " id='active' " if activecolumn == columntitle
			ret += ">"
			ret += "<a title=\"#{columndescription}\" href=\"?sort=#{CGI.escapeHTML(CGI.escape(columntitle))}\">" unless showeditbuttons
			ret += "#{CGI.escapeHTML(columntitle)}"
			ret += " #{sortsymb(scols,columntitle)}</a>" unless showeditbuttons
			if showeditbuttons
				ret += <<EDITDELETE
	<div>
		<small>
			<a href="?editcolumn=#{CGI.escapeHTML(CGI.escape(columntitle))}" title="edit">
				#{EDIT}
			</a>|
			<a href="?deletecolumn=#{CGI.escapeHTML(CGI.escape(columntitle))}" title="delete">
				#{DELETE}
			</a>
		</small>
	</div>
EDITDELETE
			end
			ret += "</th>"
		}
		ret += "<th><a href='?'>Last Edit #{sortsymb(scols,"timestamp")}</a></th>\n" unless showeditbuttons
		ret += "</tr>\n"
		ret
	end
	
	def edit_column_htmlform(activecolumn, revision)
		if activecolumn != ""
			title = activecolumn
			description = @data[title]
			title = CGI.escapeHTML(title)
			hiddeninput = "<input type='hidden' name='columnid' value=\"#{title}\" />"
		end
		return <<END
<form method='post' action=''>
	<div>
			<label for='columntitle'>Columntitle: </label>
			<input id='columntitle' size='16' type='text' value="#{title}" name='new_columnname' />
			<label for='columndescription'>Description: </label>
			<input id='columndescription' size='30' type='text' value="#{description}" name='columndescription' />
			<input type='hidden' name='undo_revision' value='#{revision}' />
			#{hiddeninput}
			<input type='submit' value='Add/Edit Column' />
	</div>
</form>
<h2>Preview</h2>
<table summary='Preview poll head'>
#{to_html([],true,activecolumn)}
</table>

END
	end
end
