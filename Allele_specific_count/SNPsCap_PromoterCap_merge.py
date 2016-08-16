# This file is create by Will @ 2016.05.13
# This file is used to merge the allel specific counts from SNPs Capture data and Promoter Capture data.
# Usage python ~/HiC-Analysis/Allele_specific_count/SNPsCap_PromoterCap_merge.py ${NAME[$i]}_eQTL.csv ${NAME[$i]}_promoters.csv > /net/shendure/vol1/home/wchen108/data/AScount/${NAME[$i]}_merged_count.csv
import os,sys,re
f1 = open(sys.argv[1])
f2 = open(sys.argv[2])

temp = {}
for line in f1:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        temp[(Chrom,ID)] = [Chrom, Pos, ID, REF, ALT, int(REFcount), int(ALTcount), int(TOTALcount)]
    else:
    	Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        head = [Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount]

for line in f2:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        if (Chrom,ID) in temp:
            temp[(Chrom,ID)][5] += int(REFcount)
            temp[(Chrom,ID)][6] += int(ALTcount)
            temp[(Chrom,ID)][7] += int(TOTALcount)
        else:
            temp[(Chrom,ID)] = [Chrom, Pos, ID, REF, ALT, int(REFcount), int(ALTcount), int(TOTALcount)]
    
print "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" % (head[0],head[1],head[2],head[3],head[4],head[5],head[6],head[7])
for i in temp:
	print "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" % (temp[i][0],temp[i][1],temp[i][2],temp[i][3],temp[i][4],temp[i][5],temp[i][6],temp[i][7]) 