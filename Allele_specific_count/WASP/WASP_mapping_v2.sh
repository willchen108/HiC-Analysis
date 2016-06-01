#Create by Will Chen @ 2016.05.31
#requires 10 cores and 10G
#Used to run WASP_mapping pipeline
workdir=$1
i=$2
NAME=$3
projdir=$workdir/$i
cd $projdir
mkdir WASP
#Step 2 
cd WASP
python ~/tools/WASP/mapping/find_intersecting_snps.py $projdir/Merge/${NAME}_merged.sorted.bam /net/shendure/vol10/projects/DNaseHiC.eQTLs/data/SNPlist_wasp/

#Step 3
bwa mem /net/shendure/vol10/nobackup/shared/alignments/bwa-0.6.1/human_g1k_hs37d5/hs37d5.fa ${NAME}_merged.sorted.remap.fq.gz > ${NAME}_merged.sorted.remapped.sam

samtools view -bS ${NAME}_merged.sorted.remapped.sam > ${NAME}_merged.sorted.remapped.bam

#Step 4
python ~/tools/WASP/mapping/filter_remapped_reads.py ${NAME}_merged.sorted.to.remap.bam ${NAME}_merged.sorted.remapped.bam ${NAME}_merged.sorted.remap.keep.bam ${NAME}_merged.sorted.to.remap.num.gz
samtools merge ${NAME}_merged.wasp.bam ${NAME}_merged.sorted.keep.bam ${NAME}_merged.sorted.remap.keep.bam
samtools sort -o ${NAME}.wasp.sorted.bam ${NAME}_merged.wasp.bam
samtools index ${NAME}.wasp.sorted.bam
