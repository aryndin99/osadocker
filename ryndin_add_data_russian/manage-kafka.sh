#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd -P )"

COMMAND="$1"
case "${COMMAND}" in 
	"feed" )
		$SCRIPT_DIR/manage.sh attach /osa/bin/kafka.sh $*
		;;
	* )
		$SCRIPT_DIR/manage.sh exec /osa/bin/kafka.sh $*
		;;
esac

