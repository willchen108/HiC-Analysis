#Create by Will Chen @ 2016.04.11
#require 2 cores 20G memory.
#This code can do a couple of things:
#	1. use *.bed.dedupe file to create subset of the pair-end reads with 1k apart or inter-chromosome.
#	2. decouple subset bed files for TEQC analysis
#	3. Run the TEQC code to generate the coverage and enrichment analysis
#USAGE: subset_quality_analysis_bulk.sh <workdirectory> <targetsfile> <targetsname> <report_name>
#example /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters eQTL_SNPs_Probes_chr_removed.bwa.bed eQTL_SNPs report_1k

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
python /net/shendure/vol10/projects/DNaseHiC.eQTLs/scripts/Will/bed_partition_1k.py $projectdir/${NAME[$i]}_eQTL_SNPs.bed.deduped > $projectdir/${NAME[$i]}_1k.bed&
python /net/shendure/vol10/projects/DNaseHiC.eQTLs/scripts/Will/bed_partition_inter_chrom.py $projectdir/${NAME[$i]}_eQTL_SNPs.bed.deduped > $projectdir/${NAME[$i]}_inter_chrom.bed&
wait
#decouple paired-end reads for TEQC analysis
python /net/shendure/vol10/projects/DNaseHiC.eQTLs/scripts/Will/decouple_bed.py $projectdir/${NAME[$i]}_1k.bed > $projectdir/${NAME[$i]}_1k_decoupled.bed&
python /net/shendure/vol10/projects/DNaseHiC.eQTLs/scripts/Will/decouple_bed.py $projectdir/${NAME[$i]}_inter_chrom.bed > $projectdir/${NAME[$i]}_inter_chrom_decoupled.bed&
wait
targetsfile=$2
targetsname=$3
report_name=$4
sample=NA${NAME[$i]}
readsfile=${NAME[$i]}_1k_decoupled.bed
Rscript /net/shendure/vol10/projects/DNaseHiC.eQTLs/scripts/capture_qc.r $projectdir $readsfile $targetsfile $sample $targetsname $projectdir/$report_name
wait
done
