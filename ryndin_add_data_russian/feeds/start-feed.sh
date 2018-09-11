#!/usr/bin/env bash

FEED_NAME=$1
if [ ! -d "${FEED_DATA_DIR}" ]; then
    exitWithError "FEED_DATA_DIR not set. Please run setup.sh"
fi

case "${FEED_NAME}" in
    "nano" )
        loop-csv.sh ${FEED_DATA_DIR}/nano.csv | csv2json.sh | sampler.sh | kafka.sh feed ${FEED_NAME}
        ;;
    "forex" )
        forex-csv.sh | csv2json.sh | kafka.sh feed ${FEED_NAME}
        ;;
    "stocks" )
        stocks-csv.sh | csv2json.sh | kafka.sh feed ${FEED_NAME}
        ;;
    "types" )
        datatypes-csv.sh | csv2json.sh | sampler.sh | kafka.sh feed ${FEED_NAME}
        ;;
    "msg" )
        message-csv.sh | csv2json.sh | sampler.sh | kafka.sh feed ${FEED_NAME}
        ;;
    "tx" )
        card-transactions-csv.sh | csv2json.sh | sampler.sh | kafka.sh feed ${FEED_NAME}
        ;;
    "spatial" )
        loop-csv.sh ${FEED_DATA_DIR}/spatial.csv | csv2json.sh | sampler.sh | kafka.sh feed ${FEED_NAME}
        ;;
    "complex" )
        loop-file.sh ${FEED_DATA_DIR}/complex.json | sampler.sh | kafka.sh feed ${FEED_NAME}
        ;;
    "buses" )
        loop-file.sh ${FEED_DATA_DIR}/30-min-at-50-rps.json | sampler.sh 20 1 | kafka.sh feed ${FEED_NAME}
        ;;
    "goldengate" )
        loop-file.sh ${FEED_DATA_DIR}/gg_orders.json | sampler.sh | kafka.sh feed ${FEED_NAME}
        ;;
    "marketing" )
        loop-csv.sh ${FEED_DATA_DIR}/RTMarketingDemo_data/events.CSV | csv2json.sh | sampler.sh | kafka.sh feed ${FEED_NAME}
        ;;
    "russian_events" )
        loop-csv.sh ${FEED_DATA_DIR}/RTMarketingDemo_data/russian_events.csv | csv2json.sh | sampler.sh | kafka.sh feed ${FEED_NAME}
        ;;
    *)
        echo "Unknown feed name: ${FEED_NAME}"
    echo "Possible feed names: nano, forex, stocks, types, msg, tx, spatial, complex, buses, goldengate"
        ;;
esac

