purge:
	rm -rf node
hdl:
	mkdir -p node/hdl
	$(HADDOC2_ROOT)/bin/haddoc2 \
	--proto=caffe/lenet_feat_ext.prototxt \
	--model=caffe/lenet.caffemodel \
	--out=node/hdl \
	--nbits=8
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
all: purge hdl proc demo



