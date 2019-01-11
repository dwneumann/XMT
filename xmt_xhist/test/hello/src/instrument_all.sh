pushd ../data
foreach f (hello.c Main.java)
$XMTCM/bin/git_filter --expand=. --xhist=. --xhist_map=$f.map $f > ../src/$f
end
popd
