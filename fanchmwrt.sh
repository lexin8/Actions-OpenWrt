#!/bin/bash
set -e

# 清理冲突组件
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,sing*,smartdns} 
rm -rf feeds/packages/utils/v2dat 
rm -rf feeds/packages/lang/golang

# 替换Golang 1.26
git clone https://github.com/kenzok8/golang -b 1.26 feeds/packages/lang/golang

# 添加Feeds源
echo "src-git immortalwrt_packages https://github.com/immortalwrt/packages.git;openwrt-24.10 \
+net/softethervpn \
+net/softethervpn5 \
+libs/openssl \
+libs/readline \
+libs/ncurses \
+libs/zlib \
+net/strongswan \
+net/swanmon" >> feeds.conf.default

echo "src-git immortalwrt_luci https://github.com/immortalwrt/luci;openwrt-24.10 \
+applications/luci-app-softethervpn \
+applications/luci-app-homeproxy \
+applications/luci-app-strongswan-swanctl \
+modules/luci-base \
+modules/luci-lib-nixio" >> feeds.conf.default

# 更新并全量安装Feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 写入编译配置
cat > .config << 'EOF'
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_KERNEL_PARTSIZE=60
CONFIG_TARGET_ROOTFS_PARTSIZE=600
CONFIG_TARGET_ROOTFS_TARGZ=y
CONFIG_VMDK_IMAGES=n

CONFIG_KERNEL_IP_FORWARD=y
CONFIG_KERNEL_NETFILTER=y
CONFIG_KERNEL_NETFILTER_XT_MATCH_POLICY=y
CONFIG_KERNEL_PPP=y
CONFIG_KERNEL_PPP_ASYNC=y
CONFIG_KERNEL_PPP_SYNC_TTY=y
CONFIG_KERNEL_PPP_L2TP=y
CONFIG_KERNEL_TUN=y
CONFIG_KERNEL_BRIDGE_NETFILTER=y

CONFIG_PACKAGE_ddns-scripts=y
CONFIG_PACKAGE_ddns-scripts-cloudflare=y
CONFIG_PACKAGE_ddns-scripts_cloudflare.com-v4=y
CONFIG_PACKAGE_luci-app-ddns=y
CONFIG_PACKAGE_luci-app-udpxy=y

CONFIG_PACKAGE_libopenssl=y
CONFIG_PACKAGE_libreadline=y
CONFIG_PACKAGE_libncurses=y
CONFIG_PACKAGE_libzlib=y
CONFIG_PACKAGE_softethervpn=y
CONFIG_PACKAGE_softethervpn5=y
CONFIG_PACKAGE_luci-app-softethervpn=y

CONFIG_PACKAGE_strongswan=y
CONFIG_PACKAGE_strongswan-swanctl=y
CONFIG_PACKAGE_swanmon=y
CONFIG_PACKAGE_luci-app-strongswan-swanctl=y

CONFIG_PACKAGE_sing-box=y
CONFIG_PACKAGE_sing-box-full=n
CONFIG_PACKAGE_luci-app-nikki=y
CONFIG_PACKAGE_luci-app-homeproxy=y
CONFIG_PACKAGE_luci-app-libreswan=y
CONFIG_PACKAGE_libreswan=y

CONFIG_DEFAULT_luci-app-arpbind=n
CONFIG_PACKAGE_luci-app-autoreboot=n
CONFIG_PACKAGE_luci-app-nlbwmon=n
CONFIG_PACKAGE_luci-app-samba4=n
CONFIG_PACKAGE_luci-app-samba=n
CONFIG_PACKAGE_luci-app-vlmcsd=n
CONFIG_PACKAGE_luci-app-wol=n
EOF

make defconfig
