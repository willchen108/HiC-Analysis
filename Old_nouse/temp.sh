workdir=/net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters/8
r1=$workdir/12872_S8_R1_001.fastq.bwam.bam
r2=$workdir/12872_S8_R2_001.fastq.bwam.bam 
( ~mkircher/bin/samtools view -H $r1; ~mkircher/bin/samtools view -X $r1 | awk 'BEGIN{ FS="\t"; OFS="\t";}{ $2="pP1"$2; print }' ; ~mkircher/bin/samtools view -X $r2 | awk 'BEGIN{ FS="\t"; OFS="\t";}{ $2="pP2"$2; print }' ) | ~mkircher/bin/samtools view -Su - | samtools sort -n -@ 10 - -T $workdir/${NAME[$i]}_test_snps | samtools fixmate -r -p - $workdir/${NAME[$i]}_${suffix}.bam




samtools sort -@ 10 -o $workdir/12872.fixmate.no.wasp.sorted.bam $workdir/12872.fixmate.no.wasp.bam

java -jar /net/shendure/vol1/home/wchen108/tools/picard-tools-1/picard.jar MarkDuplicates \
      VALIDATION_STRINGENCY=SILENT \
      I=$workdir/12872.fixmate.no.wasp.sorted.bam \
      REMOVE_DUPLICATES=true \
      O=$workdir/12872.fixmate.no.wasp.sorted.dedup.bam \
      ASSUME_SORTED=true \
      M=$workdir/12872.fixmate.no.wasp.sorted.txt

# Sort again
samtools sort -@ 10 -o $workdir/12872.fixmate.no.wasp.sorted.dedup.sort.bam $workdir/12872.fixmate.no.wasp.sorted.dedup.bam

#Add Readgroup
java -jar /net/shendure/vol1/home/wchen108/tools/picard-tools-1.141/picard.jar AddOrReplaceReadGroups \
I=$workdir/12872.fixmate.no.wasp.sorted.dedup.sort.bam \
O=$workdir/12872.fixmate.no.wasp.sorted.dedup.sort.RG.bam  \
RGID=NA12872 \
RGLB=lib1 \
RGPL=illumina \
RGPU=unit1 \
RGSM=20 \
VALIDATION_STRINGENCY=SILENT

# index
samtools index $workdir/12872.fixmate.no.wasp.sorted.dedup.sort.RG.bam


bedtools bamtobed -bedpe -mate1 -i 12872_snps_properPairs_fixmate.sorted.dedup.sort.RG.sortname.bam > 12872.snps.fixmate2.bedpe

bedtools bamtobed -bedpe -mate1 -i $workdir/12872.fixmate.no.wasp.sorted.dedup.sortname.bam > $workdir/12872.fixmate.no.wasp.bedpe
wait
# subset intra 3k and 10k pairs
python ~/HiC-Analysis/bed_file_processing/bed_partition.py 0 $workdir/12872.fixmate.no.wasp.bedpe > $workdir/12872.fixmate.no.wasp.intra.bed &
python ~/HiC-Analysis/bed_file_processing/bed_partition.py 1000 $workdir/12872.fixmate.no.wasp.bedpe > $workdir/12872.fixmate.no.wasp.intra1k.bed &
python ~/HiC-Analysis/bed_file_processing/bed_partition.py 3000 $workdir/12872.fixmate.no.wasp.bedpe > $workdir/12872.fixmate.no.wasp.intra3k.bed &
python ~/HiC-Analysis/bed_file_processing/bed_partition.py 10000 $workdir/12872.fixmate.no.wasp.bedpe > $workdir/12872.fixmate.no.wasp.intra10k.bed &

java -jar /net/shendure/vol1/home/wchen108/tools/picard-tools-1.141/picard.jar AddOrReplaceReadGroups \
I=12872_snps_properPairs_fixmate.sorted.dedup.bam \
O=temp.RG.bam  \
RGID=NA${NAME[$i]} \
RGLB=lib1 \
RGPL=illumina \
RGPU=unit1 \
RGSM=20 \
VALIDATION_STRINGENCY=SILENT





java -jar /net/shendure/vol1/home/wchen108/tools/picard-tools-2.3.0/picard.jar MarkDuplicates \
      VALIDATION_STRINGENCY=SILENT \
      I=12878_snps_properPairs_fixmate.sorted.bam \
      REMOVE_DUPLICATES=true \
      O=12878_dedup3.bam \
      ASSUME_SORTED=true \
      M=dedup3.txt

12878_snps_properPairs_fixmate.sorted.bam






python ~/HiC-Analysis/bed_file_processing/bed_subset_SPloop_v2.py /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/gencode.v19_promoter_chr_removed.bed /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/eqtl_snps_centered_snp_101bp_chr_removed.bed /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhcpair_Will/3/12878.snps.fixmate.intra10k.bed > 