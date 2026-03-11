#!/bin/bash
set -e

cat > feeds.conf.default << 'EOF'
src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git
src-git kenzo https://github.com/kenzok8/openwrt-packages
src-git small https://github.com/kenzok8/small
src-git immortalwrt_packages https://github.com/immortalwrt/packages.git;openwrt-24.10
src-git immortalwrt_luci https://github.com/immortalwrt/luci.git;openwrt-24.10
EOF

./scripts/feeds update -a

rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,smartdns} \
       feeds/packages/utils/v2dat \
       feeds/packages/lang/golang

rm -rf feeds/kenzo/luci-app-nikki 2>/dev/null || true
rm -rf feeds/small/luci-app-nikki 2>/dev/null || true
rm -rf feeds/immortalwrt_packages/luci-app-nikki 2>/dev/null || true
rm -rf feeds/immortalwrt_luci/luci-app-nikki 2>/dev/null || true
rm -rf feeds/immortalwrt_packages/net/sing-box

git clone https://github.com/kenzok8/golang -b 1.26 feeds/packages/lang/golang

./scripts/feeds install \
    softethervpn softethervpn5 \
    luci-app-softethervpn \
    strongswan strongswan-swanctl swanmon \
    luci-app-strongswan-swanctl \
    ddns-scripts luci-app-ddns \
    luci-app-udpxy \
    openssl readline ncurses zlib

./scripts/feeds install sing-box
./scripts/feeds install golang
./scripts/feeds install homeproxy
./scripts/feeds install luci-app-homeproxy
./scripts/feeds install nikki
./scripts/feeds install luci-app-nikki
./scripts/feeds install luci-i18n-nikki-zh-cn

cat > .config << 'EOF'
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_KERNEL_PARTSIZE=60
CONFIG_TARGET_ROOTFS_PARTSIZE=600
CONFIG_TARGET_ROOTFS_PERSIST_VAR=y
CONFIG_TARGET_ROOTFS_TARGZ=y

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
CONFIG_PACKAGE_zlib=y
CONFIG_PACKAGE_softethervpn=y
CONFIG_PACKAGE_softethervpn5=y
CONFIG_PACKAGE_luci-app-softethervpn=y

CONFIG_PACKAGE_strongswan=y
CONFIG_PACKAGE_strongswan-swanctl=y
CONFIG_PACKAGE_swanmon=y
CONFIG_PACKAGE_strongswan-charon=y
CONFIG_PACKAGE_strongswan-mod-kernel-netlink=y
CONFIG_PACKAGE_strongswan-mod-nonce=y
CONFIG_PACKAGE_strongswan-mod-sha1=y
CONFIG_PACKAGE_strongswan-mod-sha2=y
CONFIG_PACKAGE_strongswan-mod-aes=y
CONFIG_PACKAGE_strongswan-mod-hmac=y
CONFIG_PACKAGE_strongswan-mod-gmp=y
CONFIG_PACKAGE_strongswan-mod-pem=y
CONFIG_PACKAGE_strongswan-mod-x509=y
CONFIG_PACKAGE_strongswan-mod-vici=y

CONFIG_PACKAGE_luci-app-nikki=y
CONFIG_PACKAGE_homeproxy=y
CONFIG_PACKAGE_luci-app-homeproxy=y

# 禁用不需要的插件（保留所有注释项）
# CONFIG_PACKAGE_luci-app-arpbind is not set
# CONFIG_PACKAGE_luci-app-autoreboot is not set
# CONFIG_PACKAGE_luci-app-nlbwmon is not set
# CONFIG_PACKAGE_luci-app-samba4 is not set
# CONFIG_PACKAGE_luci-app-samba is not set
# CONFIG_PACKAGE_luci-app-vlmcsd is not set
# CONFIG_PACKAGE_luci-app-wol is not set
EOF
EOF

make defconfig
