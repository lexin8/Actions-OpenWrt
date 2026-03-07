#!/bin/bash
git clone -b main https://github.com/kiddin9/kwrt-packages diy
git clone -b openwrt-24.10 https://github.com/immortalwrt/packages swanmon

cd openwrt
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> "feeds.conf.default"
# 添加Docker官方feeds源
echo "src-git docker_feeds https://github.com/openwrt/packages.git;openwrt-24.02" >> feeds.conf.default

./scripts/feeds update -a
./scripts/feeds install -a

# 仅保留磁盘管理组件拷贝，移除strongswan相关
cp -r -n ../immortalwrt/feeds/luci/applications/luci-app-diskman/* ./feeds/luci/applications/luci-app-diskman/

# 添加kenzo源
sed -i '1i src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default
./scripts/feeds update -a && rm -rf feeds/luci/applications/luci-app-mosdns

# 清理冲突组件
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,sing*,smartdns}
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/packages/lang/golang
git clone https://github.com/kenzok8/golang -b 1.26 feeds/packages/lang/golang

# 更新并安装组件（仅Docker相关）
./scripts/feeds update -a
./scripts/feeds install -a
./scripts/feeds install docker docker-compose luci-app-docker kmod-docker
./scripts/feeds install kmod-nf-conntrack kmod-nf-ipt kmod-ipt-core
