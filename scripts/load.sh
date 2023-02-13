#!/bin/sh

# "auth"
AUTH="root"

mysql -u $AUTH --password=$AUTH -B -e "CREATE DATABASE ace_auth; CREATE DATABASE ace_shard; CREATE DATABASE ace_world;"

find DatabaseSetupScripts/Base -iname "*.sql" | while read f
do
  mysql -u $AUTH --password=$AUTH < "$f";
done;

find DatabaseSetupScripts/Updates/Shard -iname "*.sql" | while read f
do
  mysql --database=ace_shard -u $AUTH --password=$AUTH < "$f";
done;

find DatabaseSetupScripts/Updates/Authentication -iname "*.sql" | while read f
do
  mysql --database=ace_auth -u $AUTH --password=$AUTH < "$f";
done;

find DatabaseSetupScripts/Updates/World -iname "*.sql" | while read f
do
  mysql --database=ace_world -u $AUTH --password=$AUTH < "$f";
done;

find . -iname "ACE-World*.sql" | while read f
do
  mysql --database=ace_world -u $AUTH --password=$AUTH < "$f";
done;
