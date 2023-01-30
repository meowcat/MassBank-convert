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

INFO Dumping from MySQL port $MYSQL_PORT

INFO Converting to SQLite 

rm $DIR/$OUTNAME.db
rm $DIR/$OUTNAME.sqlite

$SCRIPTPATH/mysql2sqlite/mysql2sqlite $DIR/$DUMPNAME | \
	tee $DIR/$OUTNAME.sqlite | \
	sqlite3 $DIR/$OUTNAME.db
sqlite3 $DIR/$OUTNAME < $SCRIPTPATH/views.sql

