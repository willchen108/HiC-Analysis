# This file was originally created by Vijay and modified by Will.
import os,sys,re
from collections import Counter
from math import sqrt

def normalizeMatrix(matrix):
    cov = Counter()
    normed = {}
    for i in matrix:
        bin1, bin2, chrom1, chrom2 = i
        count = matrix[i]
        cov[bin1] += count
        cov[bin2] += count #why bin1 bin2? double count?
    for i in matrix:
        bin1, bin2, chrom1, chrom2 = i
        normed[i] = float(matrix[i]) / cov[bin1] / cov[bin2]
    return normed

def define_bins(chromsizes, resolution):
    bins = {}
    valid_chroms = {}
    lines = chromsizes.readlines()
    hindex = 0
    for line in lines:
        chromname, length = line.split()
        valid_chroms[chromname] = True
        for i in range(0,int(length),resolution):
            bins[(chromname, i)] = hindex
            hindex += 1
    return bins, valid_chroms

def bedpe_walk(bedpe, resolution, bins, valid_chroms):
    '''bedpe_walk walks through a bedpe file, splits out reads to outfiles of the format bin1<t>bin2<t>count<t>norm_count<t>chrom1<t>chrom2'''
    cell_matrices = {}
    cell_matrices["cell"] = Counter()
    i = "cell"
    for entry in bedpe:
            n1, f1, r1, n2, f2, r2 = entry.split()[:6]
            if n1 not in valid_chroms: continue
            if n2 not in valid_chroms: continue
            if i in cell_matrices:
                pos1_reduce = (int(f1) + int(r1)) / 2 / resolution * resolution #use the fragment midpoint
                pos2_reduce = (int(f2) + int(r2)) / 2 / resolution * resolution #use the fragment midpoint
                bin1 = bins[(n1, pos1_reduce)]
                bin2 = bins[(n2, pos2_reduce)]
                if bin1 <= bin2:
                    key = (bin1, bin2, n1, n2)
                    cell_matrices[i][key] += 1
                else:
                    key = (bin2, bin1, n2, n1)
                    cell_matrices[i][key] += 1
            else:
                cell_matrices[i] = Counter()
                pos1_reduce = (int(f1) + int(r1)) / 2 / resolution * resolution #use the fragment midpoint
                pos2_reduce = (int(f2) + int(r2)) / 2 / resolution * resolution #use the fragment midpoint
                bin1 = bins[(n1, pos1_reduce)]
                bin2 = bins[(n2, pos2_reduce)]
                if bin1 <= bin2:
                    key = (bin1, bin2, n1, n2)
                    cell_matrices[i][key] += 1
                else:
                    key = (bin2, bin1, n2, n1)
                    cell_matrices[i][key] += 1
    return cell_matrices

def main():
    genome_file = open(sys.argv[1]) #positional argument 1 --> chromosome sizes
    bedpe = open(sys.argv[2])       #positional argument 2 --> list of bedpe files
    resolution = int(sys.argv[3])
    bins, valid_chroms = define_bins(genome_file, resolution)
    cell_matrices = bedpe_walk(bedpe, resolution, bins, valid_chroms)
    for i in cell_matrices:
        fho_name = "out_matrix"
        norm = normalizeMatrix(cell_matrices[i])
        for j in norm:
            print "%s\t%s\t%s\t%s\t%s\t%s" % (j[0],j[1], cell_matrices[i][j], norm[j],j[2],j[3])
    genome_file.close()
    bedpe.close()

if __name__ == "__main__":
    main()
