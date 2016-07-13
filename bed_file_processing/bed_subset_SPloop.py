#Create by Will Chen @ 2016.05.23
# This file is used to subset the bed file with loops that are SNP-promoter loops.
# python ~/HiC-Analysis/bed_file_processing/bed_subset_SPloop.py /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/gencode.v19_promoter_chr_removed.bed $workdir/${NAME[$i]}.bed.deduped > $workdir/Promoters/$i/${NAME[$i]}_SPloops_promotercap_1k.dedup.bed &


import os,sys,re
#BED file of mapped reads
bedfile = open(sys.argv[1])
bed = open(sys.argv[2])

promoters = {}
for line in bedfile:
	chrom, fwd, rev = line.split()[0:3]
	if chrom in promoters:
		promoters[chrom].append([int(fwd),int(rev)])
	else:
		promoters[chrom] = []
		promoters[chrom].append([int(fwd),int(rev)])
 
for line in bed:
	split = line.split() #split BED file
	fcoord1 = int(split[1]) #forward coordinate
	rcoord1 = int(split[2])
	if fcoord1 == -1: continue #if either mate is unmapped, fcoord = -1
	fcoord2 = int(split[4])
	rcoord2 = int(split[5]) #reverse coordinate 
	mapq = int(split[7]) # mapq
	species1 = split[0] #ChrID of Mate 1
	species2 = split[3] #ChrID of Mate 2
	if mapq > 0:#Keep tally of reads with MAPQ > 0
		if species1 == species2:
			if species1 in promoters:
				for i in promoters[species1]:
					if rcoord2 - fcoord1 > 1000: 
						if i[0] < fcoord1 < i[1] or i[0] < rcoord1 < i[1] or i[0] < fcoord2 < i[1] or i[0] < rcoord2 < i[1]:
							print "%s" % (line.rstrip('\n'))