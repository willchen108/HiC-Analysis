#Create by Will Chen @ 2016.04.11
#require 2 cores 12G memory.
#USAGE: bed_partition_bulk.sh <workdirectory> example /net/shendure/vol10/projects/DNaseHiC.eQTLs/nobackup/promoter_capture_112515
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
workdir=$1
for i in 1 2 3 4 5 6 7 8 9 10
do 
projectdir=$workdir/Promoters/$i
python /net/shendure/vol10/projects/DNaseHiC.eQTLs/scripts/Will/bed_partition_1k.py 1000 $workdir/${NAME[$i]}.bed.deduped > $projectdir/${NAME[$i]}_1k.bed&
python /net/shendure/vol10/projects/DNaseHiC.eQTLs/scripts/Will/bed_partition_1k.py 10000 $workdir/${NAME[$i]}.bed.deduped > $projectdir/${NAME[$i]}_10k.bed&
wait
done
