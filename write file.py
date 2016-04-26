import csv
import os
#os.remove('Genome540_HW7.txt')
with open('snps_in_rao.txt', 'w') as fp:
    a = csv.writer(fp,delimiter='\t')
    a.writerow(['chrid'] + ['x1'] + ['x2'] + ['y1'] + ['y2'] + ['snps'])
    for snp in targets:
        a.writerow([str(snp[0])] + [str(snp[1])] + [str(snp[2])] + [str(snp[3])] + [str(snp[4])] + [str(snp[5])])

with open('intersted_loops_in_rao.txt','w') as loops:
    a = csv.writer(loops,delimiter='\t')
    a.writerow(['chrid'] + ['x1'] + ['x2'] + ['y1'] + ['y2'] + ['snps'] + ['promoter_start'] + ['promoter_end'])
    for loop in total:
         a.writerow([str(loop[0])] + [str(loop[1])] + [str(loop[2])] + [str(loop[3])] + [str(loop[4])] + [str(loop[5])] + [str(loop[6])] + [str(loop[7])])
       
