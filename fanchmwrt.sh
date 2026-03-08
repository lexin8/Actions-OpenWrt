#!/bin/bash
set -e  # 错误立即退出，便于排查

# 进入OpenWRT源码根目录（请根据实际路径修改）
cd openwrt || { echo "错误：找不到openwrt目录！"; exit 1; }

# ===================== 1. 清理旧配置/组件（避免冲突） =====================
# 清理feeds中旧的passwall/nikki/immortalwrt源
sed -i '/passwall/d; /nikki/d; /immortalwrt/d' feeds.conf.default
# 清理旧的homeproxy/passwall组件
rm -rf feeds/luci/applications/luci-app-homeproxy feeds/luci/applications/luci-app-passwall 2>/dev/null
rm -rf package/{homeproxy,luci-app-homeproxy,passwall-packages,passwall-luci,immortalwrt-luci-tmp} 2>/dev/null

# ===================== 2. 精准拉取luci-app-homeproxy（仅拷贝目标组件） =====================
echo "临时克隆immortalwrt/luci仓库，仅提取luci-app-homeproxy..."
# 临时克隆immortalwrt/luci（仅openwrt-24.10分支，浅克隆减少体积）
git clone --depth 1 --branch openwrt-24.10 https://github.com/immortalwrt/luci.git package/immortalwrt-luci-tmp

# 仅拷贝luci-app-homeproxy到OpenWRT的package目录（核心步骤）
mkdir -p package/luci-app-homeproxy
cp -rf package/immortalwrt-luci-tmp/applications/luci-app-homeproxy/* package/luci-app-homeproxy/

# 立即删除临时克隆的immortalwrt/luci仓库（只保留目标组件）
rm -rf package/immortalwrt-luci-tmp

# ===================== 3. 添加Passwall/nikki源（保留你的需求） =====================
sed -i '1i src-git passwall_pkgs https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' feeds.conf.default
sed -i '2i src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' feeds.conf.default
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> feeds.conf.default

# ===================== 4. 更新并安装Feeds =====================
echo "正在更新feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# ===================== 5. 写入编译配置 =====================
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
CONFIG_PACKAGE_luci-app-dockerman=y
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_blockd=y
CONFIG_PACKAGE_blkid=y
CONFIG_PACKAGE_e2fsprogs=y
CONFIG_PACKAGE_parted=y
CONFIG_PACKAGE_lsblk=y
CONFIG_PACKAGE_cfdisk=y
CONFIG_PACKAGE_mount-utils=y
CONFIG_PACKAGE_ntfs-3g=y


CONFIG_PACKAGE_luci-app-passwall=y
CONFIG_PACKAGE_luci-app-homeproxy=y
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
