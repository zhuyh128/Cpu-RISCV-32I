#!/bin/sh
# build testcase
sudo cp ./test/$@.c/test.bin ./test/test.bin
# copy test input
if [ -f ./testcase/$@.in ]; then cp ./testcase/$@.in ./test/test.in; fi
# copy test output
if [ -f ./testcase/$@.ans ]; then cp ./testcase/$@.ans ./test/test.ans; fi
# add your own test script here
# Example: assuming serial port on /dev/ttyUSB1
sudo sh ctrl/build.sh
# modify to my port
sudo ./ctrl/run.sh ./test/test.bin ./test/test.in /dev/ttyS6 -I
