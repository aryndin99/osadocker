#!/usr/bin/env bash

FILE=$1

if [ -z "$FILE" ]; then
	echo "ERROR: Missing file name. Usage: loopfile.sh inputfile" 
	exit 1
fi

if [ ! -f "$FILE" ]; then
	echo "ERROR: Missing file: '${FILE}' does not exists."
	exit 1
fi

while : ;
do
	cat ${FILE}
done

