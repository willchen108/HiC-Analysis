#Create by Will Chen @ 2016.06.16
#requires 10 cores and 10G
#usage sh ~/HiC-Analysis/Allele_specific_count/realigned_bam.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters/$i

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
i=$2

# Merge 2 bam files
#samtools merge $workdir/${NAME[$i]}_realigned_merged.bam $workdir/${NAME[$i]}_S${i}_R1_001.fastq.bwam.bam $workdir/${NAME[$i]}_S${i}_R2_001.fastq.bwam.bam 
# sort
#samtools sort -o $workdir/${NAME[$i]}_realigned_merged.sorted.bam $workdir/${NAME[$i]}_realigned_merged.bam

# Deduplicate 
java -jar /net/shendure/vol1/home/wchen108/tools/picard-tools-1.141/picard.jar MarkDuplicates \
      VALIDATION_STRINGENCY=LENIENT \
      I=$workdir/${NAME[$i]}_realigned_merged.sorted.bam \
      REMOVE_DUPLICATES=true \
      O=$workdir/${NAME[$i]}_realigned_merged.sorted.dedup.bam \
      ASSUME_SORTED=true \
      M=$workdir/${NAME[$i]}_realigned_merged.sorted.dedup.txt

# Sort again
samtools sort -o $workdir/${NAME[$i]}_realigned_merged.sort.dedup.bam $workdir/${NAME[$i]}_realigned_merged.sorted.dedup.bam

#Add Readgroup
java -jar /net/shendure/vol1/home/wchen108/tools/picard-tools-1.141/picard.jar AddOrReplaceReadGroups \
I=$workdir/${NAME[$i]}_realigned_merged.sort.dedup.bam \
O=$workdir/${NAME[$i]}_realigned_merged.sort.dedup.RG.bam  \
RGID=NA${NAME[$i]} \
RGLB=lib1 \
RGPL=illumina \
RGPU=unit1 \
RGSM=20 \
VALIDATION_STRINGENCY=SILENT

# WASP
sh ~/HiC-Analysis/Allele_specific_count/WASP/WASP_mapping.sh $workdir ${NAME[$i]} realigned_merged.sort.dedup.RG