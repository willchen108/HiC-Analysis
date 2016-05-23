data <- read.delim('/net/shendure/vol1/home/wchen108/data/AScount/AScount_9samples_v2_sorted.csv',header=T)
data <- read.delim('/Users/Will/Desktop/AScount/AScount_9samples_v2_sorted.csv',header=T)
samp <- c(6,10,14,18,22,26,30,34)
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

#filter out sites with fewer than 65 reads across all samples
trc <- t(data[,samp+2])
readsums <- apply(trc,2,sum)
data<-data[-which(readsums<quantile(readsums,0.05)),]

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
cov<-read.csv('/Users/Will/Desktop/AScount/seq_coverage.csv',header=T)
cov2<-as.matrix(cov[c(1:6,8:10),2:4])

eChr = mChr = as.integer(data[,1])
ePos = mPos = as.integer(data[,2])

results = trecase(Y = trc, Y1 = ase1, Y2 = ase2, X = cov2, Z = genos, eChr = eChr, ePos = ePos, mChr = mChr, mPos = mPos, output.tag = 'dhc_results_3', p.cut = 1, local.only = TRUE, local.distance = 1, min.AS.sample = 2, min.n.het = 1)

results = read.delim('/net/shendure/vol1/home/wchen108/data/AScount/dhc_trecase_ase_prelim_results_051716.txt', header=T)

require(qvalue)
results$final_Qvalue<-qvalue(results$final_Pvalue)$qvalues
results$ASE_Qvalue<-qvalue(results$ASE_Pvalue)$qvalues

examine<-function(x){
	a<-genos[,x]
	b<-ase1[,x]
	c<-ase2[,x]
	d<-trc[,x]
	print(tapply(b,a,sum))
	print(tapply(c,a,sum))
	print(tapply(d,a,sum))
}

results = trecase(Y = d, Y1 = b, Y2 = c, X = cov2, Z = a, eChr = eChr[1], ePos = ePos[1], mChr = mChr[1], mPos = mPos[1], output.tag = 'test', p.cut = 1, local.only = TRUE, local.distance = 1, min.AS.sample = 2, min.n.het = 1)

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
pdf('/net/shendure/vol1/home/wchen108/data/AScount/trecase_asl_qqplot_052016.pdf',width=7*1.25,height=7)
gg_qqplot(na.omit(results$final_Pvalue))
dev.off()

geno<-genos[,64291]
geno[which(geno==4)]<-2
jittergeno<-jitter(geno,0.5)
jittergeno[which(geno==0)]<-jittergeno[which(geno==0)]+1

pdf('/net/shendure/vol1/home/wchen108/data/AScount/sample_genotype_by_looping_event.pdf',width=7*1.25,height=7)
boxplot(trc[,64291]~geno,notch=F,xaxt='n',frame=F,outpch=NA,col="grey90",xlab='rs7113108',ylab='mapped reads',cex.axis=1.25,cex.lab=1.25)
points(jittergeno,as.numeric(trc[,64291]), col="grey25",pch=16,bty='n',cex=1.25)
axis(1,at=c(1:2),labels=c('A/A (ref/ref) n = 3','G/G (alt/alt) n = 6'),lty=0,cex.axis=1.25)
text(1,100,expression(italic(P)*" = 9.1 x "*10^{-79}))
dev.off()

pdf('/net/shendure/vol1/home/wchen108/data/AScount/effect_size_hist.pdf',width=7*1.25,height=7)
cuts<-cut(results$Joint_b,c(-Inf,-0.12188,0.12188,Inf))
hist(results$Joint_b,col=cuts,xlab="joint_beta")
dev.off()

cuts<-cut(results$Joint_b,c(-Inf,-0.12188,0.12188,Inf))

results$col<-rep('NS',dim(results)[1])
results$col[intersect(which(results$final_Qvalue<0.05),which(results$Joint_b<0))]<-'sig_neg'
results$col[intersect(which(results$final_Qvalue<0.05),which(results$Joint_b>0))]<-'sig_pos'
pdf('/net/shendure/vol1/home/wchen108/data/AScount/effect_size_hist.pdf',width=7*1.25,height=7)
ggplot(results,aes(x=Joint_b,fill=col)) +
  geom_histogram(binwidth=0.05) +
  scale_fill_brewer(palette="Set1") +
  scale_x_continuous(limits=c(-5,5)) +
  theme_bw() +
  theme(legend.position="none")
dev.off()