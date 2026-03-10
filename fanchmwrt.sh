#!/bin/bash
set -e

# 添加Feeds源
echo "src-git immortalwrt_packages https://github.com/immortalwrt/packages.git;openwrt-24.10 \
+net/softethervpn \
+net/softethervpn5 \
+libs/openssl \
+sing-box \
+libs/readline \
+libs/ncurses \
+libs/zlib \
+lang/golang \
+net/strongswan \
+net/swanmon" >> feeds.conf.default

echo "src-git immortalwrt_luci https://github.com/immortalwrt/luci;openwrt-24.10 \
+applications/luci-app-softethervpn \
+applications/luci-app-strongswan-swanctl \
+modules/luci-base \
+modules/luci-lib-nixio" >> feeds.conf.default

echo "src-git homeproxy https://github.com/immortalwrt/homeproxy.git" >> feeds.conf.default

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

CONFIG_PACKAGE_luci-app-nikki=y
CONFIG_PACKAGE_homeproxy=y
CONFIG_PACKAGE_luci-app-homeproxy=y

# 禁用不需要的插件（官方 is not set 格式，# 开头 + 配置项 + is not set 结尾）
# CONFIG_DEFAULT_luci-app-arpbind is not set
# CONFIG_PACKAGE_luci-app-autoreboot is not set
# CONFIG_PACKAGE_luci-app-nlbwmon is not set
# CONFIG_PACKAGE_luci-app-samba4 is not set
# CONFIG_PACKAGE_luci-app-samba is not set
# CONFIG_PACKAGE_luci-app-vlmcsd is not set
# CONFIG_PACKAGE_luci-app-wol is not set
EOF

make defconfig
