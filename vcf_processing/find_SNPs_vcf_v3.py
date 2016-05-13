import os,sys,re
import csv
from math import sqrt
VCFfile = open(sys.argv[1])

for line in VCFfile:
	if '#' in line:
		print line.strip('\n')
	else:
		line = 'chr' + line
		print line.strip('\n')