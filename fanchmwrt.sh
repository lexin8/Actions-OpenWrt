#!/bin/bash
set -e

# 进入OpenWRT源码根目录（请根据实际路径修改）
cd openwrt || { echo "错误：找不到openwrt目录！"; exit 1; }

# ===================== 1. 清理旧配置/组件 =====================
sed -i '/passwall/d; /nikki/d; /immortalwrt/d; /dockerman/d' feeds.conf.default
rm -rf feeds/luci/applications/{luci-app-homeproxy,luci-app-passwall,luci-app-dockerman} 2>/dev/null
rm -rf package/{homeproxy,luci-app-homeproxy,passwall-packages,passwall-luci,immortalwrt-luci-tmp,luci-lib-docker,luci-app-dockerman} 2>/dev/null

# ===================== 2. 拉取luci-app-homeproxy =====================
echo "临时克隆immortalwrt/luci仓库，提取luci-app-homeproxy..."
git clone --depth 1 --branch openwrt-24.10 https://github.com/immortalwrt/luci.git package/immortalwrt-luci-tmp

mkdir -p package/luci-app-homeproxy
cp -rf package/immortalwrt-luci-tmp/applications/luci-app-homeproxy/* package/luci-app-homeproxy/
rm -rf package/immortalwrt-luci-tmp

# ===================== 3. 集成lisaac原版luci-app-dockerman =====================
echo "克隆lisaac原版luci-app-dockerman及依赖..."
git clone --depth 1 https://github.com/lisaac/luci-lib-docker.git package/luci-lib-docker
git clone --depth 1 https://github.com/lisaac/luci-app-dockerman.git package/luci-app-dockerman

# ===================== 4. 添加Passwall/nikki源 =====================
sed -i '1i src-git passwall_pkgs https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' feeds.conf.default
sed -i '2i src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' feeds.conf.default
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> feeds.conf.default

# ===================== 5. 更新并安装Feeds =====================
echo "正在更新feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# ===================== 6. 写入编译配置 =====================
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

# Docker相关
CONFIG_PACKAGE_dockerd=y
CONFIG_PACKAGE_docker=y
CONFIG_PACKAGE_docker-compose=y
CONFIG_PACKAGE_luci-lib-docker=y
CONFIG_PACKAGE_luci-app-dockerman=y

# 磁盘管理组件
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
