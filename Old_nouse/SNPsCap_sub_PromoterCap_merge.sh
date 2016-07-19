#Create by Will Chen @ 2016.05.13


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
for i in {1..10}
do 
p1=/net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters/$i
p2=/net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/promoter_capture_112515/Promoters/$i
python ~/HiC-Analysis/Allele_specific_count/SNPsCap_PromoterCap_merge.py $p1/${NAME[$i]}_eQTL_subset.csv $p2/${NAME[$i]}_promoters.csv > /net/shendure/vol1/home/wchen108/data/AScount/${NAME[$i]}_SPloop_count.csv &
done

