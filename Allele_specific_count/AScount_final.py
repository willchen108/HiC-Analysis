# This file is create by Will @ 2016.05.14
# This file is used to combine the allele counts across 9 samples.
# Usage cd /net/shendure/vol1/home/wchen108/data/AScount/ 
# python /net/shendure/vol1/home/wchen108/HiC-Analysis/Allele_specific_count/AScount_final.py 10847_merged_count.csv 12814_merged_count.csv 12878_merged_count.csv 12815_merged_count.csv 12812_merged_count.csv 12813_merged_count.csv 12872_merged_count.csv 12873_merged_count.csv 12874_merged_count.csv /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/SNPs_release/eQTL_SNPs/Biallelic_eQTL_SNPs.vcf > /net/shendure/vol1/home/wchen108/data/AScount/AScount_9samples_v2.csv
import os,sys,re

f1 = open(sys.argv[1])
f2 = open(sys.argv[2])
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
        Chrom, Pos, ID, Ref, ALT, QUAL, FILTER, INFO, FORMAT, s1, s2, s3, s4, s5, s6, s7, s8, s9 = line.split()[0:18]
        table[(Chrom, Pos, ID, Ref, ALT)] = [0]*36
        table[(Chrom, Pos, ID, Ref, ALT)][3] ,table[(Chrom, Pos, ID, Ref, ALT)][7] ,table[(Chrom, Pos, ID, Ref, ALT)][11],\
        table[(Chrom, Pos, ID, Ref, ALT)][15],table[(Chrom, Pos, ID, Ref, ALT)][19],table[(Chrom, Pos, ID, Ref, ALT)][23],\
        table[(Chrom, Pos, ID, Ref, ALT)][27],table[(Chrom, Pos, ID, Ref, ALT)][31],table[(Chrom, Pos, ID, Ref, ALT)][35] =\
        s1, s2, s3, s4, s5, s6, s7, s8, s9

for line in f1:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        table[(Chrom, Pos, ID, REF, ALT)][0:3] = [int(REFcount),int(ALTcount),int(TOTALcount)]

for line in f2:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        table[(Chrom, Pos, ID, REF, ALT)][4:7] = [int(REFcount),int(ALTcount),int(TOTALcount)]

for line in f3:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        table[(Chrom, Pos, ID, REF, ALT)][8:11] = [int(REFcount),int(ALTcount),int(TOTALcount)]

for line in f4:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        table[(Chrom, Pos, ID, REF, ALT)][12:15] = [int(REFcount),int(ALTcount),int(TOTALcount)]

for line in f5:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        table[(Chrom, Pos, ID, REF, ALT)][16:19] = [int(REFcount),int(ALTcount),int(TOTALcount)]

for line in f6:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        table[(Chrom, Pos, ID, REF, ALT)][20:23] = [int(REFcount),int(ALTcount),int(TOTALcount)]

for line in f7:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        table[(Chrom, Pos, ID, REF, ALT)][24:27] = [int(REFcount),int(ALTcount),int(TOTALcount)]

for line in f8:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        table[(Chrom, Pos, ID, REF, ALT)][28:31] = [int(REFcount),int(ALTcount),int(TOTALcount)]

for line in f9:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        table[(Chrom, Pos, ID, REF, ALT)][32:35] = [int(REFcount),int(ALTcount),int(TOTALcount)]

print "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" % \
    ('#Chrom', 'Pos', 'ID', 'REF', 'ALT', 'NA10847', ' ', ' ', 'Genotype', 'NA12814', ' ', ' ','Genotype', 'NA12878', ' ', ' ', 'Genotype', 'NA12815', ' ', ' ', 'Genotype', 'NA12812', ' ', ' ', 'Genotype', 'NA12813', ' ', ' ', 'Genotype', 'NA12872', ' ', ' ', 'Genotype', 'NA12873', ' ', ' ', 'Genotype', 'NA12874', ' ', ' ','Genotype')

for key in table:
    print "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" % \
    (key[0], key[1], key[2], key[3], key[4], table[key][0], table[key][1], table[key][2], table[key][3], table[key][4], table[key][5], table[key][6],\
     table[key][7], table[key][8], table[key][9], table[key][10], table[key][11], table[key][12], table[key][13], table[key][14], table[key][15], table[key][16],\
      table[key][17], table[key][18], table[key][19], table[key][20], table[key][21], table[key][22], table[key][23], table[key][24], table[key][25], table[key][26],table[key][27],table[key][28],table[key][29],table[key][30],table[key][31],table[key][32],table[key][33],table[key][34],table[key][35])