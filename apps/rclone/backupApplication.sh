#!/bin/bash

backup_dir="/var/lib/backups/pgsql"
filename="pgsql-`hostname`-`eval date +%Y%m%d`.sql.gz"
fullpath="${backup_dir}/${filename}"

mkdir -p $backup_dir

# Dump the entire database

docker exec postgres pg_dumpall -U admin | gzip > $fullpath

if [[ $? != 0 ]]; then
  echo "Error dumping database"
  exit 1
fi

# Delete backups older than 7 days
find $backup_dir -ctime +7 -type f -delete

# Backup via rclone
cd $backup_dir
rclone sync . crypt:/composeexample
if [[ $? != 0 ]]; then
  echo "Error uploading backup"
  exit 1
fi
