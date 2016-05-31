library(asSeq)
data_total <- read.delim('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/AScount/WASP_remapped/AScount_SPloops_remapped.sorted.csv',header=T)
data_total <- read.delim('/Users/Will/Desktop/data/AScount/AScount_SPloops_remapped.sorted.csv',header=T)

cov  <- read.csv('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/AScount/seq_coverage.csv',header=T)
samp <- c(6,10,14,18,22,26,30,34,38)

#filter out sites with fewer than 65 reads across all samples
trc  <- t(data_total[,samp+2])
len <- dim(trc)[2]
filtered <- c(1)

#filter option 1
for (i in 1:len) {
  if (all(trc[,i]==0 | trc[,i]>10)=='FALSE'){
    filtered <- append(filtered,i)
    }
}

#filter option 2   I chose option to to filter out more reads.
for (i in 1:len) {
  if (all(trc[,i]>10)=='FALSE'){
    filtered <- append(filtered,i)
    }
}

filtered <- filtered[-1]
data <- data_total[-filtered,]
trc  <- t(data[,samp+2])
data <- data[-which(colSums(trc)<quantile(colSums(trc), 0.05)),]

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

#SP loops
results = trecase(Y = trc, Y1 = ase1, Y2 = ase2, X = cov2, Z = genos, eChr = eChr, ePos = ePos, mChr = mChr, mPos = mPos, output.tag = 'AScount_SPloops_remapped_053016', p.cut = 1, local.only = TRUE, local.distance = 1, min.AS.sample = 2, min.n.het = 1)


results = read.delim('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/AScount/WASP_remapped/AScount_SPloops_remapped_053016_eqtl.txt', header=T)

results = read.delim('/Users/Will/Desktop/data/AScount/AScount_SPloops_remapped_053016_eqtl.txt', header=T)
#remove all p-values = NA
results <- results[-which(is.na(x=results$final_Pvalue)),]
results_ase <- results[-which(is.na(x=results$ASE_Pvalue)),]
require(qvalue)
results$final_Qvalue<-qvalue(results$final_Pvalue)$qvalues
results_ase$ASE_Qvalue<-qvalue(results_ase$ASE_Pvalue)$qvalues

gg_qqplot = function(xs, ci=0.95) {
    N = length(xs)
    df = data.frame(observed=-log10(sort(xs)),
                    expected=-log10(1:N / N),
                    cupper=-log10(qbeta(ci,     1:N, N - 1:N + 1)),
                    clower=-log10(qbeta(1 - ci, 1:N, N - 1:N + 1)))
    log10Pe = expression(paste("Expected -log"[10], plain(P)))
    log10Po = expression(paste("Observed -log"[10], plain(P)))
    ggplot(df) +
        geom_point(aes(expected, observed), shape=1, size=3) +
        geom_abline(intercept=0, slope=1, alpha=0.5) +
        geom_line(aes(expected, cupper), linetype=2) +
        geom_line(aes(expected, clower), linetype=2) +
        xlab(log10Pe) +
        ylab(log10Po) +
        theme_bw(base_size = 20)
}

require(ggplot2)
pdf('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/AScount/WASP_remapped/trecase_asl_SPloops_qqplot_053016.pdf',width=7*1.25,height=7)
gg_qqplot(na.omit(results$final_Pvalue))
dev.off()

genos <- data.frame(genos)
trc <- data.frame(trc)


geno<-genos$X133
geno[which(geno==4)]<-2
geno[which(geno==3)]<-1
jittergeno<-jitter(geno,0.5)
jittergeno[which(geno==0)]<-jittergeno[which(geno==0)]+1
jittergeno[which(geno==1)]<-jittergeno[which(geno==1)]+1
jittergeno[which(geno==2)]<-jittergeno[which(geno==2)]+1

data[133,]
results[which(results$GeneRowID==133),]
boxplot(trc$X133~geno,notch=F,xaxt='n',frame=F,outpch=NA,col="grey90",xlab='rs37711',ylab='mapped reads',cex.axis=1.25,cex.lab=1.25)
points(jittergeno,as.numeric(trc$X133), col="grey25",pch=16,bty='n',cex=1.25)
axis(1,at=c(1:3),labels=c('T/T (ref/ref) n = 3','T/C (ref/alt) n = 5','A/A (alt/alt) n = 1'),lty=0,cex.axis=1.25)
text(1.5,60,expression(italic(P)*" = 1.83 x "*10^{-6}))
