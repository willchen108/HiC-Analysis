snpsfile = open("~/data/snps_in_rao.bed")
targetfile = open("~/data/gencode.v19_promoter_chr_removed.bed")

SNPs = []
for line in snpsfile:
	chrid, x1, x2, y1, y2, snps  = line.split()[0:6] 
	SNPs.append([chrid, int(x1),int(x2),int(y1),int(y2),int(snps)])

total =[]
for line in targetfile:
	ch,st,end = line.split()[0:3]
	st = int(st)
	end = int(end)
	for snp in SNPs:
		if snp[0] == ch:
			if st in range(snp[3],snp[4]) or end in range(snp[3],snp[4]):
				total.append([snp[0], snp[1], snp[2], snp[3], snp[4], snp[5],st, end]
				print "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" % (snp[0], snp[1], snp[2], snp[3], snp[4], snp[5],st, end) 
