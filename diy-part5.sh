#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
cd package/lean/
# svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean
# 添加主题
rm -rf luci-theme*
git clone https://github.com/esirplayground/luci-theme-atmaterial-ColorIcon
git clone https://github.com/Aslin-Ameng/luci-theme-Light
svn checkout https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-opentopd
svn checkout https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-opentomcat
svn checkout https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-ifit
# 删除配置
grep -rnl 'luci.main.mediaurlbase' ./ | xargs sed -i '/luci.main.mediaurlbase/d'
# sed -i '/luci.main.mediaurlbase/d' luci-theme-atmaterial-ColorIcon/root/etc/uci-defaults/30_luci-theme-atmaterial_ci
# sed -i '/luci.main.mediaurlbase/d' luci-theme-Light/luci-theme-Light/root/etc/uci-defaults/luci-theme-Light
# sed -i '/luci.main.mediaurlbase/d' luci-theme-opentopd/root/etc/uci-defaults/30_luci-theme-opentopd
# sed -i '/luci.main.mediaurlbase/d' luci-theme-opentomcat/files/30_luci-theme-opentomcat
# sed -i '/luci.main.mediaurlbase/d' luci-theme-ifit/files/10_luci-theme-ifit
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git
# 添加插件
svn checkout https://github.com/kenzok8/openwrt-packages/trunk/luci-app-jd-dailybonus
svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-uugamebooster
svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean/uugamebooster
# 添加依赖
svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean/pdnsd-alt
svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean/microsocks
svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean/dns2socks
svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean/simple-obfs
svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean/v2ray-plugin
svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean/trojan
svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean/ipt2socks
svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean/redsocks2
svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean/shadowsocksr-libev
cd ../ && git clone https://github.com/fw876/helloworld.git
cd ../ && rm -rf feeds/diy1/v2ray
# cd ../ && svn checkout https://github.com/kenzok8/openwrt-packages/trunk/luci-app-ssr-plus
