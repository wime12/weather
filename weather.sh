#!/bin/sh

AWKLIB=/usr/local/share/awklib
AWKFILE_DIR=/usr/local/share/weather
WEATHER_PLACES=~/.weather-places

WEATHER_UNIT="c"

while getopts f:u: opt; do
    case $opt in
	f) WEATHER_PLACES=$OPTARG
	    ;;
	u) WEATHER_UNIT=$OPTARG
	    ;;
    esac
fi

shift $((OPTIND - 1))

# if $1; then
    # if $1 ~ <WOEID> then
    #	WEATHER_LOCATION=$1
    # else if $1 ~ <place name> then
    #   WEATHER_LOCATION=$(get WOEID from .weather-places)
    # else error
# else
    # read first place from .weather_places and determine WOEID
    # if no first place found then error
# fi

# FORMAT FOR CONFIGURATION FILE
# unit c/f
# place Regensburg 687337
# place Trieching 700017
# place Juarez 116556
# place Playa del Carmen 136973

WEATHER_LOCATION=${1:-687337}

ping -q -c 1 "weather.yahooapis.com" 1>/dev/null || exit 1

fetch -q -o - "http://weather.yahooapis.com/forecastrss?w=${WEATHER_LOCATION}&u=${WEATHER_UNIT}" | \
awk -f $AWKLIB/getxml.awk -f $AWKFILE_DIR/weather.awk /dev/stdin
