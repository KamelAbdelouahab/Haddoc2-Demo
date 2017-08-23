cd GPStudio
rm -rf ./build/
rm -rf *.node
rm -rf Makefile

gpnode newproject -n lenet5
gpnode setboard -n dreamcam_c3
gpnode adddevice -n usb
gpnode adddevice -n mt9

gpnode addprocess -n lenet5 -d cnn.proc

gpnode connect -f mt9.out -t lenet5.in
gpnode connect -f mt9.out -t usb.in0
gpnode connect -f lenet5.out -t usb.in1


gpnode setproperty -n mt9.roi1.h -v 644
gpnode setproperty -n mt9.roi1.w -v 644
gpnode setproperty -n mt9.exposuretime -v 300
gpnode setproperty -n lenet5.enable -v 1

gpnode generate -o ./build

cd -
echo Succefully Generated Node ...
# make compile send
# make compile send view
