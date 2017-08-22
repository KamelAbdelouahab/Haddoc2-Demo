import sys
import os
import io
import numpy as np
import math

# Import caffe : defined in CAFFE_ROOT environment variable
CAFFE_ROOT       = os.environ['CAFFE_ROOT']
CAFFE_PYTHON_LIB = CAFFE_ROOT+'/python'
sys.path.insert(0, CAFFE_PYTHON_LIB)
import caffe;

proto = './test.prototxt';
model = './lenet.caffemodel';

net = caffe.Net(proto,model,caffe.TEST);

for b in net.blobs.keys():
	print net.blobs[b].data.shape



