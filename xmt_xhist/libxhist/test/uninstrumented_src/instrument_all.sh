foreach f (*.c)
$XMTCM/bin/git_filter --expand --xhist $f > ../$f
end
