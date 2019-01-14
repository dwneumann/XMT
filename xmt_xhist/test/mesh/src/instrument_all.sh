#!/usr/bin/tcsh
pushd ../data
foreach f ( mesh.c )
$XMTCM/bin/git_filter --expand=. --xhist=. --xhist_map=../test/$f.map ../data/$f > ../src/$f
end
popd
