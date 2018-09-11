#!/usr/bin/env bash

TICKERS="'USDHUF=x','EURHUF=x','USDEUR=x','RUBHUF=x','USDRUB=x','RUBEUR=x'"

# csv header
echo "symbol,name,price"

while : ; do
    # csv data
	curl -s "http://download.finance.yahoo.com/d/quotes.csv?s=${TICKERS}&f=snl1"
	# NOTE: there is a limit of 2000 reqest / hour / IP
	sleep 10
done


