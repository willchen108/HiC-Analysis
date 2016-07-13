#Create by Will Chen @ 2016.04.11
#Modified @ 2016.07.13
#USAGE: sh ~/HiC-Analysis/bed_file_processing/bed_subset_SPloop_bulk.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhcpair_Will snps.fixmate
#VARS

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
workdir=$1
suffix=$2
for i in {1..10}
do 
projectdir=$workdir/$i
python ~/HiC-Analysis/bed_file_processing/bed_subset_SPloop.py /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/gencode.v19_promoter_chr_removed.bed $projectdir/${NAME[$i]}.$suffix.intra3k.bed > $projectdir/${NAME[$i]}.$suffix.intra3k.SPloop.bed &
python ~/HiC-Analysis/bed_file_processing/bed_subset_SPloop.py /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/gencode.v19_promoter_chr_removed.bed $projectdir/${NAME[$i]}.$suffix.intra10k.bed > $projectdir/${NAME[$i]}.$suffix.intra10k.SPloop.bed &
done