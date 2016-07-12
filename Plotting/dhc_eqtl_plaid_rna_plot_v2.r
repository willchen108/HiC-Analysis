library(diffHic)
library(Sushi) #Sushi package need to be loaded after diffHiC
library(BSgenome.Hsapiens.1000genomes.hs37d5)
library(GenomicRanges)
setwd('/net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhcpair_Will/')

seg.frags <- segmentGenome(BSgenome.Hsapiens.1000genomes.hs37d5, size = 500)
seg.param = pairParam(seg.frags)
bin.size <- 5000
input <- c("12872_snps_properPairs_fixmate.sorted.dedup.sort.RG.sortname.h5","12813_snps_properPairs_fixmate.sorted.dedup.sort.RG.sortname.h5","12812_snps_properPairs_fixmate.sorted.dedup.sort.RG.sortname.h5","12873_snps_properPairs_fixmate.sorted.dedup.sort.RG.sortname.h5","12814_snps_properPairs_fixmate.sorted.dedup.sort.RG.sortname.h5","12815_snps_properPairs_fixmate.sorted.dedup.sort.RG.sortname.h5","12878_snps_properPairs_fixmate.sorted.dedup.sort.RG.sortname.h5","12874_snps_properPairs_fixmate.sorted.dedup.sort.RG.sortname.h5","10847_snps_properPairs_fixmate.sorted.dedup.sort.RG.sortname.h5","12875_snps_properPairs_fixmate.sorted.dedup.sort.RG.sortname.h5")
data <- squareCounts(input, seg.param, width = bin.size, filter = 1)

#filtering out uninteresting bin pairs
library(edgeR)
ave.ab <- aveLogCPM(asDGEList(data))
pdf('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/plots/dhc_snp_ave.abundance.pdf')
hist(ave.ab, xlab="average abundance", main='')
dev.off()
save(data, file='/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/plots/snp_hic_counts.robj')
save(ave.ab, file='/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/plots/snp_hic_count_avg_abundances.robj')

#of the 121,421,262 interactions with at least one read, the vast majority have too little data across samples for quantitative comparison
keep <- ave.ab > 0
data2 <- data[keep,]
#filters down to 41,422 interactions



direct <- filterDirect(data)

#normalize counts between libraries
y <- asDGEList(data2)
y$offset <- normOffsets(data, type="loess")

# target_regions
promoters <- import.bed(con='/net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/gencode.v19_promoter_chr_removed.bed')
snps <- import.bed(con='/net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/eqtl_capture_just_all_eqtls_all_promoter_snps_excluded_snp_coords_centered_on_snp_merged_no_promoter_snps.chr_removed.bed')
snps2 <- snps + 2500L
promoters2 <- flank(promoters, 1e6)
target_region <- union(snps2, promoters2)


load(file='/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/plots/snp_hic_counts.robj')

targetdata <- connectCounts(input, seg.param, regions=target_region)
#narrows down to 1,534,247 interactions but retaining original bed binning




upstream_region <- flank(promoters[which(promoters$name=='ENSG00000116771'),],1e6)
snp_region <- flank(snps[which(snps$name=='rs35004683'),], 1e6)

targetdata2<-data[queryHits(findOverlaps(target_region, data))]
system.time(a <- inflate(targetdata2, upstream_region, upstream_region, sample=1L))

environment(extract_region)<-environment(rotPlaid)
a <- extract_region("12874_snps_properPairs_fixmate.sorted.dedup.sort.RG.sortname.h5", region = upstream_region, width = 5000, param = seg.param)
b <- inflate(GInteractions(a$first, a$second), rows=as.character(a$first@seqnames@values), columns=as.character(a$first@seqnames@values), fill=a$counts)



data <- read.delim('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/AScount/AScount_9samples_v2_sorted.csv',header=T)

#change genotypes to work with asSeq
samp <- c(6,10,14,18,22,26,30,34,38)
genosamples <- colnames(data)[samp]
genosamples <- gsub('NA','',genosamples)
genos <- t(data[,samp+3])
genos[which(genos=='0|0')] <- 0
genos[which(genos=='1|0')] <- 3
genos[which(genos=='0|1')] <- 1
genos[which(genos=='1|1')] <- 4
genos <- apply(genos,2,as.numeric)

#eliminate SNPs that are monomorphic across these nine individuals
monomorphic<-apply(genos,2,function(x)length(unique(x)))
data<-data[-which(monomorphic==1),]

#create objects for trecase
trc <- t(data[,samp+2])
ase1 <- t(data[,samp])
ase2 <- t(data[,samp+1])
genos <- t(data[,samp+3])
genos[which(genos=='0|0')] <- 0
genos[which(genos=='1|0')] <- 3
genos[which(genos=='0|1')] <- 1
genos[which(genos=='1|1')] <- 4
genos <- apply(genos,2,as.numeric)

genosub<-genos[,which(data$ID=='rs35004683')]

pdf('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/plots/ENSG00000116771_rotplaid_plot_test.pdf')
rotPlaid2("12874_snps_properPairs_fixmate.sorted.dedup.sort.RG.sortname.h5", region = upstream_region, width = 5000, param = seg.param)
dev.off()

#rnaseq
require(rtracklayers)
rna10847<-import.bedGraph('/net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/rnaseq/NA10847.rnaseq.bedgraph')

require(TxDb.Hsapiens.UCSC.hg19.knownGene)
gene.body<-genes()