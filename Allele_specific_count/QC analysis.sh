# This file is created by Will on 2017.01.12
# This file is used to count the number of reads for each step.
#!/bin/sh

workdir=$1
filename=$2

$workdir
# Count for fastq file
cat *R1*.fastq | echo $((`wc -l`/4)) > 

# Count for mapping

# Count for WASP 

# Count for fixmate

# Count for deduplication/final pairs

samtools flagstat   | echo 