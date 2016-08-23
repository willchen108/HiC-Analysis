#Create by Will Chen @ 2016.08.22
# This file is used create a table that shows the nearest promoter to a SNP
# 

import os,sys,re
#BED file of mapped reads
SNPfile = open(sys.argv[1])
Promoterfile = open(sys.argv[2])

SNPs = {}
for line in SNPfile:
	chrom, temp, SNP, snpID = line.split()[0:4]
	if chrom in SNPs:
		SNPs[chrom].append([int(SNP),snpID])
	else:
		SNPs[chrom] = []
		SNPs[chrom].append([int(SNP),snpID])

promoters = {}
for line in Promoterfile:
	chrom, start, end, ID = line.split()[0:4]
	if chrom in promoters:
		promoters[chrom].append([int(start),int(end),ID])
	else:
		promoters[chrom] = []
		promoters[chrom].append([int(start),int(end),ID])

NP_list=[]
for chrom in SNPs:
	for snp in SNPfile[chrom]:
		mdis = 1e10
		pro  = [0,0,0]
		for promoter in promoters[chrom]:
			dis = snp[0] - promoter[0]
			if abs(dis) < abs(mdis):
				mdis = dis
				pro  = promoter
		print "%s\t%s\t%s\t%s\t%s"% (chrom,snp[0],snp[1],pro[0],pro[1],pro[2])