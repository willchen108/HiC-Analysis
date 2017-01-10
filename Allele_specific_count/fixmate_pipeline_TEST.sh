#!/bin/sh
#Create by Will Chen @ 2017.01.09


workdir=$1
r1=$2
r2=$3

cd $workdir
#Align each read separately with BWA MEM -M 
bwa mem -M /net/shendure/vol10/nobackup/shared/alignments/bwa-0.6.1/human_g1k_hs37d5/hs37d5.fa $r1 | samtools view -bS - > $r1.bwam.bam&
bwa mem -M /net/shendure/vol10/nobackup/shared/alignments/bwa-0.6.1/human_g1k_hs37d5/hs37d5.fa $r2 | samtools view -bS - > $r2.bwam.bam&
wait

# Sort for WASP
samtools sort -o $workdir/${r1}_bwam.sort.bam $workdir/$r1.bwam.bam &
samtools sort -o $workdir/${r2}_bwam.sort.bam $workdir/$r2.bwam.bam &
wait
rm $r1.bwam.bam
rm $r2.bwam.bam

# WASP
sh /net/shendure/vol1/home/wchen108/HiC-Analysis/Allele_specific_count/WASP/WASP_mapping.sh $workdir $r1 bwam.sort &
sh /net/shendure/vol1/home/wchen108/HiC-Analysis/Allele_specific_count/WASP/WASP_mapping.sh $workdir $r2 bwam.sort &
wait

( ~mkircher/bin/samtools view -H $r1.bwam.sort.wasped.bam; ~mkircher/bin/samtools view -X $r1.bwam.sort.wasped.bam | awk 'BEGIN{ FS="\t"; OFS="\t";}{ $2="pP1"$2; print }' ; ~mkircher/bin/samtools view -X $r2.bwam.sort.wasped.bam | awk 'BEGIN{ FS="\t"; OFS="\t";}{ $2="pP2"$2; print }' ) | ~mkircher/bin/samtools view -Su - | samtools sort -n -  | samtools fixmate -r -p - $workdir/$r1.fixmate.bam

# sort
samtools sort -o $workdir/$r1.fixmate.sorted.bam $workdir/$r1.fixmate.bam

# Deduplicate 
java -jar /net/shendure/vol1/home/wchen108/tools/picard-tools-1.141/picard.jar MarkDuplicates \
      VALIDATION_STRINGENCY=SILENT \
      I=$workdir/$r1.fixmate.sorted.bam \
      REMOVE_DUPLICATES=true \
      O=$workdir/$r1.fixmate.sorted.dedup.bam \
      ASSUME_SORTED=true \
      M=$workdir/$r1.fixmate.sorted.dedup.txt

#Add Readgroup
java -jar /net/shendure/vol1/home/wchen108/tools/picard-tools-1.141/picard.jar AddOrReplaceReadGroups \
      I=$workdir/$r1.fixmate.sorted.dedup.bam \
      O=$workdir/$r1.fixmate.sorted.dedup.RG.bam  \
      RGID=$r1 \
      RGLB=lib1 \
      RGPL=illumina \
      RGPU=unit1 \
      RGSM=20 \
      VALIDATION_STRINGENCY=SILENT

# sortname
samtools sort -n -o $workdir/$r1.fixmate.sorted.dedup.RG.sortname.bam $workdir/$r1.fixmate.sorted.dedup.RG.bam

#convert to paired bed files
bedtools bamtobed -bedpe -mate1 -i $workdir/$r1.fixmate.sorted.dedup.RG.sortname.bam > $workdir/$r1.fixmate.temp.bedpe
wait
python /net/shendure/vol10/projects/DNaseHiC.eQTLs/scripts/dedupe_bed.py $workdir/$r1.fixmate.temp.bedpe > $workdir/$r1.fixmate.bedpe

rm $workdir/$r1.fixmate.sorted.dedup.bam
rm $workdir/$r1.fixmate.sorted.bam
rm $workdir/$r1.fixmate.temp.bedpe

# subset intra 3k, 10k and intra pairs
python /net/shendure/vol1/home/wchen108/HiC-Analysis/bed_file_processing/bed_partition.py intra 3000 $workdir/$r1.fixmate.bedpe > $workdir/$r1.fixmate.intra3k.bed &
python /net/shendure/vol1/home/wchen108/HiC-Analysis/bed_file_processing/bed_partition.py intra 10000 $workdir/$r1.fixmate.bedpe > $workdir/$r1.fixmate.intra10k.bed &
python /net/shendure/vol1/home/wchen108/HiC-Analysis/bed_file_processing/bed_partition.py inter 0 $workdir/$r1.fixmate.bedpe > $workdir/$r1.fixmate.inter.bed &
wait

# Subset SPloops
python /net/shendure/vol1/home/wchen108/HiC-Analysis/bed_file_processing/bed_subset_SPloop.py /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/gencode.v19_promoter_chr_removed.bed /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/eqtl_snps_centered_snp_101bp_chr_removed.bed $workdir/$r1.fixmate.intra3k.bed > $workdir/$r1.fixmate.intra3k.SPloop.bed &
python /net/shendure/vol1/home/wchen108/HiC-Analysis/bed_file_processing/bed_subset_SPloop.py /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/gencode.v19_promoter_chr_removed.bed /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/eqtl_snps_centered_snp_101bp_chr_removed.bed $workdir/$r1.fixmate.intra10k.bed > $workdir/$r1.fixmate.intra10k.SPloop.bed &
wait
