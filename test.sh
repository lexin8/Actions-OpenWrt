#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
#拉取源码
git clone https://github.com/coolsnowwolf/packages packages
cd openwrt
sed -i 's/192.168.6.1/192.168.20.1/g' package/base-files/files/bin/config_generate


cd feeds/packages/net/
rm -rf nfs-kernel-server
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/packages/net/nfs-kernel-server .

