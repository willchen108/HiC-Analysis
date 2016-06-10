#Create by Will Chen @ 2016.05.31
#requires 10 cores and 10G
#sh /net/shendure/vol1/home/wchen108/HiC-Analysis/Allele_specific_count/WASP/WASP_mapping_v2.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhc_paired_bams 1 10847 &
#Used to run WASP_mapping pipeline
# 
projdir=$1
i=$2
NAME=$3
cd $projdir
mkdir -p WASP/$i
mv ${NAME}_promoters.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.bam WASP/$i
mv ${NAME}_snps.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.bam WASP/$i
#Step 2 
cd WASP/$i

python ~/tools/WASP/mapping/find_intersecting_snps.py -s ${NAME}_promoters.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.bam /net/shendure/vol10/projects/DNaseHiC.eQTLs/data/SNPlist_wasp/ &
python ~/tools/WASP/mapping/find_intersecting_snps.py -s ${NAME}_snps.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.bam /net/shendure/vol10/projects/DNaseHiC.eQTLs/data/SNPlist_wasp/ &
wait

#Step 3
bwa mem -M /net/shendure/vol10/nobackup/shared/alignments/bwa-0.6.1/human_g1k_hs37d5/hs37d5.fa ${NAME}_promoters.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.remap.fq.gz | samtools view -bS > ${NAME}_promoters.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.remapped.bam &

bwa mem -M /net/shendure/vol10/nobackup/shared/alignments/bwa-0.6.1/human_g1k_hs37d5/hs37d5.fa ${NAME}_snps.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.remap.fq.gz | samtools view -bS > ${NAME}_snps.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.remapped.bam &
wait

#Step 4
python ~/tools/WASP/mapping/filter_remapped_reads.py ${NAME}_promoters.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.to.remap.bam ${NAME}_promoters.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.remapped.bam ${NAME}_promoters.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.remap.keep.bam ${NAME}_promoters.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.to.remap.num.gz&

python ~/tools/WASP/mapping/filter_remapped_reads.py ${NAME}_snps.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.to.remap.bam ${NAME}_snps.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.remapped.bam ${NAME}_snps.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.remap.keep.bam ${NAME}_snps.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.to.remap.num.gz&
wait

samtools merge ${NAME}_promoters.wasp.bam ${NAME}_promoters.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.keep.bam ${NAME}_promoters.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.remap.keep.bam &
samtools merge ${NAME}_snps.wasp.bam ${NAME}_snps.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.keep.bam ${NAME}_snps.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.remap.keep.bam &
wait

#Sort for RNA-seq data
samtools sort -n -o $projdir/WASP/$i/${NAME}_promoters.wasp.sorted.bam $projdir/WASP/$i/${NAME}_promoters.wasp.bam &
samtools sort -n -o $projdir/WASP/$i/${NAME}_snps.wasp.sorted.bam $projdir/WASP/$i/${NAME}_snps.wasp.bam&
wait

#Sort for GATK
samtools sort -o $projdir/WASP/$i/${NAME}_promoters.wasp.sorted.bam $projdir/WASP/$i/${NAME}_promoters.wasp.chr.bam &
samtools sort -o $projdir/WASP/$i/${NAME}_snps.wasp.sorted.bam $projdir/WASP/$i/${NAME}_snps.wasp.chr.bam&
wait

samtools index ${NAME}_promoters.wasp.sorted.sort.bam
samtools index ${NAME}_snps.wasp.sorted.sort.bam

mv ${NAME}_promoters.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.bam ../../
mv ${NAME}_snps.fix.secondary_alignments_flagged_coordinate_sorted_dups_removed.bam ../../