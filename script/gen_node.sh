cd node
#~ rm -rf ./build/
#~ rm -rf *.node
#~ rm -rf Makefile

gpnode newproject -n demo
gpnode setboard -n dreamcam_c3
gpnode adddevice -n usb
gpnode adddevice -n mt9

gpnode addprocess -n lenet5 -d cnn.proc

gpnode connect -f usb.out0 -t lenet5.in
gpnode connect -f lenet5.out -t usb.in1
gpnode setproperty -n lenet5.enable -v 1

gpnode generate -o ./build

echo Succefully Generated Node ...
# make printfi
# make compile send
# make compile send view
