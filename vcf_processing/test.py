import os,sys,re
import csv
VCFfile = open(sys.argv[1])
IDs = {}
for line in VCFfile:
	Chrom, Pos, ID, REF, ALT, QUAL, FILTER, INFO, FORMAT, s1, s2, s3, s4, s5, s6, s7, s8, s9 = line.split()[0:18]
	if ID in IDs: 
		print 'copy'
	else:
		IDs[ID] = []
		print line.strip('\n')