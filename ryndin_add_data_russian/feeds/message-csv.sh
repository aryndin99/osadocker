#!/usr/bin/env bash

export DICTIONARY=/usr/share/dict/words
export TOTAL_NUMBER=$(cat $DICTIONARY | wc -l)

random_word()
{
    lineidx=$(( ($RANDOM * 10000 + $RANDOM) % $TOTAL_NUMBER ))
    echo "$(tail -n+${lineidx} ${DICTIONARY} | head -n1)"
}

# echo csv header
echo "messagetime,messagenumber,messagetext"

while : ; do
    fMessage="$(random_word) $(random_word) $(random_word) $(random_word) $(random_word) $(random_word) $(random_word)"
    fNumber=$RANDOM
    fTime=$(date +%s%N)
# echo csv data
    echo "\"${fTime}\",${fNumber},\"${fMessage}\""

done






