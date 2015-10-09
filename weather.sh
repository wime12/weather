#!/bin/sh

AWKLIB=/usr/local/share/awklib
AWKFILE_DIR=/usr/local/share/weather
WEATHERRC=~/.weatherrc

WEATHER_UNIT="c"
WEATHER_WOEID=""

usage() {
    echo "$0 [-f rcfile] [-u unit] [woeid|place]"
}

while getopts f:u: opt; do
    case $opt in
        f) WEATHERRC=$OPTARG
            ;;
        u) WEATHER_UNIT=$OPTARG
            ;;
    esac
done

shift $((OPTIND - 1))

if [ ! -f "$WEATHERRC" ]; then
    echo "$0: configuration file $WEATHERRC not found"
    exit 1
fi

line=$(egrep -m 1 '^[[:blank:]]*unit[[:blank:]]+[cf][[:blank:]]*$'
if [ -n "line" ]; then
    WEATHER_UNIT=$(echo "$line" | egrep -o "[cf][[:blank:]]*$")
    WEATHER_UNIT=${WEATHER_UNIT%%[!cf]}
fi

# TODO: Do not read location from configuration file if WOEID is set
case $# in
    0)  line=$(egrep -m 1 '^[[:blank:]]*place[[:blank:]]+.*[0-9]+[[:blank:]]*$' \
            "$WEATHERRC")
        if [ -z "$line" ]; then
            echo "$0: no default location found in $WEATHERRC" >&2
	    exit 1
        else
            woeid=$(echo $line | egrep -o "[0-9]+[[:blank:]]*$")
            woeid=${woeid%%[!0-9]*}
        fi
        ;;
    1)  if echo $1 | egrep -q "^[0-9]+$"; then
            woeid=$1
        else
            line=$(egrep "^[[:blank:]]*place[[:blank:]]+$1[[:blank:]]+[0-9]+[[:blank:]]*$" \
                "$WEATHERRC")
            if [ -n "$line" ]; then
                woeid=$(echo $line | egrep -o "[0-9]+[[:blank:]]*$")
                woeid=${woeid%%[!0-9]*}
            else
                echo "$0: location \"$1\" not found" >&2
		exit 1
            fi
        fi
        ;;
    *)  echo "$0: too many arguments" >&2
        usage
	exit 1
esac

# fetch -q -o -
curl -m 4 -s "http://weather.yahooapis.com/forecastrss?w=${woeid}&u=${WEATHER_UNIT}" | \
awk -f $AWKLIB/getxml.awk -f $AWKFILE_DIR/weather.awk /dev/stdin
