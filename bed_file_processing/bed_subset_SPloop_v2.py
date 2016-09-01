#Create by Will Chen @ 2016.05.23
#Modified @ 2016.08.31 to take trans qtl and promoter interaction
# This file is used to subset the bed file with loops that are SNP-promoter loops.
# python ~/HiC-Analysis/bed_file_processing/bed_subset_SPloop_v2.py /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/gencode.v19_promoter_chr_removed.bed /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/eqtl_snps_centered_snp_101bp_chr_removed.bed $workdir/${NAME[$i]}.bed.deduped > $workdir/Promoters/$i/${NAME[$i]}_SPloops_promotercap_1k.dedup.bed &


import os,sys,re
#BED file of mapped reads
promlist = open(sys.argv[1])
snplist  = open(sys.argv[2])
bed = open(sys.argv[3])

promoters = {}
for line in promlist:
	chrom, fwd, rev = line.split()[0:3]
	if chrom in promoters:
		promoters[chrom].append([int(fwd),int(rev)])
	else:
		promoters[chrom] = []
		promoters[chrom].append([int(fwd),int(rev)])
 
SNPs={}
for snp in snplist:
	chrom,fwd,rev,ref = snp.split()[0:4]
	if chrid in SNPs:
		SNPs[chrid].append([int(fwd),int(rev),ref])
	else:
		SNPs[chrid] = []
		SNPs[chrid].append([int(fwd),int(rev),ref])

#first round filter with promoter
temp=[]

for line in bed:
	split = line.split() #split BED file
	fcoord1,rcoord1 = int(split[1]),int(split[2]) #forward coordinate
	fcoord2,rcoord2 = int(split[4]),int(split[5]) #reverse coordinate 
	species1 = split[0] #ChrID of Mate 1
	species2 = split[3] #ChrID of Mate 2
	for chrom in promoters:
		for promoter in promoters[chrom]:  #In the temp bed file, SNP coordinate comes first.
			if promoter[0] < fcoord1 < promoter[1] or promoter[0] < rcoord1 < promoter[1]:
				temp.append([species2,fcoord2,rcoord2,species1,fcoord1,rcoord1,split[6],split[7],split[8],split[9]])
			elif promoter[0] < fcoord2 < promoter[1] or promoter[0] < rcoord2 < promoter[1]:
				temp.append([species1,fcoord1,rcoord1,species2,fcoord2,rcoord2,split[6],split[7],split[8],split[9]])
#second round filter with SNPs

for line in temp:
	start,end = line[1],line[2]
	for chrom in SNPs:
		if line[0] == chrom:
			for snp in SNPs[chrom]:
				if snp[0] < start < snp[1] or snp[0] < end < snp[1]:
					print "%s" % (line.rstrip('\n'))