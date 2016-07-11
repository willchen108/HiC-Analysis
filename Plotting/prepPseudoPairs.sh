#!/bin/sh

#$ -N prepPseudoPairs
#$ -S /bin/bash
#$ -cwd
#$ -l mfree=8G
#$ -l h_rt=24:0:0
#$ -V
#usage sh ~/HiC-Analysis/Plotting/prepPseudoPairs.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhcpair_Will _snps_properPairs_fixmate.sorted.dedup.sort.RG.sortname
#   or sh ~/HiC-Analysis/Plotting/prepPseudoPairs.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhcpair_Will _promoters_properPairs_fixmate.sorted.dedup.sort.RG.sortname
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
suffix=$2
for i in {1..10}
do
Rscript ~/HiC-Analysis/Plotting/prepPseudoPairs.r $workdir/$i/ ${NAME[$i]} $suffix &
done