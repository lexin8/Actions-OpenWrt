#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
cd package/lede/
rm -rf luci-theme-argon && git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git
svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean/microsocks
svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean/redsocks2
svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean/v2ray
svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean/xray
cd ../ && git clone https://github.com/fw876/helloworld.git
