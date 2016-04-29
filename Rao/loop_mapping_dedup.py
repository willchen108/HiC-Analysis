# This file is created by Will @ 2016.04.29
# This code is used to find the duplicates in loops maping bed file.

import os,sys,re

targetfile = open(sys.argv[1])
dedup = {}
for line in targetfile:
	if line not in dedup:
		dedup[line] = []
		print "%s" % (line.rstrip('\n'))