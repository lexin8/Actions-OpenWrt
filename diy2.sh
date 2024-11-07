#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
#拉取源码
cd openwrt
git reset --hard 33913d674f71807f4e9711b647fdb8f6b504e393
./scripts/feeds update -a
./scripts/feeds install -a
# 退回 packages
cd feeds/
rm -rf packages/
rm -rf luci/
git clone -b openwrt-23.05 https://github.com/immortalwrt/packages
git clone -b openwrt-23.05 https://github.com/immortalwrt/luci
cd packages/
git reset --hard 322c4266835a9b73eb1045cf3e532ee15802c85a
cd ..
cd luci/
git reset --hard 65e5852f965462eb3e85e8a50dd6cb313491acf7
