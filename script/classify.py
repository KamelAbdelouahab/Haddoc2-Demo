#!/usr/bin/env python
# coding: utf8
import os
import sys
import numpy as np
import matplotlib.pyplot as plt

# Import openCV
sys.path.append('/usr/local/lib/python2.7/dist-packages')
import cv2

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
	if (data.ndim ==3):
		patch = data[:,x:x+patchSize , y:y+patchSize];
	else:
		patch = data[x:x+patchSize , y:y+patchSize];
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
    newImage = np.concatenate((image[:,n:width],image[:,0:n]),axis=1);
    return newImage;

def caffeForward(data,net):
	net.blobs['data'].data[...]= data
	net.forward()
	return net.blobs['prob'].data

def tpr(A,B):
    tp = 0;
    a = A.flatten();
    b = B.flatten();
    for i in range(a.shape[0]):
        if (a[i] == b[i]):
            tp = tp + 1;
    return tp;	
# ---------------------------------------------------------------
if __name__ == '__main__':
	resultPath = 'img/'
	samplePath = 'img/sample.png'
	
	# Test Hardware Implementation
	# Load image to test
	sample  = loadImage(samplePath);

    #  Load Kernels
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
		feature[featureID,:,:] = loadImage(resultPath + "/feature" + str(featureID) + ".png");
		#~ feature[featureID,:,:] = loadImage(resultPath + "/featureSim" + str(featureID) + ".pgm");
		featureNormed[featureID,:,:] = normalizeHW(feature[featureID,:,:]);
		featureNormed[featureID,:,:] = reArrange(featureNormed[featureID,:,:],1);
		
	
	# Input classifier
	stride = 7;
	patchSize=6;
	featSize = 69; #Temporary
	predictions = [];
	probs = [];
	
	for y in xrange(0,featSize,stride):
		for x in xrange(0,featSize,stride):		
			featPatch = extractPatch(featureNormed,x,y,patchSize=patchSize)
			# FeedForward propgation in classifier
			prob 		= caffeForward(featPatch,classiferNet)
			prediction  = prob.argmax()
			probs 		= np.append(probs,np.amax(prob))
			predictions = np.append(predictions,prediction);
	
	predMapSize 	= 10
	predictionMap 	= np.reshape(predictions,(predMapSize,predMapSize)).T
	probaMap 		= np.reshape(probs,(predMapSize,predMapSize)).T
	
	print predictionMap.astype('uint8');		
	print np.array_str(probaMap, precision=1, suppress_small=True)		

	#~ labels = np.load('/home/kamel/dev/demo-dloc/img/label.npy');
	#~ labels = np.reshape(labels,(predMapSize,predMapSize))
	#~ print labels
	#~ print tpr(labels,predictionMap)

	# --------------------------------------------------------------------------------------
	# Test Software implementation 
	deployModel    = 'caffe/lenet.prototxt'
	deployNet 		= caffe.Net(deployModel,kernels,caffe.TEST)
	# Input classifier
	stride = 28;
	patchSize=28;
	sampleSize = sample.shape[0]-2; #Temporary
	swPredictions = [];
	swProbs = [];
	
	sampleNormed = np.true_divide(sample,255)
	for y in xrange(0,sampleSize,stride):
		for x in xrange(0,sampleSize,stride):		
			samplePatch = extractPatch(sampleNormed,x,y,patchSize=patchSize)
			# FeedForward propgation in classifier
			swProb 		  = caffeForward(samplePatch,deployNet)
			swPrediction  = swProb.argmax()
			swProbs 	  = np.append(swProbs,np.amax(swProb))
			swPredictions = np.append(swPredictions,swPrediction);	
	
	print swPredictions.shape
	swPredMapSize 	= 10
	swPredictionMap = np.reshape(swPredictions,(predMapSize,predMapSize)).T
	swProbaMap 		= np.reshape(swProbs,(predMapSize,predMapSize)).T
	
	print swPredictionMap.astype('uint8');		
	print np.array_str(swProbaMap, precision=1, suppress_small=True)		

