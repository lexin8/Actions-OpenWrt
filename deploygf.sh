#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
#拉取源码
git clone https://github.com/tuanqing/mknop
git clone https://github.com/openwrt/openwrt
git clone https://github.com/coolsnowwolf/lede
cd openwrt
./scripts/feeds update -a && ./scripts/feeds install -a
cd package
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/lede/package/lean .
