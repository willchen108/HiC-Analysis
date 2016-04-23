import os,sys,re

bed_r1 = open(sys.argv[1])
bed_r2 = open(sys.argv[2])

org = {}


for line in bed_r1:
	chrid,fcoord,rcoord,title,qual,strand = line.split()
	if title in org:
		org[title].append((chrid,fcoord,rcoord,qual,strand))
	else:
		org[title] = []
		org[title].append((chrid,fcoord,rcoord,qual,strand))

for line in bed_r2:
	chrid,fcoord,rcoord,title,qual,strand = line.split()
	if title in org:
		org[title].append((chrid,fcoord,rcoord,qual,strand))
	else:
		org[title] = []
		org[title].append((chrid,fcoord,rcoord,qual,strand))

for i in org:
	if len(org[i]) >= 2:#get rid of those with only one read.
		for j in range(len(org[i])-1):
			chrid_1,fcoord1,rcoord1,qual1,strand1 = org[i][j]
			chrid_2,fcoord2,rcoord2,qual2,strand2 = org[i][j+1]
			if chrid_1 == chrid_2:
				if int(fcoord1) > int(fcoord2):
					print "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" % (chrid_2, fcoord2, rcoord2, chrid_1, fcoord1,\
						rcoord1, i, int(qual1) + int(qual2), strand2, strand1) 
				else:
					print "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" % (chrid_1, fcoord1, rcoord1, chrid_2, fcoord2,\
                               	        	rcoord2, i, int(qual1) + int(qual2), strand1, strand2)
			elif chrid_1 >= chrid_2:
				print "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" % (chrid_2, fcoord2, rcoord2, chrid_1, fcoord1,\
                       	        	rcoord1, i, int(qual1) + int(qual2), strand2, strand1)
			else:
				print "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" % (chrid_1, fcoord1, rcoord1, chrid_2, fcoord2,\
					rcoord2, i, int(qual1) + int(qual2), strand1, strand2)	