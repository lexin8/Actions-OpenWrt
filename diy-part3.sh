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
# mv2 index.htm package/lean/autocore/files/x86
# mv2 luci.mk feeds/luci
# mv2 adbyby package/lean/luci-app-adbyby-plus/root/etc/config
# mv2 passwall feeds/diy1/luci-app-passwall/root/etc/config
# mv2 white.list package/helloworld/luci-app-ssr-plus/root/etc/ssrplus
# mv2 black.list package/helloworld/luci-app-ssr-plus/root/etc/ssrplus
# mv2 shadowsocksr package/helloworld/luci-app-ssr-plus/root/etc/config
# mv2 sysctl.conf etc/
# mv2 hostname etc/

# ExtraPackages git openwrt-upx https://github.com/Hyy2001X master
# ExtraPackages svn luci-app-mentohust https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw
# ExtraPackages svn mentohust https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw
# ExtraPackages svn luci-theme-opentomato https://github.com/kenzok8/openwrt-packages/trunk
# ExtraPackages svn luci-theme-opentomcat https://github.com/kenzok8/openwrt-packages/trunk
# ExtraPackages svn luci-app-adguardhome https://github.com/Lienol/openwrt/trunk/package/diy
# ExtraPackages git luci-app-adguardhome https://github.com/rufengsuixing master
# ExtraPackages git openwrt-OpenAppFilter https://github.com/Lienol master
}
