#Create by Will Chen @ 2016.06.16
#requires 10 cores and 10G
#usage 
# workdir=
#for i in {1..10}
#do 
#sh ~/HiC-Analysis/Allele_specific_count/realigned_bam.sh $workdir/$i $i promoter_properPair_fixmate /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhcpair_Will &
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

# Sort first
samtools sort -@ 5 -o $workdir/${NAME[$i]}_S${i}_R1_001.fastq.bwam.sort.bam $workdir/${NAME[$i]}_S${i}_R1_001.fastq.bwam.bam &
samtools sort -@ 5 -o $workdir/${NAME[$i]}_S${i}_R2_001.fastq.bwam.sort.bam $workdir/${NAME[$i]}_S${i}_R2_001.fastq.bwam.bam &
wait
# WASP
sh ~/HiC-Analysis/Allele_specific_count/WASP/WASP_mapping.sh $workdir ${NAME[$i]} S${i}_R1_001.fastq.bwam.sort &
sh ~/HiC-Analysis/Allele_specific_count/WASP/WASP_mapping.sh $workdir ${NAME[$i]} S${i}_R2_001.fastq.bwam.sort &
wait

# Merge 2 bam files and add pair flag
r1=$workdir/${NAME[$i]}_S${i}_R1_001.fastq.bwam.sort.wasp.bam
r2=$workdir/${NAME[$i]}_S${i}_R2_001.fastq.bwam.sort.wasp.bam 
( ~mkircher/bin/samtools view -H $r1; ~mkircher/bin/samtools view -X $r1 | awk 'BEGIN{ FS="\t"; OFS="\t";}{ $2="pP1"$2; print }' ; ~mkircher/bin/samtools view -X $r2 | awk 'BEGIN{ FS="\t"; OFS="\t";}{ $2="pP2"$2; print }' ) | ~mkircher/bin/samtools view -Su - | samtools sort -n -@ 10 - -T $workdir/${NAME[$i]}_test_snps | samtools fixmate -r -p - $destdir/${NAME[$i]}_${suffix}.bam
# sort
samtools sort -@ 10 -o $destdir/${NAME[$i]}_${suffix}.sorted.bam $destdir/${NAME[$i]}_${suffix}.bam

# Deduplicate 
java -jar /net/shendure/vol1/home/wchen108/tools/picard-tools-1.141/picard.jar MarkDuplicates \
      VALIDATION_STRINGENCY=SILENT \
      I=$destdir/${NAME[$i]}_${suffix}.sorted.bam \
      REMOVE_DUPLICATES=false \
      O=$destdir/${NAME[$i]}_${suffix}.sorted.dedup.bam \
      ASSUME_SORTED=true \
      M=$destdir/${NAME[$i]}_${suffix}.sorted.dedup.txt

# Sort again
samtools sort -@ 10 -o $destdir/${NAME[$i]}_${suffix}.sorted.dedup.sort.bam $destdir/${NAME[$i]}_${suffix}.sorted.dedup.bam

#Add Readgroup
java -jar /net/shendure/vol1/home/wchen108/tools/picard-tools-1.141/picard.jar AddOrReplaceReadGroups \
I=$destdir/${NAME[$i]}_${suffix}.sorted.dedup.sort.bam \
O=$destdir/${NAME[$i]}_${suffix}.sorted.dedup.sort.RG.bam  \
RGID=NA${NAME[$i]} \
RGLB=lib1 \
RGPL=illumina \
RGPU=unit1 \
RGSM=20 \
VALIDATION_STRINGENCY=SILENT

samtools index $destdir/${NAME[$i]}_${suffix}.sorted.dedup.sort.RG.bam
