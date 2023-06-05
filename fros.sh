#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
#拉取源码
git clone https://github.com/lexin8/kernel opt
git clone https://github.com/openfros/fros openwrt
cd openwrt
./scripts/feeds update -a
./scripts/feeds install -a
./build.sh -l x86_64
