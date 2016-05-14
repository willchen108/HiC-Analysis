# This file is create by Will @ 2016.05.14
# This file is used to combine the allele counts across 9 samples.
# Usage cd /net/shendure/vol1/home/wchen108/data/AScount/ 
# python /net/shendure/vol1/home/wchen108/HiC-Analysis/Allele_specific_count/AScount_final.py 10847_merged_count.csv 12814_merged_count.csv 12878_merged_count.csv 12815_merged_count.csv 12812_merged_count.csv 12813_merged_count.csv 12872_merged_count.csv 12873_merged_count.csv 12874_merged_count.csv /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/SNPs_release/eQTL_SNPs/Biallelic_eQTL_SNPs.vcf > /net/shendure/vol1/home/wchen108/data/AScount/AScount_9samples.csv
import os,sys,re

f1 = open(sys.argv[1])
f3 = open(sys.argv[2])
f3 = open(sys.argv[3])
f4 = open(sys.argv[4])
f5 = open(sys.argv[5])
f6 = open(sys.argv[6])
f7 = open(sys.argv[7])
f8 = open(sys.argv[8])
f9 = open(sys.argv[9])
VCFfile = open(sys.argv[10])

table = {}
for line in VCFfile:
    if '#' in line:
        continue
    else:
        Chrom, Pos, ID, Ref, ALT= line.split()[0:5]
        table[(Chrom, Pos, ID, Ref, ALT)] = [0]*27

for line in f1:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        table[(Chrom, Pos, ID, REF, ALT)][0:3] = [int(REFcount),int(ALTcount),int(TOTALcount)]

for line in f2:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        table[(Chrom, Pos, ID, REF, ALT)][3:6] = [int(REFcount),int(ALTcount),int(TOTALcount)]

for line in f3:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        table[(Chrom, Pos, ID, REF, ALT)][6:9] = [int(REFcount),int(ALTcount),int(TOTALcount)]

for line in f4:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        table[(Chrom, Pos, ID, REF, ALT)][9:12] = [int(REFcount),int(ALTcount),int(TOTALcount)]

for line in f5:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        table[(Chrom, Pos, ID, REF, ALT)][12:15] = [int(REFcount),int(ALTcount),int(TOTALcount)]

for line in f6:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        table[(Chrom, Pos, ID, REF, ALT)][15:18] = [int(REFcount),int(ALTcount),int(TOTALcount)]

for line in f7:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        table[(Chrom, Pos, ID, REF, ALT)][18:21] = [int(REFcount),int(ALTcount),int(TOTALcount)]

for line in f8:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        table[(Chrom, Pos, ID, REF, ALT)][21:24] = [int(REFcount),int(ALTcount),int(TOTALcount)]

for line in f9:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        table[(Chrom, Pos, ID, REF, ALT)][24:27] = [int(REFcount),int(ALTcount),int(TOTALcount)]

for key in table:
    print "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" % \
    (key[0], key[1], key[2], key[3], key[4], key[5], table[key][0], table[key][1], table[key][2], table[key][3], table[key][4], table[key][5], table[key][6],\
     table[key][7], table[key][8], table[key][9], table[key][10], table[key][11], table[key][12], table[key][13], table[key][14], table[key][15], table[key][16],\
      table[key][17], table[key][18], table[key][19], table[key][20], table[key][21], table[key][22], table[key][23], table[key][24], table[key][25], table[key][26])