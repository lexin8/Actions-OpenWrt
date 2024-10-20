#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
cd openwrt
./scripts/feeds update -a
./scripts/feeds install -a
git clone https://github.com/kenzok8/openwrt-packages.git package/kenzok8
git clone https://github.com/liudf0716/luci.git package/liudf0716
git clone https://github.com/kiddin9/openwrt-packages.git package/kiddin9
rm -rf feeds/luci/applications/luci-theme*
cd feeds/luci/themes/
ls |grep -v luci-theme-bootstrap |xargs rm -rf && cd -
pushd package/lean
# 添加主题
rm -rf luci-theme*
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/kenzok8/luci-app-openclash .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/kenzok8/luci-app-clash .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/kenzok8/luci-app-wechatpush .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/kenzok8/luci-app-store .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/liudf0716/applications/luci-app-strongswan-swanctl .

# 删除配置
grep -rnl 'luci.main.mediaurlbase' ./ | xargs sed -i '/luci.main.mediaurlbase/d'
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git
git clone https://github.com/jerrykuku/luci-app-argon-config
git clone https://github.com/jerrykuku/lua-maxminddb.git
popd
# 添加插件
cd package && git clone https://github.com/fw876/helloworld.git
git clone https://github.com/xiaorouji/openwrt-passwall.git

cd ../
#&& rm -rf feeds/diy1/v2ray
rm -rf package/kenzok8
rm -rf package/liudf0716
rm -rf package/kiddin9
