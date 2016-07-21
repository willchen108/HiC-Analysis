#Create by Will Chen @ 2016.04.11, borrow from sort_strandedness_bulk.py
# Usage /net/shendure/vol1/home/wchen108/HiC-Analysis/bed_file_processing/bed_decouple+10.py $projectdir/${NAME[$i]}_k.bed > $workdir/${NAME[$i]}.snps.fixmate.intra3k.SPloop.decoupled.bed 


import os,sys,re
#BED file of mapped reads
fhi = open(sys.argv[1])

#Just a list with different types of ligation junctions

for line in fhi:
	split = line.split() #split BED file
	#Chr1 
	fcoord1 = int(split[1]) 
	rcoord1 = int(split[2])
	#Chr2
	fcoord2 = int(split[4])
	rcoord2 = int(split[5]) 
	#name
	ID = split[6]
	mapq = int(split[7]) # mapq
	species1 = split[0] #ChrID of Mate 1
	species2 = split[3] #ChrID of Mate 2
	#get strands
	s1 = split[8]
	s2 = split[9]
	if species1 == species2:
		if int(fcoord1) > int(fcoord2):
			strand1 = s2
			strand2 = s1
		else:
			strand1 = s1
			strand2 = s2
	elif species1 >= species2:
		strand1 = s2
		strand2 = s1
	else:
		strand1 = s1
		strand2 = s2
	print "%s\t%s\t%s\t%s\t%s" % (species1, fcoord1-10, rcoord1+10, ID, strand1) 
	print "%s\t%s\t%s\t%s\t%s" % (species2, fcoord2-10, rcoord2+10, ID, strand2)