#!/bin/bash
set -e

# 基础初始化：更新并安装 feeds（精简条件判断）
[ ! -d "./feeds/luci" -o ! -f "./feeds.conf.default" ] && ./scripts/feeds update -a
./scripts/feeds install -a

# 拉取 luci-app-homeproxy 及核心依赖 sing-box（核心逻辑）
if [ ! -d "./package/luci-app-softethervpn" ]; then
    # 1. 拉取 homeproxy 独立仓库（适配 openwrt-24.10）
    git clone --depth 1 https://github.com/immortalwrt/homeproxy.git package/luci-app-homeproxy
    # 2. 拉取 sing-box 依赖（homeproxy 必需，仅拉取目标目录）
    if [ ! -d "./package/sing-box" ]; then
        git clone --depth 1 --branch openwrt-24.10 https://github.com/immortalwrt/packages.git -n package/immortalwrt-tmp
        cd package/immortalwrt-tmp && git sparse-checkout set net/sing-box && git checkout && cd -
        cp -rf package/immortalwrt-tmp/net/sing-box package/ && rm -rf package/immortalwrt-tmp
    fi
fi

# 【关键修改1：删除 luci-app-dockerman 拉取逻辑】
# 原脚本中拉取 luci-lib-docker/luci-app-dockerman 的代码已移除

# 添加 passwall/nikki feeds（保留核心逻辑）
grep -q "passwall_pkgs" feeds.conf.default || sed -i '1i src-git passwall_pkgs https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' feeds.conf.default
grep -q "passwall_luci" feeds.conf.default || sed -i '2i src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' feeds.conf.default
grep -q "nikki" feeds.conf.default || echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> feeds.conf.default

# ========== 新增：添加 kenzo 源（编译 luci-app-softethervpn 核心） ==========
# 1. 检查 kenzo 源是否已存在，不存在则添加
grep -q "kenzo" feeds.conf.default || sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
grep -q "small" feeds.conf.default || sed -i '$a src-git small https://github.com/kenzok8/small' feeds.conf.default

# 2. 更新 kenzo/small 源并安装 softethervpn 相关包
./scripts/feeds update kenzo small
./scripts/feeds install -a -p kenzo
./scripts/feeds install luci-app-softethervpn softethervpn  # 强制安装主程序+luci插件
# ========== kenzo 源添加结束 ==========

./scripts/feeds update passwall_pkgs passwall_luci nikki
./scripts/feeds install -a -p nikki

# 写入编译配置（【关键修改2：删除所有 Docker 相关编译项】）
cat > .config << 'EOF'
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_KERNEL_PARTSIZE=60
CONFIG_TARGET_ROOTFS_PARTSIZE=600
CONFIG_TARGET_ROOTFS_TARGZ=y
# CONFIG_VMDK_IMAGES is not set
# CONFIG_PACKAGE_igmpproxy is not set

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

CONFIG_PACKAGE_luci-app-passwall=y
CONFIG_PACKAGE_luci-app-nikki=y
CONFIG_PACKAGE_luci-app-homeproxy=y
CONFIG_PACKAGE_sing-box=y
CONFIG_PACKAGE_luci-app-libreswan=y
CONFIG_PACKAGE_libreswan=y
CONFIG_PACKAGE_luci-app-softether=y
CONFIG_PACKAGE_softethervpn=y

# 禁用不必要的插件
# CONFIG_DEFAULT_luci-app-arpbind is not set
# CONFIG_PACKAGE_luci-app-autoreboot is not set
# CONFIG_PACKAGE_luci-app-nlbwmon is not set
# CONFIG_PACKAGE_luci-app-samba4 is not set
# CONFIG_PACKAGE_luci-app-samba is not set
# CONFIG_PACKAGE_luci-app-vlmcsd is not set
# CONFIG_PACKAGE_luci-app-wol is not set
# CONFIG_PACKAGE_luci-app-strongswan-swanctl is not set
EOF

# 编译前置配置（精简，静默执行）
export CCACHE_DIR=$(pwd)/ccache
export USE_CCACHE=1
mkdir -p "$CCACHE_DIR" && ccache -M 50G > /dev/null 2>&1

make defconfig
# ========== 你指定的位置：补充 softethervpn 依赖检查 ==========
# 检查 softethervpn 依赖是否安装，确保编译不报错
./scripts/feeds install -f softethervpn luci-app-softethervpn
# ========== 依赖检查结束 ==========
make prereq 2>&1 | tee prereq.log || exit 0
