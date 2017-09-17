# -*- coding: utf-8 -*-

from PIL import Image as Image
import numpy as np
import math
import os,sys
import compare
import matplotlib.pyplot as plt
sys.path.append('/usr/local/lib/python2.7/dist-packages')
import cv2

def softmaxFunction(x):
    # e = np.exp(x)
    e = np.exp(x-np.max(x))
    s = e / np.sum(e)
    return s

def classifyRegion(x):
    s   = softmaxFunction(x);
    cla = np.argmax(s);
    return cla;

def probRegion(x):
    s   = softmaxFunction(x);
    p = np.max(s);
    return p;

def classifyMap(fcFilename,fcShape):
    fcData = np.zeros(fcShape)
    #Load fcdata in numpy array
    for fcIndex in range(fcShape[0]):
        imgName = fcFilename + str(fcIndex) + ".png"
        fcData[fcIndex,:,:] = compare.loadImage(imgName);
        # [0:255] -> [-127:127]
        fcData[fcIndex,:,:] = fcData[fcIndex,:,:] - 127;

    regionVector = np.zeros(fcShape[0])
    classMap     = np.zeros((fcShape[1],fcShape[2]),dtype=int)

    for i in range(fcShape[1]):
        for j in range(fcShape[2]):
            for fcIndex in range(fcShape[0]):
                regionVector[fcIndex] = fcData[fcIndex,i,j];
            classMap[i,j] = classifyRegion(regionVector)
    return classMap;

def probMap(fcFilename,fcShape):
    fcData = np.zeros(fcShape)
    #Load fcdata in numpy array
    for fcIndex in range(fcShape[0]):
        imgName = fcFilename + str(fcIndex) + ".png"
        fcData[fcIndex,:,:] = compare.loadImage(imgName);
        # [0:255] -> [-127:127]
        fcData[fcIndex,:,:] = fcData[fcIndex,:,:] - 127;

    regionVector  = np.zeros(fcShape[0])
    probMap_value = np.zeros((fcShape[1],fcShape[2]),dtype=int)

    for i in range(fcShape[1]):
        for j in range(fcShape[2]):
            for fcIndex in range(fcShape[0]):
                regionVector[fcIndex] = fcData[fcIndex,i,j];
            probMap_value[i,j] = 100*probRegion(regionVector)
    return probMap_value;


def tpr(A,B):
    tp = 0;
    for i in range(A.shape[0]):
        if (A[i] == B[i]):
            tp = tp + 1;
    return tp;


if __name__ == '__main__':
    swPath = "../result/sw_fc"
    hwPath = "../result/hw_fc"
    labelPath  = '../result/label.npy'
    predPath  = './pred.npy'
    fcShape = (10,74,74)


    # Prepare Data for classif
    hwClass = classifyMap(hwPath,fcShape)
    swClass = classifyMap(swPath,fcShape)

    swClass_ns = np.zeros((100),dtype=int)
    hwClass_ns = np.zeros((100),dtype=int)


    # Generates classification with 8 pixels stride (10x10 image)
    i = 0;
    for x in xrange(0,74,8):
        for y in xrange(0,74,8):
            swClass_ns[i] = swClass[x,y]
            hwClass_ns[i] = hwClass[x,y]
            i = i+1;

    # Computes and prints TPR
    label  = np.load(labelPath)
    sw_tpr = tpr(swClass_ns,label);
    hw_tpr = tpr(hwClass_ns,label);
    kk_tpr = tpr(hwClass_ns,swClass_ns)
    print ('SW TPR = %d'%sw_tpr)
    print ('HW TPR = %d'%hw_tpr)
    print ('KK TPR = %d'%kk_tpr)

    # Generates Classification map
    label      = np.reshape(label,[10,10])
    swClass_ns = np.reshape(swClass_ns,[10,10])
    hwClass_ns = np.reshape(hwClass_ns,[10,10])

    print hwClass_ns
    # fig = plt.figure("Hardware vs Software Classification")
    # ax = fig.add_subplot(1,2,1)
    # plt.imshow(hwClass_ns, vmin = 0, vmax = 9)
    # plt.colorbar()
    # ax = fig.add_subplot(1,2,2)
    # plt.imshow(swClass_ns, vmin = 0, vmax = 9)
    # plt.colorbar()
    # plt.show()

    # miss_class = np.abs(hwClass_ns - swClass_ns);
    # for i in range(miss_class.shape[0]):
    #     for j in range(miss_class.shape[1]):
    #         if (miss_class[i,j] != 0):
    #             miss_class[i,j] = 1;
    #
    #
    # fig = plt.figure("Hardware vs Software Classification")
    # plt.imshow(miss_class, vmin = 0, vmax = 1)
    # plt.colorbar()
    # plt.show()

        # Probability of Presence
    hwProb = probMap(hwPath,fcShape);
    swProb = probMap(swPath,fcShape);
    #
    #     # Plot Probability map
    # fig = plt.figure("Hardware vs Software probs")
    # ax = fig.add_subplot(1,2,1)
    # plt.imshow(hwProb,vmin = 0, vmax = 100)
    # plt.colorbar()
    # ax = fig.add_subplot(1,2,2)
    # plt.imshow(swProb,vmin = 0, vmax = 100)
    # plt.colorbar()
    # plt.show()

    S = 4;
    K = 30;
    W = 322;

    real_map = np.zeros((W,W),dtype=int);
    for X in xrange(0,W,S):
        x = (X-K)/S;
        for Y in xrange(0,W,S):
            y = ((Y-K)/S);
            real_map[X:X+K,Y:Y+K] = hwProb[x,y];


        # Plot Probability map
    fig = plt.figure("Agagag")
    plt.imsave("../result/hw_prob.png", real_map, vmin = 0, vmax = 100)
    # plt.imshow(real_map,vmin = 0, vmax = 100)
    # #plt.colorbar()
    # plt.axis("off")
    # plt.show()

    background = Image.open("../result/sampleSW.png")
    overlay = Image.open("../result/hw_prob.png")
    background = background.convert("RGBA")
    overlay = overlay.convert("RGBA")
    new_img = Image.blend(background, overlay, 0.45)
    new_img.save("../result/sample_HW.png","PNG")
