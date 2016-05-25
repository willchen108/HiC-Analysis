#Create by Will Chen @ 2016.05.24
#requires 10 cores and 10G
#Used to run WASP_mapping pipeline
#usage sh ~/HiC-Analysis/WASP/WASP_mapping_v2_temp.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters
# 	or sh ~/HiC-Analysis/WASP/WASP_mapping.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/promoter_capture_112515/Promoters

projdir=$1
NAME=$2
cd $projdir

#Step 2 
python ~/tools/WASP/mapping/find_intersecting_snps.py ${NAME}_merged_subset_RG.bam /net/shendure/vol1/home/wchen108/data/SNPlist_wasp/ 

#Step 3
bwa mem /net/shendure/vol10/nobackup/shared/alignments/bwa-0.6.1/human_g1k_hs37d5/hs37d5.fa ${NAME}_merged_subset_RG.remap.fq.gz > ${NAME}_merged_subset_RG.remapped.sam
samtools view -bS ${NAME}_merged_subset_RG.remapped.sam > ${NAME}_merged_subset_RG.remapped.bam

#Step 4
python ~/tools/WASP/mapping/filter_remapped_reads.py ${NAME}_merged_subset_RG.to.remap.bam ${NAME}_merged_subset_RG.remapped.bam ${NAME}_merged_subset_RG.remap.keep.bam ${NAME}_merged_subset_RG.to.remap.num.gz 

samtools merge ${NAME}_subset.wasp.bam ${NAME}_merged_subset_RG.keep.bam ${NAME}_merged_subset_RG.remap.keep.bam 
samtools sort -o ${NAME}_subset.wasp.sorted.bam ${NAME}_subset.wasp.bam
samtools index ${NAME}_subset.wasp.sorted.bam