import os,sys,re
import csv
VCFfile = open(sys.argv[1])
IDs = {}
for line in VCFfile:
	ID = line.split()[2]
	if ID in IDs: 
		print 'copy'
	else:
		IDs[ID] = []
		print line.strip('\n')