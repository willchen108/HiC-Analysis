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
workdir=$1
for i in {1..10}
do 
projectdir=$workdir/$i
samtools sort -o $projectdir/${NAME[$i]}_merged_RG.sorted.bam $projectdir/${NAME[$i]}_merged_RG.bam &
done