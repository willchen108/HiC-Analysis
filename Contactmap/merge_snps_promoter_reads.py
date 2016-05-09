'''
This file is used to merge SNPs capture counts and promoter capture counts.
Created by Will @2016.05.08
'''
import os,sys,re
from math import sqrt

C1 = open(sys.argv[1])
C2 = open(sys.argv[2])

Merged = {}
for read in C1:
	chrid,bin1,bin2,snp,count,norm_count = read.split()
	if chrid != 'Chrom':
		if chrid in Merged:
			Merged[chrid].append([int(bin1),int(bin2),int(snp),int(count), float(norm_count)])
		else:
			Merged[chrid] = []
			Merged[chrid].append([int(bin1),int(bin2),int(snp),int(count), float(norm_count)])

print "%s\t%s\t%s\t%s\t%s\t%s" % ('Chrid', 'bin1', 'bin2', 'snp', 'count', 'norm_count')

for line in C2:
	chrid,bin1,bin2,snp,count,norm_count = line.split()
	if chrid in Merged.keys():
		bin1,bin2,snp,count,norm_count = int(bin1),int(bin2),int(snp),int(count),float(norm_count)
		ct = 0
		for i in range(len(Merged[chrid])):
			if bin1== Merged[chrid][i][0] and bin2 == Merged[chrid][i][1] and snp == Merged[chrid][i][2]:
				Merged[chrid][i][3] += count
				Merged[chrid][i][4] += norm_count
				ct +=1
		if ct == 0:
			Merged[chrid].append([bin1,bin2,snp,count,norm_count])


for chrid in Merged:
	for loop in Merged[i]:
		print "%s\t%s\t%s\t%s\t%s\t%s" % (chrid,loop[0],loop[1],loop[2], loop[3],loop[4])