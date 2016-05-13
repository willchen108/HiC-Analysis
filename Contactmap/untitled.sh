#Create by Will Chen @ 2016.04.16
#require 2 cores 16G memory.
#USAGE: contact_map_bulk.sh <workdirectory> example /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters/
#VARS 
module load vcflib/20150313
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
for i in {1..10}
do 
cd $i
java -jar /net/shendure/vol1/home/wchen108/tools/picard-tools-1.141/picard.jar BuildBamIndex \
	I=${NAME[$i]}_merged_RG.sorted.bam &
cd ../
done


java -jar /net/shendure/vol1/home/wchen108/tools/picard-tools-1.141/picard.jar BuildBamIndex \
    I=10847_merged_RG.sorted.bam

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
for i in {1..10}
do 
 java -jar /net/gs/vol3/software/modules-sw/GATK/3.5/Linux/RHEL6/x86_64/GenomeAnalysisTK.jar \
   -R /net/shendure/vol10/nobackup/shared/genomes/human_g1k_hs37d5/hs37d5.fa \
   -T ASEReadCounter \
   -o /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/promoter_capture_112515/Promoters/$i/${NAME[$i]}_promoter.csv \
   -I /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/promoter_capture_112515/Promoters/$i/${NAME[$i]}_merged_RG.bam \
   -sites /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/SNPs_release/eQTL_SNPs/samples/${NAME[$i]}_eQTL_SNPs.vcf \
   -U ALLOW_N_CIGAR_READS \ &
done

  -o /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters/$i/${NAME[$i]}_eQTL.csv \
  -I /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters/$i/${NAME[$i]}_merged_RG.bam \
