#Create by Will Chen @ 2016.04.16
#require 2 cores 16G memory.
#USAGE: contact_map_bulk.sh <workdirectory> example /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters/
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
for i in {1..10}
do 
cd $i
samtools merge ${NAME[$i]}_merged.bam ${NAME[$i]}_*_R1_001.fastq.bam ${NAME[$i]}_*_R2_001.fastq.bam
cd ../
done


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
   -R /net/shendure/vol10/nobackup/shared/GATK.resources/v2.5/ucsc.hg19.fasta \
   -T ASEReadCounter \
   -o /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/promoter_capture_112515/Promoters/$i/${NAME[$i]}_promoter.csv \
   -I /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/promoter_capture_112515/Promoters/$i/${NAME[$i]}_merged_RG.bam \
   -sites /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/SNPs_release/eQTL_SNPs/All_eQTL_SNPs.vcf \
   -U ALLOW_N_CIGAR_READS \ &
done

  -o /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters/$i/${NAME[$i]}_eQTL.csv \
  -I /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters/$i/${NAME[$i]}_merged_RG.bam \
