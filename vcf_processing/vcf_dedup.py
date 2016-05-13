import os,sys,re
import csv
from math import sqrt
VCFfile = open(sys.argv[1])
IDs = {}
for line in VCFfile:
	if '#' in line:
		print line.strip('\n')
	else:
		ID = line.split()[2]
		if ID in IDs: 
			break
		else:
			IDs[ID] = []
			print line.strip('\n')