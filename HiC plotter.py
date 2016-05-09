'''---------------------------------------------------------------------------------------
HiCPlotter: plotting Hi-C data with additional datasets
------------------------------------------------------------------------------------------'''

import os,sys
if sys.version_info[0] != 2 or sys.version_info[1] != 7:
	print >>sys.stderr, "\nYou are using python" + str(sys.version_info[0]) + '.' + str(sys.version_info[1]) + " HiCPlotter needs python2.7.*!\n"
	sys.exit()

import platform
if platform.platform().split('-')[0]=='Linux' or platform.platform().split('-')[0]=='Windows':
	import matplotlib
	matplotlib.use('Agg')

from math  import sqrt, isnan, floor, ceil, pi
from numpy import log2, array, max
from mpl_toolkits.axes_grid1 import make_axes_locatable
from matplotlib.ticker  import MultipleLocator
from matplotlib.patches import Polygon, Rectangle, Circle
from scipy.signal import argrelextrema
from scipy import ndimage
import scipy.sparse as sps
import matplotlib.pyplot as plt
import numpy as np
import argparse
import bisect
import logging

version = "0.5.05"

def read_sparseHiCdata(filename,chromosome,bedFile,startBin,endBin,wholeGenome,smooth_noise=0.5,ins_window=5,rel_window=8,plotInsulation=True,plotTadDomains=False,randomBins=False):
	
	'''
    load Hi-C interaction matrix from triple-column sparse file
    
    parameters:
    filename: file name. format "bin1\tbin2\tdata\n..."
    chromosome: plotting which chromosome
    bedFile: a bed file for locations of bins
    startBin: starting bin - 0 zero-based
    endBin: end point for the plot
    wholeGenome: for plotting more than one chromosome interactions. chromosome parameter will be used for until which chromosome interactions will be plotted.
    smooth_noise: variable values under will be replace with 0's to clean noise in the matrix
    ins_window: window size for scanning diagonal of the matrix for insulation scores
    rel_window: relative extrama extension size - will be extend to both directions
    
    returns:
    
    matrix: data matrix over the selected set of chromosome.
    nums: insulation scores array.
    tricks: putative insulator sites
    '''
		
	chromosomes = {}
	
	try:
		bed = open(bedFile,'r') 
	except IOError:
		print >>sys.stderr, 'cannot open', bedFile
		raise SystemExit
	
	for line in bed.readlines():
		tags = line.strip().split("\t")
		if tags[0]=='chrM':continue
		if tags[0] not in chromosomes.keys():
			chromosomes[tags[0]]=[]
			chromosomes[tags[0]].append(int(tags[3]))
		else: chromosomes[tags[0]].append(int(tags[3]))
	
	if not wholeGenome:
		clast = chromosomes[chromosome][-1]-1
		start = chromosomes[chromosome][0]+startBin
		end = chromosomes[chromosome][0]+endBin
	
		end=clast if end == chromosomes[chromosome][0] else end
		if end > clast: end=clast
		if start > clast: start=chromosomes[chromosome][0]
	else:
		start = 1
		end = chromosomes[chromosome][-1]
		clast = end
	
	length = end-start+1
	
	mtx = sps.dok_matrix((length, length), dtype=np.int)
	
	try:
		matrixFile = open(filename,'r') 
	except IOError:
		print >>sys.stderr, 'cannot open', filename
		raise SystemExit
	
	for line in matrixFile.xreadlines():
		tags = line.strip().split("\t")
		if int(tags[0]) <= end and int(tags[0])>=start :
			if int(tags[1]) <= end and int(tags[1])>=start :
				mtx[int(tags[0])-start, int(tags[1])-start] = int(round(float(tags[2])))
				mtx[int(tags[1])-start, int(tags[0])-start] = int(round(float(tags[2])))
		if int(tags[0]) > end: break
	
	matrix = mtx.todense()
	
	if plotInsulation or plotTadDomains and not wholeGenome: nums,tricks=insulation(matrix,ins_window,rel_window)
	else: nums=[];tricks=[];
	
	#matrix[matrix<smooth_noise]=0
	return matrix,nums,tricks,clast-chromosomes[chromosome][0]+1

def read_bedGraph(filename,resolution,chromosome): # add stopping after certain chromosome passed
	
	'''
    reads bedGraph files for various file type plottings
    parameters:
    filename: file name. format could be either "chr\tstart\tend" or "chr\tstart\tend\tvalue..."
    resolution: bin size for the matrix
	
	returns:
	x_scores = location along the given chromosome - start sites
	x_scores2 = location along the given chromosome - end sites
	y_scores = signal scores for the assay
	colors = allow for colors option
    '''
	
	try:
		fone=open(filename,'r')
	except IOError:
		print >>sys.stderr, 'cannot open', filename
		raise SystemExit
	
	x_scores=[]
	x_scores2=[]
	y_scores=[] 
	colors=[]
	texts=[]
	
	for line in fone.xreadlines():
		tags = line.strip().split("\t")
		if tags[0]==chromosome:
			x_scores.append(float(tags[1])/resolution)
			x_scores2.append(float(tags[2])/resolution)
			if len(tags) > 3:
				y_scores.append(float(tags[3]))
				if len(tags) > 4:
					hex = '#%02x%02x%02x' % (int(tags[4].split(',')[0]), int(tags[4].split(',')[1]), int(tags[4].split(',')[2]))
					colors.append(hex)
					if len(tags) > 5:
						texts.append(tags[5])
				
	if len(y_scores) !=0 and len(y_scores)!=len(x_scores):
		print >>sys.stderr, 'BedGraph('+filename+') has some missing values'
		raise SystemExit
	if len(x_scores)==0 or len(x_scores2)==0:
		print >>sys.stderr, 'BedGraph('+filename+') has some missing values'
		raise SystemExit
	# color and text controls
	return x_scores,x_scores2,y_scores,colors,texts
	
def read_peakFile(filename,resolution,chromosome): # add stopping after certain chromosome passed
	
	'''
    reads peak files for annotating the matrix
    parameters:
    filename: file name. format could be either "chr\tstart\tend" or "chr\tstart\tend\tvalue..."
    resolution: bin size for the matrix
	
	returns:
	origin_x = location along x axis on the given chromosome
	origin_y = location along y axis on the given chromosome
	radius = radius of circle
	colors = allow for colors option
    '''
	
	try:
		fone=open(filename,'r')
	except IOError:
		print >>sys.stderr, 'cannot open', filename
		raise SystemExit
	
	origin_x=[]
	origin_y=[]
	radius=[] 
	colors=[]
	
	for line in fone.xreadlines():
		tags = line.strip().split("\t")
		if tags[0]==chromosome and tags[3]==chromosome:
			x1 = float(tags[1])/resolution
			x2 = float(tags[2])/resolution
			origin_x.append(x1+(x2-x1)/2)
			radius.append((x2-x1)/2)
			y1 = float(tags[4])/resolution
			y2 = float(tags[5])/resolution
			origin_y.append(y1+(y2-y1)/2)
			
			if len(tags) > 5:
				hex = '#%02x%02x%02x' % (int(tags[6].split(',')[0]), int(tags[6].split(',')[1]), int(tags[6].split(',')[2]))
				colors.append(hex)
			
	if len(origin_y) !=0 and len(origin_x)!=len(origin_y):
		print >>sys.stderr, 'Peak file ('+filename+') has some missing values'
		raise SystemExit
	if len(origin_x)==0 or len(origin_y)==0:
		print >>sys.stderr, 'Peak file ('+filename+') has some missing values'
		raise SystemExit
	# color control
	return origin_x,origin_y,radius,colors



def where(start,end,arr):
    """Find where the start location and end location indexes in an array"""
    
    astart = bisect.bisect_left(arr, start)
    aend = bisect.bisect_right(arr[start:], end) + start
        
    return astart, aend

def get_ellipse_coords(a=0.0, b=0.0, x=0.0, y=0.0, angle=0.0, k=2):
    """ Draws an ellipse using (360*k + 1) discrete points
    k = 1 means 361 points (degree by degree)
    a = major axis distance,
    b = minor axis distance,
    x = offset along the x-axis
    y = offset along the y-axis
    angle = clockwise rotation [in degrees] of the ellipse;
        * angle=0  : the ellipse is aligned with the positive x-axis
        * angle=30 : rotated 30 degrees clockwise from positive x-axis
        
    this function is obtained from : http://scipy-central.org/item/23/2/plot-an-ellipse
    """
    pts = np.zeros((360*k+1, 2))

    beta = -angle * np.pi/180.0
    sin_beta = np.sin(beta)
    cos_beta = np.cos(beta)
    alpha = np.radians(np.r_[0.:360.:1j*(360*k+1)])
 
    sin_alpha = np.sin(alpha)
    cos_alpha = np.cos(alpha)
    
    pts[:, 0] = x + (a * cos_alpha * cos_beta - b * sin_alpha * sin_beta)
    pts[:, 1] = y + (a * cos_alpha * sin_beta + b * sin_alpha * cos_beta)

    return pts

def HiCplotter(files=[],names=[],resolution=100000,chromosome='',output='',histograms=[],histLabels=[],fillHist=[],histMax=[],verbose=False,fileHeader=1,fileFooter=1,matrixMax=0,histColors=[],barPlots=[],barLabels=[],\
			start=0,end=0,tileLabels=[],tilePlots=[],tileColors=[],tileText=False,arcLabels=[],arcPlots=[],arcColors=[],peakFiles=[],epiLogos='',window=5,tadRange=8,tripleColumn=False,bedFile='',barColors=[],\
			smoothNoise=0.5,cleanNANs=True,plotTriangular=True,plotTadDomains=False,randomBins=False,wholeGenome=False,plotPublishedTadDomains=False,plotDomainsAsBars=False,imputed=False,barMax=[],spine=False,\
			highlights=0,highFile='',heatmapColor=3,highResolution=True,plotInsulation=True,plotCustomDomains=False,publishedTadDomainOrganism=True,customDomainsFile=[]):
	
	'''
    plot the interaction matrix with additional datasets
 	Required parameters:
    files 			(-f)		: a list of filenames to be plotted.
    name 			(-n) 		: a list of labels for the experiment.
    chr				(-chr)		: chromosome to be plotted.
    output			(-o)		: prefix for the output file.
    
    Optional parameters:
    
    verbose			(-v)		: print version and arguments into a file.
    tripleColumn	(-tri)		: a boolean if input file is from HiC-Pro pipeline.
    bedFile			(-bed)		: a file name for bin annotations, if -tri parameter is set.
    histograms		(-hist)		: a list of filenames to be plotted as histogram.
    histLabels		(-h)		: a list of labels for the histograms.
    fillHist		(-fhist)	: a list whether each histogram will be filled (1) or not (0:default).
    histColors		(-hc)		: a list of hexadecimal number for histogram filling colors.
    histMax 		(-hm)		: a list of integer for maximum values of histograms.
    start			(-s)		: retain after x-th bin (0:default).
    end				(-e)		: continues until x-th bin (default: length of the matrix).
    resolution		(-r)		: resolution of the bins (default: 100000).
    matrixMax		(-mm)		: an integer value for the interaction matrix heatmap scale upper-limit.
    barPlots		(-b)		: a list of filenames to be plotted as bar plots.
    barLabels		(-bl)		: a list of labels for the bar plots.
    barColors		(-bc)		: a list of hexadecimal numbers for coloring the bar plots.
    barMax	 		(-bm)		: a list of integer for maximum values of bar plots.
    tilePlots		(-t)		: a list of filenames to be plotted as tile plots.
    tileLabels		(-tl)		: a list of labels for the tile plots.
    tileColors		(-tc)		: a list of hexadecimal numbers for coloring the tile plots.
    tileText		(-tt)		: a boolean whether text will be displayed above tiles (0:default) or not (1).
    arcPlots		(-a)		: a list of filenames to be plotted as arc plots.
    arcLabels		(-al)		: a list of labels for the arc plots.
    arcColors		(-ac)		: a list of hexadecimal numbers for coloring the arc plots.
    highlights		(-high)		: a boolean for enabling highlights on the plot (0:default), enable(1). 
    highFile		(-hf)		: a file name for a bed file to highlight selected intervals.
    peakFiles 		(-peak)		: a list of filenames to be plotted on the matrix.
    epiLogos 		(-ep)		: a filename to be plotted as Epilogos format.
    imputed 		(-im)		: a boolean if imputed epilogos will be plotted. (default:0 for observed)
    spine			(-spi)		: a boolean to remove top and left borders for each tracks (default:0) enable(1).
    window			(-w)		: an integer of distance to calculate insulation score.
    tadRange		(-tr)		: an integer of window to calculate local minima for TAD calls.
    fileHeader		(-fh)		: an integer for how many lines should be ignored in the matrix file (1:default).
    fileFooter		(-ff)		: an integer for how many lines should be skipped at the end of the matrix file (0:default).
    smoothNoise		(-sn)		: a floating-point number to clean noise in the data.
    heatmapColor	(-hmc)		: an integer for choosing heatmap color codes: Greys(0), Reds(1), YellowToBlue(2), YellowToRed(3-default), Hot(4), BlueToRed(5).
    cleanNANs		(-cn)		: a boolean for replacing NaNs in the matrix with zeros (1:default) or not (0).
    plotTriangular	(-ptr)		: a boolean for plotting rotated half matrix (1:default) or not (0).
    plotTadDomains	(-ptd)		: a boolean for plotting TADs identified by HiCPlotter (1) or not (0:default).
    plotPublishedTadDomins	(-pptd)	: a boolean for plotting TADs from Dixon et, al. 2012 (1:default) or not (0).
    plotDomainsAsBars		(-ptdb)	: a boolean for plotting TADs as bars (1) instead of triangles (0:default)
    highResolution	(-hR)		: a boolean whether plotting high resolution (1:default) or not (0).
    plotInsulation	(-pi)		: a boolean for plotting insulation scores (0:default) or plot (1).
    randomBins		(-rb)		: a boolean for plotting random resolution data (1:default) or not (0).
    wholeGenome		(-wg)		: a boolean for plotting whole genome interactions (1:default) or not (0).
    plotCustomDomains		(-pcd)	: a list of file names to be plotted beneath the matrix.
    publishedTadDomainOrganism 	(-ptdo)	: a boolean for plotting human (1:default) or mouse (0) TADs from Dixon et, al. 2012.
    customDomainsFile			(-pcdf)	: a list of filenames to be plotted as TADs for each experiments.
	
	'''
	
	numOfcols = len(files)
	numOfrows = 4
	if plotTriangular: numOfrows+=1 
	if plotTadDomains: numOfrows+=1
	if plotInsulation: numOfrows+=1
	if epiLogos: numOfrows+=1
	if len(histograms)>0: numOfrows+=len(histograms[0].split(','))
	if len(barPlots)>0: numOfrows+=len(barPlots[0].split(','))
	if len(tilePlots)>0: numOfrows+=len(tilePlots[0].split(','))
	if len(arcPlots)>0: numOfrows+=len(arcPlots[0].split(','))
	if plotCustomDomains or plotPublishedTadDomains and not plotTadDomains: numOfrows+=1
	
	fig=plt.figure(figsize=(numOfcols*5+2.5, numOfrows+numOfrows/2+0.5), facecolor='w', edgecolor='w')
	fig.set_size_inches(numOfcols*5+2.5, numOfrows+numOfrows/2+0.5)
	fig.subplots_adjust(hspace=0.48,wspace=1.0)
	
	ymaxlims = []
	yminlims = []
	cmatrix = 0
	ins_score = 0
	mlength = 0
	
	cmaps = ['Greys','Reds','YlOrBr','YlOrRd','hot']
	h_start = []
	h_end = []
	
	if highlights:
		h_start,h_end,_,_,_ = read_bedGraph(highFile,resolution,chromosome)
	
	for exp in range(0,len(files)):
		rowcounter=0
		
		if not tripleColumn:
			matrix,nums,tricks=read_HiCdata(files[exp],fileHeader,fileFooter,cleanNANs,smoothNoise,window,tadRange,plotInsulation,plotTadDomains,randomBins)
			end=len(matrix) if end == 0 else end
			if end > len(matrix): end=len(matrix)
			size=end-start
			if exp == 0 : mlength = len(matrix)
			elif len(matrix) != mlength and not randomBins:
				print len(matrix), mlength
				print >>sys.stderr, 'unbalanced matrix size of '+files[exp]+' compared to '+files[0]+' ! matrix sizes should be equal'
				raise SystemExit
			
			matrix=matrix[start:end,start:end]
		else:
			if bedFile == '':
				print >>sys.stderr, 'an annotation bed file is required for triple-column sparse input.'
				raise SystemExit
			matrix,nums,tricks,clength=read_sparseHiCdata(files[exp],chromosome,bedFile,start,end,wholeGenome,window,tadRange,plotInsulation,plotTadDomains,randomBins)
			if end > clength: end=clength
			end=clength if end == 0 else end
			size=end-start
			
		length = len(matrix)
		name=names[exp]	
		schr=chromosome.replace("chr","")
		
		''' MAIN matrix plotting '''
	
		ax1 = plt.subplot2grid((numOfrows, 4*len(files)), (0, exp*4), rowspan=4,colspan=4)

		ax1.set_title(('%s') % (name))
		if exp==0: 
			if not randomBins and not wholeGenome: ax1.set_ylabel('log2(interaction matrix) - %s Mb (resolution: %sKb)' % (chromosome , resolution/1000))
			elif randomBins: ax1.set_ylabel('log2(interaction matrix) - %s (Genomic Bins)' % (chromosome))
			elif wholeGenome: ax1.set_ylabel('')
			cmatrix = log2(pow(2, ceil(log2(max(matrix))/log2(2))))
			if matrixMax !=0: cmatrix = matrixMax
			
		ax1.set_ylim(int(start or 1) - 0.5,int(start or 1) + length - 0.5)
		ax1.set_xlim(int(start or 1) - 0.5,int(start or 1) + length - 0.5)
			
		if not wholeGenome:
			if heatmapColor < 5:
				with np.errstate(divide='ignore'): img=ax1.imshow(log2(matrix),cmap=plt.get_cmap(cmaps[heatmapColor]),origin="lower",interpolation="nearest",extent=(int(start or 1) - 0.5,\
														  		  int(start or 1) + length - 0.5,int(start or 1) - 0.5,int(start or 1) + length - 0.5),aspect='auto')
			elif heatmapColor == 3:
				cmap = plt.get_cmap(cmaps[heatmapColor])
				cmap.set_over('black')
				with np.errstate(divide='ignore'): img=ax1.imshow(log2(matrix),cmap=cmap,origin="lower",interpolation="nearest",extent=(int(start or 1) - 0.5,\
														  		  int(start or 1) + length - 0.5,int(start or 1) - 0.5,int(start or 1) + length - 0.5),aspect='auto')
			else:
				with np.errstate(divide='ignore'): img=ax1.imshow(log2(matrix),origin="lower",interpolation="nearest",extent=(int(start or 1) - 0.5,\
														  		  int(start or 1) + length - 0.5,int(start or 1) - 0.5,int(start or 1) + length - 0.5),aspect='auto')
		else:
			if heatmapColor < 5:
				with np.errstate(divide='ignore'): img=ax1.imshow(log2(matrix),cmap=plt.get_cmap(cmaps[heatmapColor]),interpolation="nearest",extent=(int(start or 1) - 0.5,\
														  		  int(start or 1) + length - 0.5,int(start or 1) - 0.5,int(start or 1) + length - 0.5),aspect='auto')
			elif heatmapColor == 3:
				cmap = plt.get_cmap(cmaps[heatmapColor])
				cmap.set_over('black')
				with np.errstate(divide='ignore'): img=ax1.imshow(log2(matrix),cmap=cmap,origin="lower",interpolation="nearest",extent=(int(start or 1) - 0.5,\
														  		  int(start or 1) + length - 0.5,int(start or 1) - 0.5,int(start or 1) + length - 0.5),aspect='auto')
			else:
				with np.errstate(divide='ignore'): img=ax1.imshow(log2(matrix),interpolation="nearest",extent=(int(start or 1) - 0.5,\
														  		  int(start or 1) + length - 0.5,int(start or 1) - 0.5,int(start or 1) + length - 0.5),aspect='auto')
			plt.setp(ax1.get_xticklabels(), visible=False)
			
		if len(peakFiles) > 0:
			origin_x,origin_y,radius,colors = read_peakFile(peakFiles[exp],resolution,chromosome)
			for citem in range(0,len(origin_x)):
				if len(colors)==0: circle = Circle((origin_x[citem], origin_y[citem]), radius[citem], facecolor='none', edgecolor='black', linewidth=1, alpha=0.85)
				else: circle = Circle((origin_x[citem], origin_y[citem]), radius[citem], facecolor='none', edgecolor=colors[citem], linewidth=3, alpha=0.85)
				ax1.add_patch(circle)
				
		divider = make_axes_locatable(ax1)
		img.set_clim([0,cmatrix])
		
		if wholeGenome : plt.setp(ax1.get_yticklabels(), visible=False)
		ax1.get_yaxis().set_label_coords(-0.125,0.5) 
		if plotTadDomains:
			ax1.set_xticks(tricks, minor=True)
			ax1.xaxis.grid(True,which='minor',linewidth=2)
		
		if h_start > 0:
			for item in range(0,len(h_start)):
				ax1.axvspan(h_start[item], h_end[item], facecolor='g', alpha=0.10, linestyle='dashed')
		
		rowcounter+=4
		ax1.get_xaxis().set_label_coords(0.5,-0.125)
		if numOfrows <= rowcounter and not randomBins and not wholeGenome: 
			cax = divider.append_axes("bottom", size="2.5%", pad=0.9)
			cbar = plt.colorbar(img, cax=cax, ticks=MultipleLocator(2.0), format="%.1f",orientation='horizontal',extendfrac='auto',spacing='uniform')
			plt.setp(ax1.get_xticklabels(), visible=True)
			ax1.set_xlabel('Chromosome %s Mb (resolution: %sKb)' % (schr , resolution/1000))
		elif numOfrows <= rowcounter and randomBins: ax1.set_xlabel('Chromosome %s (Genomic Bins)' % (schr))
		elif numOfrows <= rowcounter and wholeGenome: ax1.set_xlabel('')
		else:
			cax = divider.append_axes("bottom", size="2.5%", pad=0.1)
			cbar = plt.colorbar(img, cax=cax, ticks=MultipleLocator(2.0), format="%.1f",orientation='horizontal',extendfrac='auto',spacing='uniform')
			plt.setp(ax1.get_xticklabels(), visible=False)
		
		''' Whole Genome matrix plotting '''
		
		if wholeGenome and numOfrows > rowcounter:
			print >>sys.stderr, 'Whole genome can be plotted only as matrix - this feature will be improved in future releases'
			raise SystemExit
		
		''' Triangular (Rotated Matrix) plotting '''
		
		if plotTriangular: 
		
			ax2 = plt.subplot2grid((numOfrows, 4*len(files)), (rowcounter, exp*4), rowspan=1,colspan=4,sharex=ax1)
			dst=ndimage.rotate(matrix,45,order=0,reshape=True,prefilter=False,cval=0)
			matrix=[];
			height=length/5
			ax2.set_ylim(start+length/2,start+length/2+height)
			ax2.set_xlim(int(start or 1) - 0.5,int(start or 1) + length - 0.5)
			ax2.set(adjustable='box-forced')
			if heatmapColor < 5:
				with np.errstate(divide='ignore'): img=ax2.imshow(log2(dst),origin="lower",cmap=plt.get_cmap(cmaps[heatmapColor]),interpolation="nearest",extent=(int(start or 1) - 0.5,\
															  	  int(start or 1) + length - 0.5,int(start or 1) - 0.5,int(start or 1) + length - 0.5),aspect='auto')
			else:
				with np.errstate(divide='ignore'): img=ax2.imshow(log2(dst),origin="lower",interpolation="nearest",extent=(int(start or 1) - 0.5,\
															  	  int(start or 1) + length - 0.5,int(start or 1) - 0.5,int(start or 1) + length - 0.5),aspect='auto')
			dst=[];
			img.set_clim([0,cmatrix-1])
			plt.setp(ax2.get_yticklabels(), visible=False)
			if exp==0: ax2.set_ylabel('Triangular')
			ax2.get_yaxis().set_label_coords(-0.125,0.5)
			if plotTadDomains:
				ax2.set_xticks(tricks, minor=True)
				ax2.xaxis.grid(True,which='minor',linewidth=2)
			rowcounter+=1
			if numOfrows <= rowcounter and not randomBins: ax2.set_xlabel('Chromosome %s Mb (resolution: %sKb)' % (schr , resolution/1000))
			elif numOfrows <= rowcounter and randomBins: ax2.set_xlabel('Chromosome %s (Genomic Bins)' % (schr))
			
			if h_start > 0:
				for item in range(0,len(h_start)):
					ax2.axvspan(h_start[item], h_end[item], facecolor='g', alpha=0.10, linestyle='dashed')
			
		''' Random Bins matrix/triangular plotting '''
		
		if randomBins and numOfrows > rowcounter:
			print >>sys.stderr, 'Random bins data can be plotted only as matrix and triangular - this feature will be improved in future releases'
			raise SystemExit
		
		''' Histogram plotting '''
		
		if len(histograms)>0: 
			for x in range(0,len(histograms[0].split(','))):
				ax3 = plt.subplot2grid((numOfrows, 4*len(files)), (rowcounter, exp*4), rowspan=1,colspan=4,sharex=ax1)
				ax3.get_yaxis().set_label_coords(-0.125,0.5)
				x_comps,x_comps2,y_comps,colors,texts = read_bedGraph(histograms[exp].split(',')[x],resolution,chromosome)
				ax3.plot(x_comps,y_comps,color='black')
				if exp==0: 
					ystart,yend = where(start,end,x_comps)
					ymin = min(y_comps[ystart:yend])+ min(y_comps[ystart:yend])/10 if min(y_comps[ystart:yend]) < 0 else min(y_comps[ystart:yend])-min(y_comps[ystart:yend])/10
					yminlims.append(ymin)
					if len(histMax)==0:
						ax3.set_ylim(ymin,max(y_comps[ystart:yend])+max(y_comps[ystart:yend])/10)
						ymaxlims.append(max(y_comps[ystart:yend]))
						#print ymin, max(y_comps[ystart:yend])+max(y_comps[ystart:yend])/10
					else:
						ax3.set_ylim(ymin,int(histMax[exp].split(',')[x])+int(histMax[exp].split(',')[x])/10)
					ax3.set_ylabel(histLabels[exp].split(',')[x])
				else:
					if len(histMax)==0:
						ax3.set_ylim(yminlims[x],ymaxlims[x]+ymaxlims[x]/10)
					else:
						ax3.set_ylim(ymin,int(histMax[exp].split(',')[x])+int(histMax[exp].split(',')[x])/10)
				
				ax3.locator_params(axis='y',tight=False, nbins=3)
				ax3.set_xlim(int(start or 1) - 0.5,int(start or 1) + length - 0.5)
				
				
				if len(fillHist) > 0 and int(fillHist[exp].split(',')[x])==1:
					comps2=array(y_comps)
					if len(histColors)>0:
						if histColors[exp].split(',')[x] != '':
							ax3.fill_between(x_comps, comps2,0, color='#'+histColors[exp].split(',')[x], interpolate=True)
							if ymin < 0: 
								with np.errstate(all='ignore'):ax3.fill_between(x_comps, comps2,0, comps2>0, color='#'+histColors[exp].split(',')[x], interpolate=True)
								with np.errstate(all='ignore'):ax3.fill_between(x_comps, comps2, 0, where=comps2<0, color='black', interpolate=True)
						else:
							ax3.fill_between(x_comps, comps2,0, color='gray', interpolate=True)
							if ymin < 0: 
								with np.errstate(all='ignore'):ax3.fill_between(x_comps, comps2,0, comps2>0, color='gray', interpolate=True)
								with np.errstate(all='ignore'):ax3.fill_between(x_comps, comps2, 0, where=comps2<0, color='black', interpolate=True)
					else:
						ax3.fill_between(x_comps, comps2,0, color='gray', interpolate=True)
						if ymin < 0: 
							with np.errstate(all='ignore'):ax3.fill_between(x_comps, comps2,0, comps2>0, color='gray', interpolate=True)
							with np.errstate(all='ignore'):ax3.fill_between(x_comps, comps2, 0, where=comps2<0, color='black', interpolate=True)
							
				x_comps=[];x_comps2=[];y_comps=[];colors==[];	
				if plotTadDomains:
					ax3.set_xticks(tricks, minor=True)
					ax3.xaxis.grid(True,which='minor')
				
				if h_start > 0:
					for item in range(0,len(h_start)):
						ax3.axvspan(h_start[item], h_end[item], facecolor='g', alpha=0.10, linestyle='dashed')
				
				if spine > 0:
					ax3.spines['right'].set_visible(False)
					ax3.spines['top'].set_visible(False)
					ax3.xaxis.set_ticks_position('bottom')
					ax3.yaxis.set_ticks_position('left')
				
				rowcounter+=1
			if numOfrows <= rowcounter and not randomBins: ax3.set_xlabel('Chromosome %s Mb (resolution: %sKb)' % (schr , resolution/1000))
			elif numOfrows <= rowcounter and randomBins: ax3.set_xlabel('Chromosome %s (Genomic Bins)' % (schr))
		
		
		''' Bar plotting '''
		
		if len(barPlots)>0: 
			for x in range(0,len(barPlots[0].split(','))):
	
				ax3 = plt.subplot2grid((numOfrows, 4*len(files)), (rowcounter, exp*4), rowspan=1,colspan=4,sharex=ax1)
				if exp==0: ax3.set_ylabel(barLabels[exp].split(',')[x])
				ax3.get_yaxis().set_label_coords(-0.125,0.5)
				x_comps,x_comps2,y_comps,colors,texts = read_bedGraph(barPlots[exp].split(',')[x],resolution,chromosome)
				
				if len(barMax)==0: hMax = max(y_comps)
				else: hMax = float(barMax[exp].split(',')[x]) #need to implement length check
				
				for item in range(0,len(x_comps)):
					#if x_comps[item]>=start and x_comps[item]<=end:
					if len(barMax)>0 and y_comps[item]>float(barMax[exp].split(',')[x]): y_comps[item]=float(barMax[exp].split(',')[x])
					if len(barColors)==0 and len(colors)==0: rect = Rectangle((x_comps[item],0.0), (x_comps2[item]-x_comps[item]), y_comps[item], color='#0099FF',alpha=y_comps[item]/hMax)
					elif len(colors)>0: rect = Rectangle((x_comps[item],0.0), (x_comps2[item]-x_comps[item]),  y_comps[item], color=colors[item])
					elif len(barColors)>0: rect = Rectangle((x_comps[item],0.0), (x_comps2[item]-x_comps[item]),  y_comps[item], color='#'+barColors[exp].split(',')[x],alpha=y_comps[item]/hMax)
					ax3.add_patch(rect)
				x_comps=[];x_comps2=[];y_comps=[];colors==[];
				ax3.set_xlim(int(start or 1) - 0.5,int(start or 1) + length - 0.5)
				ax3.set_ylim(0,hMax+hMax/10)
				ax3.locator_params(axis='y',tight=False, nbins=4)
				if plotTadDomains:
					ax3.set_xticks(tricks, minor=True)
					ax3.xaxis.grid(True,which='minor')
				
				if h_start > 0:
					for item in range(0,len(h_start)):
						ax3.axvspan(h_start[item], h_end[item], facecolor='g', alpha=0.10, linestyle='dashed')
				
				if spine > 0:
					ax3.spines['right'].set_visible(False)
					ax3.spines['top'].set_visible(False)
					ax3.xaxis.set_ticks_position('bottom')
					ax3.yaxis.set_ticks_position('left')
				
				rowcounter+=1
			if numOfrows <= rowcounter and not randomBins: ax3.set_xlabel('Chromosome %s Mb (resolution: %sKb)' % (schr , resolution/1000))
			elif numOfrows <= rowcounter and randomBins: ax3.set_xlabel('Chromosome %s (Genomic Bins)' % (schr))

		
				
		''' Tile plotting '''
		
		if len(tilePlots)>0: 
			for x in range(0,len(tilePlots[0].split(','))):
	
				ax3 = plt.subplot2grid((numOfrows, 4*len(files)), (rowcounter, exp*4), rowspan=1,colspan=4,sharex=ax1)
				if exp==0: ax3.set_ylabel(tileLabels[exp].split(',')[x])
				ax3.get_yaxis().set_label_coords(-0.125,0.5)
				x_comps,x_comps2,y_comps,colors,texts = read_bedGraph(tilePlots[exp].split(',')[x],resolution,chromosome)
				for item in range(0,len(x_comps)):
					if len(tileColors)==0 and len(colors)==0: rect = Rectangle((x_comps[item],0.35), (x_comps2[item]-x_comps[item]), 0.25, color='#0099FF')
					elif len(colors)>0: rect = Rectangle((x_comps[item],0.35), (x_comps2[item]-x_comps[item]), 0.25, color=colors[item])
					elif len(tileColors)>0: rect = Rectangle((x_comps[item],0.35), (x_comps2[item]-x_comps[item]), 0.25, color='#'+tileColors[exp].split(',')[x])
					if len(texts) > 0 and tileText: ax3.text(x_comps[item]-1, 0.75, texts[item], fontsize=10)
					ax3.add_patch(rect)
				x_comps=[];x_comps2=[];y_comps=[];colors==[];
				ax3.set_xlim(int(start or 1) - 0.5,int(start or 1) + length - 0.5)
				ax3.set_ylim(0,1)
				plt.setp(ax3.get_yticklabels(), visible=False)
				if plotTadDomains:
					ax3.set_xticks(tricks, minor=True)
					ax3.xaxis.grid(True,which='minor')
				
				if h_start > 0:
					for item in range(0,len(h_start)):
						ax3.axvspan(h_start[item], h_end[item], facecolor='g', alpha=0.10, linestyle='dashed')
				
				if spine > 0:
					ax3.spines['right'].set_visible(False)
					ax3.spines['top'].set_visible(False)
					ax3.xaxis.set_ticks_position('bottom')
					ax3.yaxis.set_ticks_position('left')
				
				rowcounter+=1
			if numOfrows <= rowcounter and not randomBins: ax3.set_xlabel('Chromosome %s Mb (resolution: %sKb)' % (schr , resolution/1000))
			elif numOfrows <= rowcounter and randomBins: ax3.set_xlabel('Chromosome %s (Genomic Bins)' % (schr))
		
		
		''' Arc plotting '''
		
		if len(arcPlots)>0: 
			for x in range(0,len(arcPlots[0].split(','))):

				ax3 = plt.subplot2grid((numOfrows, 4*len(files)), (rowcounter, exp*4), rowspan=1,colspan=4,sharex=ax1)
				if exp==0: ax3.set_ylabel(arcLabels[exp].split(',')[x])
				ax3.get_yaxis().set_label_coords(-0.125,0.5)
				x_comps,x_comps2,y_comps,colors,texts = read_bedGraph(arcPlots[exp].split(',')[x],resolution,chromosome)
				ymax = 0
				for item in range(0,len(x_comps)):
				
					center = x_comps[item]+(x_comps2[item]-x_comps[item])/2
					rad = (x_comps2[item]-x_comps[item])/2
					pts = get_ellipse_coords(a=rad, b=1.0, x=center, k=1./8)
					if len(arcColors)==0 and len(colors)==0: ax3.plot(pts[:,0], pts[:,1],c='black')
					elif len(colors)>0: ax3.fill_between(pts[:,0], pts[:,1],0, color=colors[item], interpolate=True, alpha=0.35)
					elif len(arcColors)>0: ax3.fill_between(pts[:,0], pts[:,1],0, color='#'+arcColors[exp].split(',')[x], interpolate=True, alpha=0.35)
				
				x_comps=[];x_comps2=[];y_comps=[];colors==[];
				ax3.set_xlim(int(start or 1) - 0.5,int(start or 1) + length - 0.5)
				ax3.set_ylim(0,1)
				plt.setp(ax3.get_yticklabels(), visible=False)
				if plotTadDomains:
					ax3.set_xticks(tricks, minor=True)
					ax3.xaxis.grid(True,which='minor')
				
				if h_start > 0:
					for item in range(0,len(h_start)):
						ax3.axvspan(h_start[item], h_end[item], facecolor='g', alpha=0.10, linestyle='dashed')
				
				if spine > 0:
					ax3.spines['right'].set_visible(False)
					ax3.spines['top'].set_visible(False)
					ax3.xaxis.set_ticks_position('bottom')
					ax3.yaxis.set_ticks_position('left')
				
				rowcounter+=1
			if numOfrows <= rowcounter and not randomBins: ax3.set_xlabel('Chromosome %s Mb (resolution: %sKb)' % (schr , resolution/1000))
			elif numOfrows <= rowcounter and randomBins: ax3.set_xlabel('Chromosome %s (Genomic Bins)' % (schr))

		
		
		''' Insulation Scores '''
		
		if plotInsulation: 
		
			ax4 = plt.subplot2grid((numOfrows,4*len(files)), (rowcounter, exp*4), rowspan=1,colspan=4,sharex=ax1)
			if exp==0: 
				ax4.set_ylabel('Insulation')
				ins_score = max(nums[start:end])+max(nums[start:end])/5
					
			ax4.get_yaxis().set_label_coords(-0.125,0.5)
			ax4.locator_params(axis='y',tight=False, nbins=3)		
			ax4.set_ylim(0,ins_score)
			ax4.set_xlim(int(start or 1) - 0.5,int(start or 1) + length - 0.5)
			ax4.plot(range(0,len(nums)),nums,'black')
			ax4.fill_between(range(0,len(nums)),nums,0,color='0.8')
			if plotTadDomains:
				ax4.set_xticks(tricks, minor=True)
				ax4.xaxis.grid(True,which='minor')
			
			if h_start > 0:
				for item in range(0,len(h_start)):
					ax4.axvspan(h_start[item], h_end[item], facecolor='g', alpha=0.10, linestyle='dashed')
				
			if spine > 0:
				ax4.spines['right'].set_visible(False)
				ax4.spines['top'].set_visible(False)
				ax4.xaxis.set_ticks_position('bottom')
				ax4.yaxis.set_ticks_position('left')
					
			rowcounter+=1
			if numOfrows <= rowcounter and not randomBins: ax4.set_xlabel('Chromosome %s Mb (resolution: %sKb)' % (schr , resolution/1000)) 
			elif numOfrows <= rowcounter and randomBins: ax4.set_xlabel('Chromosome %s (Genomic Bins)' % (schr))
			
		'''TAD plotings - determined by insulation score'''
		
		if plotTadDomains: 
	
			ax5 = plt.subplot2grid((numOfrows,4*len(files)), (rowcounter, exp*4), rowspan=1,colspan=4,sharex=ax1)
			
			for item in range(0,len(tricks)-1):
				if plotDomainsAsBars:
					if not plotPublishedTadDomains: p = Rectangle((tricks[item],0.2), (tricks[item+1]-tricks[item]), 0.25, color='darkkhaki',alpha=0.75)
					else: p = Rectangle((tricks[item],0.1), (tricks[item+1]-tricks[item]), 0.15, color='darkkhaki',alpha=0.75)
				else:
					pts= np.array([[tricks[item],0],[tricks[item+1],0],[floor((tricks[item]+tricks[item+1])/2),0.75]])
					p = Polygon(pts, closed=True,color='darkkhaki',alpha=max(nums[tricks[item]:tricks[item+1]])/max(nums))
				if sum(nums[slice(tricks[item],tricks[item+1])]) > np.percentile(np.array(nums),75):
					ax5.add_patch(p)

			if plotPublishedTadDomains:
				## adding TAD domain predictions from Dixon et al. Nature 2009
				if publishedTadDomainOrganism:
					fone=open('data/IMR90_domains_hg19.bed','r')
					for line in fone.xreadlines():
						tags = line.strip().split("\t")
						if tags[0]==chromosome:
							Tstart = int(tags[1])/resolution
							Tend = int(tags[2])/resolution
							if plotDomainsAsBars:
								p = Rectangle((Tstart,0.3), (Tend-Tstart), 0.15, color='salmon',alpha=0.75)
							else:
								pts= np.array([[Tstart,0],[Tend,0],[floor((Tstart+Tend)/2),0.25]])
								p = Polygon(pts, closed=True,color='salmon',alpha=0.5)
							ax5.add_patch(p)
					fone=open('data/hESC_domains_hg19.bed','r')
					for line in fone.xreadlines():
						tags = line.strip().split("\t")
						if tags[0]==chromosome:
							Tstart = int(tags[1])/resolution
							Tend = int(tags[2])/resolution
							if plotDomainsAsBars:
								p = Rectangle((Tstart,0.5), (Tend-Tstart), 0.15, color='steelblue',alpha=0.75)
							else:
								pts= np.array([[Tstart,0],[Tend,0],[floor((Tstart+Tend)/2),0.4]])
								p = Polygon(pts, closed=True,color='steelblue',alpha=0.5)
							ax5.add_patch(p)
					ax5.set_title('Khaki:%s - Blue:hES - Red:IMR90' % (name),fontsize=8)
				else:
					fone=open('data/mCortex_domains_mm9.bed','r')
					for line in fone.xreadlines():
						tags = line.strip().split("\t")
						if tags[0]==chromosome:
							Tstart = int(tags[1])/resolution
							Tend = int(tags[2])/resolution
							if plotDomainsAsBars:
								p = Rectangle((Tstart,0.3), (Tend-Tstart), 0.15, color='salmon',alpha=0.75)
							else:
								pts= np.array([[Tstart,0],[Tend,0],[floor((Tstart+Tend)/2),0.25]])
								p = Polygon(pts, closed=True,color='salmon',alpha=0.5)
							ax5.add_patch(p)
					fone=open('data/mES_domains_mm9.bed','r')
					for line in fone.xreadlines():
						tags = line.strip().split("\t")
						if tags[0]==chromosome:
							Tstart = int(tags[1])/resolution
							Tend = int(tags[2])/resolution
							if plotDomainsAsBars:
								p = Rectangle((Tstart,0.5), (Tend-Tstart), 0.15, color='steelblue',alpha=0.75)
							else:
								pts= np.array([[Tstart,0],[Tend,0],[floor((Tstart+Tend)/2),0.4]])
								p = Polygon(pts, closed=True,color='steelblue',alpha=0.5)
							ax5.add_patch(p)
					ax5.set_title('Khaki:%s - Blue:mES - Red:Cortex' % (name),fontsize=8)
			else:
				ax5.set_title('Khaki:%s' % (name))
				
			ax5.set_xlim(int(start or 1) - 0.5,int(start or 1) + length - 0.5)
			if exp==0: ax5.set_ylabel("Domains")
			ax5.locator_params(axis='y',tight=False, nbins=3)
			ax5.get_yaxis().set_label_coords(-0.125,0.5)
			plt.setp(ax5.get_yticklabels(), visible=False)
			if not plotCustomDomains and not randomBins: ax5.set_xlabel('Chromosome %s Mb (resolution: %sKb)' % (schr , resolution/1000))
			elif not plotCustomDomains and randomBins: ax5.set_xlabel('Chromosome %s (Genomic Bins)' % (schr))
			ax5.set_ylim(0,0.75)
			if spine > 0:
				ax5.spines['right'].set_visible(False)
				ax5.spines['top'].set_visible(False)
				ax5.xaxis.set_ticks_position('bottom')
				ax5.yaxis.set_ticks_position('left')
			rowcounter+=1
		

		

		if not randomBins:		
			ticks= ax1.get_xticks().tolist()
			for item in range(0,len(ticks)): ticks[item]=round(ticks[item]*resolution/1000000,1) 
			ax1.set_xticklabels(ticks)
			ax1.set_yticklabels(ticks)
	
	if 'JPEG' in plt.gcf().canvas.get_supported_filetypes_grouped().keys() or 'Joint Photographic Experts Group' in plt.gcf().canvas.get_supported_filetypes_grouped().keys(): extension='.jpeg'
	else : extension = '.png'
	
	print 'Plotting now!!'	
	if wholeGenome:	
		if highResolution:
			plt.savefig(output+'-WholeGenome-'+str(resolution/1000)+'K'+extension,dpi=200)
		else:
			plt.savefig(output+'-WholeGenome-'+str(resolution/1000)+'K'+extension)
	elif randomBins:
		if highResolution:
			plt.savefig(output+'-'+chromosome+'.'+'ofBins('+str(start)+'-'+str(end)+').RandomBins'+extension,dpi=200)
		else:
			plt.savefig(output+'-'+chromosome+'.'+'ofBins('+str(start)+'-'+str(end)+').RandomBins'+extension)
	else:
		if highResolution:
			plt.savefig(output+'-'+chromosome+'.'+'ofBins('+str(start)+'-'+str(end)+').'+str(resolution/1000)+'K'+extension,dpi=200)
		else:
			plt.savefig(output+'-'+chromosome+'.'+'ofBins('+str(start)+'-'+str(end)+').'+str(resolution/1000)+'K'+extension)

if __name__=='__main__':
	
	parser = argparse.ArgumentParser(usage='HiCPlotter.py -f file1 file2 ... -n name1 name2 ... -chr chr12 -o hES',add_help=False,formatter_class=argparse.RawDescriptionHelpFormatter)
	
	group = parser.add_argument_group("Required Parameters")
	group.add_argument('-f','--files', nargs='+',help='',metavar='',required=True)
	group.add_argument('-n','--names', nargs='+',metavar='',required=True)
	group.add_argument('-chr', '--chromosome',default='',metavar='',required=True)
	group.add_argument('-o', '--output',default='',metavar='',required=True)
	
	group1 = parser.add_argument_group("Optional Parameters")
	group1.add_argument('-h', '--help', action="help")
	group1.add_argument("-v", "--verbose", help="increase output verbosity", action="store_true",default=False)
	group1.add_argument('-tri', '--tripleColumn',default=False,type=int,metavar='',help='default:0 - enable with 1')
	group1.add_argument('-bed', '--bedFile',default='',metavar='',help='')
	group1.add_argument('-hist', '--histograms', nargs='+',metavar='',default=[])
	group1.add_argument('-hl', '--histLabels', nargs='+',metavar='',default=[])
	group1.add_argument('-hm', '--histMax', nargs='+',metavar='',default=[])
	group1.add_argument('-fhist', '--fillHist', nargs='+',metavar='',default=[],help='(0:no, 1:yes)')
	group1.add_argument('-hc', '--histColors', nargs='+',metavar='',default=[])
	group1.add_argument('-b', '--barPlots', nargs='+',metavar='',default=[])
	group1.add_argument('-bl', '--barLabels', nargs='+',metavar='',default=[])
	group1.add_argument('-bc', '--barColors', nargs='+',metavar='',default=[])
	group1.add_argument('-bm', '--barMax', nargs='+',metavar='',default=[])
	group1.add_argument('-t', '--tilePlots', nargs='+',metavar='',default=[])
	group1.add_argument('-tl', '--tileLabels', nargs='+',metavar='',default=[])
	group1.add_argument('-tc', '--tileColors', nargs='+',metavar='',default=[])
	group1.add_argument('-tt', '--tileText',type=int,default=False,metavar='',help="default: 0 - enable with 1")
	group1.add_argument('-a', '--arcPlots', nargs='+',metavar='',default=[])
	group1.add_argument('-al', '--arcLabels', nargs='+',metavar='',default=[])
	group1.add_argument('-ac', '--arcColors', nargs='+',metavar='',default=[])
	group1.add_argument('-high', '--highlights',default=0,type=int,metavar='',help='default:0 - enable with 1')
	group1.add_argument('-hf', '--highFile',default='',metavar='',help='')
	group1.add_argument('-peak', '--peakFiles', nargs='+',metavar='',default=[])
	group1.add_argument('-ep', '--epiLogos',metavar='',default='')
	group1.add_argument('-spi', '--spine',metavar='',type=int,default=False,help="default: 0 - enable with 1")
	group1.add_argument('-im', '--imputed',type=int,default=False,metavar='',help="default: 0 - enable with 1")
	group1.add_argument('-s', '--start',type=int,default=0,metavar='',help="default: 0")
	group1.add_argument('-e', '--end',type=int,default=0,metavar='',help="default: matrix end")
	group1.add_argument('-r', '--resolution',type=int,default=100000,metavar='',help="default: 100000")
	group1.add_argument('-rb', '--randomBins',type=int,default=False,metavar='',help="default: 0 - enable with 1")
	group1.add_argument('-wg', '--wholeGenome',type=int,default=False,metavar='',help="default: 0 - enable with 1")
	group1.add_argument('-w', '--window',type=int,default=5,metavar='',help="default: 5")
	group1.add_argument('-fh', '--fileHeader',type=int,default=1,metavar='',help="default: 1")
	group1.add_argument('-ff', '--fileFooter',type=int,default=0,metavar='',help="default: 0")
	group1.add_argument('-tr', '--tadRange',type=int,default=8,metavar='',help="default: 8")
	group1.add_argument('-hmc', '--heatmapColor',type=int,default=3,metavar='',help="Colors for heatmap: Greys(0), Reds(1), YellowToBlue(2), YellowToRed(3-default), Hot(4), BlueToRed(5)")
	group1.add_argument('-sn', '--smoothNoise',type=float,default=0.5,metavar='',help="default: 0.5")
	group1.add_argument('-mm', '--matrixMax',type=int,default=10,metavar='',help="default: 0")
	group1.add_argument('-cn', '--cleanNANs',type=int,default=True,metavar='',help="default: 1 - disable with 0")
	group1.add_argument('-hR', '--highResolution',type=int,default=True,metavar='',help="default: 1 - disable with 0")
	group1.add_argument('-pi', '--plotInsulation',type=int,default=False,metavar='',help="default: 0 - enable with 1")
	group1.add_argument('-ptr', '--plotTriangular',type=int,default=False,metavar='',help="default: 1 - disable with 0")
	group1.add_argument('-ptd', '--plotTadDomains',type=int,default=False,metavar='',help="default: 0 - enable with 1")
	group1.add_argument('-pcd', '--plotCustomDomains',type=int,default=False,metavar='',help="default: 0 - enable with 1")
	group1.add_argument('-pdb', '--plotDomainsAsBars',type=int,default=False,metavar='',help="default: 0 - enable with 1")
	group1.add_argument('-pcdf', '--customDomainsFile',nargs='+',metavar='',default=[])
	group1.add_argument('-pptd', '--plotPublishedTadDomains',type=int,default=False,metavar='',help="default: 0 - enable with 1")
	group1.add_argument('-ptdo', '--publishedTadDomainOrganism',type=int,default=True,metavar='',help="human(default): 1 - mouse: 0")
	
	args = vars(parser.parse_args())
	
	if len(args['files']) != len(args['names']):
		print >>sys.stderr, 'Upps!! Please provide equal number of HiC matrix and names'
		raise SystemExit
	if len(args['histograms'])>0 and len(args['histograms'])!=len(args['files']):
		print >>sys.stderr, 'Upps!! Please provide equal number of HiC matrix and BedGraphs'
		raise SystemExit
	if len(args['histLabels'])>0 and len(args['histLabels'])!=len(args['files']):
		print >>sys.stderr, 'Upps!! Please provide equal number of HiC matrix and BedGraph Labels'
		raise SystemExit
	if len(args['histograms'])+len(args['histLabels'])+len(args['fillHist'])>0 and len(args['histLabels'])!=len(args['histograms']) and len(args['histLabels'])!=len(args['fillHist']):
		print >>sys.stderr, 'Upps!! Please provide equal number of BedGraphs, BedGraph Labels and FillUnders (0:no, 1:yes)'
		raise SystemExit
	if len(args['barPlots'])>0 and len(args['barPlots'])!=len(args['files']):
		print >>sys.stderr, 'Upps!! Please provide equal number of HiC matrix and bar plots'
		raise SystemExit
	if len(args['barLabels'])>0 and len(args['barLabels'])!=len(args['files']):
		print >>sys.stderr, 'Upps!! Please provide equal number of HiC matrix and bar plot Labels'
		raise SystemExit
	if len(args['barPlots'])+len(args['barLabels'])>0 and len(args['barPlots'])!=len(args['barLabels']):
		print >>sys.stderr, 'Upps!! Please provide equal number of bar plot and bar plot Labels'
		raise SystemExit
	if len(args['barColors'])>0 and len(args['barPlots'])!=len(args['barColors']):
		print >>sys.stderr, 'Upps!! Please provide equal number of bar plot and bar plot colors'
		raise SystemExit
	if len(args['tilePlots'])>0 and len(args['tilePlots'])!=len(args['files']):
		print >>sys.stderr, 'Upps!! Please provide equal number of HiC matrix and tile plots'
		raise SystemExit
	if len(args['tileLabels'])>0 and len(args['tileLabels'])!=len(args['files']):
		print >>sys.stderr, 'Upps!! Please provide equal number of HiC matrix and tile plot Labels'
		raise SystemExit
	if len(args['tilePlots'])+len(args['tileLabels'])>0 and len(args['tilePlots'])!=len(args['tileLabels']):
		print >>sys.stderr, 'Upps!! Please provide equal number of tile plot and tile plot Labels'
		raise SystemExit
	if len(args['tileColors'])>0 and len(args['tilePlots'])!=len(args['tileColors']):
		print >>sys.stderr, 'Upps!! Please provide equal number of tile plot and tile plot colors'
		raise SystemExit
	if len(args['arcPlots'])>0 and len(args['arcPlots'])!=len(args['files']):
		print >>sys.stderr, 'Upps!! Please provide equal number of HiC matrix and arc plots'
		raise SystemExit
	if len(args['arcLabels'])>0 and len(args['arcLabels'])!=len(args['files']):
		print >>sys.stderr, 'Upps!! Please provide equal number of HiC matrix and arc plot Labels'
		raise SystemExit
	if len(args['arcPlots'])+len(args['arcLabels'])>0 and len(args['arcPlots'])!=len(args['arcLabels']):
		print >>sys.stderr, 'Upps!! Please provide equal number of arc plot and arc plot Labels'
		raise SystemExit
	if len(args['arcColors'])>0 and len(args['arcPlots'])!=len(args['arcColors']):
		print >>sys.stderr, 'Upps!! Please provide equal number of arc plot and arc plot colors'
		raise SystemExit
	if args['plotCustomDomains'] and len(args['customDomainsFile'])==0:
		print >>sys.stderr, 'Upps!! Please provide a bedGraph file for custom domains'
		raise SystemExit
	if args['plotCustomDomains'] and len(args['customDomainsFile'])!=len(args['files']):
		print >>sys.stderr, 'Upps!! Please provide equal number of HiC matrix and custom domains'
		raise SystemExit
	if args['start'] < 0 or args['end'] < 0 or args['end'] - args['start'] < 0:
		print >>sys.stderr, 'Upps!! Start and end should be positive and end bigger than start'
		raise SystemExit
	if len(args['peakFiles'])>0 and len(args['peakFiles'])!=len(args['files']):
		print >>sys.stderr, 'Upps!! Please provide equal number of HiC matrix and peak files'
		raise SystemExit
		
	if args['verbose']:
		logging.basicConfig(filename=args['output']+'.log',level=logging.DEBUG,format='%(asctime)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p')
		logging.info('You are using HiCPlotter version:%s',version)
		logging.info('Using arguments: %s',args)
		logging.info('\n#################################\n')
	
	HiCplotter(**args)