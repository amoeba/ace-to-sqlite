#!/bin/sh

# export.sh
#
# Dump ACE database to SQLite databases

DBS="ace_auth ace_shard ace_world"

echo "$DBS" | tr ' ' '\n' | while read -r db; do
  echo "Exporting database $db..."

  db-to-sqlite --all "mysql://root:root@localhost/$db" "$db.db"
  echo "...done exporting database $db."
done
