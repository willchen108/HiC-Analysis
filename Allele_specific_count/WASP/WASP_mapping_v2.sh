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
mv ${NAME}_promoters.fix.secondary_alignments_flagged.bam WASP/$i
mv ${NAME}_snps.fix.secondary_alignments_flagged.bam WASP/$i
#Step 2 
cd WASP/$i

python ~/tools/WASP/mapping/find_intersecting_snps.py ${NAME}_promoters.fix.secondary_alignments_flagged.bam /net/shendure/vol10/projects/DNaseHiC.eQTLs/data/SNPlist_wasp/ &
python ~/tools/WASP/mapping/find_intersecting_snps.py ${NAME}_snps.fix.secondary_alignments_flagged.bam /net/shendure/vol10/projects/DNaseHiC.eQTLs/data/SNPlist_wasp/ &
wait

#Step 3
bwa mem -M /net/shendure/vol10/nobackup/shared/alignments/bwa-0.6.1/human_g1k_hs37d5/hs37d5.fa ${NAME}_promoters.fix.secondary_alignments_flagged.remap.fq.gz | samtools view -bS > ${NAME}_promoters.fix.secondary_alignments_flagged.remapped.bam &

bwa mem -M /net/shendure/vol10/nobackup/shared/alignments/bwa-0.6.1/human_g1k_hs37d5/hs37d5.fa ${NAME}_snps.fix.secondary_alignments_flagged.remap.fq.gz | samtools view -bS > ${NAME}_snps.fix.secondary_alignments_flagged.remapped.bam &
wait

#Step 4
python ~/tools/WASP/mapping/filter_remapped_reads.py ${NAME}_promoters.fix.secondary_alignments_flagged.to.remap.bam ${NAME}_promoters.fix.secondary_alignments_flagged.remapped.bam ${NAME}_promoters.fix.secondary_alignments_flagged.remap.keep.bam ${NAME}_promoters.fix.secondary_alignments_flagged.to.remap.num.gz&

python ~/tools/WASP/mapping/filter_remapped_reads.py ${NAME}_snps.fix.secondary_alignments_flagged.to.remap.bam ${NAME}_snps.fix.secondary_alignments_flagged.remapped.bam ${NAME}_snps.fix.secondary_alignments_flagged.remap.keep.bam ${NAME}_snps.fix.secondary_alignments_flagged.to.remap.num.gz&
wait

samtools merge ${NAME}_promoters.wasp.bam ${NAME}_promoters.fix.secondary_alignments_flagged.keep.bam ${NAME}_promoters.fix.secondary_alignments_flagged.remap.keep.bam &
samtools merge ${NAME}_snps.wasp.bam ${NAME}_snps.fix.secondary_alignments_flagged.keep.bam ${NAME}_snps.fix.secondary_alignments_flagged.remap.keep.bam &
wait

~mkircher/bin/samtools view -H ${NAME}_promoters.wasp.bam; ~mkircher/bin/samtools view -X ${NAME}_promoters.wasp.bam | awk 'BEGIN{ FS="\t"; OFS="\t";}{ $2="p1"$2; print }' ; | ~mkircher/bin/samtools view -Su - | samtools sort -n -@ 8 - -T $projdir/WASP/$i/${NAME}_test_snps | samtools fixmate -r - $projdir/WASP/$i/${NAME}_promoters.wasp.fix.bam &

~mkircher/bin/samtools view -H ${NAME}_snps.wasp.bam; ~mkircher/bin/samtools view -X ${NAME}_snps.wasp.bam | awk 'BEGIN{ FS="\t"; OFS="\t";}{ $2="p1"$2; print }' ; | ~mkircher/bin/samtools view -Su - | samtools sort -n -@ 8 - -T $projdir/WASP/$i/${NAME}_test_snps | samtools fixmate -r - $projdir/WASP/$i/${NAME}_snps.wasp.fix.bam&
wait

samtools index ${NAME}_promoters.wasp.sorted.bam
samtools index ${NAME}_snps.wasp.sorted.bam

