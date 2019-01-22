rm -f *.trace *.out *.log;
$XMTXHIST/test/mesh/test/runmesh --language=java;
$XMTXTEST/bin/xtest --iut "jdb -sourcepath $XMTXHIST/test/mesh/src:$XMTXHIST/libxhist/src -classpath .:$XMTXHIST/test/mesh/$T/Mesh.jar:$XMTXHIST/libxhist/$T/Xhist.jar Mesh 0 10000 10001 10002 10003 10004 10005" --test Mesh.xtest 
