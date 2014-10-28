#! /usr/bin/env python

import sys
from collections import defaultdict

# todo
# interval based summary
# tall vs wide vs super wide output

def help():
    print("log2chart.py input.csv")
    print("turns any rtl_logfile csv into a gnuplot chart")
    sys.exit()

if len(sys.argv) <= 1:
    help()

if len(sys.argv) > 2:
    help()

path = sys.argv[1]

xtics = []


lastFq = None
lastRate = None
lastTend = None
for line in open(path):
    line = line.strip().split(', ')
    tstart = line[0]
    tend = line[1]
    fq = int(line[2])
    rate = int(line[3])
    smpi = [float(d)/127. for d in line[4::2]]
    smpq = [float(d)/127. for d in line[5::2]]

    if lastFq == fq and lastRate == rate:
        idx += (tstart - lastTend) * rate
    else:
        if lastFq is not None:
            print('e')
        idx = 0
        print('set xtics("' + tstart + '" ' + str(idx) + ',"' + tend + '" ' + str(idx+len(smpi)) + ')')
        print('plot "-" with lines, "-" with lines')

    lastFq = fq
    lastRate = rate
    lastTend = tend

    for i in range(0,len(smpi)):
        print(str(idx+i)+" "+str(smpi[i]))
    print('')

    for i in range(0,len(smpq)):
        print(str(idx+i)+" "+str(smpq[i]))
    print('')

    idx += len(smpi)
    print("e")
