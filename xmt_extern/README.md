HOW TO INSTALL DEBIAN PACKAGES INTO xmt_extern

cd /$XMTEXT/src;
apt-get download doxygen;       # creates ./doxygen_1.8.13-10ubuntu3_amd64.deb
mkdir -p /tmp/mydir;            # temp extraction directory
dpkg-deb -xv ./doxygen_1.8.13-10ubuntu3_amd64.deb /tmp/mydir;  # extract files
cp -r -i /tmp/mydir/* $XMTEXT;  # install binaries, libs, conf files, man pages ... to here
                                # be careful about overwrites
rm -r /tmp/mydir;               # remove the temp directory

# add newly installed directories to search PATHs
cd $XMTEXT;
echo 'setenv PATH "${PATH}:$XMTEXT/'`find . -name bin`'"' >> proto/cshrc
echo 'setenv LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:$XMTEXT/'`find . -name lib`'"' >> proto/cshrc
echo 'setenv MANPATH "${MANPATH}:$XMTEXT/'`find . -name man`'"' >> proto/cshrc
mandb --debug;                  # rebuild man database. watch for permission denied

# exportfs $XMT so developers can use these binaries without having to install anything
/home/XMT		10.0.0.0/24(ro,sync,no_subtree_check)
