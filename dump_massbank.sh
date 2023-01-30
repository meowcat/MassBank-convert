#!/bin/bash

INSTANCE=${1:-1}
TARGET=${2:-/tmp}
DUMP_NAME=massbank_$INSTANCE_`date +%s.sql`

docker exec ${INSTANCE}_mariadb_1 \
    bash -c 'mysqldump -hlocalhost -uroot -p$MYSQL_ROOT_PASSWORD MassBank --result-file /tmp/dump.sql'

docker cp ${INSTANCE}_mariadb_1:/tmp/dump.sql $TARGET/$DUMP_NAME

docker exec ${INSTANCE}_mariadb_1 \
    bash -c 'rm /tmp/dump.sql'

echo $TARGET/$DUMP_NAME