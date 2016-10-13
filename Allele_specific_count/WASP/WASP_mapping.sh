#Create by Will Chen @ 2016.05.24
#requires 10 cores and 10G
#Used to run WASP_mapping pipeline
#usage sh /net/shendure/vol1/home/wchen108/HiC-Analysis/Allele_specific_count/WASP/WASP_mapping.sh $workdir ${NAME[$i]} S${i}_R1_001.fastq.bwam.sort

workdir=$1
NAME=$2
suffix=$3

#Step 2 
python ~/tools/WASP/mapping/find_intersecting_snps.py -s $workdir/${NAME}_$suffix.bam /net/shendure/vol10/projects/DNaseHiC.eQTLs/data/SNPlist_wasp/

#Step 3
bwa mem -M /net/shendure/vol10/nobackup/shared/alignments/bwa-0.6.1/human_g1k_hs37d5/hs37d5.fa $workdir/${NAME}_$suffix.remap.fq.gz | samtools view -bS > $workdir/${NAME}_$suffix.remapped.bam

#Step 4
python ~/tools/WASP/mapping/filter_remapped_reads.py $workdir/${NAME}_$suffix.to.remap.bam $workdir/${NAME}_$suffix.remapped.bam ${NAME}_$suffix.remap.keep.bam $workdir/${NAME}_$suffix.to.remap.num.gz 

samtools merge $workdir/${NAME}_$suffix.wasped.bam $workdir/${NAME}_$suffix.keep.bam $workdir/${NAME}_$suffix.remap.keep.bam 

#rm $workdir/${NAME}_$suffix.remap.fq.gz
#rm $workdir/${NAME}_$suffix.to.remap.num.gz
#rm $workdir/${NAME}_$suffix.remapped.bam
#rm $workdir/${NAME}_$suffix.remap.keep.bam