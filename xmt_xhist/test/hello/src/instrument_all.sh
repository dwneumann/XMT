#!/bin/sh

export O=../obj/$XMTBUILD_DFLT_ARCH;
export T=../tgt/$XMTBUILD_DFLT_ARCH;

#  cd to the ../data directory (where the uninstrumented src resides)
#  we want the instrumented src output to ../src/ and the map file 
#  written to the directory where the executable resides.
cd ../data;
f=hello.c
$XMTCM/bin/git_filter --expand=. --xhist=. --xhist_map=$f.map $f > ../src/$f
f=Hello.java
$XMTCM/bin/git_filter --expand=. --xhist=. --xhist_map=$f.map $f > ../src/$f
