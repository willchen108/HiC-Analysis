#This file is created by Will @ 2016.04.25
#This file is used to find the significant promoter(among the 2k promoters that we picked.) loops from the data from Rao's HiC paper.
import os,sys,re
from collections import Counter
from math import sqrt

snpsfile = open("/Users/Will/Desktop/snps_in_rao.txt")
loopsfile = open("/Users/Will/Desktop/intersted_loops_in_rao.txt")

loops,SNPs = {},{}
for line in snpsfile:
	chrid, y1, y2, x1, x2, snps = line.split()[0:6]
	if chrid != "chrid":
		tag = (chrid, y1, y2, x1, x2)
		if tag in SNPs:
			SNPs[tag].append([snps])
		else:
			SNPs[tag] = []
			SNPs[tag].append([snps])

for line in loopsfile:
	chrid, y1, y2, x1, x2, snps, start, end = line.split()[0:8]
	if chrid != "chrid":
		tag = (chrid, y1, y2, x1, x2)
		if tag in loops:
			loops[tag].append([snps,start,end])
		else:
			loops[tag] = []
			loops[tag].append([snps,start,end])