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

if __name__ == '__main__':
	samplePath = '/home/kamel/dev/demo-dloc/img/sample.png'
	kernels  = '/home/kamel/caffe/examples/mnist/lenet_iter_10000.caffemodel'
	cnnModel = '/home/kamel/caffe/examples/mnist/lenet_train_test.prototxt'
	cnnNet = caffe.Net(cnnModel,kernels,caffe.TEST)
	cnnNet.forward()
	testData = cnnNet.blobs['data'].data
	
	img = np.zeros((280,280),dtype=float)
	patchNb = 100;
	patchSize = 28;
	patchIndex = 0;
	
	for y in xrange(0,img.shape[0],patchSize):
		for x in xrange(0,img.shape[0],patchSize):
			img[x:x+patchSize,y:y+patchSize] = testData[patchIndex,0]
			patchIndex = patchIndex + 1
	
	#~ img = np.reshape(testData,(img.shape[0],img.shape[1]),order='A')
	img = (255*img).astype('uint8');
	img = cv2.copyMakeBorder(img,1,1,1,1,cv2.BORDER_REPLICATE)
	print img.shape
	cv2.imwrite(samplePath,img);
