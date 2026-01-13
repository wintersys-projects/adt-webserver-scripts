#!/bin/sh

file_removed() {
xmessage "$2 was removed from $1" &
}

file_modified() {
TIMESTAMP=date
echo "[$TIMESTAMP]: The file $1$2 was modified" >> monitor_log
}

file_created() {
TIMESTAMP=date
echo "[$TIMESTAMP]: The file $1$2 was created" >> monitor_log
}

inotifywait -q -m -r -e modify,delete,create $1 | while read DIRECTORY EVENT FILE
do
  case $EVENT in
    MODIFY*)
      file_modified "$DIRECTORY" "$FILE"
    ;;
    CREATE*)
      file_created "$DIRECTORY" "$FILE"
    ;;
    DELETE*)
      file_removed "$DIRECTORY" "$FILE"
    ;;
  esac
done
