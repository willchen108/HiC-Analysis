# This file is created by Will @2016.05.20
# This file is used to create SNP files required for WASP
import csv
import os,sys,re

VCFfile = open(sys.argv[1])

VCF = {}
for line in VCFfile:
    if '#' in line:
        continue
    else:
        Chrom, Pos, ID, Ref, ALT = line.split()[0:5]
        if Chrom in VCF:
        	VCF[Chrom].append([Pos,Ref,ALT])
        else:
        	VCF[Chrom] = []
        	VCF[Chrom].append([Pos,Ref,ALT])

temp  = 'chr.snps.txt'
for i in range(1,22):
    fname = temp[0:3] + str(i) +temp[3:]
    with open(fname, 'w') as file:
        for snp in VCF[str(i)]:
            string = snp[0] + '\t' + snp[1] + '\t' + snp[2] + '\n'
            file.write(string)
        file.close()