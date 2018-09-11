#!/usr/bin/env bash

LINES=$1
SLEEPTIME=$2

lines=1
sleeptime=1

if [ ! -z "$LINES" ]; then
	lines=$LINES
fi
if (($lines==0)); then
	let lines=1
fi
if [ ! -z "$SLEEPTIME" ]; then
	sleeptime=$SLEEPTIME
fi
if (($sleeptime==0)); then
	let sleeptime=1
fi

counter=0

while read line
do
	echo $line
	let counter+=1
	if (($counter==$lines)); then
		let counter=0
		sleep $sleeptime	
	fi
done


