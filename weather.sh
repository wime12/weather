#!/bin/sh

AWKLIB=~/.awklib

# Trieching
# WEATHER_LOCATION=700017

# Juarez
# WEATHER_LOCATION=116556

# Playa del Carmen
# WEATHER_LOCATION=136973

# Regensburg
WEATHER_LOCATION=${1:-687337}

WEATHER_UNIT="c"

ping -q -c 1 "weather.yahooapis.com" 1>/dev/null || exit 1

fetch -q -o - "http://weather.yahooapis.com/forecastrss?w=${WEATHER_LOCATION}&u=${WEATHER_UNIT}" | \
awk -f $AWKLIB/getxml.awk -f $AWKLIB/weather.awk /dev/stdin
