#!/bin/bash

source "$(dirname "$( realpath ${BASH_SOURCE[0]} )" )"/b-log/b-log.sh  # include the script
LOG_LEVEL_ALL

shopt -s extglob
shopt -s dotglob

INSTANCE=$1

source config

INFO Dumping MassBank instance: $INSTANCE

DIR=/store/massbank/instances/$INSTANCE
source $DIR/config

MYSQL_PORT=809${INSTANCE_ID}

INFO Dumping from MySQL port $MYSQL_PORT

INFO Converting to SQLite 

mysql2sqlite/mysql2sqlite $DIR/export/MassBank.sql | sqlite3 $DIR/export/MassBank.db
sqlite3 $DIR/export/MassBank.db < views.sql

if [[ "$TARGET_EXPORT_DEPLOY" != "" ]]
then
	INFO Exporting to $TARGET_EXPORT_DEPLOY/$INSTANCE
	rm -rf $TARGET_EXPORT_DEPLOY/$INSTANCE
	cp -r $DIR/export $TARGET_EXPORT_DEPLOY/$INSTANCE
fi