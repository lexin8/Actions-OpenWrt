#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
#拉取源码
# git clone https://github.com/lexin8/kernel opt
# git clone https://github.com/coolsnowwolf/lede openwrt
cd openwrt
# git reset --hard f833707a78974af47ddbe1f7e038bf62b463f633
# sed -i '$a src-git diy1 https://github.com/xiaorouji/openwrt-passwall.git;main' feeds.conf.default
# echo "src-git mihomo https://github.com/morytyann/OpenWrt-mihomo.git;main" >> "feeds.conf.default"
# sed -i '$a src-git luci https://github.com/coolsnowwolf/luci.git;openwrt-23.05' feeds.conf.default
# sed -i '2,3d' feeds.conf.default

./scripts/feeds update -a
./scripts/feeds install -a
# 退回 packages
#cd feeds/
#rm -rf packages/
#rm -rf luci/
#git clone https://github.com/coolsnowwolf/packages
#git clone https://github.com/coolsnowwolf/luci
#cd packages/
#git reset --hard 889d742b61b153ed9cfc73bd3c24aa8ad30a03ec
#cd ..
#cd luci/
#git reset --hard 0cb5c5c78274871cd98c3e114ed9e70ab86ad5d6
#cd ../../
# EOF
git clone https://github.com/kenzok8/openwrt-packages.git package/kenzok8
git clone https://github.com/liudf0716/luci.git package/liudf0716
git clone https://github.com/kiddin9/openwrt-packages.git package/kiddin9
rm -rf feeds/luci/applications/luci-theme*
rm -rf feeds/luci/applications/luci-app-unblockmusic*
cd feeds/luci/themes/
ls |grep -v luci-theme-bootstrap |xargs rm -rf && cd -
pushd package/lean
# 添加主题
rm -rf luci-theme*
# rm -rf luci-lib-docker
# rm -rf luci-app-diskman
# svn co https://github.com/lisaac/luci-app-dockerman/trunk/applications/luci-app-dockerman
# svn co https://github.com/lisaac/luci-app-diskman/trunk/applications/luci-app-diskman
# git clone https://github.com/lisaac/luci-lib-docker
git clone https://github.com/esirplayground/luci-theme-atmaterial-ColorIcon
git clone https://github.com/Aslin-Ameng/luci-theme-Light
git clone https://github.com/sirpdboy/luci-theme-opentopd
git clone -b 18.06 https://github.com/kiddin9/luci-theme-edge.git
git clone https://github.com/virualv/luci-theme-pink.git
git clone https://github.com/thinktip/luci-theme-neobird.git
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/kenzok8/luci-app-openclash .
# svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/kenzok8/luci-app-clash .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/kenzok8/luci-theme-ifit .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/kenzok8/luci-app-wechatpush .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/kenzok8/luci-theme-design .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/kenzok8/luci-app-store .
# cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package//kiddin9/luci-app-mihomo .
# cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package//kiddin9/mihomo .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/liudf0716/applications/luci-app-strongswan-swanctl .

# 删除配置
grep -rnl 'luci.main.mediaurlbase' ./ | xargs sed -i '/luci.main.mediaurlbase/d'
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git
# git clone https://github.com/jerrykuku/luci-theme-argon.git
git clone https://github.com/jerrykuku/luci-app-argon-config
git clone https://github.com/jerrykuku/lua-maxminddb.git
# git clone https://github.com/jerrykuku/luci-app-vssr.git
# svn checkout https://github.com/kenzok8/openwrt-packages/trunk/luci-app-openclash
popd
# 添加插件
# cd package && git clone https://github.com/fw876/helloworld
cd package && git clone https://github.com/fw876/helloworld.git
# cd package && git clone --depth=1 https://github.com/fw876/helloworld.git
# git clone -b luci https://github.com/xiaorouji/openwrt-passwall.git passwall
# git clone https://github.com/xiaorouji/openwrt-passwall2.git passwall2
git clone https://github.com/xiaorouji/openwrt-passwall.git
# git clone https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git
# git clone --branch master https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git
# cd luci-app-unblockneteasemusic && git reset --hard 3d1e3ba97724880bdd9c1170d5522e6a993811c6 && cd ..
# git clone https://github.com/tuanqing/install-program
# git clone https://github.com/sirpdboy/netspeedtest
# svn checkout https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-koolproxyR
cd ../
#&& rm -rf feeds/diy1/v2ray
rm -rf package/kenzok8
rm -rf package/liudf0716
rm -rf package/kiddin9
