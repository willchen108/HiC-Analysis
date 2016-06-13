#Create by Will Chen @ 2016.05.13
#requires 10 cores and 5G
#usage sh ~/HiC-Analysis/Allele_specific_count/GATK_ASE_bulk.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters eQTL_remapped
# 	or sh ~/HiC-Analysis/Allele_specific_count/GATK_ASE_bulk.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/promoter_capture_112515/Promoters promoters_remapped
# /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhc_paired_bams/WASP snps.wasp.sorted.chr snps_realigned_dedup_wasp

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
suffix_in=$2
suffix_out=$3
for i in {1..10}
do 
projectdir=$workdir/$i
 java -jar /net/gs/vol3/software/modules-sw/GATK/3.5/Linux/RHEL6/x86_64/GenomeAnalysisTK.jar \
   -R /net/shendure/vol10/nobackup/shared/genomes/human_g1k_hs37d5/hs37d5.fa \
   -T ASEReadCounter \
   -o $projectdir/${NAME[$i]}_$suffix_out.csv \
   -I $projectdir/${NAME[$i]}_$suffix_in.bam \
   -sites /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/SNPs_release/eQTL_SNPs/Biallelic_eQTL_SNPs.vcf \
   -U ALLOW_N_CIGAR_READS \
   &
done