#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
pushd package/lean
# 添加主题
rm -rf luci-theme*
rm -rf luci-lib-docker
rm -rf luci-app-diskman
svn co https://github.com/lisaac/luci-app-dockerman/trunk/applications/luci-app-dockerman
svn co https://github.com/lisaac/luci-app-diskman/trunk/applications/luci-app-diskman
git clone https://github.com/lisaac/luci-lib-docker
git clone https://github.com/esirplayground/luci-theme-atmaterial-ColorIcon
git clone https://github.com/Aslin-Ameng/luci-theme-Light
svn checkout https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-opentopd
svn checkout https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-opentomcat
svn checkout https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-ifit
# 删除配置
grep -rnl 'luci.main.mediaurlbase' ./ | xargs sed -i '/luci.main.mediaurlbase/d'
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git
git clone https://github.com/jerrykuku/luci-app-argon-config
git clone https://github.com/jerrykuku/lua-maxminddb.git
git clone https://github.com/jerrykuku/luci-app-vssr.git
popd
# 添加插件
cd package && git clone https://github.com/fw876/helloworld
cd ../ && rm -rf feeds/diy1/v2ray
