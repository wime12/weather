#!/bin/sh

AWKLIB=/usr/local/share/awklib
AWKFILE_DIR=/usr/local/share/weather
SHLIB=/usr/local/share/shlib
WEATHERRC=~/.weatherrc

WEATHER_WOEID=""

. $SHLIB/isnumber.sh

usage() {
    echo "$0 [-f rcfile] [-u unit] [woeid|place]"
}

search_woeid() {
    if [ $4 == $5 ]; then
	woeid=${woeid:-$3}
    fi
}

first_woeid() {
    woeid=${woeid:-$3}
}

readrc() { # arguments: $1 = function, $2 = data
    while read token data rest; do
	case $token in
	    woeid) $1 token data rest $2
		;;
	    unit)
		unit=${unit:-$data}
	esac
    done < "$rcfile"
}

# Command line processing

rcfile="$WEATHERRC"
unit="$WEATHER_UNIT"

while getopts f:u: opt; do
    case $opt in
        f)  if [ ! -f "$OPTARG" ]; then
		echo "$1: Could not find configuration file $OPTARG" >&2
		exit 1
	    fi
	    rcfile=$OPTARG
            ;;
        u)  if [ $OPTARG != "c" ] || [ $OPTARG != "f" ]; then
		echo "$1: Wrong unit, can only be 'c' or 'f'." >&2
		exit 1
	    fi
	    unit=$OPTARG
            ;;
    esac
done

shift $((OPTIND - 1))

case # in
    0)  woeid=$(readrc first_woeid)
	if [ -n $woeid ]; then
	    "$1: No default WOEID found in configuration file."
	    exit 1
	fi
	;;
    1)	if only_digits $1; then
	    woeid=$1
	else
	    woeid=$(readrc search_woeid $1)
	    if [ -n $woeid ]; then
		"$1: Could not find WOEID of '$1' in configuration file."
		exit 1
	    fi
	fi
	;;
    *)  echo "$1: Wrong number of arguments" >&2
        usage
	exit 1
esac

if [ ! -f "$WEATHERRC" ]; then
    echo "$0: configuration file $WEATHERRC not found"
    exit 1
fi

if [ -n $unit ] && [ -n $woeid ]; then

WEATHER_UNIT=${WEATHER_UNIT:-c}

# fetch -q -o -
curl -m 4 -s "http://weather.yahooapis.com/forecastrss?w=${woeid}&u=${WEATHER_UNIT}" | \
awk -f $AWKLIB/getxml.awk -f $AWKFILE_DIR/weather.awk /dev/stdin
