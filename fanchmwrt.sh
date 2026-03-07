#!/bin/bash
# fanchmwrt-24.10.4 编译脚本
# 适配openwrt-24.10分支，集成Nikki插件、Docker、IPsec/L2TP依赖、磁盘分区工具

# 拉取基础扩展包
git clone -b main https://github.com/kiddin9/kwrt-packages diy
git clone -b openwrt-24.10 https://github.com/immortalwrt/packages swanmon

cd openwrt

# 1. 修改默认管理IP地址为192.168.10.1
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 2. 自定义设备型号为3865U（覆盖默认的Unknown）
# 方式1：修改系统信息生成脚本，强制设置设备型号
sed -i '/DISTRIB_DESCRIPTION=/a\export DISTRIB_MODEL="3865U"' package/base-files/files/bin/config_generate
# 方式2：直接修改openwrt_release模板，确保型号写入
sed -i 's/DISTRIB_DESCRIPTION='\''%D %V %C'\''/DISTRIB_DESCRIPTION='\''%D %V %C (3865U)'\''/g' package/base-files/files/etc/openwrt_release
# 方式3：补充型号变量（防止部分版本读取不到）
echo 'DISTRIB_MODEL="3865U"' >> package/base-files/files/etc/openwrt_release

# 添加Nikki插件源码源
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> "feeds.conf.default"

# 更新并安装基础软件源
./scripts/feeds update -a
./scripts/feeds install -a

# 集成磁盘管理工具组件
cp -r -n ../immortalwrt/feeds/luci/applications/luci-app-diskman/* ./feeds/luci/applications/luci-app-diskman/

# 集成kenzo和small软件源并清理冲突组件
sed -i '1i src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default
./scripts/feeds update -a && rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,v2ray*,sing*,smartdns}
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/packages/lang/golang
git clone https://github.com/kenzok8/golang -b 1.26 feeds/packages/lang/golang

# 再次更新并安装软件源
./scripts/feeds update -a
./scripts/feeds install -a

# 拉取IPsec/L2TP相关组件，适配docker-ipsec-vpn-server
git clone -b openwrt-24.10 https://github.com/openwrt/packages openwrt-packages
cp -rf ../openwrt-packages/net/libreswan ./feeds/packages/net/ 2>/dev/null
cp -rf ../openwrt-packages/net/xl2tpd ./feeds/packages/net/ 2>/dev/null
cp -rf ../openwrt-packages/net/strongswan ./feeds/packages/net/ 2>/dev/null
cp -rf ../openwrt-packages/net/ipsec-tools ./feeds/packages/net/ 2>/dev/null
cp -rf ../openwrt-packages/net/ipset ./feeds/packages/net/ 2>/dev/null

# 拉取Docker及Web管理组件
git clone -b openwrt-24.10 https://github.com/openwrt/luci openwrt-luci
cp -rf ../openwrt-luci/applications/luci-app-docker ./feeds/luci/applications/ 2>/dev/null
cp -rf ../openwrt-luci/applications/luci-app-dockerman ./feeds/luci/applications/ 2>/dev/null

# 拉取磁盘分区及格式化工具组件
git clone -b openwrt-24.10 https://github.com/openwrt/packages openwrt-packages-temp
cp -rf ../openwrt-packages-temp/utils/blockd ./feeds/packages/utils/ 2>/dev/null
cp -rf ../openwrt-packages-temp/utils/blkid ./feeds/packages/utils/ 2>/dev/null
cp -rf ../openwrt-packages-temp/utils/e2fsprogs ./feeds/packages/utils/ 2>/dev/null
cp -rf ../openwrt-packages-temp/utils/parted ./feeds/packages/utils/ 2>/dev/null
cp -rf ../openwrt-packages-temp/utils/lsblk ./feeds/packages/utils/ 2>/dev/null
cp -rf ../openwrt-packages-temp/utils/cfdisk ./feeds/packages/utils/ 2>/dev/null

# 最终更新软件源确保所有组件安装完成
./scripts/feeds update -a
./scripts/feeds install -a
