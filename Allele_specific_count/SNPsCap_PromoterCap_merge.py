# This file is create by Will @ 2016.05.13
# This file is used to merge the allel specific counts from SNPs Capture data and Promoter Capture data.
# Usage 
import os,sys,re
f1 = open(sys.argv[1])
f2 = open(sys.argv[2])

temp = {}
for line in f1:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        temp[(Chrom,ID)].append([Chrom, Pos, ID, REF, ALT, int(REFcount), int(ALTcount), int(TOTALcount)])
    else:
    	head = line.strip('\n')

for line in f2:
    if 'contig' not in line:
        Chrom, Pos, ID, REF, ALT, REFcount, ALTcount, TOTALcount = line.split()[0:8]
        if (Chrom,ID) in temp:
            temp[(Chrom,ID)][5] += int(REFcount)
            temp[(Chrom,ID)][6] += int(ALTcount)
            temp[(Chrom,ID)][7] += int(TOTALcount)
        else:
            temp[(Chrom,ID)]=[Chrom, Pos, ID, REF, ALT, int(REFcount), int(ALTcount), int(TOTALcount)]

for i in temp:
	print "%s" % (head)
	print "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" % (temp[i][0],temp[i][1],temp[i][2],temp[i][3],temp[i][4],temp[i][5],temp[i][6],temp[i][7]) 