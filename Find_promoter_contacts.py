#This file is created by Will @ 2016.04.19
#This file is used to find the significant promoter(among the 2k promoters that we picked.) loops from the data from Rao's HiC paper.
import os,sys,re
from collections import Counter
from math import sqrt

readfile = open("/Users/Will/Downloads/GSE63525_GM12878_primary+replicate_HiCCUPS_looplist.txt")
targetfile = open("/Users/Will/Desktop/gencode.v19_promoter_chr_removed.bed")
loops,targets = {},{}
for line in readfile:
    chr1,x1,x2,chr2,y1,y2 = line.split()[0:6] 
    if chr1 != "chr1":
        if chr1 in loops:
            loops[chr1].append([int(x1),int(x2),int(y1),int(y2)])
        else:
            loops[chr1] = []
            loops[chr1].append([int(x1),int(x2),int(y1),int(y2)])
for line in targetfile:
    ch,st,end = line.split()[0:3]
    if ch in targets:
        targets[ch].append([int(st),int(end)])
    else:
        targets[ch] = []
        targets[ch].append([int(st),int(end)])

promoters={}
for chrid in loops:
	for i in range(0,len(loops[chrid])):
		x1,x2,y1,y2 = loops[chrid][i][0:4]
		for j in range(0,len(targets[chrid])):
			st, end = targets[chrid][j][0:2]
			tag = (chrid,st,end)
			if st in range(x1,x2+1) or end in range(x1,x2+1):
				if tag in promoters:
					promoters[tag].append([y1,y2,x1,x2]) #x1, x2 are region of promoters  y1 y2 are regions that interact with promoters.
				else:
					promoters[tag]=[]
					promoters[tag].append([y1,y2,x1,x2])
			elif st in range(y1,y2+1) or end in range(y1,y2+1):
				if tag in promoters:
					promoters[tag].append([x1,x2,y1,y2])
				else:
					promoters[tag]=[]
					promoters[tag].append([x1,x2,y1,y2])

SNPs={}
for line in SNPfile:
	chrid, snps = line.split()[0:2]
	chrid = chrid[0]
	for i in range(0,len(loops[chrid])):
		x1,x2,y1,y2 = loops[chrid][i][0:4]
		if snps in range(x1,x2):
			if chrid in SNPs:
				SNPs[chrid].append([snps,x1,x2,y1,y2])
			else:
				SNPs[chrid] = []
				SNPs[chrid].append([snps,x1,x2,y1,y2])
		elif snps in range(y1,y2):
			if chrid in SNPs:
				SNPs[chrid].append([snps,y1,y2,x1,x2])
			else:
				SNPs[chrid] = []
				SNPs[chrid].append([snps,y1,y2,x1,x2])
contacts={}
for line in SNPfile:
	chrid, snps = line.split()[0:2]
	for i in promoters:
		chrid2 = i[0]
		if int(chrid) == int(chrid2):
			for j in range(len(promoters[i])):
				p1,p2 = promoters[i][j][0:2]
				if snps in range(p1,p2):
					if i in contacts:
						contacts[i].append(promoters[i][j])
					else:
						contacts[i]=[]
						contacts[i].append(promoters[i][j])
