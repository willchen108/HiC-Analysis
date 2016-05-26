#This code is created by Ron Hause and modified by Will
#Usage 
library(asSeq)
data_total <- read.delim(args[1],header=T)
tagname <- args[2]
args<-commandArgs(TRUE)
cov  <- read.csv('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/AScount/seq_coverage.csv',header=T)
samp <- c(6,10,14,18,22,26,30,34,38)

#filter out sites with fewer than 65 reads across all samples
trc  <- t(data_total[,samp+2])
data <- data_total[-which(colSums(trc)<quantile(colSums(trc), 0.10)),]

#change genotypes to work with asSeq
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

#use total read coverage as a covariate
cov  <- read.csv('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/AScount/seq_coverage.csv',header=T)
cov2 <- as.matrix(cov[c(1:6,8:10),2:4])

eChr = mChr = as.integer(data[,1])
ePos = mPos = as.integer(data[,2])

results = trecase(Y = trc, Y1 = ase1, Y2 = ase2, X = cov2, Z = genos, eChr = eChr, ePos = ePos, mChr = mChr, mPos = mPos, output.tag = tagname, p.cut = 1, local.only = TRUE, local.distance = 1, min.AS.sample = 2, min.n.het = 1)

results = read.delim('/net/shendure/vol1/home/wchen108/data/AScount/dhc_trecase_ase_prelim_results_051716.txt', header=T)

require(qvalue)
results$final_Qvalue<-qvalue(results$final_Pvalue)$qvalues
results$ASE_Qvalue<-qvalue(results$ASE_Pvalue)$qvalues

