import pickle
import os,sys,re
import matplotlib
matplotlib.use('Agg') 
import matplotlib.pyplot as plt
import numpy as np
import matplotlib.image as mpimg
bedfile = open('/net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/gencode.v19_promoter_chr_removed.bed')
bed = open('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/joint_beds_SPloops/12874_joint_SPloops_1k.dedup.bed')
prefix = '12874'
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
						promoters[species][promoter][202] += 1
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
						promoters[species][promoter][202] += 1
				else:
					bin = 101 + int(dis/res) - 1
					if bin >= 0:
						promoters[species][promoter][bin] += 1
					else:
						promoters[species][promoter][0] += 1

fname = prefix + '_joint_SPloops_1k.pickle'
with open(fname,'wb') as handle:
    pickle.dump(promoters,handle)

matrix = np.zeros(shape=(len(prom_list),num),dtype=float)

for i in range(len(prom_list)):
	chrom, start, end = prom_list[i][0], prom_list[i][1], prom_list[i][2]
	matrix[i,] = promoters[chrom][(start,end)]

log_matrix = np.log(matrix+1)
# Start plot a figure
figname = prefix + '_joint_SPloops_1k.pdf'
figtitle = 'NA'+prefix
fig = plt.figure()
axes = plt.subplot(111)
plt.imshow(log_matrix,origin="lower",cmap=plt.get_cmap('Reds'),interpolation="nearest",aspect='auto',vmin=0,vmax=8)
plt.colorbar(label="Log(Count)")   
axes.set_xticks([0,50,100,150,200])
axes.set_xticklabels(["-500", "-250","0","250","500"])
axes.set_yticks([])
plt.xlabel('Interaction distance (kb)', fontsize=16)
plt.title(figtitle,fontsize=20)
plt.savefig(figname)