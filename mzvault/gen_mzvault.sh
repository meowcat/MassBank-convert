#!/bin/bash

SCRIPTPATH="$(dirname "$( realpath ${BASH_SOURCE[0]} )" )"

DUMPNAME=$1
OUTNAME_=${DUMPNAME#.}
OUTNAME="${DUMPNAME%"$OUTNAME_"}${OUTNAME_%.*}"
echo $OUTNAME

DIR=/data
TMPDIR=/tmp/sql_$(date +%s)
mkdir -p $TMPDIR
export MZVGEN_CONFIG_DIR=$TMPDIR

# create config file
echo "data_source: /data/$DUMPNAME" > $TMPDIR/config.yaml
echo "file_out: /data/$OUTNAME-mzvault.db" >> $TMPDIR/config.yaml
echo 'massbank_base: "https://massbank.eu/MassBank/RecordDisplay?id="' >> $TMPDIR/config.yaml
echo "collapse_inchikey: false" >> $TMPDIR/config.yaml

echo -----------------
echo Using settings:
cat $TMPDIR/config.yaml
echo -----------------

# run R conversion script
cd $SCRIPTPATH
Rscript $SCRIPTPATH/workflow.R

