# This file is create by Will @ 2016.06.17
# This file is used to convert bam files into chicagoinput
# Usage sh ~/HiC-Analysis/CHiCAGO/bam2chicago_bulk.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhc_v2 promoter /net/shendure/vol10/projects/DNaseHiC.eQTLs/data/pro_design/promoter.baitmap
#    	sh ~/HiC-Analysis/CHiCAGO/bam2chicago_bulk.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhc_v2 snps /net/shendure/vol10/projects/DNaseHiC.eQTLs/data/snp_design/SNPs.baitmap
NAME[1]=10847
NAME[2]=12814
NAME[3]=12878
NAME[4]=12815
NAME[5]=12812
NAME[6]=12813
NAME[7]=12875
NAME[8]=12872
NAME[9]=12873
NAME[10]=12874
projectdir=$1
suffix=$2
baitmap=$3
for i in {1..10}
do
qsub -l mfree=5G /net/shendure/vol1/home/wchen108/tools/chicago/chicagoTools/bam2chicago.sh $projectdir/$i/${NAME[$i]}.$suffix.fixmate.sorted.dedup.RG.sortname.bam $baitmap /net/shendure/vol10/projects/DNaseHiC.eQTLs/data/Dnasemap_hs37d5.rmap $projectdir/$i/Chicago/${NAME[$i]}.$suffix &
done