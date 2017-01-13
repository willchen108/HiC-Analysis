# This file is created by Will on 2017.01.12
# This file is used to count the number of reads for each step.
#!/bin/sh

workdir=$1
filename=$2

cd $workdir

# Count for fastq file
echo 'fastq counts' > $workdir/$filename.txt
cat $workdir/${filename}_1.trunc.fastq | echo -e $((`wc -l`/4)) >> $workdir/$filename.txt

# Count for mapping
echo 'bwa f1 counts' >> $workdir/$filename.txt
samtools flagstat $workdir/${filename}_1.trunc.fastq_bwam.sort.bam | grep 'mapped' >> $workdir/$filename.txt
echo 'bwa f2 counts' >> $workdir/$filename.txt
samtools flagstat $workdir/${filename}_2.trunc.fastq_bwam.sort.bam | grep 'mapped' >> $workdir/$filename.txt
# Count for WASP 
echo 'wasp f1 counts' >> $workdir/$filename.txt
samtools flagstat $workdir/${filename}_1.trunc.fastq_bwam.sort.wasped.bam | grep 'mapped' >> $workdir/$filename.txt
echo 'wasp f2 counts' >> $workdir/$filename.txt
samtools flagstat $workdir/${filename}_2.trunc.fastq_bwam.sort.wasped.bam | grep 'mapped' >> $workdir/$filename.txt
# Count for fixmate
echo 'fixmate counts' >> $workdir/$filename.txt
samtools flagstat $workdir/${filename}.fixmate.sort.bam | grep 'read1' >> $workdir/$filename.txt

# Count for deduplication/final pairs
echo 'dedup counts' >> $workdir/$filename.txt 
samtools flagstat $workdir/${filename}.fixmate.sort.dedup.bam | grep 'read1' >> $workdir/$filename.txt