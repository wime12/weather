#!/bin/sh

AWKLIB=/usr/local/share/awklib
AWKFILE_DIR=/usr/local/share/weather
WEATHERRC=~/.weatherrc

WEATHER_UNIT="c"

while getopts f:u: opt; do
    case $opt in
	f) WEATHERRC=$OPTARG
	    ;;
	u) WEATHER_UNIT=$OPTARG
	    ;;
    esac
fi

shift $((OPTIND - 1))

if $(($# == 0)); then
    line=$(egrep -m 1 '^[[:space:]]*place[[:space:]]+.*[[:digit:]]+[[:space:]]*$' "$WEATHERRC")
    if [ -n $line ]""; then
	error "no default location found"
    else
	woeid=$(echo $line | egrep -o "[[:digit:]]+[[:space:]]*$")
	woeid=${woeid%%[!0-9]*}
    fi
elsif $(($# == 1)); then
    if $1 ~ WOEID; then
	woeid=$1
    else
	get_WOEID_from_rc
	if WOEID_found
	   woeid=$location
	else
	    error "location not found"
	    usage
	fi
    fi
else
    error "too many arguments"
    usage
fi

# FORMAT FOR CONFIGURATION FILE
# unit c/f
# place Regensburg 687337
# place Trieching 700017
# place Juarez 116556
# place Playa del Carmen 136973

woeid=${1:-687337}

ping -q -c 1 "weather.yahooapis.com" 1>/dev/null || exit 1

fetch -q -o - "http://weather.yahooapis.com/forecastrss?w=${woeid}&u=${WEATHER_UNIT}" | \
awk -f $AWKLIB/getxml.awk -f $AWKFILE_DIR/weather.awk /dev/stdin
