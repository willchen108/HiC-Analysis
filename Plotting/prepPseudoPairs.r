
require(diffHic)
require(BSgenome.Hsapiens.1000genomes.hs37d5)
args<-commandArgs(TRUE)
exptPath <- args[1]
sample <- args[2]
suffix <- args[3]

seg.frags <- segmentGenome(BSgenome.Hsapiens.1000genomes.hs37d5, size = 500)
prepPseudoPairs(paste0(exptPath,sample,suffix,".bam"), pairParam(seg.frags), file = paste0(exptPath,sample,suffix,".h5"), dedup = TRUE, minq = NA)