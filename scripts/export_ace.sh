#!/bin/sh

# export_ace.sh
#
# Dump ACE database to CSV files

DBS="ace_auth ace_shard ace_world"
WORKDIR="/var/lib/mysql-files"
DBUSERNAME="root"
DBPASSWORD="root"
TEMPFILE="$WORKDIR/tempdata"

echo "$DBS" | tr ' ' '\n' | while read -r db; do
  echo "Exporting database $db..."

  # Create folder for each db
  mkdir "$WORKDIR/$db"

  # Get tables for db
  TABLES=$(mysql -u $DBUSERNAME --password=$DBPASSWORD -B -e "SELECT distinct table_name FROM information_schema.columns WHERE table_schema = '$db';" | awk '{print $1}' | grep -iv ^TABLE_NAME)

  for table in $TABLES; do
    echo "Exporting table $table..."

    outfile="/var/lib/mysql-files/$db/$table.csv"

    # Headers
    mysql -u $DBUSERNAME --password=$DBPASSWORD -B -e "SELECT distinct column_name FROM information_schema.columns WHERE table_name = '$table';" | awk '{print $1}' | grep -iv ^COLUMN_NAME$ | sed 's/^/"/g;s/$/"/g' | tr '\n' ',' > "$outfile"
    echo "" >> "$outfile"

    # Data
    mysql -u $DBUSERNAME --password=$DBPASSWORD "$db" -B -e "SELECT * INTO OUTFILE '$TEMPFILE' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '""' FROM $table;"
    cat $TEMPFILE >> "$outfile"
    rm $TEMPFILE

    echo "...done exporting table $table from database $db to $outfile"
  done

  echo "...done exporting database $db."
done
