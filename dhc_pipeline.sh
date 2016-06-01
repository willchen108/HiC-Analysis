# 2016.05.31
# sh ~/HiC-Analysis/dhc_pipeline.sh /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/eQTL_SNPs_151228/Promoters 1 10847


workdir=$1
i=$2
NAME=$3
projdir=$workdir/$i
cd $projdir
mkdir Merge
cd Merge
samtools sort -o ${NAME}_S${i}_R1_001.fastq.sorted.sam $projdir/${NAME}_S${i}_R1_001.fastq.sam &
samtools sort -o ${NAME}_S${i}_R2_001.fastq.sorted.sam $projdir/${NAME}_S${i}_R2_001.fastq.sam &
wait

samtools merge ${NAME}_S${i}_merged.sam ${NAME}_S${i}_R1_001.fastq.sorted.sam ${NAME}_S${i}_R2_001.fastq.sorted.sam

samtools sort -o ${NAME}_S${i}_merged.sorted.sam ${NAME}_S${i}_merged.sam

samtools view -bS ${NAME}_S${i}_merged.sorted.sam > ${NAME}_S${i}_merged.sorted.bam
