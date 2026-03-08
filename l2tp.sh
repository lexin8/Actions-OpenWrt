#!/bin/bash

cd $OPENWRT_PATH

# 添加IPSec/L2TP相关依赖
echo "CONFIG_PACKAGE_luci-app-ipsec-vpnserver-manyusers=y" >> .config
echo "CONFIG_PACKAGE_libipsec=y" >> .config
echo "CONFIG_PACKAGE_openswan=y" >> .config
echo "CONFIG_PACKAGE_l2tpd=y" >> .config
echo "CONFIG_PACKAGE_ppp-mod-pptp=y" >> .config
echo "CONFIG_PACKAGE_ppp-mod-l2tp=y" >> .config
echo "CONFIG_PACKAGE_strongswan=y" >> .config
echo "CONFIG_PACKAGE_strongswan-ipsec=y" >> .config

# 重新生成配置
make defconfig
