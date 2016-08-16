# This file is create by Will @ 2016.05.18

import os,sys,re
f1 = open('/Users/Will/Documents/AScount_biased.xlsx')

AS = {}
for line in f1:
    if '#' not in line:
        Chrom, Pos, ID, REF, ALT, r1, a1, t1, g1, r2, a2, t2, g2,r3, a3, t3,g3, r4, a4, t4, g4, r5, a5, t5, g5, \
        r6, a6, t6, g6,r7, a7, t7,g7, r8, a8, t8, g8, r9, a9, t9, g9 = line.split()[0:41]
        gs = [g1,g2,g3,g4,g5,g6,g7,g8,g9]
        rs = [r1,r2,r3,r4,r5,r6,r7,r8,r9]
        alts = [a1,a2,a3,a4,a5,a6,a7,a8,a9]
        ts = [t1,t2,t3,t4,t5,t6,t7,t8,t9]
        temp_r,temp_a = 0,0
        for g in range(len(gs)):
            if gs[g][0] != gs[g][2]:
                temp_r += int(rs[g])
                temp_a += int(alts[g])
        AS[(Chrom, Pos, ID, REF, ALT)] = [temp_r,temp_a]
#print "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" % (head[0],head[1],head[2],head[3],head[4],head[5],head[6],head[7])
#for i in temp:
#	print "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" % (temp[i][0],temp[i][1],temp[i][2],temp[i][3],temp[i][4],temp[i][5],temp[i][6],temp[i][7]) 