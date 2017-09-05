cd node
rm -rf ./build/
rm -rf *.node
rm -rf Makefile

gpnode newproject -n demo
gpnode setboard -n dreamcam_c3
gpnode adddevice -n usb

gpnode addprocess -n lenet5 -d cnn.proc

gpnode connect -f usb.out0 -t usb.in0
gpnode connect -f usb.out1 -t lenet5.in
gpnode connect -f lenet5.out -t usb.in1

gpnode generate -o ./build

echo Succefully Generated Node ...
make printfi
# make compile send
# make compile send view
