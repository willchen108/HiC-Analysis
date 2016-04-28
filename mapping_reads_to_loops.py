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

for line in bedfile:
	chr1, f1, r1, chr2, f2, r2 = line.split()[0:6]
	f1, r1, f2, r2 = int(f1), int(r1), int(f2), int(r2)
	try:
		int(chr1)
	except ValueError:
		continue
	if chr1 in loops:
		for loc in loops[chr1]:
			x1, x2, y1, y2 = loc[0:4]
			if y1 < f1 < y2 or y1 < r1 < y2):
				if x1 < f2 < x2 or x1 < r2 < x2:
					print "%s" % (line.rstrip('\n'))
			elif y1 < f2 <y2 or y1 < r2 <y2 :
				if x1 < f1 < x2 or x1 < r1 <x2:
					print "%s" % (line.rstrip('\n'))