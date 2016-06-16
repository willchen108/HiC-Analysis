# This file is create by Will @ 2016.06.16
# python /net/shendure/vol1/home/wchen108/HiC-Analysis/CHiCAGO/rmap_convert.py > /net/shendure/vol10/projects/DNaseHiC.eQTLs/data/Dnasemap_hs37d5.rmap
import os,sys,re
rmap = open('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/Dnase_map_hs37d5.rmap')
print "%s\t%s\t%s\t%s" % \
    ('chr', 'start', 'end', 'fragmentID')
for line in rmap:
    if "start" not in line:
        if 'hs37d5' or 'NC_00' in line:
            Chrom, start, end, ID = line.split()[0:4]
        else:
            Chrom, s1, s2, start, end, ID = line.split()[0:6]
        print "%s\t%s\t%s\t%s" %  (Chrom, start, end, ID)