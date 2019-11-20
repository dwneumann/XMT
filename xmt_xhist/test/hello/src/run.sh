#!/bin/sh

export O=obj/$XMTBUILD_DFLT_ARCH;
export T=tgt/$XMTBUILD_DFLT_ARCH;

#  cd to the directory where we want the trace file to end up, 
#  then run the executable from there.
if [ "$1" = "c" ] ;then
    cd ../$T;
    hello
elif [ "$1" = "java" ]; then
    cd ../$O;
    java -cp .:$XMTXHIST/libxhist/$T/Xhist.jar   Hello 
fi
