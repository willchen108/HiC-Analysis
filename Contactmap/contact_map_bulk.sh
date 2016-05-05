#Create by Will Chen @ 2016.04.16
#require 2 cores 16G memory.
#USAGE: contact_map_bulk.sh <workdirectory> example /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters/
#VARS 
module load mpc/latest
module load mpfr/latest
module load gmp/latest
module load gcc/latest

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
for i in 1 2 3 4 5 6 7 8 9 10
do 
projectdir=$workdir/$i
python /net/shendure/vol1/home/wchen108/HiC-Analysis/Contactmap/bin_standard_hic_will.py  /net/shendure/vol1/home/wchen108/data/hg19.genome $projectdir/${NAME[$i]}_1k.bed 1000000 > $projectdir/${NAME[$i]}_res1mb_1k.matrix &
python /net/shendure/vol1/home/wchen108/HiC-Analysis/Contactmap/bin_standard_hic_will.py  /net/shendure/vol1/home/wchen108/data/hg19.genome $projectdir/${NAME[$i]}_1k.bed 50000 > $projectdir/${NAME[$i]}_res50k_1k.matrix &
wait
Rscript ~/scripts_will/ggplot.r $projectdir ${NAME[$i]}_res1mb_1k.matrix "1Mb bin" &
Rscript ~/scripts_will/ggplot.r $projectdir ${NAME[$i]}_res50k_1k.matrix "50kb bin" &
wait
done
