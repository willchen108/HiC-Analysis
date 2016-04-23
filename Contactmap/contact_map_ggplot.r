#Create by Will Chen @ 2016.04.16
library(ggplot2)
args<-commandArgs(TRUE)
exptPath <- args[1]
matrixfile<-file.path(exptPath, args[2])
matrix<-read.table(matrixfile)
filename<-paste(args[2],".pdf",sep="")
binsize<-args[3]

ggplot() + geom_raster(data=subset(matrix,V1 != V2), aes(x=V1,y=V2,fill=log(V3))) + geom_raster(data=subset(matrix,V1 != V2), aes(x=V2,y=V1,fill=log(V3))) + scale_fill_gradient2(low="white", high="red") + theme_bw() + theme(panel.grid.major = element_blank(), panel.grid.minor= element_blank(), text =element_text(size = 30)) + scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0)) + labs(x=binsize, y=binsize)
ggsave(filename,path = exptPath,dpi = 800)