#!/bin/sh
TAG=${1:-${TAG:?}}

FREQMIN=${FREQMIN:-24M}
FREQMAX=${FREQMAX:-1700M}
FREQINTERVAL="${2:-1M}"

TIMEMIN="$(date +%s)"
TIMEINTERVAL="${3:-100}"
TOTALTIME="${4:-15m}"

GAIN="${5:-50}"

DATADIR=web/data
mkdir -p $DATADIR

tmp="$(mktemp)"

echo "Logging $TAG-$FREQINTERVAL-$FREQMIN-$FREQMAX-$TOTALTIME-$TIMEINTERVAL-$TIMEMIN-..."

rtl_power -f "$FREQMIN:$FREQMAX:$FREQINTERVAL" -i "$TIMEINTERVAL" -g $GAIN -e "$TOTALTIME" "$tmp" || exit 1

TIMEMAX="$(date +%s)"
name="$TAG-$FREQINTERVAL-$FREQMIN-$FREQMAX-$TOTALTIME-$TIMEINTERVAL-$TIMEMIN-$TIMEMAX"
#DATADIR="$DATADIR/$name"
mkdir -p "$DATADIR"
namepfx="$DATADIR/$name-"

RTL_POWER_CSV="$namepfx"rtl_power.csv
RTL_POWER_PNG="$namepfx"rtl_power.png
FLATTEN_RANGE_CSV="$namepfx"flatten_range.csv
FLATTEN_RANGE_PNG="$namepfx"flatten_range.png

mv "$tmp" "$RTL_POWER_CSV"
echo "$RTL_POWER_CSV"
./heatmap.py "$RTL_POWER_CSV" "$RTL_POWER_PNG"
echo "$RTL_POWER_PNG"
./flatten-range.py "$RTL_POWER_CSV" > "$FLATTEN_RANGE_CSV"
echo "$FLATTEN_RANGE_CSV"
{
	echo 'set terminal png'
	echo 'plot "-" with yerrorlines'
	cat "$FLATTEN_RANGE_CSV"
	echo e
} | gnuplot > "$FLATTEN_RANGE_PNG"
echo "$FLATTEN_RANGE_PNG"
