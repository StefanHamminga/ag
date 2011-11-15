#!/bin/bash

# Play nice and don't fuck up my movie that is playing at the same time
ionice -c 3 -p $$ > /dev/null
renice -n 5 -p $$ > /dev/null

usage() {
	echo -e "apt-get shortcuts\n"
	echo "Usage:"
	echo "$0 {u|i|a|ui|ua|d|t|r|p|s|v|c} [options]"
	echo -e "\tu\tupdate"
	echo -e "\ti\tinstall [packages]"
	echo -e "\ta\tinstall -y --no-remove [packages]"
	echo -e "\tui\tupdate && install [packages]"
	echo -e "\tua\tupdate && install -y --no-remove [packages]"
	echo -e "\td\tupdate && dist-upgrade"
	echo -e "\tt\tsimulate dist-upgrade"
	echo -e "\tr\tremove [packages]"
	echo -e "\tp\tremove --purge [packages]"
	echo -e "\ts\tsearch for [package regexp.]"
	echo -e "\tv\tDisplay version info for package(s)"
	echo -e "\tc\tautoremove && clean"
}

# Nasty hack to give the search output colors.
# This was taken and modified from an example found on some website, if it was
# you, send me a message and I will properly attribute the part.
sedgrep() {
    C_PATT=`echo -e '\033[33;01m'`
    C_NORM=`echo -e '\033[m'`

    sed -s "s/$1/${C_PATT}&${C_NORM}/gi"
}

checkforroot() {
	if [[ $EUID -ne 0 ]]; then
		echo "This function must be run as root" 1>&2
		usage
		exit 1
	fi
}

case "$1" in
	"u")
	checkforroot
	shift
	apt-get -qq update $@ && echo "Update succesfull"
	;;
	"i")
	checkforroot
	shift
	apt-get install $@
	;;
	"a")
	checkforroot
	shift
	apt-get install -y --no-remove --install-recommends $@
	;;
	"ui")
	checkforroot
	shift
	apt-get -qq update
	apt-get install $@
	;;
	"ua")
	checkforroot
	shift
	apt-get -qq update
	apt-get install -y --no-remove --install-recommends $@
	;;
	"d")
	checkforroot
	shift
	apt-get -qq update && apt-get -qq --no-remove dist-upgrade && echo "Dist upgrade succesfull"
	;;
	"t")
	apt-get -qq update && echo "The following packages would be upgraded:" && apt-get -s -qq --no-remove dist-upgrade | grep ^"Inst" | sed s/"^Inst "// | sort
	;;
	"r")
	checkforroot
	shift
	apt-get remove $@
	;;
	"p")
	checkforroot
	shift
	apt-get remove --purge $@
	;;
	"s")
	shift
	apt-cache search $@ | sedgrep $@ | sort
	;;
	"v")
	shift
	dpkg-query -W *${@}* | sedgrep $@ | sort
	;;
	"c")
	checkforroot
	shift
	apt-get autoremove && apt-get clean
	;;
	*)
	usage
esac
