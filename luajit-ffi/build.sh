#!/bin/bash


#uncomment main function
#gcc libvideometa.c -o videometa -I/usr/local/include  -lavformat -lavdevice  -lavcodec -lavutil  -lavfilter  -lswresample -lswscale -lm -llzma -lbz2 -lz -pthread
#valgrind --tool=memcheck ./videometa  xxxx.mp4


gcc  libvideometa.c -shared -O2 -fPIC -o libvideometa.so 


