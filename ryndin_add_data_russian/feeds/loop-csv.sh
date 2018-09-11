#!/usr/bin/env bash

FILE=$1

if [ -z "$FILE" ]; then
	echo "ERROR: Missing file name. Usage: loopcsv.sh inputfile" 
	exit 1
fi
if [ ! -f "$FILE" ]; then
	echo "ERROR: Missing file: '${FILE}' does not exists."
	exit 1
fi

head -n1 $FILE

while : ; do
	tail -n +2 $FILE
done

