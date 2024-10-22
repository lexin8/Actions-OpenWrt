#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
#拉取源码
cd openwrt
./scripts/feeds update -a
./scripts/feeds install -a
cd package
git clone https://github.com/jerrykuku/luci-app-argon-config
git clone https://github.com/fw876/helloworld.git
cd ..


