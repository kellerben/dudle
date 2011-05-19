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

DOMAIN=dudle

locale: $(foreach p,$(wildcard locale/*/$(DOMAIN).po), $(addsuffix .mo,$(basename $p)))

locale/$(DOMAIN).pot: *.rb *.cgi
	rm -f $@
	rgettext *.cgi *.rb -o $@

%.mo: %.po
	msgfmt $*.po -o $*.mo

locale/%/$(DOMAIN).po: locale/$(DOMAIN).pot
	msgmerge $@ $? >/tmp/$(DOMAIN)_$*_tmp.po
	if [ "`msgcomm -u /tmp/$(DOMAIN)_$*_tmp.po $@`" ];then\
		mv /tmp/$(DOMAIN)_$*_tmp.po $@;\
	else\
		touch $@;\
	fi
	@if [ "`potool -fnt $@ -s`" != "0" -o "`potool -ff $@ -s`" != "0" ];then\
		echo "WARNING: There are untranslated Strings in $@";\
		if [ "X:$$DUDLE_POEDIT_AUTO" = "X:$*" ]; then\
			poedit $@;\
		fi;\
	fi
