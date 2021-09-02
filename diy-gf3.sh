#!/bin/bash
# https://github.com/Hyy2001X/AutoBuild-Actions
# AutoBuild Module by Hyy2001
# AutoBuild Actions



mv2() {
if [ -f $GITHUB_WORKSPACE/Customize/$1 ];then
	echo "[$(date "+%H:%M:%S")] File [$1] is detected!"
	if [ -z $2 ];then
		Patch_Dir=$GITHUB_WORKSPACE/openwrt
	else
		Patch_Dir=$GITHUB_WORKSPACE/openwrt/$2
	fi
	[ ! -d $Patch_Dir ] && mkdir -p $Patch_Dir
	if [ -z $3 ];then
		[ -f $Patch_Dir/$1 ] && rm -f $Patch_Dir/$1 > /dev/null 2>&1
		mv -f $GITHUB_WORKSPACE/Customize/$1 $Patch_Dir/$1
	else
		[ -f $Patch_Dir/$1 ] && rm -f $Patch_Dir/$3 > /dev/null 2>&1
		mv -f $GITHUB_WORKSPACE/Customize/$1 $Patch_Dir/$3
	fi
else
	echo "[$(date "+%H:%M:%S")] File [$1] is not detected!"
fi
}

Diy-Part1() {
# [ ! -d ./package/lean ] && mkdir ./package/lean

# mv2 feeds.conf.default
# mv2 AutoUpdate.sh package/base-files/files/bin
mv2 banner package/base-files/files/etc
mv2 luci.mk feeds/luci
mv2 target.mk include
mv2 adbyby package/lean/luci-app-adbyby-plus/root/etc/config
mv2 sysctl.conf etc/

}
