#!/bin/sh

AWKLIB=/usr/local/share/awklib
AWKFILE_DIR=/usr/local/share/weather
SHLIB=/usr/local/share/shlib
WEATHERRC=~/.weatherrc

WEATHER_WOEID=""

. $SHLIB/isnumber.sh

usage() {
    echo "$0 [-f rcfile] [-u unit] [woeid|place]" >&2
}

search_woeid() {
    if [ "$3" == "$4" ]; then
	echo "$2"
    fi
}

first_woeid() {
    echo "$2"
}

readrc() { # arguments: $1 = function, $2 = data
    local rc_woeid rc_unit
    while [ -z "$rc_woeid" ] || [ -z "$rc_unit" ] && read token data rest; do
	echo $token $data $rest
	case "$token" in
	    woeid)
		rc_woeid=$($1 token data rest "$2")
		;;
	    unit)
		rc_unit=$data
	esac
    done < "$rcfile"
    # TODO: return woeid and unit (assignment or echo?)
}

# Command line processing

rcfile="$WEATHERRC"
unit="$WEATHER_UNIT"

while getopts f:u: opt; do
    case $opt in
	f)  if [ ! -f "$OPTARG" ]; then
	       	echo "$0: Could not find configuration file $OPTARG" >&2
		exit 1
	    fi
	    rcfile=$OPTARG
	    ;;
	u)  if [ $OPTARG != "c" ] || [ $OPTARG != "f" ]; then
		echo "$0: Wrong unit, can only be 'c' or 'f'." >&2
		exit 1
	    fi
	    unit=$OPTARG
	    ;;
	\?) echo "$0: Invalid option: -$OPTARG" >&2
    esac
done

shift $((OPTIND - 1))

case $# in
    0)  woeid=$(readrc first_woeid)
	if [ -n "$woeid" ]; then
	    echo "$0: No default WOEID found in configuration file." >&2
	    exit 1
	fi
	;;
    1)  if only_digits "$1"; then
	    woeid="$1"
	else
	    woeid=$(readrc search_woeid $1)
	    if [ -n "$woeid" ]; then
		echo "$0: Could not find WOEID of '$1' in configuration file." >&2
		exit 1
	    fi
	fi
	;;
    *)  echo "$0: Wrong number of arguments" >&2
        usage
	exit 1
esac

WEATHER_UNIT=${WEATHER_UNIT:-c}

# curl -m 4 -s "http://weather.yahooapis.com/forecastrss?w=${woeid}&u=${WEATHER_UNIT}" | \
fetch -q -o - | \
awk -f $AWKLIB/getxml.awk -f $AWKFILE_DIR/weather.awk /dev/stdin
