pushd ../data
foreach f (*.c)
$XMTCM/bin/git_filter --expand=. --xhist=. $f > ../src/$f
end
popd
