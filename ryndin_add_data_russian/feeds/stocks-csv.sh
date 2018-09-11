#!/usr/bin/env bash

TICKERS="orcl,aapl,msft,csco,ibm,intc"

# csv header
echo "symbol,name,price,date,_time,volume"

while : ; do
    # csv data
	curl -s "http://download.finance.yahoo.com/d/quotes.csv?s=${TICKERS}&f=snl1d1t1v"
    # NOTE: there is a limit of 2000 reqest / hour / IP
	sleep 10
done


