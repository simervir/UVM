#!/bin/csh -f
################################################################################
#
# Copyright 2020-2022 Daniel H.Y. Teng. All Rights Reserved.
#
################################################################################
clear
chmod u+x ./script/run_regression.csh
mkdir ucdb
# Set up Questa SIM
#source /CMC/scripts/mentor.questasim.2019.2.csh
source /CMC/scripts/mentor.questasim.2020.1_1.csh
 
setenv QUESTA_HOME $CMC_MNT_QSIM_HOME
setenv UVM_HOME $QUESTA_HOME/verilog_src/uvm-1.2
# Phase independent
set rootdir = `dirname $0`
set rootdir = `cd $rootdir && pwd`
set script_name = $0:t
#echo script $script_name
set phase_no = `echo $script_name:r | sed -e  s/run_//`
#echo phase $phase_no


set workdir = "$rootdir/../verification/"
if (! -d $workdir ) then
  echo "ERROR: $workdir doesn't exist!"
  exit 0
else
  echo "Working directory: $workdir"
endif


# Phase 9 specific
if ($#argv == 0 || $#argv > 2 ) then
  echo "ERROR: Too many or too few arguments"
  echo "USAGE: $script_name -l | -t <testcase>"
  exit 0
endif

# Avoid hardcoded testcases in this script
#set testcase_list = ( "sanity_check" \
#                      "reset_test" \
#                      "fifo_empty_read" "fifo_full_write" )

# Solution 1: Assume all tests are listed in phase9_testcases/testcase_list 
# 	*** Must update testcase_list when new tests are created. 

# Solution 2: Assume all tests are included in phase9_testcases/test_pkg.svh
#	**** May have to modify pattern match to fit other test names
set testcase_list = `cat $workdir/lab4_pkg.sv | grep "^[ ]*class.* extends test;" | sed -e 's/ *extends *[A-Za-z0-9_]*//' -e 's/class *//g' -e 's/;//g'`

switch ($argv[1])
case "-l":
  if ($#argv > 1) then
      echo "ERROR: Too many arguments"
      exit 0
  else
    echo "List of test cases:"
    @ testcase_no = 0
    foreach testcase ($testcase_list)
      @ testcase_no++
      echo "  $testcase_no : $testcase"
    end
  endif
  breaksw

case "-t":
  # NOTE: $#argv > 2 is already checked at the beginning
  if ($#argv != 2) then 
    echo "ERROR: Too few arguments"
    exit 0
  else if ( "$argv[2]" == "all_test") then
    vlog -f ./script/run_all.f
    set  ucdb_files  = ""
    foreach testcase ($testcase_list)
      echo  $testcase
      vsim -c top -L $QUESTA_HOME/uvm-1.2 +UVM_TESTNAME=$testcase -do "coverage save -onexit ./ucdb/"$testcase"_fcov.ucdb; run -all;exit;"
      set ucdb_files = "${ucdb_files} ./ucdb/${testcase}_fcov.ucdb"
    end
      #vcover merge ./ucdb/lab4_fcov.ucdb ./ucdb/"$testcase"_fcov.ucdb
      vcover merge ./ucdb/lab4_fcov.ucdb $ucdb_files
      vcover report -details ./ucdb/lab4_fcov.ucdb -output ./ucdb/lab4_fcov.html
      vcover report -summary ./ucdb/lab4_fcov.ucdb -output ./ucdb/lab4_fcov.rpt
    
  else
    set test_specified = "$argv[2]"
    set test_exist = `echo $testcase_list | grep "$test_specified"`
    if ("$test_exist" != "") then
      vlog -f ./script/run_all.f
      vsim -c top -L $QUESTA_HOME/uvm-1.2 +UVM_TESTNAME="$test_specified" -do "coverage save -onexit ./ucdb/"$test_specified"_fcov.ucdb; run -all;exit;"
      vcover report -details ./ucdb/"$test_specified"_fcov.ucdb -output ./ucdb/"$test_specified"_fcov.html
      vcover report -summary ./ucdb/"$test_specified"_fcov.ucdb -output ./ucdb/"$test_specified"_fcov.rpt
    else
      echo "ERROR: Testcase $test_specified doesn't exist!"
      exit 0
    endif
  endif
  breaksw
default:    
  echo "ERROR: invalid arguments"
  exit 0
endsw

