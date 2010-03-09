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

default: locale/de/dudle.mo

locale/dudle.pot: *.rb *.cgi
	rm -f $@
	rgettext *.cgi *.rb -o $@

%.mo: %.po
	rmsgfmt $*.po -o $*.mo

locale/%/dudle.po: locale/dudle.pot
	msgmerge locale/$*/dudle.po locale/dudle.pot >/tmp/dudle_$*_tmp.po
	if [ "`msgcomm -u /tmp/dudle_$*_tmp.po locale/$*/dudle.po`" ];then\
		mv /tmp/dudle_$*_tmp.po locale/$*/dudle.po;\
	else\
		touch locale/$*/dudle.po;\
	fi
	if [ "`postats -f locale/$*/dudle.po|tail -n1 |cut -d"(" -f3|cut -d")" -f1`" = "100%\n" ];\
		then poedit locale/$*/dudle.po;\
	fi
