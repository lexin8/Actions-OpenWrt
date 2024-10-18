#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
#拉取源码
# git clone https://github.com/lexin8/kernel opt
cd openwrt
sed -i 's/192.168.1.1/192.168.10.253/g' package/base-files/files/bin/config_generate
./scripts/feeds update -a
./scripts/feeds install -a

git clone https://github.com/kenzok8/openwrt-packages.git package/kenzok8
git clone https://github.com/liudf0716/luci.git package/liudf0716
git clone https://github.com/kiddin9/openwrt-packages.git package/kiddin9
pushd package/diy
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/kenzok8/luci-app-openclash .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/kenzok8/luci-app-clash .
popd
# 添加插件
# cd package && git clone https://github.com/fw876/helloworld
cd package && git clone https://github.com/fw876/helloworld.git
# cd package && git clone --depth=1 https://github.com/fw876/helloworld.git
# git clone -b luci https://github.com/xiaorouji/openwrt-passwall.git passwall
# git clone https://github.com/xiaorouji/openwrt-passwall2.git passwall2
git clone https://github.com/xiaorouji/openwrt-passwall.git
# git clone --branch master https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git
# cd luci-app-unblockneteasemusic && git reset --hard 3d1e3ba97724880bdd9c1170d5522e6a993811c6 && cd ..
cd ../
#&& rm -rf feeds/diy1/v2ray
rm -rf package/kenzok8
rm -rf package/liudf0716
rm -rf package/kiddin9



