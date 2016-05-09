# This file is used to call the counts for 276 SNPs， including both reads_count and frequency.
# usage: python /net/shendure/vol1/home/wchen108/HiC-Analysis/Contactmap/count_loop-reads.py matrixfile SNPs_bin file

Mfile = open(sys.argv[1])
SNPsfile = open(sys.argv[2])

#SNPsfile = open("/Users/Will/Desktop/loops_snps_bin.txt")
#Mfile = open("/Users/Will/Desktop/10847_res5k_1k.matrix")

SNPs = {}
for snp in SNPsfile:
	chrid,bin1,bin2,s = snp.split()[0:4]
	if chrid != 'Chrid':
		if chrid in SNPs:
			SNPs[chrid].append([int(bin1),int(bin2),int(s)])
		else:
			SNPs[chrid] = []
			SNPs[chrid].append([int(bin1),int(bin2),int(s)])

print "%s\t%s\t%s\t%s\t%s\t%s" % ('Chrom', 'bin1', 'bin2', 'snp', 'count', 'norm_count')
for line in Mfile:
	bin1, bin2, count, freq, chrid = line.split()[0:5]
	if chrid in SNPs.keys():
		for loop in SNPs[chrid]:
			if int(bin1) == loop[0] and int(bin2) == loop[1]:
				#result.append([chrid,loop[0],loop[1],loop[2],count,freq])
				print "%s\t%s\t%s\t%s\t%s\t%s" % (chrid,loop[0],loop[1],loop[2],count,freq) # loop[0] contains the SNP
			elif int(bin1) == loop[1] and int(bin2) == loop[0]:
				#result.append([chrid,loop[0],loop[1],loop[2],count,freq])
				print "%s\t%s\t%s\t%s\t%s\t%s" % (chrid,loop[0],loop[1],loop[2],count,freq)