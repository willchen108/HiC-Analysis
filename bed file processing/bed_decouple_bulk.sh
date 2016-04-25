#Create by Will Chen @ 2016.04.11
#require 2 cores 12G memory.
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
#partition reads >1k and inter_chromosome
projectdir=$workdir/$i
#decouple paired-end reads for TEQC analysis
python /net/shendure/vol10/projects/DNaseHiC.eQTLs/scripts/Will/decouple_bed.py $projectdir/${NAME[$i]}_1k.bed > $projectdir/${NAME[$i]}_1k_decoupled.bed&
python /net/shendure/vol10/projects/DNaseHiC.eQTLs/scripts/Will/decouple_bed.py $projectdir/${NAME[$i]}_inter_chrom.bed > $projectdir/${NAME[$i]}_inter_chrom_decoupled.bed&
wait
done