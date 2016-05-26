#Create by Will Chen @ 2016.05.25
# This file is used to create promoter centered loop counts plot. Each promoter has a 41 cells(or 101 cells,depending on theresolution, 5kb or 1kb) long array, with count of looping to promoter.
#promoter is 101th and 500kb upstream is [1-100] 500kb downstream is [102-201]. 0 is reads that are >100kb upstream; 202 is >100kb downstream.
# python ~/HiC-Analysis/bed_file_processing/promoter_looping_map_500k.py /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/gencode.v19_promoter_chr_removed.bed ${NAME[$i]}_joint_SPloops_1k.dedup.bed &

bedfile = open('/net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/gencode.v19_promoter_chr_removed.bed')
bed = open('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/joint_beds_SPloops/12873_joint_SPloops_1k.dedup.bed')
prefix = '12873'
import pickle
import os,sys,re
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
from scipy import ndimage
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
		promoters[chrom][(start,end)] = []
	else:
		promoters[chrom]={}
		promoters[chrom][(start,end)] = []

for line in bed:
	split = line.split() #split BED file
	fcoord1,rcoord1 = int(split[1]),int(split[2]) 
	fcoord2,rcoord2 = int(split[4]),int(split[5])
	species = split[0]
	if species in promoters:
		for promoter in promoters[species]:
			start, end = int(promoter[0]),int(promoter[1])
			mid = (fcoord2+rcoord2)/2
			promoters[species][promoter].append(mid - start)