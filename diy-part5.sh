#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
cd package/lean/
# 添加主题
rm -rf luci-theme-argon && git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git
git clone https://github.com/esirplayground/luci-theme-atmaterial-ColorIcon
git clone https://github.com/Aslin-Ameng/luci-theme-Light
svn checkout https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-opentopd
svn checkout https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-opentomcat
svn checkout https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-ifit
# 添加插件
svn checkout https://github.com/kenzok8/openwrt-packages/trunk/luci-app-jd-dailybonus
# 添加依赖
svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean/microsocks
svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean/redsocks2
svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean/v2ray
svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean/xray
cd ../ && git clone https://github.com/fw876/helloworld.git
# cd ../ && svn checkout https://github.com/kenzok8/openwrt-packages/trunk/luci-app-ssr-plus
