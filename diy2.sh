#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
#拉取源码
git clone https://github.com/kenzok8/small-package.git small
cd openwrt
sed -i 's/192.168.6.1/192.168.20.1/g' package/base-files/files/bin/config_generate
./scripts/feeds update -a
./scripts/feeds install -a

cd package/
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/small/luci-app-istorex .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/small/luci-app-quickstart .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/small/luci-app-store .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/small/luci-lib-taskd .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/small/quickstart .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/small/luci-lib-xterm .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/small/taskd .

ls
