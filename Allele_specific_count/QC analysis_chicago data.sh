# This file is created by Will on 2017.01.12
# This file is used to count the number of reads for each step.
#!/bin/sh

workdir=$1
filename=$2

cd $workdir
# Count for fastq file
cat $workdir/${filename}_1.trunc.fastq | echo -e $((`wc -l`/4)) ' \t' 'fastq counts'> $workdir/$filename.txt

# Count for mapping
samtools flagstat $workdir/${filename}_1.trunc.fastq_bwam.sort.bam | grep 'mapped' | echo >> $workdir/$filename.txt
samtools flagstat $workdir/${filename}_2.trunc.fastq_bwam.sort.bam | grep 'mapped' | echo >> $workdir/$filename.txt
# Count for WASP 
samtools flagstat $workdir/${filename}_1.trunc.fastq_bwam.sort.wasped.bam | grep 'mapped' | echo >> $workdir/$filename.txt
samtools flagstat $workdir/${filename}_2.trunc.fastq_bwam.sort.wasped.bam | grep 'mapped' | echo >> $workdir/$filename.txt
# Count for fixmate
samtools flagstat $workdir/${filename}.fixmate.sort.bam | grep 'read1' | echo >> $workdir/$filename.txt
# Count for deduplication/final pairs 
samtools flagstat $workdir/${filename}.fixmate.sort.dedup.bam | grep 'read1' | echo >> $workdir/$filename.txt