#Create by Will Chen @ 2016.05.24
#requires 10 cores and 10G
#Used to run WASP_mapping pipeline
#usage sh ~/HiC-Analysis/Allele_specific_count/WASP/WASP_mapping_bulk_v2.sh

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
workdir=/net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhc_paired_bams
for i in {1..10}
do 
sh /net/shendure/vol1/home/wchen108/HiC-Analysis/Allele_specific_count/WASP/WASP_mapping_v2.sh $workdir $i ${NAME[$i]} &
done