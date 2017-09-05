mkdir -p node/hdl/haddocLib
cp $HADDOC2_ROOT/lib/hdl/* node/hdl/haddocLib
cp etc/deploy.proc node/cnn.proc
cp etc/cnn_slave.vhd node/hdl/cnn_slave.vhd
cp etc/cnn.vhd node/hdl/cnn.vhd
