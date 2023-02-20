#!/bin/bash
#
# generate_world_database.sh
#
# Generates a SQLite database from the latest ACE World release. Assumes you
# have MySQL running locally with root password turned off. Also assumes you
# have the following tools already installed:
#
#   - curl
#   - jq
#   - unzip
#   - mysql
#   - csvs-to-sqlite (python -m pip install csvs-to-sqlite)
#
# Usage:
#
#   ./generate_world_database.sh [-v]

AUTH="root"
DB="ace_world"
ORG="ACEmulator"
REPO="ACE-World-16PY-Patches"
VERBOSE=0

LOG() {
  if [ "$VERBOSE" == 1 ]; then
    echo "$1"
  fi
}

process_command_line_args() {
  if [ -n "$1" ] && [ "$1" == "-v" ]; then
    VERBOSE=1
  fi
}

exit_unless_exe_exists() {
  if [ -z $(command -v "$1") ]; then
    echo "Program $1 was not found and is required. Install it and re-run this script."
    exit
  fi
}

download_and_decompress_latest_release() {
  LOG "Fiding latest release..."
  DOWNLOAD_URL=$(curl -s https://api.github.com/repos/$ORG/$REPO/releases | jq '.[0].assets[0].browser_download_url' | tr -d '"')

  LOG "Downloading latest release from $DOWNLOAD_URL..."
  curl -s -O -L "$DOWNLOAD_URL"

  # unzip can't read from stdin so we do this as a separate step
  unzip -o ACE-World-Database*.sql.zip
  LOG "Done downloading and decompressing latest World release."
}

provision_db_and_load_sql() {
  LOG "Dropping databases..."
  mysql -u $AUTH -B -e "DROP DATABASE $DB;"
  LOG "Creating databases..."
  mysql -u $AUTH -B -e "CREATE DATABASE $DB;"
  LOG "Loading World release..."
  find . -iname "ACE-World*.sql" | while read -r f
  do
    LOG "$f"
    mysql --database=ace_world -u $AUTH < "$f";
  done;
  LOG "Done provisioning and loading SQL."
}

export_as_tsvs() {
  TABLES=$(mysql -u $AUTH -B -e "SELECT distinct table_name FROM information_schema.columns WHERE table_schema = '$DB';" | awk '{print $1}' | grep -iv ^TABLE_NAME)
  OUTDIR="./$DB"
  mkdir -p "$OUTDIR"

  for table in $TABLES; do
    LOG "Exporting table $table..."
    outfile="./$DB/$table.tsv"
    mysql -u $AUTH "$DB" -B -e "SELECT * FROM $table;" > "$outfile"
    LOG "Done exporting table $table from database $DB to $outfile."
  done
}

convert_to_sqlite() {
  LOG "Creating SQLite database..."
  csvs-to-sqlite $OUTDIR/*.tsv "$DB.db" -s $'\t'
  LOG "Done."
}

main() {
  process_command_line_args "$1"

  download_and_decompress_latest_release
  provision_db_and_load_sql
  export_as_tsvs
  convert_to_sqlite
}

exit_unless_exe_exists "curl"
exit_unless_exe_exists "jq"
exit_unless_exe_exists "unzip"
exit_unless_exe_exists "mysql"
exit_unless_exe_exists "csvs-to-sqlite"

main "$@"
