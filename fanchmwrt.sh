#!/bin/bash

cd openwrt

# 1. 引入nikki源码（兼容官方版）
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> feeds.conf.default

# 2. 保留你要求的kenzo/small源（解决passwall/homeproxy依赖）
sed -i '1i src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default

# 3. 更新feeds并清理冲突组件
./scripts/feeds update -a
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,sing*,smartdns}
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/packages/lang/golang

# 4. 替换高版本golang（解决passwall/homeproxy编译依赖）
git clone https://github.com/kenzok8/golang -b 1.26 feeds/packages/lang/golang

# 5. 关键补充：强制安装passwall/homeproxy依赖
./scripts/feeds install -a
./scripts/feeds install luci-app-passwall luci-app-homeproxy luci-app-nikki

# 6. 修复官方版luci接口兼容问题
sed -i 's/luci-base >= 22.03/luci-base >= 21.02/g' feeds/kenzo/luci-app-passwall/Makefile
sed -i 's/luci-base >= 22.03/luci-base >= 21.02/g' feeds/kenzo/luci-app-homeproxy/Makefile
