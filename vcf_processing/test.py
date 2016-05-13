import os,sys,re
import csv
VCFfile = open(sys.argv[1])
IDs = {}
for line in VCFfile:
	if '#' in line:
		print line.strip('\n')
	else:
		Chrom, Pos, ID= line.split()[0:3]
		if ID in IDs: 
			print 'copy'
		else:
			IDs[ID] = []
			print line.strip('\n')