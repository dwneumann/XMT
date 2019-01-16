#!/bin/sh

#  cd to the ../data directory (where the uninstrumented src resides)
#  write instrumented src to ../src directory 
#  write map file to ../test directory 
cd ../data;
for ext in c java 
do
    mapfile=../test/${ext}mesh.map
    for f in *.$ext
    do
	$XMTCM/bin/git_filter --expand=. --xhist=. --xhist_map=$mapfile $f > ../src/$f
    done
done

