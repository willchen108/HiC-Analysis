#Create by Will Chen @ 2016.04.16
#require 2 cores 16G memory.
#USAGE: contact_map_bulk.sh <workdirectory> example /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters/
#VARS 
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
samtools sort -@ 2 -n -o /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhcpair_Will/$i/${NAME[$i]}_promoters_properPairs_fixmate.sorted.dedup.sort.RG.sortname.bam /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhcpair_Will/$i/${NAME[$i]}_promoters_properPairs_fixmate.sorted.dedup.sort.RG.bam &
done