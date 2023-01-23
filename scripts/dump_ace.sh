#!/bin/sh

# dump_ace.sh
#
# Dump ACE database to CSV files

set -x

DBS=("ace_auth" "ace_shard" "ace_world")
WORKDIR="/var/lib/mysql-files"
DBUSERNAME="root"
DBPASSWORD="1999asheron2017" # Changeme
TEMPFILE="$WORKDIR/tempdata"

for db in ${DBS[@]}; do
  echo "$db"

  # Get tables for db
  TABLES=`mysql -u $DBUSERNAME --password=$DBPASSWORD -B -e "SELECT distinct table_name FROM information_schema.columns WHERE table_schema = '$db';" | awk '{print $1}' | grep -iv ^TABLE_NAME`

  for table in $TABLES; do
    echo "$table"

    outfile="/var/lib/mysql-files/$db-$table.csv"

    # Headers
    mysql -u $DBUSERNAME --password=$DBPASSWORD -B -e "SELECT distinct column_name FROM information_schema.columns WHERE table_name = '$table';" | awk '{print $1}' | grep -iv ^COLUMN_NAME$ | sed 's/^/"/g;s/$/"/g' | tr '\n' ',' > $outfile
    echo "" >> $outfile

    # Data
    mysql -u $DBUSERNAME --password=$DBPASSWORD $db -B -e "SELECT * INTO OUTFILE '$TEMPFILE' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' FROM $table;"
    cat $TEMPFILE >> $OUTFILE
    rm $TEMPFILE

    echo "Done with $outfile"
  done
done
