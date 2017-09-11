#!/usr/bin/tclsh
proc c {} {
  puts " \t >> Compiling project files ..."
  set path_to_projectfiles /home/kamel/dev/demo-dloc/sim/hdl

  vlib work
  vmap work work

  vcom -93 -work work $path_to_projectfiles/bitwidths.vhd
  vcom -93 -work work $path_to_projectfiles/haddocLib/cnn_types.vhd
  vcom -93 -work work $path_to_projectfiles/params.vhd
  vcom -93 -work work $path_to_projectfiles/haddocLib/taps.vhd
  vcom -93 -work work $path_to_projectfiles/haddocLib/neighExtractor.vhd
  vcom -93 -work work $path_to_projectfiles/haddocLib/convElement.vhd
  vcom -93 -work work $path_to_projectfiles/haddocLib/sumElement_single.vhd
  vcom -93 -work work $path_to_projectfiles/haddocLib/sumElement.vhd
  vcom -93 -work work $path_to_projectfiles/haddocLib/firstLayer.vhd
  vcom -93 -work work $path_to_projectfiles/haddocLib/convLayer.vhd
  vcom -93 -work work $path_to_projectfiles/haddocLib/maxPool.vhd
  vcom -93 -work work $path_to_projectfiles/haddocLib/poolH.vhd
  vcom -93 -work work $path_to_projectfiles/haddocLib/poolV.vhd
  vcom -93 -work work $path_to_projectfiles/haddocLib/display_mux.vhd
  vcom -93 -work work $path_to_projectfiles/haddocLib/poolLayer.vhd
  vcom -93 -work work $path_to_projectfiles/haddocLib/to_signedPixel.vhd
  vcom -93 -work work $path_to_projectfiles/cnn_process.vhd
  vcom -93 -work work $path_to_projectfiles/cnn_tb.vhd

}

proc s {} {
  puts " \t >> Performing RTL Sim ..."
  vsim -novopt -t 1ps -gSelection=0 -L cyclonev work.cnn_tb
  run 600000 ns
  vsim -novopt -t 1ps -gSelection=1 -L cyclonev work.cnn_tb
  run 600000 ns
  vsim -novopt -t 1ps -gSelection=2 -L cyclonev work.cnn_tb
  run 600000 ns
  vsim -novopt -t 1ps -gSelection=3 -L cyclonev work.cnn_tb
  run 600000 ns
  vsim -novopt -t 1ps -gSelection=4 -L cyclonev work.cnn_tb
  run 600000 ns
  vsim -novopt -t 1ps -gSelection=5 -L cyclonev work.cnn_tb
  run 600000 ns
  vsim -novopt -t 1ps -gSelection=6 -L cyclonev work.cnn_tb
  run 600000 ns
  vsim -novopt -t 1ps -gSelection=7 -L cyclonev work.cnn_tb
  run 600000 ns
  vsim -novopt -t 1ps -gSelection=8 -L cyclonev work.cnn_tb
  run 600000 ns
  vsim -novopt -t 1ps -gSelection=9 -L cyclonev work.cnn_tb
  run 600000 ns
  vsim -novopt -t 1ps -gSelection=10 -L cyclonev work.cnn_tb
  run 600000 ns
  vsim -novopt -t 1ps -gSelection=11 -L cyclonev work.cnn_tb
  run 600000 ns
  vsim -novopt -t 1ps -gSelection=12 -L cyclonev work.cnn_tb
  run 600000 ns
  vsim -novopt -t 1ps -gSelection=13 -L cyclonev work.cnn_tb
  run 600000 ns
  vsim -novopt -t 1ps -gSelection=14 -L cyclonev work.cnn_tb
  run 600000 ns
  vsim -novopt -t 1ps -gSelection=15 -L cyclonev work.cnn_tb
  run 600000 ns
   
}

proc Q  {} {
 quit -force
}

c
s
Q
