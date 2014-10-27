#! /usr/bin/env python

import sys
from collections import defaultdict

def help():
    print("attenuation.py left.csv right.csv")
    print("produces the difference between two flattened inputs")
    sys.exit()

if len(sys.argv) <= 2:
    help()

if len(sys.argv) > 3:
    help()

leftpath = sys.argv[1]
rightpath = sys.argv[2]

aves = defaultdict(float)
mins = defaultdict(float)
maxs = defaultdict(float)

def frange(start, stop, step):
    i = 0
    f = start
    while f <= stop:
        f = start + step*i
        yield f
        i += 1

for line in open(leftpath):
    line = line.strip().split(', ')
    f = int(line[0])
    aves[f] = float(line[1])
    mins[f] = float(line[2])
    maxs[f] = float(line[3])

for line in open(rightpath):
    line = line.strip().split(', ')
    f = int(line[0])
    aves[f] -= float(line[1])
    # subtract max from min and min from max for largest extent
    mins[f] -= float(line[3])
    maxs[f] -= float(line[2])

for f in sorted(ave):
    print(','.join([str(f), str(ave[f]), str(mins[f]), str(maxs[f])]))
    

