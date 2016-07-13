#Create by Will Chen @ 2016.04.11
#Modified @ 2016.07.13
#USAGE: sh ~/HiC-Analysis/bed_file_processing/bamtobed.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhcpair_Will snps
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
suffix=${2}_properPairs_fixmate.sorted.dedup.sort.RG.sortname
for i in {1..10}
do 
projectdir=$workdir/$i
bedtools bamtobed -bedpe -mate1 -i $projectdir/${NAME[$i]}_$suffix.bam > $projectdir/${NAME[$i]}.${2}.fixmate.bedpe & 
done