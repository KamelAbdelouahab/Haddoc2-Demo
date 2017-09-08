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
	print (" >> Max value of %s is %d" %(imagePath,np.max(imageName)));
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

def extractPatch(image,x,y,patchSize=30,tmpName='./tmpPatch.png'):
	patch = image[x:x+patchSize , y:y+patchSize];
	cv2.imwrite(tmpName,patch);
	return tmpName;

def normalizeHW(value,scale_factor=127):
    ## comp2
    if (value>scale_factor):
        s = np.array(value - 256);
    else:
        s=np.array(value);
    return np.array(scale_factor + s - 1,dtype=int).astype("uint8");
    # return np.array(scale_factor + value,dtype=int).astype("uint8");

def reArrange (image,n):
    width = image.shape[1];
    print image[:,n:width].shape
    print image[:,0:n].shape
    newImage = np.concatenate((image[:,n:width],image[:,0:n]),axis=1);
    return newImage;

def caffeFCForward(data,net):
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
    featExtModel    = 'caffe/lenet_feat_ext.prototxt'
    classiferModel  = 'caffe/lenet_classifier.prototxt'
    kernels 	    = 'caffe/lenet.caffemodel'
    net = caffe.Net(featExtModel,kernels,caffe.TEST)
    features = net.blobs['pool2'].data[0,...];
    hw = np.zeros(features.shape)
	
    # Normalize hw result and write into png
    for neuron in range(features.shape[0]):
        hw[neuron,:,:] = loadImage(resultPath + "/feature" + str(neuron) + ".png");
        for x in range(hw.shape[1]):
            for y in range(hw.shape[2]):
                hw[neuron,x,y] = normalizeHW(hw[neuron,x,y]).astype("uint8");
        saveImage(hw[neuron,:,:],resultPath + "/featNormed" + str(neuron) + ".png")
    
	# Read featNormed
	feature= np.zeros(16,6,6)
	#~ dummyFeature = np.zeros(79,79)
	for featIndex in range (0,16):
		fileName = resultPath+"featNormed"+str(featIndex)+".png"
		dummyFeature = loadImage(fileName);
		feature[0,featIndex,:,:] = dummyFeature[0:6,0:6];
