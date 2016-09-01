#Create by Will Chen @ 2016.04.11, borrow from sort_strandedness_bulk.py
import os,sys,re
#BED file of mapped reads
pos = sys.argv[1]
distance = int(sys.argv[2])
fhi = open(sys.argv[3])
#Just a list with different types of ligation junctions

for line in fhi:
	split = line.split() #split BED file
	fcoord1 = int(split[1]) #forward coordinate
	if fcoord1 == -1: continue #if either mate is unmapped, fcoord = -1
	rcoord2 = int(split[5]) #reverse coordinate 
	mapq = int(split[7]) # mapq
	species1 = split[0] #ChrID of Mate 1
	species2 = split[3] #ChrID of Mate 2
	if mapq > 0:#Keep tally of reads with MAPQ > 0
		if pos == 'intra':
			if species1 == species2:
				if rcoord2 - fcoord1 > distance: 
					print "%s" % (line.rstrip('\n'))
		elif pos == 'inter':
			if species1 != species2:
				if rcoord2 - fcoord1 > distance: 
					print "%s" % (line.rstrip('\n'))
