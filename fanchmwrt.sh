#!/bin/bash

# 进入openwrt源码目录（确保路径正确）
cd openwrt || exit 1

cat > .config << 'EOF'
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_KERNEL_PARTSIZE=100
CONFIG_TARGET_ROOTFS_PARTSIZE=2048
CONFIG_TARGET_ROOTFS_TARGZ=y
# CONFIG_VMDK_IMAGES is not set
# CONFIG_PACKAGE_igmpproxy is not set
CONFIG_PACKAGE_ddns-scripts=y
CONFIG_PACKAGE_ddns-scripts-cloudflare=y
CONFIG_PACKAGE_ddns-scripts_cloudflare.com-v4=y
CONFIG_PACKAGE_luci-app-ddns=y
CONFIG_PACKAGE_luci-app-passwall=y
CONFIG_PACKAGE_luci-app-udpxy=y
CONFIG_PACKAGE_luci-app-homeproxy=y
CONFIG_PACKAGE_luci-app-nikki=y
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

# 明确禁用smartdns（关键：从编译层面排除）
CONFIG_PACKAGE_smartdns=n

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

# 1. 引入nikki源码（兼容官方版）
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> feeds.conf.default

# 2. 保留要求的kenzo/small源（解决passwall/homeproxy依赖）
sed -i '1i src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default

# 3. 更新feeds（先更新再清理，避免路径不存在）
./scripts/feeds update -a

# 4. 清理冲突组件（增强smartdns清理，覆盖所有可能路径）
rm -rf feeds/luci/applications/luci-app-mosdns 2>/dev/null
rm -rf feeds/packages/net/alist 2>/dev/null
rm -rf feeds/packages/net/adguardhome 2>/dev/null
rm -rf feeds/packages/net/mosdns 2>/dev/null
rm -rf feeds/packages/net/xray* 2>/dev/null
rm -rf feeds/packages/net/v2ray* 2>/dev/null
rm -rf feeds/packages/net/sing* 2>/dev/null
rm -rf feeds/packages/net/smartdns 2>/dev/null
rm -rf feeds/packages/utils/v2dat 2>/dev/null
rm -rf feeds/packages/lang/golang 2>/dev/null
# 新增：删除kenzo源下的smartdns（核心修复）
rm -rf feeds/kenzo/smartdns 2>/dev/null
rm -rf feeds/kenzo/luci-app-smartdns 2>/dev/null

# 5. 替换高版本golang（解决passwall/homeproxy编译依赖）
git clone https://github.com/kenzok8/golang -b 1.26 feeds/packages/lang/golang

# 6. 重新更新feeds并安装所有组件
./scripts/feeds update -a
./scripts/feeds install -a

# 7. 强制安装核心组件（指定正确路径）
./scripts/feeds install -p small luci-app-homeproxy
./scripts/feeds install -p kenzo luci-app-passwall
./scripts/feeds install -p nikki luci-app-nikki

# 8. 修复依赖缺失问题（手动添加ucode-mod-digest）
./scripts/feeds install ucode-mod-digest

# 9. 修复luci版本依赖（针对small/kenzo源的正确路径）
sed -i 's/luci-base >= 22.03/luci-base >= 21.02/g' feeds/small/luci-app-homeproxy/Makefile 2>/dev/null
sed -i 's/luci-base >= 22.03/luci-base >= 21.02/g' feeds/kenzo/luci-app-passwall/Makefile 2>/dev/null

# 新增：可选方案 - 若仍有rust依赖问题，安装rust环境（备用）
# ./scripts/feeds install rust
# ./scripts/feeds install rust-bindgen/host
