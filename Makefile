purge:
	rm -rf node
hdl:
	mkdir -p node/hdl
	python3 $(HADDOC2_ROOT)/lib/haddoc2.py \
	--proto=caffe/lenet_feat_ext.prototxt \
	--model=caffe/lenet.caffemodel \
	--out=node/hdl \
	--nbits=5
proc:
	mkdir -p node/hdl/haddocLib
	cp $(HADDOC2_ROOT)/lib/hdl/* node/hdl/haddocLib
	cp etc/deploy.proc node/cnn.proc
	cp etc/cnn_slave.vhd node/hdl/cnn_slave.vhd
	cp etc/cnn.vhd node/hdl/cnn.vhd
.ONESHELL:
demo:
	cd node/
	gpnode newproject -n demo
	gpnode setboard -n dreamcam_c3
	gpnode adddevice -n usb
	gpnode adddevice -n mt9
	gpnode addprocess -n lenet5 -d cnn.proc
	gpnode connect -f usb.out0 -t lenet5.in
	gpnode connect -f lenet5.out -t usb.in1
	gpnode setproperty -n lenet5.enable -v 1
	gpnode generate -o ./build
mt9:
	mkdir -p node_mt9/hdl
	$(HADDOC2_ROOT)/bin/haddoc2 \
	--proto=caffe/lenet_feat_ext.prototxt \
	--model=caffe/lenet.caffemodel \
	--out=node_mt9/hdl \
	--nbits=8
	mkdir -p node_mt9/hdl/haddocLib
	cp $(HADDOC2_ROOT)/lib/hdl/* node_mt9/hdl/haddocLib
	cp etc/deploy.proc node_mt9/cnn.proc
	cp etc/cnn_slave.vhd node_mt9/hdl/cnn_slave.vhd
	cp etc/cnn.vhd node_mt9/hdl/cnn.vhd
	cd node_mt9/
	gpnode newproject -n demo
	gpnode setboard -n dreamcam_c3
	gpnode adddevice -n usb
	gpnode adddevice -n mt9
	gpnode addprocess -n lenet5 -d cnn.proc
	gpnode connect -f mt9.out -t lenet5.in
	gpnode connect -f mt9.out -t usb.in0
	gpnode connect -f lenet5.out -t usb.in1
	gpnode generate -o ./build
all: purge hdl proc demo
