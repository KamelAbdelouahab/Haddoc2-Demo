mkdir -p sim
cd sim
rm -rf simbuild
rm -rf Makefile
gpproc generatetb
cp in.stim simbuild/in.stim
make all
cd -
