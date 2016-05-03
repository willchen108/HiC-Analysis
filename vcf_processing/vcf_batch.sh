cd /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/SNPs_release/
module load vcflib/20150313
for i in {19..22}
do 
vcfkeepsamples ALL.chr$i.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf NA10847 NA12814 NA12878 NA12815 NA12812 NA12813 NA12872 NA12873 NA12874 > Chr$i.all.vcf
wait
done




vcfkeepsamples ALL.chr10.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf [NA10847] [NA12814] NA12878 NA12815 NA12812 NA12813 NA12875 NA12872 NA12873 NA12874 > Chr10.all.vcf

vcfkeepsamples ALL.chr10.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf [NA10847] [NA12814] > Chr10.all.vcf



for i in {1..22}
do 
python ~/HiC-Analysis/find_SNPs_vcf.py Chr$i.all.vcf ~/data/eqtl_capture_just_all_eqtls_all_promoter_snps_excluded_snp_coords_sorted_chr_removed.bed > /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/SNPs_release/SNPs_gntype/Chr$i.SNPs.bed
wait
done