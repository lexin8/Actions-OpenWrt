#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
#拉取源码
git clone https://github.com/tuanqing/mknop
git clone https://github.com/coolsnowwolf/lede openwrt
cd openwrt
 sed -i '$a src-git diy1 https://github.com/xiaorouji/openwrt-passwall.git;main' feeds.conf.default
./scripts/feeds update -a && ./scripts/feeds install -a
git clone https://github.com/kenzok8/openwrt-packages.git package/kenzok8
pushd package/lean
# 添加主题
rm -rf luci-theme*
# rm -rf luci-lib-docker
# rm -rf luci-app-diskman
svn co https://github.com/lisaac/luci-app-dockerman/trunk/applications/luci-app-dockerman
# svn co https://github.com/lisaac/luci-app-diskman/trunk/applications/luci-app-diskman
# git clone https://github.com/lisaac/luci-lib-docker
git clone https://github.com/esirplayground/luci-theme-atmaterial-ColorIcon
git clone https://github.com/Aslin-Ameng/luci-theme-Light
git clone https://github.com/sirpdboy/luci-theme-opentopd
git clone -b 18.06 https://github.com/kiddin9/luci-theme-edge.git
git clone https://github.com/virualv/luci-theme-pink.git
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/kenzok8/luci-app-openclash .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/kenzok8/luci-theme-opentomcat .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/kenzok8/luci-theme-ifit .
# 删除配置
grep -rnl 'luci.main.mediaurlbase' ./ | xargs sed -i '/luci.main.mediaurlbase/d'
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git
git clone https://github.com/jerrykuku/luci-app-argon-config
git clone https://github.com/jerrykuku/lua-maxminddb.git
git clone https://github.com/jerrykuku/luci-app-vssr.git
# svn checkout https://github.com/kenzok8/openwrt-packages/trunk/luci-app-openclash
popd
# 添加插件
cd package && git clone https://github.com/fw876/helloworld
git clone https://github.com/tuanqing/install-program
git clone https://github.com/sirpdboy/NetSpeedTest
# svn checkout https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-koolproxyR
 cd ../ && rm -rf feeds/diy1/v2ray
rm -rf package/kenzok8

