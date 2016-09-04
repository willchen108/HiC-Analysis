#Create by Will Chen @ 2016.06.16
#requires 10 cores and 10G
#usage sh ~/HiC-Analysis/Allele_specific_count/fixmate_bulk.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters snps_properPairs_fixmate /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhcpair_Will
#	   sh ~/HiC-Analysis/Allele_specific_count/fixmate_bulk.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/promoter_capture_112515/Promoters promoters_properPairs_fixmate /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/dhcpair_Will

workdir=$1
suffix=$2
destdir=$3
for i in {1..10}
do 
mkdir $destdir/$i
sh ~/HiC-Analysis/Allele_specific_count/fixmate_pipeline.sh $workdir/$i $i $suffix $destdir/$i &
done 