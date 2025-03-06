#!/bin/sh

DAYS=90

# installation path
DUDLE_DIR=/var/www/dudle/

for i in `find $DUDLE_DIR -maxdepth 2 -name last_read_access -mtime +$DAYS`;do
	echo "[`date --rfc-3339=seconds`] `ls -l $i`"
	rm -rf "`dirname "$i"`"
done

# clean up manually deleted polls
for i in `find /tmp/ -maxdepth 2 \! -readable -prune -o -name last_read_access -mtime +$DAYS -print`;do
	echo "[`date --rfc-3339=seconds`] `ls -l $i`"
	rm -rf "`dirname "$i"`"
done
