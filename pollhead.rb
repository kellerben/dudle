############################################################################
# Copyright 2009-2019 Benjamin Kellermann                                  #
#                                                                          #
# This file is part of Dudle.                                              #
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
	# returns true if deletion successful
	def delete_column(column)
		!@data.delete(column).nil?
	end

	# add new column if columnid = ""
	# returns parsed title or false if parsed title == ""
	def edit_column(column, newtitle, cgi)
		delete_column(column) if column != ''
		parsedtitle = newtitle.strip

		return false unless parsedtitle != ''

		@data[parsedtitle] = cgi['columndescription'].strip
		parsedtitle
	end

	def to_html(scols, showeditbuttons = false, activecolumn = nil)
		def sortsymb(scols, col)
			<<SORTSYMBOL
			<span class="sortsymb visually-hidden headerSymbol">#{scols.include?(col) ? _('Sort') : _('No Sort')}</span>
			<span class='sortsymb' aria-hidden='true'> #{scols.include?(col) ? SORT : NOSORT}</span>
SORTSYMBOL
		end
		ret = '<tr>'
		ret += "<th colspan='2'><a href='?sort=name'>" + _('Name') + " #{sortsymb(scols, 'name')}</a></th>\n" unless showeditbuttons
		@data.sort.each { |columntitle, columndescription|
			ret += "<th class='polloptions' title=\"#{CGI.escapeHTML(columndescription)}\""
			ret += " id='active' " if activecolumn == columntitle
			ret += '>'
			ret += "<a href=\"?sort=#{CGI.escape(columntitle)}\">" unless showeditbuttons
			ret += "#{CGI.escapeHTML(columntitle)} <span class='visually-hidden'>#{CGI.escapeHTML(columndescription)} </span>"
			ret += "#{sortsymb(scols, columntitle)}</a>" unless showeditbuttons
			if showeditbuttons
				editstr = _('Edit option')
				deletestr = _('Delete option')
				ret += <<EDITDELETE
<form method='post' action=''>
	<div class='editdelete'>
			<a class='editcolumn' href="?editcolumn=#{CGI.escape(columntitle)}" title="#{editstr}" aria-label="#{editstr}">
				#{EDIT}
			</a>|
		<input style='padding:0;margin:0' title='#{deletestr}' aria-label='#{deletestr}' class='delete' type='submit' value='#{DELETE}' />
		<input type='hidden' name='deletecolumn' value="#{CGI.escapeHTML(columntitle)}" />
	</div>
</form>
EDITDELETE
			end
			ret += '</th>'
		}
		ret += "<th><a href='?'>" + _('Last edit') + " #{sortsymb(scols, 'timestamp')}</a></th>\n" unless showeditbuttons
		ret += "</tr>\n"
		ret
	end

	def edit_column_htmlform(activecolumn, revision)
		if activecolumn != ''
			title = activecolumn
			description = @data[title]
			title = CGI.escapeHTML(title)
			hiddeninput = "<input type='hidden' name='columnid' value=\"#{title}\" />"
		end
		columntitlestr = _('Option')
		descriptionstr = _('Description (optional)')
		addeditstr = _('Confirm option')
		previewstr = _('Preview')
		hint = _('Enter all the options (columns) which you want the participants of the poll to choose among. For each option you give here, the participants will choose a vote.')
		ret = <<END
<form method='post' action='' accept-charset='utf-8'>
	<div class='textcolumn'>#{hint}</div>
	<table class='settingstable'>
		<tr>
			<td class='label'><label for='columntitle'>#{columntitlestr}:</label></td>
			<td><input id='columntitle' type='text' value="#{title}" name='new_columnname' /></td>
		</tr><tr>
			<td class='label'><label for='columndescription'>#{descriptionstr}:</label></td>
			<td><input id='columndescription' type='text' value="#{CGI.escapeHTML(description.to_s)}" name='columndescription' /></td>
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
#{to_html([], true, activecolumn)}
</table>
END
		end
		ret
	end
end
