#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
#拉取源码
git clone https://github.com/tuanqing/mknop
git clone https://github.com/padavanonly/immortalwrt openwrt
cd openwrt
# sed -i '$a src-git diy1 https://github.com/xiaorouji/openwrt-passwall.git;main' feeds.conf.default
./scripts/feeds update -a
./scripts/feeds install -a
git clone https://github.com/kenzok8/openwrt-packages.git package/kenzok8
git clone https://github.com/lexin8/Actions-OpenWrt.git config
pushd feeds/luci/themes
# 添加主题
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/kenzok8/luci-app-openclash ..
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/kenzok8/luci-app-bypass .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/kenzok8/smartdns-le .
popd
# 添加插件
cd feeds/luci/applications/
rm -rf luci-app-ddns
svn co https://github.com/coolsnowwolf/luci/trunk/applications/luci-app-ddns
cd ../../../
cd package && git clone https://github.com/fw876/helloworld
git clone -b luci https://github.com/xiaorouji/openwrt-passwall.git passwall
git clone https://github.com/xiaorouji/openwrt-passwall.git
#git clone https://github.com/tuanqing/install-program
git clone https://github.com/sirpdboy/netspeedtest
# svn checkout https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-koolproxyR
cd ../
#&& rm -rf feeds/diy1/v2ray
rm -rf package/kenzok8
