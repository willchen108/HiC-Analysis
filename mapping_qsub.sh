. /etc/profile.d/modules.sh

projectdir=$1
name=$2
python ~/HiC-Analysis/mapping_reads_to_loops.py $projectdir/*_1k.bed ~/data/loops_snps_promoter_list.txt > $projectdir/$name.1k_in_loops.bed