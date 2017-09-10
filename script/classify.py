#!/usr/bin/env python
# coding: utf8
import os
import sys
import numpy as np
import matplotlib.pyplot as plt

# Import openCV
sys.path.append('/usr/local/lib/python2.7/dist-packages')
import cv2

# SSIM Metric
from skimage.measure import compare_ssim as ssim
from skimage.measure import compare_psnr as psnr

# Import Caffe, pyCaffe
CAFFE_ROOT		= os.environ['CAFFE_ROOT']
sys.path.insert(0, CAFFE_ROOT +'/python')
import caffe

def loadImage(imagePath):
	imageName = cv2.imread(imagePath);
	imageName = cv2.cvtColor(imageName , cv2.COLOR_BGR2GRAY)
	#~ print (" >> Max value of %s is %d" %(imagePath,np.max(imageName)));
	return imageName.astype("uint8");

def saveImage(imagePath,image):
	cv2.imwrite(image,imagePath);

def showImage(image):
	title = str(image)
	plt.imshow(title, image)
	plt.show()

def padImage(image,p):
	pad_image = cv2.copyMakeBorder(image,p,p,p,p,cv2.BORDER_REPLICATE)
	return pad_image

def extractPatch(data,x,y,patchSize=6):
	patch = data[:,x:x+patchSize , y:y+patchSize];
	return patch;

def normalizeHW(image,scale_factor=127):
	for x in range(image.shape[0]):
		for y in range(image.shape[1]):
			pixelValue = image[x,y] # Coded as 2nd complement
			if (pixelValue>scale_factor): # Negative pixel
				s = pixelValue - 256; 
			else:
				s = pixelValue;
			
			return np.array((scale_factor + s - 1),dtype=float);
    # return np.array(scale_factor + value,dtype=int).astype("uint8");

def reArrange (image,n):
    width = image.shape[1];
    print image[:,n:width].shape
    print image[:,0:n].shape
    newImage = np.concatenate((image[:,n:width],image[:,0:n]),axis=1);
    return newImage;

def caffeForward(data,net):
	net.blobs['data'].data[...]= data
	net.forward()
	return net.blobs['prob'].data
# ---------------------------------------------------------------
if __name__ == '__main__':
	resultPath = 'img/'
	samplePath = 'img/sample.png'
	
	# Load image to test
	sample  = loadImage(samplePath);

    #  Load CNN
	kernels 	    = 'caffe/lenet.caffemodel'
    
    # Feature Extractor
	featExtModel    = 'caffe/lenet_feat_ext.prototxt'
	featExtNet 		= caffe.Net(featExtModel,kernels,caffe.TEST)
	featBlob		= featExtNet.blobs['pool2'].data[0,...];
    
    # Classifier    
	classiferModel  = 'caffe/lenet_classifier.prototxt'
	classiferNet 	= caffe.Net(classiferModel,kernels,caffe.TEST)
	featPatchBlob	= classiferNet.blobs['data'].data[0,...];
	
	feature 		= np.zeros(featBlob.shape);
	featPatch		= np.zeros(featPatchBlob.shape)
	
	# Normalize hw results
	for featureID in range(featBlob.shape[0]):
		feature[featureID,:,:] = loadImage(resultPath + "/feature" + str(featureID) + ".png");
		feature[featureID,:,:] = normalizeHW(feature[featureID,:,:]);
	
	# Input classifier
	stride = 4;
	patchSize=6;
	featSize = 74; #Temporary
	
	
	for x in xrange(0,featSize,stride):
		for y in xrange(0,featSize,stride):		
			featPatch = extractPatch(feature,x,y,patchSize=patchSize)
			#~ print featPatch
			#~ prob = caffeForward(featPatch,classiferNet)
			#~ print prob.argmax()
		#~ print (featPatch[featureID,:,:])
	# FeedForward propgation in classifier
	


