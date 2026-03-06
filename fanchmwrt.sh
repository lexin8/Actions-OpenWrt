#!/bin/bash
#===============================================
# Modify default IP
# sed -i 's/192.168.1.1/192.168.10.253/g' openwrt/package/base-files/files/bin/config_generate

# Modify default theme
# sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
# sed -i 's/OpenWrt/kenzo/g' package/base-files/files/bin/config_generate

#2. Custom settings
# sed -i 's?zstd$?zstd ucl upx\n$(curdir)/upx/compile := $(curdir)/ucl/compile?g' tools/Makefile
# sed -i 's/$(TARGET_DIR)) install/$(TARGET_DIR)) install --force-overwrite/' package/Makefile
# sed -i 's/root:.*/root:$1$tTPCBw1t$ldzfp37h5lSpO9VXk4uUE\/:18336:0:99999:7:::/g' package/base-files/files/etc/shadow

git clone -b main https://github.com/kiddin9/kwrt-packages diy
git clone -b openwrt-24.10 https://github.com/immortalwrt/packages swanmon
# git clone -b openwrt-24.10 https://github.com/immortalwrt/luci luci

cd openwrt
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> "feeds.conf.default"


./scripts/feeds update -a
./scripts/feeds install -a

# 拷贝immortalwrt
# \cp -rf ../immortalwrt/feeds/packages/lang/* ./feeds/packages/lang/
cp -r -n ../immortalwrt/feeds/luci/applications/luci-app-diskman/* ./feeds/luci/applications/luci-app-diskman/
cp -r -n ../immortalwrt/feeds/packages/net/strongswan/* ./feeds/packages/net/strongswan/
# cp -r -n ../immortalwrt/feeds/packages/net/* ./feeds/packages/net/

sed -i '1i src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default
./scripts/feeds update -a && rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,v2ray*,sing*,smartdns}
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/packages/lang/golang
git clone https://github.com/kenzok8/golang -b 1.26 feeds/packages/lang/golang

./scripts/feeds update -a
./scripts/feeds install -a
