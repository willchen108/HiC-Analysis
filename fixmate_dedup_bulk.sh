#Create by Will Chen @ 2016.05.13
#requires 10 cores and 5G
# sh  /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhc_paired_bams/WASP snps.wasp.sorted.chr.RG snps_realigned_dedup_wasp_20160614
# /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/promoter_capture_112515/Promoters
# sh  /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhc_paired_bams/WASP promoters.wasp.sorted.chr.RG promoters_realigned_dedup_wasp_20160614

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
suffix=$2 # should be promoters or snps
destdir=$4 # /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhcpair_Will
for i in {1..10}
do 
r1=$workdir/$i/${NAME[$i]}_S${i}_R1_001.fastq.bwam.bam
r2=$workdir/$i/${NAME[$i]}_S${i}_R2_001.fastq.bwam.bam
( ~mkircher/bin/samtools view -H $r1; ~mkircher/bin/samtools view -X $r1 | awk 'BEGIN{ FS="\t"; OFS="\t";}{ $2="pP1"$2; print }' ; ~mkircher/bin/samtools view -X $r2 | awk 'BEGIN{ FS="\t"; OFS="\t";}{ $2="pP2"$2; print }' ) | ~mkircher/bin/samtools view -Su - | samtools sort -n -@ 10 - -T /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/promoter_capture_112515/Promoters/$i/${NAME[$i]}_test_snps | samtools fixmate -r - $destdir/${NAME[$i]}_${suffix}_properPair_fixmate.bam
done