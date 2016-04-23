#modified from https://www.biostars.org/p/64495/
import argparse
import pybedtools
from DarrenTools import ifier

parser = argparse.ArgumentParser(description='A program to convert .bam files to .bigwig files.')
parser.add_argument('-I','--inbam', help='Input .bam file',dest='inbam')
parser.add_argument('-O','--outbigwig', help='Output .bigwig file',dest='outbigwig')
args = parser.parse_args()

print "Calculating coverage..."
#x = pybedtools.BedTool(args.inbam).genome_coverage(bg=True, split=True, g='/net/shendure/vol7/cusanovi/genomes/hg19/hg19_norandom.chromsizes.txt').saveas(args.outbigwig + ".bedgraph")
x = pybedtools.BedTool(args.inbam).genome_coverage(bg=True, split=True, g='/net/shendure/vol10/nobackup/shared/genomes/human_g1k_hs37d5/chrNameLength.txt').saveas(args.outbigwig + ".bedgraph")

print "Sorting coverage results..."
chromer = "sed -i 's/^/chr/g' " + args.outbigwig + ".bedgraph; sed 's/^/chr/g' /net/shendure/vol10/nobackup/shared/genomes/human_g1k_hs37d5/chrNameLength.txt > /net/shendure/vol7/cusanovi/genomes/hg19/human_g1k_hs37d5.chromsizes.txt"
ifier(chromer)

sorter = "LC_COLLATE=C sort -k1,1 -k2,2n " + args.outbigwig + ".bedgraph > " + args.outbigwig + ".sorted.bedgraph"
ifier(sorter)

print "Writing BigWig..."
bigwiger = "/net/shendure/vol1/home/cusanovi/bin/bedGraphToBigWig " + args.outbigwig + ".sorted.bedgraph /net/shendure/vol7/cusanovi/genomes/hg19/human_g1k_hs37d5.chromsizes.txt " + args.outbigwig
#bigwiger = "/net/shendure/vol1/home/cusanovi/bin/bedGraphToBigWig " + args.outbigwig + ".sorted.bedgraph /net/shendure/vol7/cusanovi/genomes/hg19/hg19_norandom.chromsizes.txt " + args.outbigwig
ifier(bigwiger)
#cleaner = "rm " + args.outbigwig + ".bedgraph; rm " + args.outbigwig + ".sorted.bedgraph"
#ifier(cleaner)
