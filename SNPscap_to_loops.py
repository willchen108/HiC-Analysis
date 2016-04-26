# This file is created by Will @ 2016.04.26
# This code is used to find the reads that fall into our 55 loops list.
# /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters/1/10847_1k.bed ~/data
import os,sys,re

bed = open(sys.argv[1])
loops = open(sys.argv[2])

for line in bed:
	chr1, f1, r1, chr2, f2, r2 = line.split()[0:6]
	f1, r1, f2, r2 = int(f1), int(r1), int(f2), int(r2)
	for loop in loops:
		chrid, x1, x2, y1, y2 = loop.split()[0:5]
		if x1 != "x1":
			x1, x2, y1, y2 = int(x1), int(x2), int(y1), int(y2)
			if int(chr1) == int(chrid):
				print "%s" % (line.rstrip('\n'))