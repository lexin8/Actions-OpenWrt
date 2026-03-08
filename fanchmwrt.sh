#!/bin/bash

# 进入openwrt源码目录（确保路径正确）
cd openwrt || exit 1

# ===================== 核心：拉取Passwall最新代码（方法1+方法2结合） =====================
# 1. 清理原有冲突源和旧组件（先清旧的，避免干扰）
# 清理feeds.conf.default中旧的passwall相关源
sed -i '/passwall/d' feeds.conf.default
# 清理系统自带的旧版核心库（方法2核心步骤，确保用最新版）
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls} 2>/dev/null
# 清理系统自带的旧版luci-app-passwall
rm -rf feeds/luci/applications/luci-app-passwall 2>/dev/null

# 2. 插入Passwall最新源到feeds.conf.default顶部（方法1核心，优先最新源码）
sed -i '1i src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' feeds.conf.default
sed -i '2i src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' feeds.conf.default

# 3. 额外兜底：直接克隆最新源码到package目录（方法2补充，双重保障最新）
rm -rf package/passwall-packages package/passwall-luci 2>/dev/null
git clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages
git clone https://github.com/Openwrt-Passwall/openwrt-passwall package/passwall-luci

# ===================== 原有逻辑保留+优化 =====================
# 清理并添加nikki源
sed -i '/nikki/d' feeds.conf.default
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> feeds.conf.default

# 4. 更新所有feeds（拉取最新源码，包括刚添加的Passwall源）
./scripts/feeds update -a

# 5. 清理其他冲突组件（homeproxy/mosdns等）
rm -rf feeds/packages/net/mosdns feeds/luci/applications/luci-app-mosdns 2>/dev/null
rm -rf feeds/packages/utils/v2dat feeds/packages/lang/golang 2>/dev/null

# 6. 安装所有feeds组件（确保最新源码被识别）
./scripts/feeds install -a

# 7. 写入编译配置（保留你的原有配置，修正语法错误）
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

# 禁用不需要的组件
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

# 8. 加载配置并校验（确保配置无语法错误）
make defconfig

# 9. 可选：预下载所有依赖包（首次编译建议开启，加速编译）
# make download -j$(nproc)

# 10. 开始编译（根据CPU核心数调整-j数值，如-j4，崩溃则改小）
# make -j$(nproc) V=s
