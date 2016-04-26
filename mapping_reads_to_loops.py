# This file is created by Will @ 2016.04.26
# This code is used to find the reads in SNPs capture that fall into our 55 loops list.

import os,sys,re

bed = open(sys.argv[1])
loops = open(sys.argv[2])

for read in bed:
	chr1, f1, r1, chr2, f2, r2 = read.split()[0:6]
	for loop in loops:
		chrid, x1, x2, y1, y2 = loop.split()[0:5]
		if chr1 == chrid:
			if mid1 in range(y1,y2) or mid2 in range(y1,y2):
				print "%s" % (read.rstrip('\n'))