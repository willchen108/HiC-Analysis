#Create by Will Chen @ 2016.05.16
#requires 2 cores and 5G
#
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
projdir=/net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters
for i in {1..10}
do 
cd $projdir/$i
intersectBed -a ${NAME[$i]}_S${i}_R1_001.fastq.bed -b /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/gencode.v19_promoter_chr_removed.bed > temp1.bed &
intersectBed -a ${NAME[$i]}_S${i}_R2_001.fastq.bed -b /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/gencode.v19_promoter_chr_removed.bed > temp2.bed &
wait

python ~/HiC-Analysis/Allele_specific_count/merge_bed.py temp1.bed temp2.bed > temp_merged.bed

awk -v x=1 '{print $x}' temp_merged.bed > ${NAME[$i]}_IDlist.txt

# Subset sam file with IDs
LC_ALL=C grep -w -F -f ${NAME[$i]}_IDlist.txt < ${NAME[$i]}_S${i}_R1_001.fastq.sam > temp1.sam &
LC_ALL=C grep -w -F -f ${NAME[$i]}_IDlist.txt < ${NAME[$i]}_S${i}_R2_001.fastq.sam > temp2.sam &
wait

samtools view -H ${NAME[$i]}_S${i}_R1_001.fastq.sam > temp_head1.sam &
samtools view -H ${NAME[$i]}_S${i}_R2_001.fastq.sam > temp_head2.sam &
wait

cat temp_head1.sam temp1.sam > temp1_head.sam &
cat temp_head2.sam temp2.sam > temp2_head.sam &
wait 

#Convert sam file to bam file and merge bam files.
samtools view -bS temp1_head.sam > temp1.bam&
samtools view -bS temp2_head.sam > temp2.bam&
wait

samtools merge ${NAME[$i]}_merged_subset.bam temp1.bam temp2.bam

#rm temp*

java -jar /net/shendure/vol1/home/wchen108/tools/picard-tools-1.141/picard.jar AddOrReplaceReadGroups \
		I=/net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/promoter_capture_112515/Promoters/$i/${NAME[$i]}_merged_subset.bam \
		O=/net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/promoter_capture_112515/Promoters/$i/${NAME[$i]}_merged_subset_RG.bam  \
		RGID=NA${NAME[$i]} \
		RGLB=lib1 \
		RGPL=illumina \
		RGPU=unit1 \
		RGSM=20
wait
samtools sort -o ${NAME[$i]}_merged_subset_RG.sorted.bam ${NAME[$i]}_merged_subset_RG.bam

java -jar /net/shendure/vol1/home/wchen108/tools/picard-tools-1.141/picard.jar BuildBamIndex \
      I=${NAME[$i]}_merged_subset_RG.sorted.bam\

done 