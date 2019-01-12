pushd ../data
foreach f (mesh.c Mesh.java)
$XMTCM/bin/git_filter --expand=. --xhist=. --xhist_map=$f.map $f > ../src/$f
end
popd
