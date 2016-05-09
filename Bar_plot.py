# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import numpy as np
import matplotlib.pyplot as plt
import pylab as pl
y1 = [0.540798325,0.571762802,0.550280657,0.648060502,0.622404218,
      0.603088933,0.518245493,0.672114579,0.472062512,0.415569175]
y2 = [0.102234455,0.112529496,0.127839271,0.114016083,0.103276041,
      0.244588689,0.134652774,0.124458875,0.122396884,0.135728267]
y3 = [0.161580578,0.18566516,0.11122413,0.186562811,0.192532807,
      0.304156853,0.216749664,0.125647928,0.152824503,0.138264665]
y4 = [0.434646206,0.392718789,0.435724364,0.420010214,0.450819021,
      0.288734766,0.403353976,0.466918037,0.422425597,0.466682826]
y5 = [0.301538761,0.309086555,0.325212234,0.279410891,0.253372132,
      0.162519691,0.245243587,0.282975159,0.302353016,0.259324242]
      
z1 = [0.519696205,0.531522949,0.515805343,0.598202145,0.588587634,
       0.648427481,0.447108138,0.606218631,0.35402917,0.336381008]
z2 = [0.118991739,0.11606648,0.132942291,0.116106721,0.111455333,
      0.133089122,0.13119118,0.122412379,0.109849137,0.122212175]
z3 = [0.152015712,0.163290706,0.106736579,0.168942291,0.178389426,
      0.346831272,0.166540527,0.107843392,0.121296595,0.103446113]
z4 = [0.422111286,0.398873484,0.434650366,0.424240212,0.448269502,
      0.333155048,0.442840116,0.476261705,0.443942236,0.495743361]
z5 = [0.306881262,0.32176933,0.325670765,0.290710775,0.261885739,
      0.186924558,0.259428177,0.293482525,0.324912031,0.278598351]
labels = ['GM10847_SNPsCap','GM12814_SNPsCap','GM12878_SNPsCap','GM12815_SNPsCap','GM12812_SNPsCap','GM12813_SNPsCap','GM12875_SNPsCap','GM12872_SNPsCap','GM12873_SNPsCap','GM12874_SNPsCap']
x = range(0,len(y1))
colors = ['#624ea5', '#0072B2','g', 'yellow', 'orange', 
          tuple(np.array([200,187,69])/255.0),
          tuple(np.array([62, 169, 226])/255.0),
          tuple(np.array([7, 198, 172])/255.0),
          tuple(np.array([239, 99, 76])/255.0),
          tuple(np.array([247, 171, 17])/255.0)]
# make up some data in the interval ]0, 1[
# plot with various axes scales
'''
plt.figure(1)
plt.title('Promoter Cap')

plt.subplot(231)
plt.bar(x, z1,color=colors)
plt.title('Fraction_usable')
plt.grid(True)

plt.subplot(232)
plt.bar(x, z2,color=colors)
plt.title('<0.2kb_contacts')
plt.grid(True)


plt.subplot(233)
plt.bar(x, z3,color=colors)
plt.title('0.2−1kb_contacts')
plt.grid(True)

plt.subplot(234)
plt.bar(x, z4,color=colors)
plt.title('>1kb_contacts')
plt.grid(True)

plt.subplot(235)
plt.bar(x, z5,color=colors)
plt.title('Interchromosomal_contacts')
plt.grid(True)
plt.tight_layout()
pl.savefig('Promoter_Cap.pdf')
plt.show()

plt.figure(2)

plt.subplot(231)
plt.bar(x, y1,color=colors)
plt.title('Fraction_usable')
plt.grid(True)

plt.subplot(232)
plt.bar(x, y2,color=colors)
plt.title('<0.2kb_contacts')
plt.grid(True)


plt.subplot(233)
plt.bar(x, y3,color=colors)
plt.title('0.2−1kb_contacts')
plt.grid(True)

plt.subplot(234)
plt.bar(x, y4,color=colors)
plt.title('>1kb_contacts')
plt.grid(True)

plt.subplot(235)
plt.bar(x, y5,color=colors)
plt.title('Interchromosomal_contacts')
plt.grid(True)

plt.tight_layout()
pl.savefig('SNPs_Cap.pdf')
plt.show()
'''
f, ((ax1, ax2,ax3, ax4,ax5), (ax6, ax7,ax8, ax9, ax10)) = plt.subplots(2, 5, sharex='col')

ax1.bar(x, z1,color=colors)
ax1.set_title('Fraction_usable')
ax1.grid(True)

ax2.bar(x, z2,color=colors)
ax2.set_title('<0.2kb_contacts')
ax2.grid(True)

ax3.bar(x, z3,color=colors)
ax3.set_title('0.2−1kb_contacts')
ax3.grid(True)

ax4.bar(x, z4,color=colors)
ax4.set_title('>1kb_contacts')
ax4.grid(True)

ax5.bar(x, z5,color=colors)
ax5.set_title('Interchromosomal_contacts')
ax5.grid(True)



plt.tight_layout()
plt.show()