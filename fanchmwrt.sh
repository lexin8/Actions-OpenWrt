#!/bin/bash
set -e

# 切换到OpenWrt源码目录
cd openwrt || exit 1

# 更新feeds（仅无缓存时执行）
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

# 添加Passwall源
sed -i '1i src-git passwall_pkgs https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' feeds.conf.default
sed -i '2i src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' feeds.conf.default
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> feeds.conf.default

# 重新安装feeds
./scripts/feeds update -a
./scripts/feeds install -a

# ===================== 核心修改：直接写入完整编译配置（无需外部文件） =====================
cat > .config << 'EOF'
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_KERNEL_PARTSIZE=100
CONFIG_TARGET_ROOTFS_PARTSIZE=2048
CONFIG_TARGET_ROOTFS_TARGZ=y
# CONFIG_VMDK_IMAGES is not set
# CONFIG_PACKAGE_igmpproxy is not set

# 基础组件
CONFIG_PACKAGE_ddns-scripts=y
CONFIG_PACKAGE_ddns-scripts-cloudflare=y
CONFIG_PACKAGE_ddns-scripts_cloudflare.com-v4=y
CONFIG_PACKAGE_luci-app-ddns=y
CONFIG_PACKAGE_luci-app-udpxy=y

# Docker 相关
CONFIG_PACKAGE_dockerd=y
CONFIG_PACKAGE_docker=y
CONFIG_PACKAGE_docker-compose=y
CONFIG_PACKAGE_luci-lib-docker=y
CONFIG_PACKAGE_luci-app-dockerman=y

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

# 启用ccache缓存
export CCACHE_DIR=$(pwd)/ccache
export USE_CCACHE=1

# 预生成依赖文件（确保配置生效）
make defconfig
