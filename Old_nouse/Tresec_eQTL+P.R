library(asSeq)
data_total <- read.delim('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/AScount/WASP_remapped/AScount_eQTL_promoter_remapped.sorted.csv',header=T)
data_total <- read.delim('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/AScount/realigned_wasp_remapped/AScount_eQTLonly_realigned_dedup_wasp_sorted_20160614.csv',header=T)


data_total <- read.delim('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/AScount/WASP/AScount_eQTL+Promoter_20160706.sorted.csv',header=T)

cov  <- read.csv('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/AScount/seq_coverage.csv',header=T)
samp <- c(6,10,14,18,22,26,30,34,38)

#filter out sites with fewer than 65 reads across all samples
trc  <- t(data_total[,samp+2])
len <- dim(trc)[2]
filtered <- c(1)
for (i in 1:len) {
  if (all(trc[,i]==0 | trc[,i]>10)=='FALSE'){
    filtered <- append(filtered,i)
    }
}
filtered <- filtered[-1]
data <- data_total[-filtered,] # filter for each column
trc  <- t(data[,samp+2])
data <- data[-which(colSums(trc)<quantile(colSums(trc), 0.05)),] # filter for colsum

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

# eQTL+promoters
results = trecase(Y = trc, Y1 = ase1, Y2 = ase2, X = cov2, Z = genos, eChr = eChr, ePos = ePos, mChr = mChr, mPos = mPos, output.tag = 'AScount_eQTL_promoter_remapped_070716', p.cut = 1, local.only = TRUE, local.distance = 1, min.AS.sample = 2, min.n.het = 1)


results = read.delim('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/AScount/WASP_remapped/AScount_eQTL_promoter_remapped_060616_eqtl.txt', header=T)

results = read.delim('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/AScount/WASP/AScount_eQTL_promoter_remapped_070716_eqtl.txt', header=T)

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
pdf('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/AScount/WASP_remapped/trecase_asl_qqplot_052616.pdf',width=7*1.25,height=7)
gg_qqplot(na.omit(results$final_Pvalue))
dev.off()



pdf('/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/AScount/WASP_remapped/sample_genotype_by_looping_event.pdf',width=7*1.25,height=7)

# Plot box plot
growIDs <- results$GeneRowID[which(results$final_Pvalue<1.0e-5)]
projdirs <- '/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/AScount/WASP/box_plot/'
for (i in 1:length(growIDs)) 
  {
  growID <- growIDs[i] 
  geno<-genos[,growID]
  geno[which(geno==4)]<-2
  geno[which(geno==3)]<-1
  jittergeno<-jitter(geno,0.5)
  jittergeno[which(geno==0)]<-jittergeno[which(geno==0)]+1
  jittergeno[which(geno==1)]<-jittergeno[which(geno==1)]+1
  jittergeno[which(geno==2)]<-jittergeno[which(geno==2)]+1
  ratio<- c(1,1.284588336,1.100746437,1.439222354,1.3094681,1.251398306,1.662814981,1.067659613,0.734573258)

  data[growID,]
  ref <- data[growID,4]
  alt <- data[growID,5]
  results[which(results$GeneRowID==growID),]
  cmax <- max(trc[,growID]/ratio)
  ylim <- 10^floor(log10(cmax)) * (round(cmax/10^floor(log10(cmax)))+1)
  x1 <- (trc[,growID]/ratio)[which(geno==0)]
  x2 <- (trc[,growID]/ratio)[which(geno==1)]
  x3 <- (trc[,growID]/ratio)[which(geno==2)]
  pdf(paste0(projdirs,data[growID,3],".pdf"),width=7*1.25,height=7)
  boxplot(x1,x2,x3,notch=F,xaxt='n',frame=F,outpch=NA,col="grey90",xlab=data[growID,3],ylab='Mapped reads(Normalized)',ylim=c(0, ylim),cex.axis=1.25,cex.lab=1.25)
  points(jittergeno,as.numeric(trc[,growID]/ratio), col="grey25",pch=16,bty='n',cex=1.25)
  axis(1,at=c(1:3),labels=c(paste0(ref,"/",ref,"(ref/ref) n = ",toString(sum(geno==0))),paste0(ref,"/",alt,"(ref/alt) n = ",toString(sum(geno==1))),paste0(alt,"/",alt,"(alt/alt) n = ",toString(sum(geno==2)))),lty=0,cex.axis=1.25)
  pvalue <- toString(results[which(results$GeneRowID==growID),][20])
  text(1,10,paste0("P = ",pvalue))
  dev.off()
}


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