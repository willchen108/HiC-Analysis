# This file is created by Will @ 2016.04.26
# This code is used to find the reads that fall into our 55 loops list.
# /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters/1/10847_1k.bed ~/data
import os,sys,re

bedfile = open(sys.argv[1])
loopsfile = open(sys.argv[2])

loops={}
for loop in loopsfile:
	chrid, x1, x2, y1, y2 = loop.split()[0:5]
	if chrid in loops:
		loops[chrid].append([int(x1), int(x2), int(y1), int(y2)])
	else:
		loops[chrid] = []
		loops[chrid].append([int(x1), int(x2), int(y1), int(y2)])

for line in bed:
	chr1, f1, r1, chr2, f2, r2 = line.split()[0:6]
	f1, r1, f2, r2 = int(f1), int(r1), int(f2), int(r2)
	for loc in loops[chr1]:
		y1, y2 = loc[2:4]
		if f1 in range(y1,y2) or r1 in range(y1,y2) or f2 in range(y1,y2) or r2 in range(y1,y2):
			print "%s" % (read.rstrip('\n'))