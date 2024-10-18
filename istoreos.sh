#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
#拉取源码
# git clone https://github.com/lexin8/kernel opt
cd openwrt
sed -i 's/192.168.1.1/192.168.10.253/g' package/base-files/files/bin/config_generate
./scripts/feeds update -a
./scripts/feeds install -a






