#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import sys
import os
import io
import numpy as np
import math

# Import caffe : defined in CAFFE_ROOT environment variable
CAFFE_ROOT       = os.environ['CAFFE_ROOT']
CAFFE_PYTHON_LIB = CAFFE_ROOT+'/python'
sys.path.insert(0, CAFFE_PYTHON_LIB)
os.environ['GLOG_minloglevel'] = '2' # Supresses Display on console
import caffe;

proto = 'caffe/deploy/fc.prototxt';
model = 'caffe/deploy/lenet.caffemodel';

net = caffe.Net(proto,model,caffe.TEST);
print 'Layer' + '\t|\t' + 'N' + '\t|\t' + 'Feature'
print '-----' + '\t|\t' + '--' + '\t|\t' + '-------'


for b in net.blobs.keys():
    n = net.blobs[b].data.shape[1]
    if ('ip' in b or 'fc' in b or 'prob' in b):
        i = 1
    else:
        i = net.blobs[b].data.shape[2]
    print b + '\t|\t' + str(n) + '\t|\t' + str(i) + 'x' + str(i)


