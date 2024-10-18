#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
#拉取源码
# git clone https://github.com/lexin8/kernel opt
cd openwrt
# sed -i '$a src-git diy https://github.com/xiaorouji/openwrt-passwall.git;main' feeds.conf.default
# sed -i '$a src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main' feeds.conf.default
sed -i 's/192.168.1.1/192.168.10.253/g' package/base-files/files/bin/config_generate
./scripts/feeds update -a
./scripts/feeds install -a

git clone https://github.com/kenzok8/openwrt-packages.git package/kenzok8
git clone https://github.com/liudf0716/luci.git package/liudf0716
git clone https://github.com/kiddin9/openwrt-packages.git package/kiddin9
# git clone https://github.com/xiaorouji/openwrt-passwall-packages package/
# git clone https://github.com/xiaorouji/openwrt-passwall.git package/passwall
pushd package/diy
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/kenzok8/luci-app-openclash .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/kenzok8/luci-app-clash .


cd ../

rm -rf package/kenzok8
rm -rf package/liudf0716
rm -rf package/kiddin9



