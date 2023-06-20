# MassBank conversion

This container contains tools to convert MassBank SQL dumps into SQLite and mzVault formats.
SQLite is convenient for use with RforMassSpectrometry Spectra/MsBackendMassbankSql, while
mzVault is useful for use in Compound Discoverer.

## Usage

* Build the Docker container: `docker build . -t massbank_convert`
* Download a MassBank SQL dump from https://github.com/MassBank/MassBank-data/releases/latest
* If you are running your own MassBank instance with proprietary data: create an SQL dump using
    `dump_massbank.sh` on the MassBank host. This requires only Docker and Bash. Usage:
    `./dump_massbank.sh $INSTANCE [$TARGET]`, where `$INSTANCE` is the MassBank instance number 
    (check `docker ps` if you don't know) and `$TARGET`  is an optional path prefix (`/tmp` by default.)
    The script prints the path of the created dump, which is timestamped.
* Convert the MassBank MariaDB dump to sqlite:
    `docker run --rm -v /$DATADIR:/data massbank_convert /scripts/sqlite/gen_sqlite.sh $DUMPNAME.sql`
    where `$DATADIR` is the directory in which the dump is stored and `$DUMPNAME.sql` is the filename.
    The converted database will be stored in the same directory with filename `$DUMPNAME.db`.

* Convert the sqlite database to an mzVault database:
    `docker run --rm -v /$DATADIR:/data massbank_convert /scripts/mzvault/gen_mzvault.sh $DUMPNAME.db`
    where `$DATADIR` is the directory in which the dump is stored and `$DUMPNAME.db` is the filename.
    The converted database will be stored in the same directory with filename `$DUMPNAME-mzvault.db`.
    

    