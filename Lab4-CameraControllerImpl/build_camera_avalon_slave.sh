#!/bin/bash

mkdir -p vcd
mkdir -p wave

ghdl -a hw/hdl/camera_avalon_slave.vhd
ghdl -a hw/hdl/testbench/camera_avalon_slave_tb.vhd
ghdl -e camera_avalon_slave_tb
ghdl -r camera_avalon_slave_tb --vcd=vcd/slave.vcd --wave=wave/slave.ghw --stop-time=100us
