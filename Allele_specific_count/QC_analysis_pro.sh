# This file is created by Will on 2017.01.12
# This file is used to count the number of reads for each step.
#!/bin/sh
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

i=$1
workdir=$1
destdir=/net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhc_v2
# Count for fastq file
echo 'fastq counts' > $workdir/${NAME[$i]}.txt

cat $workdir/$i/${NAME[$i]}_S${i}_R1_001.fastq | echo $((`wc -l`/4)) >> $workdir/${NAME[$i]}.txt

# Count for mapping
echo 'bwa f1 counts' >> $workdir/${NAME[$i]}.txt
samtools flagstat $workdir/$i/${NAME[$i]}_S${i}_R1_001.fastq.bwam.bam | grep 'mapped' >> $workdir/${NAME[$i]}.txt
echo 'bwa f2 counts' >> $workdir/${NAME[$i]}.txt
samtools flagstat $workdir/$i/${NAME[$i]}_S${i}_R2_001.fastq.bwam.bam | grep 'mapped' >> $workdir/${NAME[$i]}.txt

# Count for WASP 
echo 'wasp f1 counts' >> $workdir/${NAME[$i]}.txt
samtools flagstat $workdir/$i/${NAME[$i]}_S${i}_R1_001.fastq.bwam.was*.bam | grep 'mapped' >> $workdir/${NAME[$i]}.txt
echo 'wasp f2 counts' >> $workdir/${NAME[$i]}.txt
samtools flagstat $workdir/$i/${NAME[$i]}_S${i}_R1_001.fastq.bwam.was*.bam | grep 'mapped' >> $workdir/${NAME[$i]}.txt

# Count for fixmate
echo 'fixmate counts(nowasp)' >> $workdir/${NAME[$i]}.txt
samtools flagstat $workdir/${filename}.fixmate.sort.bam | grep 'read1' >> $workdir/${NAME[$i]}.txt

echo 'fixmate counts(wasped)'
# Count for deduplication/final pairs
echo 'dedup counts' >> $workdir/${NAME[$i]}.txt 
samtools flagstat $workdir/${filename}.fixmate.sort.dedup.bam | grep 'read1' >> $workdir/${NAME[$i]}.txt