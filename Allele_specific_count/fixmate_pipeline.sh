#Create by Will Chen @ 2016.06.16
#for i in {1..10}
#do 
#sh ~/HiC-Analysis/Allele_specific_count/realigned_bam.sh $workdir/$i $i promoter.properPair /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhcpair_Will &
#done

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
destdir=$4

r1=$workdir/${NAME[$i]}_S${i}_R1_001.fastq
r2=$workdir/${NAME[$i]}_S${i}_R2_001.fastq

#Clip off bridge adapter
fastx_clipper -a GCTGAGGGATCCCTCAGC -l 20 -Q33 -i $r1 -o $r1.clipped -v > $r1.clipping_stats&
fastx_clipper -a GCTGAGGGATCCCTCAGC -l 20 -Q33 -i $r2 -o $r2.clipped -v > $r2.clipping_stats& 
wait

#Align each read separately with BWA MEM -M 
bwa mem -M /net/shendure/vol10/nobackup/shared/alignments/bwa-0.6.1/human_g1k_hs37d5/hs37d5.fa $r1.clipped | samtools view -bS - > $r1.bwam.bam&
bwa mem -M /net/shendure/vol10/nobackup/shared/alignments/bwa-0.6.1/human_g1k_hs37d5/hs37d5.fa $r2.clipped | samtools view -bS - > $r2.bwam.bam&
wait

# Sort for WASP
samtools sort -@ 5 -o $r1.bwam.sort.bam $r1.bwam.bam &
samtools sort -@ 5 -o $r2.bwam.sort.bam $r2.bwam.bam &
wait
rm $r1.bwam.bam
rm $r2.bwam.bam

# WASP
sh /net/shendure/vol1/home/wchen108/HiC-Analysis/Allele_specific_count/WASP/WASP_mapping.sh $workdir ${NAME[$i]} S${i}_R1_001.fastq.bwam.sort &
sh /net/shendure/vol1/home/wchen108/HiC-Analysis/Allele_specific_count/WASP/WASP_mapping.sh $workdir ${NAME[$i]} S${i}_R2_001.fastq.bwam.sort &
wait

# Merge 2 bam files and add pair flag
( ~mkircher/bin/samtools view -H $r1.bwam.sort.wasped.bam; ~mkircher/bin/samtools view -X $r1.bwam.sort.wasped.bam | awk 'BEGIN{ FS="\t"; OFS="\t";}{ $2="pP1"$2; print }' ; ~mkircher/bin/samtools view -X $r2.bwam.sort.wasped.bam | awk 'BEGIN{ FS="\t"; OFS="\t";}{ $2="pP2"$2; print }' ) | ~mkircher/bin/samtools view -Su - | samtools sort -n -@ 10 - -T $workdir/${NAME[$i]}_test_snps | samtools fixmate -r -p - $destdir/${NAME[$i]}.${suffix}.bam

# sort
samtools sort -@ 10 -o $destdir/${NAME[$i]}.${suffix}.sorted.bam $destdir/${NAME[$i]}.${suffix}.bam

# Deduplicate 
java -jar /net/shendure/vol1/home/wchen108/tools/picard-tools-1.141/picard.jar MarkDuplicates \
      VALIDATION_STRINGENCY=SILENT \
      I=$destdir/${NAME[$i]}.${suffix}.sorted.bam \
      REMOVE_DUPLICATES=true \
      O=$destdir/${NAME[$i]}.${suffix}.sorted.dedup.bam \
      ASSUME_SORTED=true \
      M=$destdir/${NAME[$i]}.${suffix}.sorted.dedup.txt

#Add Readgroup
java -jar /net/shendure/vol1/home/wchen108/tools/picard-tools-1.141/picard.jar AddOrReplaceReadGroups \
      I=$destdir/${NAME[$i]}.${suffix}.sorted.dedup.bam \
      O=$destdir/${NAME[$i]}.${suffix}.sorted.dedup.RG.bam  \
      RGID=NA${NAME[$i]} \
      RGLB=lib1 \
      RGPL=illumina \
      RGPU=unit1 \
      RGSM=20 \
      VALIDATION_STRINGENCY=SILENT

# sortname
samtools sort -n -o $destdir/${NAME[$i]}.${suffix}.sorted.dedup.RG.sortname.bam $destdir/${NAME[$i]}.${suffix}.sorted.dedup.RG.bam

#convert to paired bed files
bedtools bamtobed -bedpe -mate1 -i $destdir/${NAME[$i]}.${suffix}.sorted.dedup.RG.sortname.bam > $destdir/${NAME[$i]}.${suffix}.temp.bedpe
wait
python /net/shendure/vol10/projects/DNaseHiC.eQTLs/scripts/dedupe_bed.py $destdir/${NAME[$i]}.${suffix}.temp.bedpe > $destdir/${NAME[$i]}.${suffix}.bedpe
rm $destdir/${NAME[$i]}.${suffix}.sorted.dedup.bam
rm $destdir/${NAME[$i]}.${suffix}.sorted.bam
rm $destdir/${NAME[$i]}.${suffix}.temp.bedpe

# subset intra 3k, 10k and intra pairs
python /net/shendure/vol1/home/wchen108/HiC-Analysis/bed_file_processing/bed_partition.py intra 3000 $destdir/${NAME[$i]}.${suffix}.bedpe > $destdir/${NAME[$i]}.$suffix.intra3k.bed &
python /net/shendure/vol1/home/wchen108/HiC-Analysis/bed_file_processing/bed_partition.py intra 10000 $destdir/${NAME[$i]}.${suffix}.bedpe > $destdir/${NAME[$i]}.$suffix.intra10k.bed &
python /net/shendure/vol1/home/wchen108/HiC-Analysis/bed_file_processing/bed_partition.py inter 0 $destdir/${NAME[$i]}.${suffix}.bedpe > $destdir/${NAME[$i]}.$suffix.inter.bed &
wait
# Subset SPloops
python /net/shendure/vol1/home/wchen108/HiC-Analysis/bed_file_processing/bed_subset_SPloop.py /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/gencode.v19_promoter_chr_removed.bed /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/eqtl_snps_centered_snp_101bp_chr_removed.bed $destdir/${NAME[$i]}.$suffix.intra3k.bed > $destdir/${NAME[$i]}.$suffix.intra3k.SPloop.bed &
python /net/shendure/vol1/home/wchen108/HiC-Analysis/bed_file_processing/bed_subset_SPloop.py /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/gencode.v19_promoter_chr_removed.bed /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/eqtl_snps_centered_snp_101bp_chr_removed.bed $destdir/${NAME[$i]}.$suffix.intra10k.bed > $destdir/${NAME[$i]}.$suffix.intra10k.SPloop.bed &
wait
#convert to h5 files
#Rscript ~/HiC-Analysis/Plotting/prepPseudoPairs.r $destdir/ ${NAME[$i]} ${suffix}.sorted.dedup.sort.RG &

# Sort again
samtools sort -@ 10 -o $destdir/${NAME[$i]}.${suffix}.sorted.dedup.RG.sort.bam $destdir/${NAME[$i]}.${suffix}.sorted.dedup.RG.bam
samtools index $destdir/${NAME[$i]}.${suffix}.sorted.dedup.RG.sort.bam


#GATK ASE count
java -jar /net/gs/vol3/software/modules-sw/GATK/3.5/Linux/RHEL6/x86_64/GenomeAnalysisTK.jar \
  -R /net/shendure/vol10/nobackup/shared/genomes/human_g1k_hs37d5/hs37d5.fa \
  -T ASEReadCounter \
  -o $destdir/${NAME[$i]}.${suffix}.csv \
  -I $destdir/${NAME[$i]}.${suffix}.sorted.dedup.RG.sort.bam \
  -sites /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/SNPs_release/eQTL_SNPs/Biallelic_eQTL_SNPs.vcf \
  -U ALLOW_N_CIGAR_READS \
  &