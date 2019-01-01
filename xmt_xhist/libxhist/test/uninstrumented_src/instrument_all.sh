foreach f (*.c)
$XMTCM/bin/git_filter --xhist --xhist_map=../hellofoo.map $f > ../$f
end
