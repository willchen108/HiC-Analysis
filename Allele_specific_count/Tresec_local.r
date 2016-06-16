results = read.delim('/Users/Will/Desktop/data/AScount/AScount_eQTL_promoter_remapped_060616_eqtl.txt', header=T)
data <- read.delim('/Users/Will/Desktop/data/AScount/AScount_eQTLonly_realigned_dedup_wasp_sorted_20160614.csv')

results = read.delim('/Users/Will/Desktop/data/AScount/AScount_SPloops_remapped_053016_eqtl.txt', header=T)
data_total <- read.delim('/Users/Will/Desktop/data//AScount/AScount_SP_loops_sorted.csv')

samp <- c(6,10,14,18,22,26,30,34,38)

trc <- t(data[,samp+2])
readsums <- apply(trc,2,sum)
data<-data[-which(readsums<quantile(readsums,0.05)),]

trc  <- t(data_total[,samp+2])
len <- dim(trc)[2]
filtered <- c(1)
for (i in 1:len) {
  if (all(trc[,i]>10)=='FALSE'){
    filtered <- append(filtered,i)
  }
}

filtered <- filtered[-1]

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

gg_qqplot(na.omit(results_ase$final_Pvalue))



# SPloop plot
geno<-genos$X451
geno[which(geno==4)]<-2
geno[which(geno==3)]<-1
jittergeno<-jitter(geno,0.5)
jittergeno[which(geno==0)]<-jittergeno[which(geno==0)]+1
jittergeno[which(geno==1)]<-jittergeno[which(geno==1)]+1
jittergeno[which(geno==2)]<-jittergeno[which(geno==2)]+1
ratio<- c(1,1.284588336,1.100746437,1.439222354,1.3094681,1.251398306,1.662814981,1.067659613,0.734573258)

data_sub[1,]
results[which(results$GeneRowID==3),]
boxplot(trc$X451/ratio~geno,notch=F,xaxt='n',frame=F,outpch=NA,col="grey90",xlab='rs35004683',ylab='Mapped reads(Normalized)',ylim=c(0, 1000),cex.axis=1.25,cex.lab=1.25)
points(jittergeno,as.numeric(trc$X451/ratio), col="grey25",pch=16,bty='n',cex=1.25)
axis(1,at=c(1:3),labels=c('T/T (ref/ref) n = 3','T/C (ref/alt) n = 5','C/C (alt/alt) n = 1'),lty=0,cex.axis=1.25)
text(3,700,expression(italic(P)*" = 6.31 x "*10^{-4}))


ratio2 <- c(1.2845883, 1.3094681, 1.2513983, 1.6628150, 0.7345733)
r <- data.frame(c(334,286,257,439,385))
a <- data.frame(c(242,183,177,310,323))
colnames(r) <- 'Ref(T)'
colnames(a) <- 'Alt(C)'
test <- cbind(r,a)
Names <- colnames(ref)
test <- test/ratio2
test <- cbind(test,Names)
test.m <-melt(test,id.vars='Names')
library(ggplot2)
ggplot(test.m, aes(Names, value)) +   
  geom_bar(aes(fill = variable), position = "dodge", stat="identity")+ylab("Number of reads")+xlab("")

#plot1
geno<-genos$X3803
geno[which(geno==4)]<-2
geno[which(geno==3)]<-1
jittergeno<-jitter(geno,0.5)
jittergeno[which(geno==0)]<-jittergeno[which(geno==0)]+1
jittergeno[which(geno==1)]<-jittergeno[which(geno==1)]+1
jittergeno[which(geno==2)]<-jittergeno[which(geno==2)]+1

data[3803,]
results[which(results$GeneRowID==3803),]
boxplot(trc$X3803~geno,notch=F,xaxt='n',frame=F,outpch=NA,col="grey90",xlab='rs37711',ylab='mapped reads',cex.axis=1.25,cex.lab=1.25)
points(jittergeno,as.numeric(trc$X3803), col="grey25",pch=16,bty='n',cex=1.25)
axis(1,at=c(1:3),labels=c('G/G (ref/ref) n = 3','G/A (ref/alt) n = 5','A/A (alt/alt) n = 1'),lty=0,cex.axis=1.25)
text(1.5,60,expression(italic(P)*" = 1.83 x "*10^{-6}))

#plot2
geno<-genos$X9997
geno[which(geno==4)]<-2
geno[which(geno==3)]<-1
jittergeno<-jitter(geno,0.5)
jittergeno[which(geno==0)]<-jittergeno[which(geno==0)]+1
jittergeno[which(geno==1)]<-jittergeno[which(geno==1)]+1
jittergeno[which(geno==2)]<-jittergeno[which(geno==2)]+1

data[9997,]
results[which(results$GeneRowID==9997),]
boxplot(trc$X9997~geno,notch=F,xaxt='n',frame=F,outpch=NA,col="grey90",xlab='rs4654636',ylab='mapped reads',cex.axis=1.25,cex.lab=1.25)
points(jittergeno,as.numeric(trc$X9997), col="grey25",pch=16,bty='n',cex=1.25)
axis(1,at=c(1:3),labels=c('C/C (ref/ref) n = 3','C/A (ref/alt) n = 5','A/A (alt/alt) n = 1'),lty=0,cex.axis=1.25)
text(1,60,expression(italic(P)*" = 1.44 x "*10^{-7}))

#plot3
geno<-genos$X12142
geno[which(geno==4)]<-2
geno[which(geno==3)]<-1
jittergeno<-jitter(geno,0.5)
jittergeno[which(geno==0)]<-jittergeno[which(geno==0)]+1
jittergeno[which(geno==1)]<-jittergeno[which(geno==1)]+1
jittergeno[which(geno==2)]<-jittergeno[which(geno==2)]+1

data[12142,]
results[which(results$GeneRowID==12142),]
boxplot(trc$X12142~geno,notch=F,xaxt='n',frame=F,outpch=NA,col="grey90",xlab='rs10210291',ylab='mapped reads',cex.axis=1.25,cex.lab=1.25)
points(jittergeno,as.numeric(trc$X12142), col="grey25",pch=16,bty='n',cex=1.25)
axis(1,at=c(1:3),labels=c('C/C (ref/ref) n = 2','C/t (ref/alt) n = 5','T/T (alt/alt) n = 2'),lty=0,cex.axis=1.25)
text(1.5,100,expression(italic(P)*" = 3.76 x "*10^{-6}))


#Plot4
geno<-genos$X18830
geno[which(geno==4)]<-2
geno[which(geno==3)]<-1
jittergeno<-jitter(geno,0.5)
jittergeno[which(geno==0)]<-jittergeno[which(geno==0)]+1
jittergeno[which(geno==1)]<-jittergeno[which(geno==1)]+1
jittergeno[which(geno==2)]<-jittergeno[which(geno==2)]+1

data[18830,]
results[which(results$GeneRowID==18830),]
boxplot(trc$X18830~geno,notch=F,xaxt='n',frame=F,outpch=NA,col="grey90",xlab='rs7586384',ylab='mapped reads',cex.axis=1.25,cex.lab=1.25)
points(jittergeno,as.numeric(trc$X18830), col="grey25",pch=16,bty='n',cex=1.25)
axis(1,at=c(1:3),labels=c('T/T (ref/ref) n = 3','T/C (ref/alt) n = 4','C/C (alt/alt) n = 2'),lty=0,cex.axis=1.25)
text(1.5,80,expression(italic(P)*" = 8.01 x "*10^{-6}))

#plot 5
geno<-genos$X45023
geno[which(geno==4)]<-2
geno[which(geno==3)]<-1
jittergeno<-jitter(geno,0.5)
jittergeno[which(geno==0)]<-jittergeno[which(geno==0)]+1
jittergeno[which(geno==1)]<-jittergeno[which(geno==1)]+1
jittergeno[which(geno==2)]<-jittergeno[which(geno==2)]+1

data[45023,]
results[which(results$GeneRowID==45023),]
boxplot(trc$X45023~geno,notch=F,xaxt='n',frame=F,outpch=NA,col="grey90",xlab='rs7741616',ylab='mapped reads',cex.axis=1.25,cex.lab=1.25)
points(jittergeno,as.numeric(trc$X45023), col="grey25",pch=16,bty='n',cex=1.25)
axis(1,at=c(1:3),labels=c('G/G (ref/ref) n = 4','G/A (ref/alt) n = 3','A/A (alt/alt) n = 2'),lty=0,cex.axis=1.25)
text(2,120,expression(italic(P)*" = 5.21 x "*10^{-6}))

#plot 6
geno<-genos$X61654
geno[which(geno==4)]<-2
geno[which(geno==3)]<-1
jittergeno<-jitter(geno,0.5)
jittergeno[which(geno==0)]<-jittergeno[which(geno==0)]+1
jittergeno[which(geno==1)]<-jittergeno[which(geno==1)]+1
jittergeno[which(geno==2)]<-jittergeno[which(geno==2)]+1

data[61654,]
results[which(results$GeneRowID==61654),]
boxplot(trc$X61654~geno,notch=F,xaxt='n',frame=F,outpch=NA,col="grey90",xlab='rs10820601',ylab='mapped reads',cex.axis=1.25,cex.lab=1.25)
points(jittergeno,as.numeric(trc$X61654), col="grey25",pch=16,bty='n',cex=1.25)
axis(1,at=c(1:3),labels=c('G/G (ref/ref) n = 3','G/A (ref/alt) n = 4','A/A (alt/alt) n = 2'),lty=0,cex.axis=1.25)
text(2,60,expression(italic(P)*" = 9.1 x "*10^{-6}))


#plot7
geno<-genos$X79079
geno[which(geno==4)]<-2
geno[which(geno==3)]<-1
jittergeno<-jitter(geno,0.5)
jittergeno[which(geno==0)]<-jittergeno[which(geno==0)]+1
jittergeno[which(geno==1)]<-jittergeno[which(geno==1)]+1
jittergeno[which(geno==2)]<-jittergeno[which(geno==2)]+1

data[79079,]
results[which(results$GeneRowID==79079),]
boxplot(trc$X79079~geno,notch=F,xaxt='n',frame=F,outpch=NA,col="grey90",xlab='rs750584',ylab='mapped reads',cex.axis=1.25,cex.lab=1.25)
points(jittergeno,as.numeric(trc$X79079), col="grey25",pch=16,bty='n',cex=1.25)

axis(1,at=c(1:3),labels=c('G/G (ref/ref) n = 3','G/A (ref/alt) n = 5','A/A (alt/alt) n = 1'),lty=0,cex.axis=1.25)
text(1.5,60,expression(italic(P)*" = 1.83 x "*10^{-6}))





samp <- c(6,10,14,18,22,26,30,34,38)
results_subset <- results[-which(is.na(results$Joint_b)),]
index <- which(results_subset$final_Pvalue<1.0e-05)
results_final <- results_subset[index,]
index2 <- results_final$GeneRowID
data_subset2 <- data[index2,]

results <- results[-which(is.na(results$Joint_b)),]
results_test <- results_subset[-which(is.na(results_subset$final_Pvalue)),]

results_a <- results[-which(is.na(x=results$final_Pvalue)),]
results_a <- results_a[-which(is.na(results_a$Joint_b)),]
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
pdf('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/AScount/WASP_remapped/trecase_asl_qqplot_052716.pdf',width=7*1.25,height=7)
gg_qqplot(na.omit(results$final_Pvalue))
dev.off()



pdf('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/AScount/WASP_remapped/effect_size_hist.pdf',width=7*1.25,height=7)
cuts<-cut(results$Joint_b,c(-Inf,-0.12188,0.12188,Inf))
hist(results$Joint_b,col=cuts,xlab="joint_beta")
dev.off()

cuts<-cut(results$Joint_b,c(-Inf,-0.12188,0.12188,Inf))

results$col<-rep('NS',dim(results)[1])
results$col[intersect(which(results$final_Qvalue<0.05),which(results$Joint_b<0))]<-'sig_neg'
results$col[intersect(which(results$final_Qvalue<0.05),which(results$Joint_b>0))]<-'sig_pos'
pdf('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/AScount/WASP_remapped/effect_size_hist_2.pdf',width=7*1.25,height=7)
ggplot(results,aes(x=Joint_b,fill=col)) +
  geom_histogram(binwidth=0.05) +
  scale_fill_brewer(palette="Set1") +
  scale_x_continuous(limits=c(-5,5)) +
  theme_bw() +
  theme(legend.position="none")
dev.off()