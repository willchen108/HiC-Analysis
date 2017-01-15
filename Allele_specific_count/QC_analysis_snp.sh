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
workdir=/net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters
destdir=/net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhc_v2
QCdir=/net/shendure/vol10/projects/DNaseHiC.eQTLs/data/QCstat
# Count for fastq file
echo 'fastq counts' > $QCdir/${NAME[$i]}.snp.txt
cat $workdir/$i/${NAME[$i]}_S${i}_R1_001.fastq | echo $((`wc -l`/4)) >> $QCdir/${NAME[$i]}.snp.txt

# Count for mapping
echo -e ' \n' 'bwa f1 counts' >> $QCdir/${NAME[$i]}.snp.txt
samtools flagstat $workdir/$i/${NAME[$i]}_S${i}_R1_001.fastq.bwam.bam | grep '+ 0 mapped' >> $QCdir/${NAME[$i]}.snp.txt
echo -e ' \n' 'bwa f2 counts' >> $QCdir/${NAME[$i]}.snp.txt
samtools flagstat $workdir/$i/${NAME[$i]}_S${i}_R2_001.fastq.bwam.bam | grep '+ 0 mapped' >> $QCdir/${NAME[$i]}.snp.txt

# Count for WASP 
echo -e ' \n' 'wasp f1 counts' >> $QCdir/${NAME[$i]}.snp.txt
samtools flagstat $workdir/$i/${NAME[$i]}_S${i}_R1_001.fastq.bwam.sort.wasp.bam | grep '+ 0 mapped' >> $QCdir/${NAME[$i]}.snp.txt
echo -e ' \n' 'wasp f2 counts' >> $QCdir/${NAME[$i]}.snp.txt
samtools flagstat $workdir/$i/${NAME[$i]}_S${i}_R2_001.fastq.bwam.sort.wasp.bam | grep '+ 0 mapped' >> $QCdir/${NAME[$i]}.snp.txt

# Count for fixmate
echo -e ' \n' 'fixmate counts(nowasp)' >> $QCdir/${NAME[$i]}.snp.txt
samtools flagstat $workdir/$i/${NAME[$i]}.snp.fixmate.sorted.bam | grep 'read1' >> $QCdir/${NAME[$i]}.snp.txt

echo -e ' \n' 'fixmate counts(wasped)' >> $QCdir/${NAME[$i]}.snp.txt
samtools flagstat $destdir/$i/${NAME[$i]}.snps.fixmate.bam | grep 'read1' >> $QCdir/${NAME[$i]}.snp.txt

# Count for deduplication/final pairs
echo -e ' \n' 'dedup counts(nowasp)' >> $QCdir/${NAME[$i]}.snp.txt 
samtools flagstat $workdir/$i/${NAME[$i]}.snp.fixmate.sorted.dedup.bam | grep 'read1' >> $QCdir/${NAME[$i]}.snp.txt

echo -e ' \n' 'dedup counts(wasped)' >> $QCdir/${NAME[$i]}.snp.txt 
samtools flagstat $destdir/$i/${NAME[$i]}.snps.fixmate.sorted.dedup.RG.bam | grep 'read1' >> $QCdir/${NAME[$i]}.snp.txt

