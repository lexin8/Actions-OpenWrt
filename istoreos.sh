#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
#拉取源码
# git clone https://github.com/lexin8/kernel opt
cd openwrt
# sed -i '$a src-git diy https://github.com/xiaorouji/openwrt-passwall.git;main' feeds.conf.default
# sed -i '$a src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main' feeds.conf.default
sed -i 's/192.168.6.1/192.168.20.1/g' package/base-files/files/bin/config_generate
./scripts/feeds update -a
./scripts/feeds install -a

git clone https://github.com/kenzok8/small-package.git small
pushd package/
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/small/luci-app-istorex .


cd ../
rm -rf small
