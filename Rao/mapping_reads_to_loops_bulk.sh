#Create by Will Chen @ 2016.04.11
#require 10 cores 20G memory.
#USAGE: bed_partition_bulk.sh <workdirectory> example /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters/
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
for i in 1 2 3 4 5 6 7 8 9 10
do 
projectdir=$workdir/$i
python ~/HiC-Analysis/mapping_reads_to_loops.py $projectdir/${NAME[$i]}_1k.bed ~/data/loops_snps_promoter_list.txt > $projectdir/${NAME[$i]}_1k_in_loops.bed 
wait
done
