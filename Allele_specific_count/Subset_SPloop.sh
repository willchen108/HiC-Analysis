#Create by Will Chen @ 2016.07.20
#This file is used to subset the SNPs that are looping to promoters from the bam file. I call it SP_loop.
# Start from intra3K_SPloop
# sh /net/shendure/vol1/home/wchen108/HiC-Analysis/Allele_specific_count/Subset_SPloop.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhcpair_Will/1 1
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

# Get the IDlist for parsing
awk -v x=7 '{print $x}' $workdir/${NAME[$i]}.snps.fixmate.intra3k.SPloop.bed > $workdir/${NAME[$i]}.snps.fixmate.intra3k.SPloop.IDs.bed &
# Decouple bedfiles for 1st subsetting
python /net/shendure/vol10/projects/DNaseHiC.eQTLs/scripts/Will/decouple_bed.py $workdir/${NAME[$i]}.snps.fixmate.intra3k.SPloop.bed > $workdir/${NAME[$i]}.snps.fixmate.intra3k.SPloop.decoupled.bed 

# 1st subsetting
(samtools view -H $workdir/${NAME[$i]}_snps_properPairs_fixmate.sorted.dedup.sort.RG.bam; samtools view -L $workdir/${NAME[$i]}.snps.fixmate.intra3k.SPloop.decoupled.bed $workdir/${NAME[$i]}_snps_properPairs_fixmate.sorted.dedup.sort.RG.bam) | samtools view -Su - |samtools sort -n -@ 2 - |samtools fixmate -r -p - $workdir/temp.fixmate.bam

samtools sort -@ 2 -o $workdir/temp.fixmate.sort.bam $workdir/temp.fixmate.bam

java -jar /net/shendure/vol1/home/wchen108/tools/picard-tools-1.141/picard.jar MarkDuplicates \
      VALIDATION_STRINGENCY=SILENT \
      I=$workdir/temp.fixmate.sort.bam \
      REMOVE_DUPLICATES=true \
      O=$workdir/temp.fixmate.sort.dedup.bam \
      ASSUME_SORTED=true \
      M=temp.fixmate.sort.dedup.txt

samtools sort -n -@ 2 -o $workdir/temp.fixmate.sort.dedup.sortname.bam $workdir/temp.fixmate.sort.dedup.bam
# 2nd subsetting
(samtools view -H $workdir/temp.fixmate.sort.dedup.sortname.bam; samtools view $workdir/temp.fixmate.sort.dedup.sortname.bam | LC_ALL=C grep -f $workdir/${NAME[$i]}.snps.fixmate.intra3k.SPloop.IDs.bed)| samtools view -bS - > $workdir/temp.fixmate.sort.dedup.sortname.subset.bam

samtools sort -o $workdir/${NAME[$i]}.snps.subset.intra3k.SPloop.bam $workdir/temp.fixmate.sort.dedup.sortname.subset.bam
samtools index $workdir/${NAME[$i]}.snps.subset.intra3k.SPloop.bam
rm temp*