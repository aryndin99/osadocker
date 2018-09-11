#!/usr/bin/env bash

export DICTIONARY=/usr/share/dict/words
export TOTAL_NUMBER=$(cat $DICTIONARY | wc -l)

random_word()
{
    lineidx=$(( ($RANDOM * 10000 + $RANDOM) % $TOTAL_NUMBER ))
    echo "$(tail -n+${lineidx} ${DICTIONARY} | head -n1)"
}

random_bool()
{
    bools=(true false)
    boolidx=$((RANDOM%2))
    echo ${bools[$boolidx]};
}

# write header
    echo "messagetime,messageint,messagedouble,messagetext,messageboolean"


while : ; do
    fMessage="$(random_word) $(random_word) $(random_word) $(random_word) $(random_word) $(random_word) $(random_word)"
    fInteger=$RANDOM
    fTime=$(date +%s%N)
    fDouble=$RANDOM.$RANDOM
    fBoolean=$(random_bool)
# write data
    echo "${fTime},${fInteger},${fDouble},\"${fMessage}\",$fBoolean"
done






