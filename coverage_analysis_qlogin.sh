#Create by Will Chen @ 2016.04.11
#require 2 cores 12G memory.
#USAGE: coverage_analysis_qlogin.sh <workdirectory> <targetsfile> <targetsname> <report_name>
#example: coverage_analysis_qlogin.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters eQTL_SNPs_Probes_chr_removed.bwa.bed eQTL_SNPs report_1k
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
for i in 1 2 3 4 5 6 7 8 9 10
do 
projectdir=$1/$i
targetsfile=$2
targetsname=$3
report_name=$4
sample=NA${NAME[$i]}
readsfile=${NAME[$i]}_1k_decoupled.bed
Rscript /net/shendure/vol10/projects/DNaseHiC.eQTLs/scripts/capture_qc.r $projectdir $readsfile $targetsfile $sample $targetsname $projectdir/$report_name
wait
done