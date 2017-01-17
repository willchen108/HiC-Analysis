#!/bin/sh
#Create by Will Chen @ 2016.06.16
#qsub -pe serial 10 -l mfree=5G /net/shendure/vol1/home/wchen108/HiC-Analysis/Allele_specific_count/fixmate.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/promoter_capture_112515/Promoters/1 1 promoter.fixmate


workdir=$1
fname=$2
suffix=$3

r1=$workdir/${fname}_1.trunc.fastq
r2=$workdir/${fname}_2.trunc.fastq

bwa mem -M /net/shendure/vol10/nobackup/shared/alignments/bwa-0.6.1/human_g1k_hs37d5/hs37d5.fa $r1 | samtools view -bS - > $r1.bwam.bam&
bwa mem -M /net/shendure/vol10/nobackup/shared/alignments/bwa-0.6.1/human_g1k_hs37d5/hs37d5.fa $r2 | samtools view -bS - > $r2.bwam.bam&
wait

# Sort for WASP
samtools sort -o ${r1}_bwam.sort.bam $r1.bwam.bam &
samtools sort -o ${r2}_bwam.sort.bam $r2.bwam.bam &
wait

# WASP
sh /net/shendure/vol1/home/wchen108/HiC-Analysis/Allele_specific_count/WASP/WASP_mapping.sh $workdir ${fname}_1.trunc.fastq bwam.sort.bam &
sh /net/shendure/vol1/home/wchen108/HiC-Analysis/Allele_specific_count/WASP/WASP_mapping.sh $workdir ${fname}_2.trunc.fastq bwam.sort.bam &
wait

( ~mkircher/bin/samtools view -H ${r1}_bwam.sort.bam; ~mkircher/bin/samtools view -X ${r1}_bwam.sort.bam; | awk 'BEGIN{ FS="\t"; OFS="\t";}{ $2="pP1"$2; print }' ; ~mkircher/bin/samtools view -X ${r2}_bwam.sort.bam; | awk 'BEGIN{ FS="\t"; OFS="\t";}{ $2="pP2"$2; print }' ) | ~mkircher/bin/samtools view -Su - | samtools sort -n - -T $workdir/test_snps | samtools fixmate -r -p - $workdir/${fname}.fixmate.bam

( ~mkircher/bin/samtools view -H ${r1}_bwam.sort.wasped.bam; ~mkircher/bin/samtools view -X ${r1}_bwam.sort.wasped.bam; | awk 'BEGIN{ FS="\t"; OFS="\t";}{ $2="pP1"$2; print }' ; ~mkircher/bin/samtools view -X ${r2}_bwam.sort.wasped.bam; | awk 'BEGIN{ FS="\t"; OFS="\t";}{ $2="pP2"$2; print }' ) | ~mkircher/bin/samtools view -Su - | samtools sort -n - -T $workdir/test_snps2 | samtools fixmate -r -p - $workdir/${fname}.wasped.fixmate.bam

# sort
samtools sort -o $workdir/${fname}.fixmate.sorted.bam $workdir/${fname}.fixmate.bam
samtools sort -o $workdir/${fname}.wasped.fixmate.sorted.bam $workdir/${fname}.wasped.fixmate.bam


# Deduplicate 
java -jar /net/shendure/vol1/home/wchen108/tools/picard-tools-1.141/picard.jar MarkDuplicates \
      VALIDATION_STRINGENCY=SILENT \
      I=$workdir/${fname}.fixmate.sorted.bam \
      REMOVE_DUPLICATES=true \
      O=$workdir/${fname}.fixmate.sorted.dedup.bam \
      ASSUME_SORTED=true \
      M=$workdir/${fname}.fixmate.sorted.dedup.txt


# Deduplicate 
java -jar /net/shendure/vol1/home/wchen108/tools/picard-tools-1.141/picard.jar MarkDuplicates \
      VALIDATION_STRINGENCY=SILENT \
      I=$workdir/${fname}.wasped.fixmate.sorted.bam \
      REMOVE_DUPLICATES=true \
      O=$workdir/${fname}.wasped.fixmate.sorted.dedup.bam \
      ASSUME_SORTED=true \
      M=$workdir/${fname}.wasped.fixmate.sorted.dedup.txt
