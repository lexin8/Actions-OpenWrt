#!/bin/bash
set -e

# 切换到OpenWrt源码目录
cd openwrt || exit 1

# 更新基础feeds（仅无缓存时执行）
if [ ! -d "./feeds/luci" ]; then
    ./scripts/feeds update -a
fi
./scripts/feeds install -a

# 精准拉取luci-app-homeproxy
if [ ! -d "./package/luci-app-homeproxy" ]; then
    git clone --depth 1 --branch openwrt-24.10 https://github.com/immortalwrt/luci.git package/immortalwrt-luci-tmp
    mkdir -p package/luci-app-homeproxy
    cp -rf package/immortalwrt-luci-tmp/applications/luci-app-homeproxy/* package/luci-app-homeproxy/
    rm -rf package/immortalwrt-luci-tmp
fi

# 集成lisaac原版luci-app-dockerman
if [ ! -d "./package/luci-app-dockerman" ]; then
    git clone --depth 1 https://github.com/lisaac/luci-lib-docker.git package/luci-lib-docker
    git clone --depth 1 https://github.com/lisaac/luci-app-dockerman.git package/luci-app-dockerman
fi

# 添加Passwall源（避免重复添加）
# grep -q "passwall_pkgs" feeds.conf.default || sed -i '1i src-git passwall_pkgs https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' feeds.conf.default
# grep -q "passwall_luci" feeds.conf.default || sed -i '2i src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' feeds.conf.default
grep -q "nikki" feeds.conf.default || echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> feeds.conf.default

# 仅更新新增的feeds
./scripts/feeds update passwall_pkgs passwall_luci nikki
# ./scripts/feeds install -a -p passwall_pkgs
# ./scripts/feeds install -a -p passwall_luci
./scripts/feeds install -a -p nikki

# 备份原有配置（如有）
[ -f .config ] && cp .config .config.bak.$(date +%Y%m%d%H%M%S)

# 写入完整编译配置
cat > .config << 'EOF'
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_KERNEL_PARTSIZE=100
CONFIG_TARGET_ROOTFS_PARTSIZE=2048
CONFIG_TARGET_ROOTFS_TARGZ=y
# CONFIG_VMDK_IMAGES is not set
# CONFIG_PACKAGE_igmpproxy is not set

# 内核核心配置（IPsec/L2TP/Docker必需）
CONFIG_KERNEL_IP_FORWARD=y
CONFIG_KERNEL_NETFILTER=y
CONFIG_KERNEL_NETFILTER_XT_MATCH_POLICY=y
CONFIG_KERNEL_PPP=y
CONFIG_KERNEL_PPP_ASYNC=y
CONFIG_KERNEL_PPP_SYNC_TTY=y
CONFIG_KERNEL_PPP_L2TP=y
CONFIG_KERNEL_TUN=y
CONFIG_KERNEL_BRIDGE_NETFILTER=y

# 基础组件
CONFIG_PACKAGE_ddns-scripts=y
CONFIG_PACKAGE_ddns-scripts-cloudflare=y
CONFIG_PACKAGE_ddns-scripts_cloudflare.com-v4=y
CONFIG_PACKAGE_luci-app-ddns=y
CONFIG_PACKAGE_luci-app-udpxy=y
CONFIG_PACKAGE_coreutils=y
CONFIG_PACKAGE_coreutils-base64=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_wget=y

# Docker 相关
CONFIG_PACKAGE_dockerd=y
CONFIG_PACKAGE_docker=y
CONFIG_PACKAGE_docker-compose=y
CONFIG_PACKAGE_luci-lib-docker=y
CONFIG_PACKAGE_luci-app-dockerman=y

# IPsec/L2TP 容器依赖（内核模块+用户态工具）
CONFIG_PACKAGE_kmod-ppp=y
CONFIG_PACKAGE_kmod-ppp-generic=y
CONFIG_PACKAGE_kmod-ppp-l2tp=y
CONFIG_PACKAGE_kmod-tun=y
CONFIG_PACKAGE_kmod-br-netfilter=y
CONFIG_PACKAGE_kmod-ipt-nat=y
CONFIG_PACKAGE_kmod-ipt-extra=y
CONFIG_PACKAGE_kmod-nf-nat-pptp=y
CONFIG_PACKAGE_ppp=y
CONFIG_PACKAGE_ppp-mod-l2tp=y
CONFIG_PACKAGE_ipset=y
CONFIG_PACKAGE_iptables-mod-extra=y
CONFIG_PACKAGE_sysctl=y

# 磁盘管理
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_blockd=y
CONFIG_PACKAGE_blkid=y
CONFIG_PACKAGE_e2fsprogs=y
CONFIG_PACKAGE_parted=y
CONFIG_PACKAGE_lsblk=y
CONFIG_PACKAGE_cfdisk=y
CONFIG_PACKAGE_mount-utils=y
CONFIG_PACKAGE_ntfs-3g=y

# 代理组件
CONFIG_PACKAGE_luci-app-passwall=y
CONFIG_PACKAGE_luci-app-homeproxy=y

# Libreswan（IPsec/L2TP）
CONFIG_PACKAGE_luci-app-libreswan=y
CONFIG_PACKAGE_libreswan=y

# 其他组件
CONFIG_PACKAGE_luci-app-nikki=y

# 禁用无关组件
# CONFIG_DEFAULT_luci-app-arpbind is not set
# CONFIG_PACKAGE_luci-app-autoreboot is not set
# CONFIG_PACKAGE_luci-app-nlbwmon is not set
# CONFIG_PACKAGE_luci-app-samba4 is not set
# CONFIG_PACKAGE_luci-app-samba is not set
# CONFIG_PACKAGE_luci-app-vlmcsd is not set
# CONFIG_PACKAGE_luci-app-wol is not set
# CONFIG_PACKAGE_luci-app-zerotier is not set
# CONFIG_PACKAGE_luci-app-strongswan-swanctl is not set
EOF

# 启用ccache缓存（初始化+设置大小）
export CCACHE_DIR=$(pwd)/ccache
export USE_CCACHE=1
[ ! -d "$CCACHE_DIR" ] && mkdir -p "$CCACHE_DIR" && ccache -M 50G

# 预生成依赖文件（确保配置生效）
make defconfig

# 可选：检查配置完整性
echo "配置生成完成，开始检查依赖..."
make prereq 2>&1 | tee prereq.log
if [ $? -ne 0 ]; then
    echo "依赖检查失败，请查看 prereq.log"
    exit 1
fi
echo "配置验证通过，可执行 make -j$(nproc) 开始编译"
