#!/bin/bash

SCRIPTPATH="$(dirname "$( realpath ${BASH_SOURCE[0]} )" )"

source $SCRIPTPATH/b-log/b-log.sh  # include the script
LOG_LEVEL_ALL

shopt -s extglob
shopt -s dotglob

DUMPNAME=$1
OUTNAME_=${DUMPNAME#.}
OUTNAME="${DUMPNAME%"$OUTNAME_"}${OUTNAME_%.*}"
echo $OUTNAME

DIR=/data

TMPDIR=/tmp/sql_$(date +%s)
mkdir -p $TMPDIR

INFO Preprocessing: excise views

VIEW_START_LINE=$(\
	cat $DIR/$DUMPNAME |
	grep -n 'Temporary table structure' | \
	cut -f1 -d: | \
	head -n1
	)

cat $DIR/$DUMPNAME | \
	head -n$VIEW_START_LINE \
	> $TMPDIR/$DUMPNAME

INFO Converting to SQLite 

rm -f $DIR/$OUTNAME.db

$SCRIPTPATH/mysql2sqlite/mysql2sqlite $TMPDIR/$DUMPNAME | \
	tee $TMPDIR/$OUTNAME.sqlite | \
	sqlite3 $DIR/$OUTNAME.db

INFO Adding views

sqlite3 $DIR/$OUTNAME.db < $SCRIPTPATH/views.sql

INFO Cleanup: removing temporary files
rm -r $TMPDIR
