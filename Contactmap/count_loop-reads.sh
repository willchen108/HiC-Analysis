#Create by Will Chen @ 2016.04.16
#require 1 cores 5G memory.
#USAGE: count_loop-reads.sh <workdirectory> example /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters/
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
python /net/shendure/vol1/home/wchen108/HiC-Analysis/Contactmap/count_loop-reads.py $projectdir/${NAME[$i]}_res5k_1k.matrix /net/shendure/vol1/home/wchen108/data/loops_snps_bin.txt > $projectdir/${NAME[$i]}_res5k_1k.counts.bed
done
