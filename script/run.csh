#!/bin/csh
clear
chmod u+x ./script/run.csh

source /CMC/scripts/mentor.questasim.2020.1_1.csh

setenv QUESTA_HOME $CMC_MNT_QSIM_HOME
setenv UVM_HOME $QUESTA_HOME/verilog_src/uvm-1.2

if (! -e work) then
	vlib work
endif

vlog -f ./script/run_all.f


vsim -c top -L $QUESTA_HOME/uvm-1.2 +UVM_TESTNAME="base_test" <<!
run -all
#exit
!
