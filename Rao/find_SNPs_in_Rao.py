#This file is created by Will @ 2016.04.24
#This file is used to find the significant promoter(among the 2k promoters that we picked.) loops from the data from Rao's HiC paper.
import os,sys,re
import csv
from math import sqrt
readfile = open("/Users/Will/Downloads/GSE63525_GM12878_primary+replicate_HiCCUPS_looplist.txt")
SNPsfile = open("/Users/Will/Desktop/eqtl_capture_just_all_eqtls_all_promoter_snps_excluded_snp_coords_sorted_chr_removed.bed.txt")
targetfile = open("/Users/Will/Desktop/gencode.v19_promoter_chr_removed.bed")

loops,SNPs = {},[]
for line in readfile:
	chr1,x1,x2,chr2,y1,y2 = line.split()[0:6] 
	if chr1 != "chr1":
		if chr1 in loops:
			loops[chr1].append([int(x1),int(x2),int(y1),int(y2)])
		else:
			loops[chr1] = []
			loops[chr1].append([int(x1),int(x2),int(y1),int(y2)])

for line in SNPsfile:
	chrid, snps = line.split()[0:2]	
	try:
		temp = int(chrid)	
	except ValueError:
		chrid = chrid[0] #exception 6_cox_hap2
	snps = int(snps)
	for i in range(0,len(loops[chrid])):
		x1,x2,y1,y2 = loops[chrid][i][0:4]
		if snps in range(x1,x2):
			SNPs.append([chrid, x1, x2, y1, y2, snps])
			#print "%s\t%s\t%s\t%s\t%s\t%s" % (chrid, x1, x2, y1, y2, snps) 
		elif snps in range(y1,y2):
			#print "%s\t%s\t%s\t%s\t%s\t%s" % (chrid, y1, y2, x1, x2, snps) 
			SNPs.append([chrid, y1, y2, x1, x2, snps])

total =[]
for line in targetfile:
	ch,st,end = line.split()[0:3]
	st = int(st)
	end = int(end)
	mid = (st+end)/2
	for snp in SNPs:
		if snp[0] == ch:
			if mid in range(snp[3],snp[4]):
				total.append([snp[0], snp[1], snp[2], snp[3], snp[4], snp[5],st, end])

with open('snps_in_rao.txt', 'w') as fp:
    a = csv.writer(fp,delimiter='\t')
    a.writerow(['chrid'] + ['x1'] + ['x2'] + ['y1'] + ['y2'] + ['snps'])
    for snp in SNPs:
        a.writerow([str(snp[0])] + [str(snp[1])] + [str(snp[2])] + [str(snp[3])] + [str(snp[4])] + [str(snp[5])])

with open('intersted_loops_in_rao.txt','w') as loops:
    a = csv.writer(loops,delimiter='\t')
    a.writerow(['chrid'] + ['x1'] + ['x2'] + ['y1'] + ['y2'] + ['snps'] + ['promoter_start'] + ['promoter_end'])
    for loop in total:
         a.writerow([str(loop[0])] + [str(loop[1])] + [str(loop[2])] + [str(loop[3])] + [str(loop[4])] + [str(loop[5])] + [str(loop[6])] + [str(loop[7])])

