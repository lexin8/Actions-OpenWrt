#!/bin/bash
#===============================================
# Modify default IP
# sed -i 's/192.168.1.1/192.168.10.253/g' openwrt/package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/kenzo/g' package/base-files/files/bin/config_generate

#2. Custom settings
#sed -i 's?zstd$?zstd ucl upx\n$(curdir)/upx/compile := $(curdir)/ucl/compile?g' tools/Makefile
#sed -i 's/$(TARGET_DIR)) install/$(TARGET_DIR)) install --force-overwrite/' package/Makefile
#sed -i 's/root:.*/root:$1$tTPCBw1t$ldzfp37h5lSpO9VXk4uUE\/:18336:0:99999:7:::/g' package/base-files/files/etc/shadow

git clone -b main https://github.com/kiddin9/kwrt-packages diy
git clone -b openwrt-24.10 https://github.com/immortalwrt/packages swanmon

cd openwrt
echo "src-git mihomo https://github.com/morytyann/OpenWrt-mihomo.git;main" >> "feeds.conf.default"
#git clone -b openwrt-21.02 https://github.com/immortalwrt/luci.git package/immortalwrt
#cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/openwrt/package/immortalwrt/applications/luci-app-passwall .
#rm -rf package/immortalwrt

./scripts/feeds update -a
./scripts/feeds install -a
cd package
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/diy/luci-app-strongswan-swanctl .
cp -r ~/work/Actions-OpenWrt/Actions-OpenWrt/swanmon/utils/swanmon/ .

