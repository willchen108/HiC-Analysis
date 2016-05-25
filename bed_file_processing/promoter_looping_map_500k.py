#Create by Will Chen @ 2016.05.25
# This file is used to create promoter centered loop counts plot. Each promoter has a 41 cells(or 101 cells,depending on theresolution, 5kb or 1kb) long array, with count of looping to promoter.
#promoter is 101th and 500kb upstream is [1-100] 500kb downstream is [102-201]. 0 is reads that are >100kb upstream; 202 is >100kb downstream.
# python ~/HiC-Analysis/bed_file_processing/promoter_looping_map.py /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/gencode.v19_promoter_chr_removed.bed ${NAME[$i]}_joint_SPloops_1k.dedup.bed > ${NAME[$i]}_SPloops.matrix &


import os,sys,re
#BED file of mapped reads
bedfile = open(sys.argv[1])
bed = open(sys.argv[2])
#Just a list with different types of ligation junctions
res = 5000
num = int(500000/res) + 3
promoters = {}
for line in bedfile:
	chrom, start, end = line.split()[0:3]
	if chrom in promoters:
		promoters[chrom][(start,end)] = [0]*num
	else:
		promoters[chrom]={}
		promoters[chrom][(start,end)] = [0]*num

for line in bed:
	split = line.split() #split BED file
	fcoord1,rcoord1 = int(split[1]),int(split[2]) 
	fcoord2,rcoord2 = int(split[4]),int(split[5])
	species = split[0]
	if species in promoters:
		for promoter in promoters[species]:
			start, end = int(promoter[0]),int(promoter[1])
			if start < fcoord1 < end or start < rcoord1 < end:
				mid = (fcoord2+rcoord2)/2
				dis = mid - start
				if dis > 0:
					bin = 101 + int(dis/res)
					if bin <= 201:
						promoters[species][promoter][bin] += 1
					else:
						promoters[species][promoter][202] +=1
				else:
					bin = 101 + int(dis/res) - 1
					if bin >= 0:
						promoters[species][promoter][bin] += 1
					else:
						promoters[species][promoter][0] += 1

			elif start < fcoord2 < end or start < rcoord2 < end:
				mid = (fcoord1+rcoord1)/2
				dis = mid - start
				if dis > 0:
					bin = 101 + int(dis/res)
					if bin <= 201:
						promoters[species][promoter][bin] += 1
					else:
						promoters[species][promoter][202] +=1
				else:
					bin = 101 + int(dis/res) - 1
					if bin >= 0:
						promoters[species][promoter][bin] += 1
					else:
						promoters[species][promoter][0] +=1

for chrom in promoters:
	for promoter in promoters[chrom]:
		s = promoters[chrom][promoter]
		print "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s"% \
    (chrom,promoter[0],promoter[1],s[0],s[1],s[2],s[3],s[4],s[5],s[6],s[7],s[8],s[9],s[10],s[11],s[12],s[13],s[14],s[15],s[16],s[17],s[18],s[19],s[20],s[101],s[22],s[23],s[24],s[25],s[26],s[27],s[28],s[29],s[30],s[31],s[32],s[33],s[34],s[35],s[36],s[37],s[38],s[39],s[40],s[41],s[42])
