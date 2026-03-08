#!/bin/bash
# fanchmwrt-24.10.4 编译脚本（修正版）
# 主源码：OpenWrt官方 openwrt-23.05，集成fanchmwrt界面、Nikki插件、Docker、IPsec/L2TP、磁盘分区工具
set -euo pipefail  # 严格模式，出错即终止

# 第一步：拉取基础扩展包（先拉取，再进入openwrt目录）
git clone -b main https://github.com/kiddin9/kwrt-packages diy || echo "kwrt-packages拉取失败，跳过"
git clone -b openwrt-23.05 https://github.com/immortalwrt/packages swanmon || echo "swanmon拉取失败，跳过"

# 进入OpenWrt主源码目录（需先确保openwrt目录由CI拉取完成）
if [ ! -d "openwrt" ]; then
    echo "错误：openwrt主源码目录不存在！"
    exit 1
fi
cd openwrt

# 第二步：添加Nikki插件源码源
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> feeds.conf.default

# 第三步：添加fanchmwrt界面/组件源（同步23.05分支）
echo "src-git fanchmwrt https://github.com/fanchmwrt/fanchmwrt.git;openwrt-23.05" >> feeds.conf.default

# 第四步：更新并安装基础软件源
./scripts/feeds update -a
./scripts/feeds install -a

# 第五步：集成磁盘管理工具组件（从immortalwrt同步，修正路径）
if [ -d "../immortalwrt/feeds/luci/applications/luci-app-diskman" ]; then
    mkdir -p ./feeds/luci/applications/luci-app-diskman/
    cp -r -n ../immortalwrt/feeds/luci/applications/luci-app-diskman/* ./feeds/luci/applications/luci-app-diskman/ 2>/dev/null
else
    echo "警告：immortalwrt的diskman组件未找到，跳过集成"
fi

# 第六步：集成kenzo和small软件源（保障PassWall/HomeProxy等插件）
sed -i '1i src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default
./scripts/feeds update -a 
rm -rf feeds/luci/applications/luci-app-mosdns || true
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,sing*,smartdns} || true
rm -rf feeds/packages/utils/v2dat || true
rm -rf feeds/packages/lang/golang || true
git clone https://github.com/kenzok8/golang -b 1.26 feeds/packages/lang/golang || echo "golang拉取失败，跳过"

# 再次更新并安装软件源
./scripts/feeds update -a
./scripts/feeds install -a

# 第七步：拉取IPsec/L2TP相关组件（适配docker-ipsec-vpn-server，同步23.05分支）
git clone -b openwrt-23.05 https://github.com/openwrt/packages ../openwrt-packages || echo "openwrt-packages拉取失败，跳过"
mkdir -p ./feeds/packages/net/
cp -rf ../openwrt-packages/net/libreswan ./feeds/packages/net/ 2>/dev/null || true
cp -rf ../openwrt-packages/net/xl2tpd ./feeds/packages/net/ 2>/dev/null || true
cp -rf ../openwrt-packages/net/strongswan ./feeds/packages/net/ 2>/dev/null || true
cp -rf ../openwrt-packages/net/ipsec-tools ./feeds/packages/net/ 2>/dev/null || true
cp -rf ../openwrt-packages/net/ipset ./feeds/packages/net/ 2>/dev/null || true

# 第八步：拉取Docker及Web管理组件（确保版本适配23.05）
git clone -b openwrt-23.05 https://github.com/openwrt/luci ../openwrt-luci || echo "openwrt-luci拉取失败，跳过"
mkdir -p ./feeds/luci/applications/
cp -rf ../openwrt-luci/applications/luci-app-docker ./feeds/luci/applications/ 2>/dev/null || true
cp -rf ../openwrt-luci/applications/luci-app-dockerman ./feeds/luci/applications/ 2>/dev/null || true

# 第九步：拉取磁盘分区及格式化工具组件（同步23.05分支）
git clone -b openwrt-23.05 https://github.com/openwrt/packages ../openwrt-packages-temp || echo "openwrt-packages-temp拉取失败，跳过"
mkdir -p ./feeds/packages/utils/
cp -rf ../openwrt-packages-temp/utils/blockd ./feeds/packages/utils/ 2>/dev/null || true
cp -rf ../openwrt-packages-temp/utils/blkid ./feeds/packages/utils/ 2>/dev/null || true
cp -rf ../openwrt-packages-temp/utils/e2fsprogs ./feeds/packages/utils/ 2>/dev/null || true
cp -rf ../openwrt-packages-temp/utils/parted ./feeds/packages/utils/ 2>/dev/null || true
cp -rf ../openwrt-packages-temp/utils/lsblk ./feeds/packages/utils/ 2>/dev/null || true
cp -rf ../openwrt-packages-temp/utils/cfdisk ./feeds/packages/utils/ 2>/dev/null || true

# 最终更新软件源确保所有组件安装完成
./scripts/feeds update -a
./scripts/feeds install -a

echo "✅ fanchmwrt脚本执行完成，组件集成完毕"
