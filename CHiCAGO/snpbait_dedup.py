# This file is create by Will @ 2017.01.03
# SNP bait has multiple duplicated baitIDs. Close SNPs are assigned with same baitID
# python /net/shendure/vol1/home/wchen108/HiC-Analysis/CHiCAGO/snpbait_dedup.py 
import os,sys,re
baitfile = open('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/snp_design/SNPs.baitmap')
bait = {}
for line in baitfile:
    Chrom ,start, end, ID, rsID = line.split()[0:5]
    if ID in bait:
        bait[ID][4] +=',' + rsID
    else:
        bait[ID]=[Chrom ,start, end, ID, rsID]

for ID in bait:
    Chrom, start, end, ID,geneName = bait[ID]
    print "%s\t%s\t%s\t%s\t%s" %  (Chrom, start, end, ID,geneName)
