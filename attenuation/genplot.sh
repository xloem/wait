#!/bin/sh
TAG=${1:-${TAG:?}}

FREQMIN=${FREQMIN:-24M}
FREQMAX=${FREQMAX:-1700M}
FREQINTERVAL="${2:-250k}"

TIMEMIN="$(date +%s)"
TIMEINTERVAL="${3:-60}"
TOTALTIME="${4:-30m}"

GAIN="${5:-50}"

DATADIR=../web/data
mkdir -p $DATADIR

power_tmp="$(mktemp)"
console_tmp="$(mktemp)"
logfile_tmp=".$(mktemp)"
mkdir -p "${logfile_tmp%/*}"

echo "Logging $TAG-$FREQINTERVAL-$FREQMIN-$FREQMAX-$GAIN-$TOTALTIME-$TIMEINTERVAL-$TIMEMIN-..."

echo '>' rtl_power -f "$FREQMIN:$FREQMAX:$FREQINTERVAL" -i "$TIMEINTERVAL" -g $GAIN -e "$TOTALTIME" "$power_tmp" > "$console_tmp"
RTL_LOGFILE="$logfile_tmp" rtl_power -f "$FREQMIN:$FREQMAX:$FREQINTERVAL" -i "$TIMEINTERVAL" -g $GAIN -e "$TOTALTIME" "$power_tmp" 2>> "$console_tmp" || {
	cat "$console_tmp" 1>&2
	rm "$power_tmp"
	rm "$console_tmp"
	exit 1
}

TIMEMAX="$(date +%s)"
name="$TAG-$FREQINTERVAL-$FREQMIN-$FREQMAX-$GAIN-$TOTALTIME-$TIMEINTERVAL-$TIMEMIN-$TIMEMAX"
#DATADIR="$DATADIR/$name"
mkdir -p "$DATADIR"
namepfx="$DATADIR/$name-"

CONSOLE_TXT="$namepfx"console.txt
LOGFILE_RAW="$namepfx"logfile.raw
RTL_POWER_CSV="$namepfx"rtl_power.csv
REPORT_HTML="$namepfx"report.html

mv "$console_tmp" "$CONSOLE_TXT"
echo "$CONSOLE_TXT"

if [ -e "$logfile_tmp" ]; then
	mv "$logfile_tmp" "$LOGFILE_RAW"
	echo "$LOGFILE_RAW"
fi

mv "$power_tmp" "$RTL_POWER_CSV"
echo "$RTL_POWER_CSV"

make "$REPORT_HTML"
