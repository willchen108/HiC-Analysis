#This file is created by Will @ 2016.04.24
#This file is used to find the significant promoter(among the 2k promoters that we picked.) loops from the data from Rao's HiC paper.
import os,sys,re
from collections import Counter
from math import sqrt

readfile = open(sys.argv[1])
SNPsfile = open(sys.arge[2])
distance = int(sys.arge[3])
for line in readfile:
    chr1,x1,x2,chr2,y1,y2 = line.split()[0:6] 
    for line2 in SNPsfile:
    	chrid, snps = line2.split()[0:2]
    	chrid = chrid[0]
      	if chr1 == chrid:
      		if snps in range(x1-distance,x2+distance):
				print "%s\t%s\t%s\t%s\t%s\t%s" % (chr1, x1, x2, y1, y2, snps) 
			elif snps in range(y1-distance,y2+distance):
				print "%s\t%s\t%s\t%s\t%s\t%s" % (chr1, y1, y2, x1, x2, snps) 

