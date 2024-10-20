#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
#拉取源码
# git clone https://github.com/lexin8/kernel opt
# git clone https://github.com/coolsnowwolf/lede openwrt
cd openwrt
# git reset --hard 625dbc350539d424d44f5d0683b734435e2aa90f
# sed -i '$a src-git diy1 https://github.com/xiaorouji/openwrt-passwall.git;main' feeds.conf.default
# echo "src-git mihomo https://github.com/morytyann/OpenWrt-mihomo.git;main" >> "feeds.conf.default"
sed -i '$a src-git luci https://github.com/immortalwrt/luci.git;openwrt-23.05' feeds.conf.default
sed -i '2,3d' feeds.conf.default

./scripts/feeds update -a
./scripts/feeds install -a
