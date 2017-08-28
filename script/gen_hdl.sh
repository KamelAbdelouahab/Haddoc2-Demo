mkdir -p haddocLib
cp $HADDOC2_ROOT/lib/hdl/* haddocLib
$HADDOC2_ROOT/bin/haddoc2 \
--proto=caffe/deploy/test.prototxt \
--model=caffe/deploy/lenet.caffemodel \
--out=hdl \
--nbits=8
