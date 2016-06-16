#Create by Will Chen @ 2016.05.24
#requires 10 cores and 10G
#Used to run WASP_mapping pipeline
#usage sh ~/HiC-Analysis/Allele_specific_count/WASP/WASP_mapping.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters 12878
# 	or sh ~/HiC-Analysis/Allele_specific_count/WASP/WASP_mapping.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/promoter_capture_112515/Promoters 12878

projdir=$1
NAME=$2
suffix=$3
cd $projdir

#Step 2 
python ~/tools/WASP/mapping/find_intersecting_snps.py -s $projdir/${NAME}_$suffix.bam /net/shendure/vol10/projects/DNaseHiC.eQTLs/data/SNPlist_wasp/

#Step 3
bwa mem /net/shendure/vol10/nobackup/shared/alignments/bwa-0.6.1/human_g1k_hs37d5/hs37d5.fa $projdir/${NAME}_$suffix.remap.fq.gz | samtools view -bS > $projdir/${NAME}_$suffix.remapped.bam


#Step 4
python ~/tools/WASP/mapping/filter_remapped_reads.py $projdir/${NAME}_$suffix.to.remap.bam $projdir/${NAME}_$suffix.remapped.bam ${NAME}_$suffix.remap.keep.bam $projdir/${NAME}_$suffix.to.remap.num.gz 

samtools merge $projdir/${NAME}.realigned.wasp.bam $projdir/${NAME}_$suffix.keep.bam $projdir/${NAME}_$suffix.remap.keep.bam 
samtools sort -o $projdir/${NAME}.realigned.wasp.sorted.bam $projdir/${NAME}.realigned.wasp.bam
samtools index $projdir/${NAME}.realigned.wasp.sorted.bam