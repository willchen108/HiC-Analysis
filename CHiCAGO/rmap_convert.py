# This file is create by Will @ 2016.06.16
# python /net/shendure/vol1/home/wchen108/HiC-Analysis/CHiCAGO/rmap_convert.py > /net/shendure/vol10/projects/DNaseHiC.eQTLs/data/Dnasemap_hs37d5.rmap
import os,sys,re
rmap = open('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/Dnase_map_hs37d5.rmap')
print "%s\t%s\t%s\t%s" % \
    ('chr', 'start', 'end', 'fragmentID')
for line in rmap:
    if "start" not in line:
        if 'dna:' in line:
            Chrom, s1, s2, start, end, ID = line.split()[0:6]
        elif 'MT' in line:
        	continue 
        else:
            Chrom, start, end, ID = line.split()[0:4]            
        print "%s\t%s\t%s\t%s" %  (Chrom, int(float(start)), int(float(end)), int(float(ID)))