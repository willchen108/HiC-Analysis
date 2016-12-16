# This file is create by Will @ 2016.06.16
# python /net/shendure/vol1/home/wchen108/HiC-Analysis/CHiCAGO/baitmap_create.py gencode.v19_promoter_chr_removed.bed > /net/shendure/vol10/projects/DNaseHiC.eQTLs/data/promoter.baitmap
# python /net/shendure/vol1/home/wchen108/HiC-Analysis/CHiCAGO/baitmap_create.py eqtl_capture_just_all_eqtls_all_promoter_snps_excluded_snp_coords_centered_on_snp_merged_no_promoter_snps.chr_removed.bed > /net/shendure/vol10/projects/DNaseHiC.eQTLs/data/SNPs.baitmap
import os,sys,re
rmap = open('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/Dnasemap_hs37d5.rmap')
fname = '/net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/'+ sys.argv[1]
baitfile = open(fname)
bait = {}
for line in baitfile:
    Chrom ,start, end, ID = line.split()[0:4]
	if Chrom in bait:
		bait[Chrom].append([int(start),int(end),ID])
	else:
		bait[Chrom] = []
		bait[Chrom].append([int(start),int(end),ID])

for line in rmap:
    if "start" not in line:
    	Chrom, start, end, ID = line.split()[0:4]
    	start, end = int(float(start)), int(float(end))
        if Chrom in bait:
            for i in bait[Chrom]:
                if i[0] < start < i[1] or i[0] < end < i[1]:
                    geneName = i[2]
                    print "%s\t%s\t%s\t%s\t%s" %  (Chrom, start, end, ID,geneName)
                    break