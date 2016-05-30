#Create by Will Chen @ 2016.05.29
# This file is used to count how many SNPs are overlapping with GM12878 CTCF sites from Broad encode data
# python ~/HiC-Analysis/bed_file_processing/CTCT_SNP_overlapping.py /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/CTCF/ENCODE_Broad_GM12878_CTCF.bed /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/eqtl_capture_just_all_eqtls_all_promoter_snps_excluded_snp_coords_sorted_chr_removed.bed > GM12878_CTCF_snps.bed


import os,sys,re
#BED file of mapped reads
bedfile = open(sys.argv[1])
SNPfile = open(sys.argv[2])
CTCF = {}
for line in bedfile:
	chrom, start, end = line.split()[0:3]
	if chrom in CTCF:
		CTCF[chrom].append([int(start),int(end)])
	else:
		CTCF[chrom]={}
		CTCF[chrom].append([int(start),int(end)])

for line in SNPfile:
	chrom,s,snp,rsID = line.split()[0:4]
	snp = int(snp)
	if chrom in CTCF:
		for site in CTCF[chrom]:
			start, end = site[0],site[1]
			if start < snp < end:
				print "%s\t%s\t%s\t%s\t%s"% (chrom,start,end,snp,rsID)