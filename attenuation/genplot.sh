#!/bin/sh
TAG=${1:-${TAG:?}}

FREQMIN=${FREQMIN:-24M}
FREQMAX=${FREQMAX:-1700M}
FREQINTERVAL="${2:-1M}"

TIMEMIN="$(date +%s)"
TIMEINTERVAL="${3:-30}"
TOTALTIME="${4:-15m}"

GAIN="${5:-50}"

DATADIR=web/data
mkdir -p $DATADIR

power_tmp="$(mktemp)"
console_tmp="$(mktemp)"
logfile_tmp="$(mktemp)"

echo "Logging $TAG-$FREQINTERVAL-$FREQMIN-$FREQMAX-$TOTALTIME-$TIMEINTERVAL-$TIMEMIN-..."

echo '>' rtl_power -f "$FREQMIN:$FREQMAX:$FREQINTERVAL" -i "$TIMEINTERVAL" -g $GAIN -e "$TOTALTIME" "$power_tmp" > "$console_tmp"
RTL_LOGFILE="$logfile_tmp" rtl_power -f "$FREQMIN:$FREQMAX:$FREQINTERVAL" -i "$TIMEINTERVAL" -g $GAIN -e "$TOTALTIME" "$power_tmp" 2>>"$console_tmp" || exit 1

TIMEMAX="$(date +%s)"
name="$TAG-$FREQINTERVAL-$FREQMIN-$FREQMAX-$GAIN-$TOTALTIME-$TIMEINTERVAL-$TIMEMIN-$TIMEMAX"
#DATADIR="$DATADIR/$name"
mkdir -p "$DATADIR"
namepfx="$DATADIR/$name-"

CONSOLE_TXT="$namepfx"console.txt
LOGFILE_GZ="$namepfx"logfile.gz
RTL_POWER_CSV="$namepfx"rtl_power.csv
RTL_POWER_PNG="$namepfx"rtl_power.png
FLATTEN_RANGE_CSV="$namepfx"flatten_range.csv
FLATTEN_RANGE_PNG="$namepfx"flatten_range.png

mv "$console_tmp" "$CONSOLE_TXT"
echo "$CONSOLE_TXT"

if [ -e "$logfile_tmp" ]; then
	cat "$logfile_tmp" | zcat > "$LOGFILE_GZ"
	echo "$LOGFILE_GZ"
fi

mv "$power_tmp" "$RTL_POWER_CSV"
echo "$RTL_POWER_CSV"
./heatmap.py "$RTL_POWER_CSV" "$RTL_POWER_PNG"
echo "$RTL_POWER_PNG"

./flatten_range.py "$RTL_POWER_CSV" > "$FLATTEN_RANGE_CSV"
echo "$FLATTEN_RANGE_CSV"
{
	echo 'set terminal png'
	echo 'set datafile separator comma'
	echo 'plot "-" with yerrorlines'
	cat "$FLATTEN_RANGE_CSV"
	echo e
} | gnuplot > "$FLATTEN_RANGE_PNG"
echo "$FLATTEN_RANGE_PNG"
