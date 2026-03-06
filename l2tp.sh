#!/bin/bash
# l2tp.sh - OpenWrt 24.10 追加 L2TP/IPsec 组件配置
# 适配 Actions-OpenWrt 编译流程

set -e  # 出错立即退出

# 颜色输出定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# 检查当前目录是否有 .config 文件
if [ ! -f ".config" ]; then
    echo -e "${RED}[错误] 当前目录未找到 .config 文件，请先完成基础配置！${NC}"
    exit 1
fi

echo -e "${YELLOW}[开始] 向 .config 追加 L2TP/IPsec 组件配置...${NC}"

# 追加 L2TP/IPsec 核心组件配置
cat >> .config << EOF

# ========== L2TP/IPsec 服务器组件 (OpenWrt 24.10) ==========
# L2TP 核心服务
CONFIG_PACKAGE_xl2tpd=y

# IPsec (strongswan) 核心加密模块
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

# PPP 协议及内核驱动
CONFIG_PACKAGE_ppp=y
CONFIG_PACKAGE_ppp-mod-pppol2tp=y
CONFIG_PACKAGE_luci-proto-ppp=y
CONFIG_PACKAGE_kmod-ppp=y
CONFIG_PACKAGE_kmod-pppol2tp=y
CONFIG_PACKAGE_kmod-pppox=y

# 防火墙 NAT 转发依赖（关键）
CONFIG_PACKAGE_iptables-mod-nat-extra=y

# 基础系统依赖
CONFIG_PACKAGE_libopenssl=y
CONFIG_PACKAGE_libpthread=y
CONFIG_PACKAGE_iproute2=y
EOF

# 自动补全依赖并去重
echo -e "${YELLOW}[处理] 执行 defconfig 补全依赖...${NC}"
make defconfig > /dev/null 2>&1

# 验证关键组件是否添加成功
CHECK_COMPONENTS=("xl2tpd" "strongswan" "iptables-mod-nat-extra" "kmod-pppol2tp")
for comp in "${CHECK_COMPONENTS[@]}"; do
    if grep -q "CONFIG_PACKAGE_${comp}=y" .config; then
        echo -e "${GREEN}[成功] 组件 ${comp} 已添加到 .config${NC}"
    else
        echo -e "${RED}[失败] 组件 ${comp} 添加失败！${NC}"
        exit 1
    fi
done

echo -e "${GREEN}[完成] L2TP/IPsec 组件配置追加成功！${NC}"
exit 0
