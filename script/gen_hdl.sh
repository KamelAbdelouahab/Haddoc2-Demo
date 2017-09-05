mkdir -p node/hdl

$HADDOC2_ROOT/bin/haddoc2 \
--proto=caffe/lenet_feat_ext.prototxt \
--model=caffe/lenet.caffemodel \
--out=node/hdl \
--nbits=8
