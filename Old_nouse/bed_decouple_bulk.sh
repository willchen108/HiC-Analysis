#Create by Will Chen @ 2016.04.11
#require 2 cores 12G memory.
#USAGE: bed_partition_bulk.sh <workdirectory> example /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters/
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
workdir=$1
for i in 1 2 3 4 5 6 7 8 9 10
do 
#partition reads >1k and inter_chromosome
projectdir=$workdir/$i
#decouple paired-end reads for TEQC analysis
python /net/shendure/vol10/projects/DNaseHiC.eQTLs/scripts/Will/decouple_bed.py $projectdir/${NAME[$i]}_1k.bed > $projectdir/${NAME[$i]}_1k_decoupled.bed&
python /net/shendure/vol10/projects/DNaseHiC.eQTLs/scripts/Will/decouple_bed.py $projectdir/${NAME[$i]}_inter_chrom.bed > $projectdir/${NAME[$i]}_inter_chrom_decoupled.bed&
wait
done

workdir=/net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhcpair_Will/8
(samtools view -H $workdir/temp.dedup.bam; samtools view -L /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/SPloop_region_merged.bed $workdir/temp.dedup.bam) | samtools view -Su - |samtools sort -n -@ 2 - |samtools fixmate -r -p - $workdir/temp.fixmate.bam

bedtools bamtobed -bedpe -mate1 -i $workdir/12872_promoters_properPairs_fixmate.sorted.dedup.sort.RG.sortname.bam > 12872.promoters.fixmate.bedpe

python ~/HiC-Analysis/bed_file_processing/bed_partition.py 3000 $workdir/12872.promoters.fixmate.bedpe > $workdir/12872.promoters.fixmate.intra3k.bed &
python ~/HiC-Analysis/bed_file_processing/bed_partition.py 10000 $workdir/12872.promoters.fixmate.bedpe > $workdir/12872.promoters.fixmate.intra10k.bed &


python ~/HiC-Analysis/bed_file_processing/bed_subset_SPloop.py /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/eqtl_snps_centered_snp_101bp_chr_removed.bed $workdir/12872.promoters.fixmate.intra3k.bed > $workdir/12872.promoters.fixmate.intra3k.SPloop.bed


bedtools bamtobed -bedpe -mate1 -i $workdir/temp.fixmate.bam > $workdir/temp.fixmate.bedpe

java -jar /net/shendure/vol1/home/wchen108/tools/picard-tools-1.141/picard.jar MarkDuplicates \
      VALIDATION_STRINGENCY=SILENT \
      I=$workdir/12872_promoters_properPairs_fixmate.sorted.dedup.sort.RG.bam \
      REMOVE_DUPLICATES=true \
      O=$workdir/temp.dedup.bam \
      ASSUME_SORTED=true \
      M=$workdir/temp.dedup.txt