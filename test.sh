#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
#拉取源码
git clone https://github.com/lexin8/kernel opt
git clone https://github.com/coolsnowwolf/lede openwrt
cd openwrt
# git reset --hard f833707a78974af47ddbe1f7e038bf62b463f633
# sed -i '$a src-git diy1 https://github.com/xiaorouji/openwrt-passwall.git;main' feeds.conf.default
./scripts/feeds update -a
./scripts/feeds install -a
