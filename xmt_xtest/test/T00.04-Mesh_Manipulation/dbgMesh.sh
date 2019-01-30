# clean up old output files
rm -f *.trace *.out *.log;

# start all mesh nodes other than the one under test
$XMTXHIST/test/mesh/test/runmesh --language=java;	

# now start the implementation under test.
perl -d $XMTXTEST/bin/xtest --iut "jdb -sourcepath $XMTXHIST/test/mesh/src:$XMTXHIST/libxhist/src -classpath .:$XMTXHIST/test/mesh/$T/Mesh.jar:$XMTXHIST/libxhist/$T/Xhist.jar Mesh 0 10000 10001 10002 10003 10004 10005" --test $XMTXTEST/test/T00.04-Mesh_Manipulation/T00.04.xtest  --verbose
