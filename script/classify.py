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
	image = cv2.imread(imagePath);
	image = cv2.cvtColor(image , cv2.COLOR_BGR2GRAY)
	#~ print (" >> Max value of %s is %d" %(imagePath,np.max(image)));
	return image;

def saveImage(imagePath,image):
	cv2.imwrite(image,imagePath);

def showImage(image):
	title = str(image)
	cv2.imshow(title, image)
	cv2.waitKey(0)
	cv2.destroyAllWindows()

def padImage(image,p):
	pad_image = cv2.copyMakeBorder(image,p,p,p,p,cv2.BORDER_REPLICATE)
	return pad_image

def extractPatch(data,x,y,patchSize=6):
	patch = data[:,x:x+patchSize , y:y+patchSize];
	return patch;

def normalizeHW(image,scale_factor=127):
	for x in range(image.shape[0]):
		for y in range(image.shape[1]):
			pixelValue = image[x,y] # Coded as 2 complement
			if (pixelValue>scale_factor): # Negative pixel
				s = pixelValue - 256.0; 
			else:
				s = pixelValue;
			
			image[x,y] = scale_factor + s - 1.0
			#~ print image.dtype
	return np.true_divide(image,scale_factor);
    

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
	
	feature 		= np.zeros(featBlob.shape,dtype=int).astype('uint8');
	featureNormed	= np.zeros(featBlob.shape,dtype=float)
	featPatch		= np.zeros(featPatchBlob.shape)
	
	# Normalize hw results
	for featureID in range(featBlob.shape[0]):
		#~ feature[featureID,:,:] = loadImage(resultPath + "/feature" + str(featureID) + ".png");
		feature[featureID,:,:] = loadImage(resultPath + "/featureSim" + str(featureID) + ".pgm");
		featureNormed[featureID,:,:] = normalizeHW(feature[featureID,:,:]);
		
	
	# Input classifier
	stride = 5;
	patchSize=6;
	featSize = 79; #Temporary
	predictions = [];
	probs = [];
	
	for y in xrange(0,featSize,stride):
		print y
		for x in xrange(0,featSize-5,stride):		
			featPatch = extractPatch(featureNormed,x,y,patchSize=patchSize)
			#~ print featPatch.shape
			# FeedForward propgation in classifier
			prob 		= caffeForward(featPatch,classiferNet)
			prediction  = prob.argmax()
			probs 		= np.append(probs,np.amax(prob))
			predictions = np.append(predictions,prediction);
	
	#~ print probs
	#~ print predictions.shape
	predMapSize 	= np.sqrt(predictions.shape[0])
	predictionMap 	= np.reshape(predictions,(predMapSize,predMapSize))
	probaMap 		= np.reshape(probs,(predMapSize,predMapSize))
	
	print predictionMap.astype('uint8');		
	print np.array_str(probaMap, precision=1, suppress_small=True)		

	
	


