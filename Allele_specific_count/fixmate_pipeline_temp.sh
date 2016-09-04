#Create by Will Chen @ 2016.06.16
#for i in {1..10}
#do 
#sh ~/HiC-Analysis/Allele_specific_count/fixmate_pipeline.sh $workdir/$i $i promoter.properPair /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhcpair_Will &
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

rm $r1.bwam.bam
rm $r2.bwam.bam

# Merge 2 bam files and add pair flag
( ~mkircher/bin/samtools view -H $r1.bwam.sort.wasp.bam; ~mkircher/bin/samtools view -X $r1.bwam.sort.wasp.bam | awk 'BEGIN{ FS="\t"; OFS="\t";}{ $2="pP1"$2; print }' ; ~mkircher/bin/samtools view -X $r2.bwam.sort.wasp.bam | awk 'BEGIN{ FS="\t"; OFS="\t";}{ $2="pP2"$2; print }' ) | ~mkircher/bin/samtools view -Su - | samtools sort -n -@ 10 - -T $workdir/${NAME[$i]}_test_snps | samtools fixmate -r -p - $destdir/${NAME[$i]}.${suffix}.bam

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
samtools sort -@ 10 -n -o $destdir/${NAME[$i]}.${suffix}.sorted.dedup.RG.sortname.bam $destdir/${NAME[$i]}.${suffix}.sorted.dedup.RG.bam

#convert to paired bed files
bedtools bamtobed -bedpe -mate1 -i $destdir/${NAME[$i]}_${suffix}.sorted.dedup.RG.bam > $destdir/${NAME[$i]}_${suffix}.bedpe
wait
rm $destdir/${NAME[$i]}.${suffix}.sorted.dedup.bam
rm $destdir/${NAME[$i]}.${suffix}.sorted.bam

# subset intra 3k, 10k and intra pairs
python /net/shendure/vol1/home/wchen108/HiC-Analysis/bed_file_processing/bed_partition.py intra 3000 $destdir/${NAME[$i]}_${suffix}.bedpe > $destdir/${NAME[$i]}.$suffix.intra3k.bed &
python /net/shendure/vol1/home/wchen108/HiC-Analysis/bed_file_processing/bed_partition.py intra 10000 $destdir/${NAME[$i]}_${suffix}.bedpe > $destdir/${NAME[$i]}.$suffix.intra10k.bed &
python /net/shendure/vol1/home/wchen108/HiC-Analysis/bed_file_processing/bed_partition.py inter 0 $destdir/${NAME[$i]}_${suffix}.bedpe > $destdir/${NAME[$i]}.$suffix.inter.bed &

# Subset SPloops
python /net/shendure/vol1/home/wchen108/HiC-Analysis/bed_file_processing/bed_subset_SPloop_v2.py /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/gencode.v19_promoter_chr_removed.bed /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/eqtl_snps_centered_snp_101bp_chr_removed.bed $destdir/${NAME[$i]}.$suffix.intra3k.bed > $destdir/${NAME[$i]}.$suffix.intra3k.SPloop.bed &
python /net/shendure/vol1/home/wchen108/HiC-Analysis/bed_file_processing/bed_subset_SPloop_v2.py /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/eqtl_snps_centered_snp_101bp_chr_removed.bed $destdir/${NAME[$i]}.$suffix.intra10k.bed > $destdir/${NAME[$i]}.$suffix.intra10k.SPloop.bed &