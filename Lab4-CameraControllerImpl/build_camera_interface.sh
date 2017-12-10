#!/bin/bash

mkdir -p vcd
mkdir -p wave

ghdl -a hw/hdl/camera_interface.vhd
ghdl -a hw/hdl/testbench/camera_interface_tb.vhd
ghdl -e camera_interface_tb
ghdl -r camera_interface_tb --vcd=vcd/camif.vcd --wave=wave/camif.ghw --stop-time=100us
