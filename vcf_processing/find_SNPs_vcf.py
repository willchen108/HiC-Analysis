import os,sys,re
import csv
from math import sqrt
VCFfile = open(sys.argv[1])
SNPsfile = open(sys.argv[2])
#VCFfile = open('/Users/Will/Desktop/test2.vcf')
#SNPsfile = open('/Users/Will/Desktop/eqtl_capture_just_all_eqtls_all_promoter_snps_excluded_snp_coords_sorted_chr_removed.bed')
SNPs={}

for snp in SNPsfile:
	chrid = snp.split()[0]
	ref   = snp.split()[3]
	if chrid in SNPs:
		SNPs[chrid].append(ref)
	else:
		SNPs[chrid] = []
		SNPs[chrid].append(ref)

result = []
for line in VCFfile:
	if '##' not in line:
		Chrom, Pos, ID, REF, ALT, QUAL, FILTER, INFO, FORMAT, s1, s2, s3, s4, s5, s6, s7, s8, s9 = line.split()[0:18]
		if Pos == 'POS':
			#esult.append([Chrom, Pos, ID, s1, s2, s3, s4, s5, s6, s7, s8, s9])
			print "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" % (Chrom, Pos, ID, s1, s2, s3, s4, s5, s6, s7, s8, s9)
		else:
			for ref in SNPs[Chrom]:
				if ref == ID:
					if len(ALT) > 1:
						allel = ALT.split(',')
						allel.insert(0,REF)
					else:
						allel=REF+ALT
					gntype = []
					for sample in [s1, s2, s3, s4, s5, s6, s7, s8, s9]:
						gntype.append([allel[int(sample[0])]+allel[int(sample[2])]])
					#result.append([Chrom, Pos, ID, gntype[0], gntype[1], gntype[2], gntype[3], gntype[4], gntype[5], gntype[6], gntype[7], gntype[8]])
					print "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" % (Chrom, Pos, ID, gntype[0], gntype[1], gntype[2], gntype[3], gntype[4], gntype[5], gntype[6], gntype[7], gntype[8])