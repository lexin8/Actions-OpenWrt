#!/bin/bash
# 脚本功能：向 OpenWrt .config 追加 L2TP/IPsec 服务器所需组件配置
# 适配版本：OpenWrt 24.10
# 使用场景：GitHub Actions 编译 OpenWrt 时自动注入组件配置

set -e  # 遇到错误立即退出

# 定义颜色输出（可选，增强日志可读性）
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 检查当前目录是否为 OpenWrt 源码根目录（存在 .config 文件）
if [ ! -f ".config" ]; then
    echo -e "${RED}错误：当前目录未找到 .config 文件，请先执行 make menuconfig 生成基础配置！${NC}"
    exit 1
fi

echo -e "${YELLOW}开始向 .config 追加 L2TP/IPsec 组件配置...${NC}"

# 追加 L2TP/IPsec 核心组件配置到 .config
cat >> .config << EOF

# ========== 手动追加：L2TP/IPsec 服务器组件 (OpenWrt 24.10) ==========
# 1. L2TP 核心服务
CONFIG_PACKAGE_xl2tpd=y

# 2. IPsec (strongswan) 核心组件（仅保留必需模块，精简体积）
CONFIG_PACKAGE_strongswan=y
CONFIG_PACKAGE_strongswan-charon=y
CONFIG_PACKAGE_strongswan-ipsec=y
CONFIG_PACKAGE_strongswan-libtls=y
CONFIG_PACKAGE_strongswan-mod-aes=y
CONFIG_PACKAGE_strongswan-mod-hmac=y
CONFIG_PACKAGE_strongswan-mod-sha1=y
CONFIG_PACKAGE_strongswan-mod-sha2=y
CONFIG_PACKAGE_strongswan-mod-kernel-netlink=y
CONFIG_PACKAGE_strongswan-mod-stroke=y
CONFIG_PACKAGE_strongswan-mod-updown=y
CONFIG_PACKAGE_strongswan-mod-gmp=y
CONFIG_PACKAGE_strongswan-mod-pem=y

# 3. PPP 协议及内核驱动
CONFIG_PACKAGE_ppp=y
CONFIG_PACKAGE_ppp-mod-pppol2tp=y
CONFIG_PACKAGE_luci-proto-ppp=y
CONFIG_PACKAGE_kmod-ppp=y
CONFIG_PACKAGE_kmod-pppol2tp=y
CONFIG_PACKAGE_kmod-pppox=y

# 4. 防火墙 NAT 转发依赖（关键）
CONFIG_PACKAGE_iptables-mod-nat-extra=y

# 5. 基础系统依赖（自动补全可能遗漏的依赖）
CONFIG_PACKAGE_libopenssl=y
CONFIG_PACKAGE_libpthread=y
CONFIG_PACKAGE_iproute2=y
EOF

# 去重 + 自动补全依赖（解决重复配置和隐式依赖问题）
echo -e "${YELLOW}执行 defconfig 自动补全依赖并去重...${NC}"
make defconfig > /dev/null 2>&1

# 验证配置是否生效
CHECK_COMPONENTS=("xl2tpd" "strongswan" "iptables-mod-nat-extra" "kmod-pppol2tp")
for comp in "${CHECK_COMPONENTS[@]}"; do
    if grep -q "CONFIG_PACKAGE_${comp}=y" .config; then
        echo -e "${GREEN}✅ 组件 ${comp} 已成功添加到 .config${NC}"
    else
        echo -e "${RED}❌ 组件 ${comp} 添加失败，请手动检查！${NC}"
        exit 1
    fi
done

echo -e "${GREEN}✅ L2TP/IPsec 组件配置追加完成，.config 文件已更新！${NC}"
exit 0
