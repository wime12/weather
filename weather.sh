#!/bin/sh

AWKLIB=/usr/local/share/awklib
AWKFILE_DIR=/usr/local/share/weather
SHLIB=/usr/local/share/shlib

rcfile=~/.weatherrc

. $SHLIB/isnumber.sh

usage() {
    echo "$0 [-h] [-c] [-f rcfile] [-u unit] [woeid|place]" >&2
}

readrc() { # arguments: $1 = location name
    while read token data rest
    do
	case $token in
	    default)
		rc_default=$data
		;;
	    location)
		if [ "$rest" = "$1" ]; then
		    rc_woeid=$data
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

while getopts f:u:hc opt; do
    case $opt in
	f)  rcfile=$OPTARG
	    ;;
	u)  if ( [ $OPTARG != "c" ] && [ $OPTARG != "f" ] ); then
		echo "$0: Wrong unit, can only be 'c' or 'f'." >&2
		exit 1
	    fi
	    unit=$OPTARG
	    ;;
	h)  usage
	    exit 0
	    ;;
	c)  computer_readable=yes
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
    if [ ! -f "$rcfile" ]; then
	echo "$0: Could not find configuration file $rcfile" >&2
	exit 1
    fi
    readrc "$location_name" < "$rcfile"
fi

if [ -z $woeid ]; then
    if [ -n "$location_name" ]; then
	woeid=$rc_woeid
    else
	woeid=$rc_default
    fi
fi

if [ -z $woeid ]; then
    if [ -n "$location_name" ]; then
	echo "$0: location \"$location_name\" unknown" >&2
    else
	echo "$0: No default location in configuration file \"$rcfile\"" >&2
    fi
    exit 1
fi

unit=${unit:-$rc_unit}
unit=${unit:-c}

# fetch -q -o - \
curl -m 4 -s \
 "http://weather.yahooapis.com/forecastrss?w=${woeid}&u=${unit}" | \
awk -v computer_readable="$computer_readable" -f $AWKLIB/getxml.awk \
    -f $AWKFILE_DIR/weather.awk /dev/stdin
