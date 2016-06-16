#Create by Will Chen @ 2016.06.16
#requires 10 cores and 10G
#usage sh ~/HiC-Analysis/Allele_specific_count/realigned_bam_bulk.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters

workdir=$1
for i in {1..10}
do 
sh ~/HiC-Analysis/Allele_specific_count/realigned_bam.sh $workdir/$i $i
done