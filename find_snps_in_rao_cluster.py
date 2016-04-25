#This file is created by Will @ 2016.04.24
#This file is used to find the significant promoter(among the 2k promoters that we picked.) loops from the data from Rao's HiC paper.
import os,sys,re
from collections import Counter
from math import sqrt
readfile = open("~/data/GSE63525_GM12878_primary+replicate_HiCCUPS_looplist.txt")
SNPsfile = open("~/data/eqtl_capture_just_all_eqtls_all_promoter_snps_excluded_snp_coords_sorted_chr_removed.bed")

loops,SNPs = {},[]
#read loops list
for line in readfile:
	chr1,x1,x2,chr2,y1,y2 = line.split()[0:6] 
	if chr1 != "chr1":
		if chr1 in loops:
			loops[chr1].append([int(x1),int(x2),int(y1),int(y2)])
		else:
			loops[chr1] = []
			loops[chr1].append([int(x1),int(x2),int(y1),int(y2)])

#read snps list and find the snps in loops.
for line in SNPsfile:
	chrid, snps = line.split()[0:2]	
	try:
		temp = int(chrid)	
	except ValueError:
		chrid = chrid[0] #exception 6_cox_hap2
	snps = int(snps)
	for i in range(0,len(loops[chrid])):
		x1,x2,y1,y2 = loops[chrid][i][0:4]
		if snps in range(x1,x2):
			print "%s\t%s\t%s\t%s\t%s\t%s" % (chrid, x1, x2, y1, y2, snps) 
		elif snps in range(y1,y2):
			print "%s\t%s\t%s\t%s\t%s\t%s" % (chrid, y1, y2, x1, x2, snps) 

