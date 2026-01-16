#!/bin/bash
# Watchdawg v1.0.0

echo "Starting Watchdawg v0.0.1"
if [[ "$1" != "" && "$2" != "" ]]; then
  BACKUP_DIR=$1
  INPUT=$2
else
  echo "no arguments"
  exit
fi



mkdir -p $BACKUP_DIR
echo "Backup dir created"
file="/etc/passwd"
LOG_DIR="/var/log/.wd/"
chattr +a /var/log/
mkdir -p "$LOG_DIR"


# Read files and to watch
while IFS= read -r line; do
   printf "adding to watchlist: $line\n"
   cp -p --parents "$line" "$BACKUP_DIR"
done < "$INPUT"


while [[ true ]]; do
   while IFS= read -r line; do
      diff -q "$line" "$BACKUP_DIR$line"
      DIFF_EXIT_CODE=$?


      if [ "$DIFF_EXIT_CODE" -eq 1 ]; then
         echo "============" >> "$LOG_DIR/wd.log"
         echo "Woof! File change detected on file $line"
         echo "CHANGE on file $line at $(date)" >> "$LOG_DIR/wd.log"
         diff "$line" "$BACKUP_DIR$line" >> "$LOG_DIR/wd.log"
         cp -p "$line" "$BACKUP_DIR$line"
      fi
   done < "$INPUT"

  sleep 3
done
