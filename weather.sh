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

readrc() { # arguments: $1 = location name
    while read token data rest
    do
	case $token in
	    default)
		rc_default=$data
		;;
	    location)
		if [ "$rest" == "$1" ]; then
		    rc_location=$data
		fi
		;;
	    unit)
		rc_unit=$data
		;;
	    *) ;;
	esac
    done
}

# Command line processing

rcfile="$WEATHERRC"

while getopts f:u: opt; do
    case $opt in
	f)  if [ ! -f "$OPTARG" ]; then
	       	echo "$0: Could not find configuration file $OPTARG" >&2
		exit 1
	    fi
	    rcfile=$OPTARG
	    ;;
	u)  if ( [ $OPTARG != "c" ] && [ $OPTARG != "f" ] ); then
		echo "$0: Wrong unit, can only be 'c' or 'f'." >&2
		exit 1
	    fi
	    unit=$OPTARG
	    ;;
	\?) echo "$0: Invalid option: -$OPTARG" >&2
	    usage
	    exit 1
    esac
done

shift $((OPTIND - 1))

case $# in
    0)
	;;
    1)
	if only_digits "$1"
	then woeid=$1
	else location_name="$1"
	fi
	;;
    *)
	echo "Wrong number of arguments" >&2
	usage
	exit 1
esac

if [ -z $woeid ] || [ -z $unit ]; then
    readrc "$location_name" < "$rcfile"
    woeid=${woeid:-$rc_woeid}
fi

if [ -z $woeid ]; then
    if [ -n "$location_name" ]; then
	woeid=$rc_woeid
    else
	woeid=$rc_default
    fi
fi

if [ -z woeid ]; then
    echo "No WOEID given."
    exit 1
fi

unit=${unit:-$rc_unit}
unit=${unit:-c}

echo "Unit: " $unit "WOEID: " $woeid

# fetch -q -o - \
curl -m 4 -s \
 "http://weather.yahooapis.com/forecastrss?w=${woeid}&u=${unit}" | \
awk -f $AWKLIB/getxml.awk -f $AWKFILE_DIR/weather.awk /dev/stdin
