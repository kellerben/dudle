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

class PollHead
	def initialize
		@data = {}
	end
	def col_size
		@data.size
	end

	# returns a sorted array of all columns
	#	column should be the internal representation
	#	column.to_s should deliver humanreadable form
	def columns
		@data.keys.sort
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
			return <<SORTSYMBOL
<span class='sortsymb'> #{scols.include?(col) ? SORT : NOSORT}</span>
SORTSYMBOL
		end
		ret = "<tr>"
		ret += "<th colspan='2'><a href='?sort=name'>" + _("Name") + " #{sortsymb(scols,"name")}</a></th>\n" unless showeditbuttons
		@data.sort.each{|columntitle,columndescription|
			ret += "<th title=\"#{columndescription}\""
			ret += " id='active' " if activecolumn == columntitle
			ret += ">"
			ret += "<a href=\"?sort=#{CGI.escapeHTML(CGI.escape(columntitle))}\">" unless showeditbuttons
			ret += "#{CGI.escapeHTML(columntitle)}"
			ret += "#{sortsymb(scols,columntitle)}</a>" unless showeditbuttons
			if showeditbuttons
				editstr = _("Edit column")
				deletestr = _("Delete column")
				ret += <<EDITDELETE
<form method='post' action=''>
	<div class='editdelete'>
			<a class='editcolumn' href="?editcolumn=#{CGI.escapeHTML(CGI.escape(columntitle))}" title="#{editstr}">
				#{EDIT}
			</a>|
		<input style='padding:0;margin:0' title='#{deletestr}' class='delete' type='submit' value='#{DELETE}' />
		<input type='hidden' name='deletecolumn' value='#{CGI.escapeHTML(CGI.escape(columntitle))}' />
	</div>
</form>
EDITDELETE
			end
			ret += "</th>"
		}
		ret += "<th><a href='?'>" + _("Last Edit") + " #{sortsymb(scols,"timestamp")}</a></th>\n" unless showeditbuttons
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
		columntitlestr = _("Alternative")
		descriptionstr = _("Description (optional)")
		addeditstr = _("Add/Edit Column")
		previewstr = _("Preview")
		hint = _("Enter all alternatives (columns), you want to ask the participants of the poll. The participants will state one vote for every alternative you give here separately.")
		ret = <<END
<form method='post' action='' accept-charset='utf-8'>
	<div class='textcolumn'>#{hint}</div>
	<table class='settingstable'>
		<tr>
			<td class='label'><label for='columntitle'>#{columntitlestr}:</label></td>
			<td><input id='columntitle' type='text' value="#{title}" name='new_columnname' /></td>
		</tr><tr>
			<td class='label'><label for='columndescription'>#{descriptionstr}:</label></td>
			<td><input id='columndescription' type='text' value="#{description}" name='columndescription' /></td>
		</tr><tr>
			<td></td>
			<td>
				<input type='hidden' name='undo_revision' value='#{revision}' />
				#{hiddeninput}
				<input type='submit' value='#{addeditstr}' />
			</td>
		</tr>
	</table>
</form>
END
		if col_size > 0
			ret += <<END
<h2>#{previewstr}</h2>
<table>
#{to_html([],true,activecolumn)}
</table>
END
		end
		ret
	end
end
