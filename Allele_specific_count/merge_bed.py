import os,sys,re

bed_r1 = open(sys.argv[1])
bed_r2 = open(sys.argv[2])

org = {}


for line in bed_r1:
	chrid,fcoord,rcoord,title,qual,strand = line.split()
	if int(qual) > 0:
		if title in org:
			org[title] += 1
		else:
			org[title] = 0
			org[title] += 1

for line in bed_r2:
	chrid,fcoord,rcoord,title,qual,strand = line.split()
	if int(qual) > 0:
		if title in org:
			org[title] += 1
		else:
			org[title] = 0
			org[title] += 1

for i in org:
	print "%s\t%s" % (i, org[i]) 