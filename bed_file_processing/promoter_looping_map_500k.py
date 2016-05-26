#Create by Will Chen @ 2016.05.25
# This file is used to create promoter centered loop counts plot. Each promoter has a 41 cells(or 101 cells,depending on theresolution, 5kb or 1kb) long array, with count of looping to promoter.
#promoter is 101th and 500kb upstream is [1-100] 500kb downstream is [102-201]. 0 is reads that are >100kb upstream; 202 is >100kb downstream.
# python ~/HiC-Analysis/bed_file_processing/promoter_looping_map_500k.py /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/gencode.v19_promoter_chr_removed.bed ${NAME[$i]}_joint_SPloops_1k.dedup.bed &

import pickle
import os,sys,re
#BED file of mapped reads
bedfile = open(sys.argv[1])
bed = open(sys.argv[2])
prefix = sys.argv[2].split('_')[0]
#Just a list with different types of ligation junctions
res = 5000
num = int(1000000/res) + 3
promoters = {}
prom_list = []
for line in bedfile:
	chrom, start, end = line.split()[0:3]
	prom_list.append([chrom, start, end])
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

fname = prefix + '_joint_SPloops_1k.pickle'
with open(fname,'wb') as handle:
    pickle.dump(promoters,handle)

matrix = np.zeros(shape=(len(prom_list),num),dtype=float)

for i in range(len(prom_list)):
	chrom, start, end = prom_list[i][0], prom_list[i][1], prom_list[i][2]
	matrix[i,] = promoters[chrom][(start,end)]
figname = prefix + '_joint_SPloops_1k.pdf'
plt.figure()
plt.imshow(matrix,origin="lower",cmap=plt.get_cmap('YlOrRd'),interpolation="nearest",aspect='auto',vmin=0)
plt.colorbar()
plt.savefig(figname)