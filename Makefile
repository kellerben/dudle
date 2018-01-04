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

.DELETE_ON_ERROR:
.POSIX:

DOMAIN=dudle
INSTALL=install -p
INSTALL_DATA=$(INSTALL) -m 644
prefix=/usr/local
datadir=$(prefix)/share
localstatedir=$(prefix)/var

.PHONY: locale
locale: $(foreach p,$(wildcard locale/*/$(DOMAIN).po), $(addsuffix .mo,$(basename $p)))

RGETTEXT=$(firstword $(shell which rgettext rxgettext))

locale/$(DOMAIN).pot: *.rb *.cgi
	rm -f $@
	$(RGETTEXT) *.cgi *.rb -o $@

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

.PHONY: install
install: locale
	$(INSTALL) -d $(DESTDIR)$(localstatedir)/lib/$(DOMAIN)
	for f in about.cgi access_control.rb advanced.rb atom.rb \
		authorization_required.cgi check.cgi customize.cgi \
		customize.rb delete_poll.rb edit_columns.rb error.cgi \
		example.cgi history.rb index.cgi invite_participants.rb \
		maintenance.cgi not_found.cgi overview.rb participate.rb; do \
			$(INSTALL) -D -t $(DESTDIR)$(datadir)/$(DOMAIN) $$f; \
			ln -s $$(realpath --relative-to=$(DESTDIR)$(localstatedir)/lib/$(DOMAIN) $(DESTDIR)$(datadir)/$(DOMAIN))/$$f $(DESTDIR)$(localstatedir)/lib/$(DOMAIN)/$$f; \
	done
	for f in .htaccess charset.rb classic.css config_defaults.rb \
		date_locale.rb default.css dudle.rb favicon.ico hash.rb \
		html.rb log.rb poll.rb pollhead.rb print.css timepollhead.rb \
		timestring.rb vcs_git.rb vcs_test.rb; do \
			$(INSTALL_DATA) -D -t $(DESTDIR)$(datadir)/$(DOMAIN) $$f; \
			ln -s $$(realpath --relative-to=$(DESTDIR)$(localstatedir)/lib/$(DOMAIN) $(DESTDIR)$(datadir)/$(DOMAIN))/$$f $(DESTDIR)$(localstatedir)/lib/$(DOMAIN)/$$f; \
	done
	for mo in locale/*/$(DOMAIN).mo; do \
		lang=$$(dirname $$mo); \
		$(INSTALL_DATA) -D -t $(DESTDIR)$(datadir)/$(DOMAIN)/$$lang $$lang/$(DOMAIN).mo; \
	done
	$(INSTALL) -d $(DESTDIR)$(localstatedir)/lib/$(DOMAIN)/$$lang; \
	ln -s $$(realpath --relative-to=$(DESTDIR)$(localstatedir)/lib/$(DOMAIN) $(DESTDIR)$(datadir)/$(DOMAIN))/locale $(DESTDIR)$(localstatedir)/lib/$(DOMAIN)/locale; \
