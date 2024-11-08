#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
#拉取源码
sed -i 's/192.168.6.1/192.168.20.1/g' package/base-files/files/bin/config_generate
./scripts/feeds update -a
./scripts/feeds install -a

git clone https://github.com/kenzok8/small-package.git small
pushd package/
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/small/luci-app-istorex .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/small/luci-app-quickstart .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/small/luci-app-store .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/small/luci-lib-taskd .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/small/quickstart .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/small/luci-lib-xterm .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/small/taskd .



cd ../
rm -rf small
