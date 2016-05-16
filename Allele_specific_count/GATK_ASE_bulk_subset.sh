#Create by Will Chen @ 2016.05.16
#requires 10 cores and 5G
#usage sh ~/HiC-Analysis/GATK_ASE_bulk_subset.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters eQTL
# 	or sh ~/HiC-Analysis/GATK_ASE_bulk_subset.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/promoter_capture_112515/Promoters promoters

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
 java -jar /net/gs/vol3/software/modules-sw/GATK/3.5/Linux/RHEL6/x86_64/GenomeAnalysisTK.jar \
   -R /net/shendure/vol10/nobackup/shared/genomes/human_g1k_hs37d5/hs37d5.fa \
   -T ASEReadCounter \
   -o $projectdir/${NAME[$i]}_${suffix}_subset.csv \
   -I $projectdir/${NAME[$i]}_merged_subset_RG.sorted.bam \
   -sites /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/SNPs_release/eQTL_SNPs/Biallelic_eQTL_SNPs.vcf \
   -U ALLOW_N_CIGAR_READS \
   &
done