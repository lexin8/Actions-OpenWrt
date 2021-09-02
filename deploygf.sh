#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
#拉取源码
git clone https://github.com/tuanqing/mknop
git clone https://github.com/openwrt/openwrt
cd openwrt
 sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
./scripts/feeds update -a && ./scripts/feeds install -a
