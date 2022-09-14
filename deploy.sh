#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
#拉取源码
git clone https://github.com/lexin8/kernel opt
git clone https://github.com/tuanqing/mknop
git clone https://github.com/coolsnowwolf/lede openwrt
cd openwrt
# git reset --hard a0cac9a
# sed -i '$a src-git diy1 https://github.com/xiaorouji/openwrt-passwall.git;main' feeds.conf.default
./scripts/feeds update -a
./scripts/feeds install -a

