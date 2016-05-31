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
python ~/tools/WASP/mapping/find_intersecting_snps.py $projdir/${NAME}_S${i}_R1_001.fastq.bam /net/shendure/vol10/projects/DNaseHiC.eQTLs/data/SNPlist_wasp/ &
python ~/tools/WASP/mapping/find_intersecting_snps.py $projdir/${NAME}_S${i}_R2_001.fastq.bam /net/shendure/vol10/projects/DNaseHiC.eQTLs/data/SNPlist_wasp/ &
wait

#Step 3
bwa mem /net/shendure/vol10/nobackup/shared/alignments/bwa-0.6.1/human_g1k_hs37d5/hs37d5.fa ${NAME}_S${i}_R1_001.fastq.remap.fq.gz > ${NAME}_S${i}_R1_001.fastq.remapped.sam&
bwa mem /net/shendure/vol10/nobackup/shared/alignments/bwa-0.6.1/human_g1k_hs37d5/hs37d5.fa ${NAME}_S${i}_R2_001.fastq.remap.fq.gz > ${NAME}_S${i}_R2_001.fastq.remapped.sam&
wait

samtools view -bS ${NAME}_S${i}_R1_001.fastq.remapped.sam > ${NAME}_S${i}_R1_001.fastq.remapped.bam &
samtools view -bS ${NAME}_S${i}_R2_001.fastq.remapped.sam > ${NAME}_S${i}_R2_001.fastq.remapped.bam &
wait

#Step 4
python ~/tools/WASP/mapping/filter_remapped_reads.py ${NAME}_S${i}_R1_001.fastq.to.remap.bam ${NAME}_S${i}_R1_001.fastq.remapped.bam ${NAME}_S${i}_R1_001.fastq.remap.keep.bam ${NAME}_S${i}_R1_001.fastq.to.remap.num.gz &
python ~/tools/WASP/mapping/filter_remapped_reads.py ${NAME}_S${i}_R2_001.fastq.to.remap.bam ${NAME}_S${i}_R2_001.fastq.remapped.bam ${NAME}_S${i}_R2_001.fastq.remap.keep.bam ${NAME}_S${i}_R2_001.fastq.to.remap.num.gz &
wait

samtools merge ${NAME}_S${i}_R1.wasp.bam ${NAME}_S${i}_R1_001.fastq.keep.bam ${NAME}_S${i}_R1_001.fastq.remap.keep.bam&
samtools merge ${NAME}_S${i}_R2.wasp.bam ${NAME}_S${i}_R2_001.fastq.keep.bam ${NAME}_S${i}_R2_001.fastq.remap.keep.bam&
wait

samtools sort -o ${NAME}_S${i}_R1.wasp.sorted.bam ${NAME}_S${i}_R1.wasp.bam&
samtools sort -o ${NAME}_S${i}_R2.wasp.sorted.bam ${NAME}_S${i}_R2.wasp.bam&
wait

samtools index ${NAME}_S${i}_R1.wasp.sorted.bam&
samtools index ${NAME}_S${i}_R2.wasp.sorted.bam&