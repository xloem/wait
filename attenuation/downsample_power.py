#! /usr/bin/env python

import sys
from collections import defaultdict

# todo
# interval based summary
# tall vs wide vs super wide output

def help():
    print("flatten.py input.csv")
    print("turns any rtl_power csv into a more compact summary")
    sys.exit()

if len(sys.argv) <= 1:
    help()

if len(sys.argv) > 2:
    help()

path = sys.argv[1]

sums = defaultdict(float)
counts = defaultdict(int)
mins = defaultdict(float)
maxs = defaultdict(float)

binsize = 30000000
windowradius = 0

def frange(start, stop, step):
    i = 0
    f = start
    while f <= stop:
        f = start + step*i
        yield f
        i += 1

for line in open(path):
    line = line.strip().split(', ')
    low = int(line[2])
    high = int(line[3])
    step = float(line[4])
    if windowradius == 0:
        windowradius = round(binsize / (2*step))
        print("Setting window radius to", windowradius, "samples for a total window width of", binsize/1000000, "MHz", file=sys.stderr);
    weight = int(line[5])
    dbm = [float(d) for d in line[6:]]
    for f,d in zip(frange(low, high, step), dbm):
        #f=int(f/binsize)*binsize
        for f2 in range(-windowradius, windowradius):
            weight2 = weight * (1.0 - abs(f2) /(windowradius + 1))
            f3 = f + f2 * step
            sums[f3] += d * weight2
            counts[f3] += weight2
            #if f3 not in mins or mins[f3] > d:
            #    mins[f3] = d
            #if f3 not in maxs or maxs[f3] < d:
            #    maxs[f3] = d
        if f not in mins or mins[f] > d:
            mins[f] = d
        if f not in maxs or maxs[f] < d:
            maxs[f] = d

ave = defaultdict(float)
for f in sums:
    ave[f] = sums[f] / counts[f]

for f in sorted(ave):
    print(','.join([str(f), str(ave[f]), str(mins[f]), str(maxs[f])]))
    

