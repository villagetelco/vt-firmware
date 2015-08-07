#!/usr/bin/env bash

USAGE1="Usage: ./GetGitVersions <REVISION>   Output: gitlog.txt, gitlog.bak.txt, feeds.conf.default.txt"
USAGE2="Example: ./GetGitVersions 15.05 "

if (( $# < 1 ))
then
	echo " "
	echo "Error. Not enough arguments."
	echo $USAGE1
	echo $USAGE2
        echo "********** Failed "
	exit 1
elif (( $# > 1 ))
then
	echo " "
	echo "Error. Too many arguments."
	echo $USAGE1
	echo $USAGE2
        echo "********** Failed  "
	exit 2
elif [ $1 == "--help" ]
then
	echo " "
	echo $USAGE1
	echo $USAGE2
        echo "********** Failed  "
	exit 3
fi

REVISION=$1
REV="for-$REVISION"

# Backup logfile
mv gitlog.txt gitlog.bak.txt

echo "Get Git commit IDs and create Git log file"

printf "Details of Git repos installed\n" > gitlog.txt

printf "###########\n OpenWrt\n" >> gitlog.txt
SHA_OPENWRT=`git    log -n 1 --abbrev-commit| grep -A 3 commit | tee -a gitlog.txt | grep commit | cut -d " " -f 2`

printf "###########\n Packages\n" >> gitlog.txt
SHA_PACKAGES=`git -C ./feeds/packages   log -n 1 --abbrev-commit| grep -A 3 commit | tee -a gitlog.txt | grep commit | cut -d " " -f 2`

printf "###########\n Telephony\n" >> gitlog.txt
SHA_TELEPHONY=`git -C ./feeds/telephony   log -n 1 --abbrev-commit| grep -A 3 commit | tee -a gitlog.txt | grep commit | cut -d " " -f 2`

printf "###########\n FXS\n" >> gitlog.txt
SHA_FXS=`git -C ./feeds/fxs   log -n 1 --abbrev-commit| grep -A 3 commit | tee -a gitlog.txt | grep commit | cut -d " " -f 2`

printf "###########\n Routing\n" >> gitlog.txt
SHA_ROUTING=`git -C ./feeds/routing   log -n 1 --abbrev-commit| grep -A 3 commit | tee -a gitlog.txt | grep commit | cut -d " " -f 2`

printf "###########\n Alfred\n" >> gitlog.txt
SHA_ALFRED=`git -C ./feeds/alfred   log -n 1 --abbrev-commit| grep -A 3 commit | tee -a gitlog.txt | grep commit | cut -d " " -f 2`


echo "*** Generate new feeds.conf.default"

cat > feeds.conf.default.txt << EOF

# Package feeds

#src-git packages https://github.com/openwrt/packages.git;$REV
src-git packages https://github.com/openwrt/packages.git^$SHA_PACKAGES

#src-git telephony https://github.com/openwrt/telephony.git;$REV
src-git telephony https://github.com/openwrt/telephony.git^$SHA_TELEPHONY

#src-git fxs git://github.com/villagetelco/vt-fxs-packages.git
src-git fxs git://github.com/villagetelco/vt-fxs-packages.git^$SHA_FXS

#src-git routing https://github.com/openwrt-routing/packages.git;$REV
src-git routing https://github.com/openwrt-routing/packages.git^$SHA_ROUTING

#src-git alfred git://git.open-mesh.org/openwrt-feed-alfred.git
src-git alfred git://git.open-mesh.org/openwrt-feed-alfred.git^$SHA_ALFRED

EOF

echo "End of script "

