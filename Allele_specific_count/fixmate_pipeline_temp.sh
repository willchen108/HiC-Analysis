#!/bin/sh
#Create by Will Chen @ 2016.06.16
#for i in {1..10}
#do 
#sh ~/HiC-Analysis/Allele_specific_count/fixmate_pipeline.sh $workdir/$i $i promoter.properPair /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhcpair_Will &
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

r1=$workdir/${NAME[$i]}_S${i}_R1_001.fastq
r2=$workdir/${NAME[$i]}_S${i}_R2_001.fastq

#Align each read separately with BWA MEM -M 
bwa mem -M /net/shendure/vol10/nobackup/shared/alignments/bwa-0.6.1/human_g1k_hs37d5/hs37d5.fa $r1.clipped | samtools view -bS - > $r1.bwam.bam &
bwa mem -M /net/shendure/vol10/nobackup/shared/alignments/bwa-0.6.1/human_g1k_hs37d5/hs37d5.fa $r2.clipped | samtools view -bS - > $r2.bwam.bam &
wait

# Sort for WASP
samtools sort -@ 5 -o $r1.bwam.sort.bam $r1.bwam.bam &
samtools sort -@ 5 -o $r2.bwam.sort.bam $r2.bwam.bam &
wait


# WASP
sh /net/shendure/vol1/home/wchen108/HiC-Analysis/Allele_specific_count/WASP/WASP_mapping.sh $workdir ${NAME[$i]} S${i}_R1_001.fastq.bwam.sort &
sh /net/shendure/vol1/home/wchen108/HiC-Analysis/Allele_specific_count/WASP/WASP_mapping.sh $workdir ${NAME[$i]} S${i}_R2_001.fastq.bwam.sort &
wait
