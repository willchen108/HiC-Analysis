#!/bin/sh
#Create by Will Chen @ 2016.06.16
#qsub -pe serial 10 -l mfree=5G /net/shendure/vol1/home/wchen108/HiC-Analysis/Allele_specific_count/fixmate.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/promoter_capture_112515/Promoters/1 1 promoter.fixmate

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
suffix=$3

r1=$workdir/${NAME[$i]}_S${i}_R1_001.fastq
r2=$workdir/${NAME[$i]}_S${i}_R2_001.fastq
( ~mkircher/bin/samtools view -H $r1.bwam.sort.bam; ~mkircher/bin/samtools view -X $r1.bwam.sort.bam | awk 'BEGIN{ FS="\t"; OFS="\t";}{ $2="pP1"$2; print }' ; ~mkircher/bin/samtools view -X $r2.bwam.sort.bam | awk 'BEGIN{ FS="\t"; OFS="\t";}{ $2="pP2"$2; print }' ) | ~mkircher/bin/samtools view -Su - | samtools sort -n -@ 10 - -T $workdir/${NAME[$i]}_test_snps | samtools fixmate -r -p - $workdir/${NAME[$i]}.${suffix}.bam

# sort
samtools sort -@ 10 -o $workdir/${NAME[$i]}.${suffix}.sorted.bam $workdir/${NAME[$i]}.${suffix}.bam

# Deduplicate 
java -jar /net/shendure/vol1/home/wchen108/tools/picard-tools-1.141/picard.jar MarkDuplicates \
      VALIDATION_STRINGENCY=SILENT \
      I=$workdir/${NAME[$i]}.${suffix}.sorted.bam \
      REMOVE_DUPLICATES=true \
      O=$workdir/${NAME[$i]}.${suffix}.sorted.dedup.bam \
      ASSUME_SORTED=true \
      M=$workdir/${NAME[$i]}.${suffix}.sorted.dedup.txt