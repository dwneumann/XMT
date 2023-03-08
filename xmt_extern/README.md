# HOW TO EXPORT THIRD-PARTY PACKAGES FROM XMT

## Install debian packages and their dependencies into xmt_extern
>
    cd /$XMTEXT/src;
    apt-get update;                             # update apt cache
    set pkg=<package name>;                     # set shell variable to package name
    apt-get download $pkg;                      # download package.deb to xmt_extern/src
    dpkg-deb -I $pkg.deb;                       # list all package's dependencies
    mkdir -p /tmp/mydir;                        # create temp extraction directory
    dpkg-deb -xv ./$pkg.deb /tmp/mydir;         # extract package to safe place
    cp -r -i /tmp/mydir/* $XMTEXT/site;         # install binaries, libs, etc. to here...
                                                # prompt before overwriting
    rm -r /tmp/mydir;                           # remove the temp directory

	# fix broken links from packages that create links to absolute paths
	$XMTUTIL/bin/fixlinks $XMTEXT/site  $XMTEXT/site;

    # repeat the above steps for each package and dependency

## Add newly installed directories to search PATHs
>
    cd $XMTEXT;
    set newpaths = `find ./site -name bin | \
        perl -pe 's{^\./}{\$XMTEXT/}g; s{\n}{:}g' | $XMTUTIL/bin/modenv -s` ;
    echo 'setenv PATH '"$newpaths"':${PATH}' >> ./proto/cshrc ;
    echo 'export PATH='"$newpaths"':${PATH}' >> ./proto/bashrc ;
     
    set newpaths = `find ./site -name "*.so*" | \
        perl -pe 's{/[^/]*$}{:}; s{^\./}{\$XMTEXT/}; s{\n}{:}' | $XMTUTIL/bin/modenv -s` ;
    echo 'setenv LD_LIBRARY_PATH '"$newpaths"':${LD_LIBRARY_PATH}' >> ./proto/cshrc ;
    echo 'export LD_LIBRARY_PATH='"$newpaths"':${LD_LIBRARY_PATH}' >> ./proto/bashrc ;
     
    set newpaths = `find ./site -name man | \
        perl -pe 's{^\./}{\$XMTEXT/}g; s{\n}{:}g' | $XMTUTIL/bin/modenv -s` ;
    echo 'setenv MANPATH '"$newpaths"':${MANPATH}' >> ./proto/cshrc ;
    echo 'export MANPATH='"$newpaths"':${MANPATH}' >> ./proto/bashrc ;
    mandb ;	                  # rebuild man database. watch out for "permission denied" errors


## Exportfs $XMT so developers can use these binaries without having to install anything
>
    sudo echo "$XMT	 10.0.0.0/24(ro,sync,no_subtree_check)" >> /etc/exportfs ;
    sudo exportfs $XMT ;

