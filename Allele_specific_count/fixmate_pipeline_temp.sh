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

#convert to paired bed files
bedtools bamtobed -bedpe -mate1 -i $destdir/${NAME[$i]}.${suffix}.sorted.dedup.RG.sortname.bam > $destdir/${NAME[$i]}.${suffix}.bedpe
wait

# subset intra 3k, 10k and intra pairs
python /net/shendure/vol1/home/wchen108/HiC-Analysis/bed_file_processing/bed_partition.py intra 3000 $destdir/${NAME[$i]}.${suffix}.bedpe > $destdir/${NAME[$i]}.$suffix.intra3k.bed &
python /net/shendure/vol1/home/wchen108/HiC-Analysis/bed_file_processing/bed_partition.py intra 10000 $destdir/${NAME[$i]}.${suffix}.bedpe > $destdir/${NAME[$i]}.$suffix.intra10k.bed &
python /net/shendure/vol1/home/wchen108/HiC-Analysis/bed_file_processing/bed_partition.py inter 0 $destdir/${NAME[$i]}.${suffix}.bedpe > $destdir/${NAME[$i]}.$suffix.inter.bed &

# Subset SPloops
python /net/shendure/vol1/home/wchen108/HiC-Analysis/bed_file_processing/bed_subset_SPloop_v2.py /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/gencode.v19_promoter_chr_removed.bed /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/eqtl_snps_centered_snp_101bp_chr_removed.bed $destdir/${NAME[$i]}.$suffix.intra3k.bed > $destdir/${NAME[$i]}.$suffix.intra3k.SPloop.bed &
python /net/shendure/vol1/home/wchen108/HiC-Analysis/bed_file_processing/bed_subset_SPloop_v2.py /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/probes/eqtl_snps_centered_snp_101bp_chr_removed.bed $destdir/${NAME[$i]}.$suffix.intra10k.bed > $destdir/${NAME[$i]}.$suffix.intra10k.SPloop.bed &