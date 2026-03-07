#!/bin/bash
set -e  # 出错终止，便于调试

# 1. 克隆第三方依赖包（保留原逻辑）
git clone -b main https://github.com/kiddin9/kwrt-packages diy
git clone -b openwrt-24.10 https://github.com/immortalwrt/packages swanmon

# 2. 克隆官方luci-app-dockerman（24.10分支）
git clone -b openwrt-24.10 https://github.com/openwrt/luci openwrt-luci
mkdir -p openwrt/feeds/luci/applications/luci-app-dockerman
cp -r openwrt-luci/applications/luci-app-dockerman/* openwrt/feeds/luci/applications/luci-app-dockerman/

# 3. 进入openwrt源码目录，优先配置源（修正源顺序）
cd openwrt
# 先添加kenzo/small源（基础插件）
sed -i '1i src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default
# 添加nikki源
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> feeds.conf.default
# 添加24.10官方Docker源（修正分支）
echo "src-git docker_feeds https://github.com/openwrt/packages.git;openwrt-24.10" >> feeds.conf.default

# 4. 清理旧缓存 + 更新所有feeds
./scripts/feeds clean
./scripts/feeds update -a

# 5. 安装基础feeds
./scripts/feeds install -a

# 6. 拷贝磁盘管理组件（保留原逻辑）
cp -r -n ../immortalwrt/feeds/luci/applications/luci-app-diskman/* ./feeds/luci/applications/luci-app-diskman/

# 7. 清理冲突组件（保留原逻辑）
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,sing*,smartdns}
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/packages/lang/golang
git clone https://github.com/kenzok8/golang -b 1.26 feeds/packages/lang/golang

# 8. 重新更新feeds + 安装完整Docker/dockerman依赖
./scripts/feeds update -a
# 安装24.10官方Docker核心
./scripts/feeds install -p docker_feeds docker dockerd docker-compose kmod-docker
# 安装dockerman及必需依赖
./scripts/feeds install luci-app-dockerman ttyd ucode-mod-socket
# 安装网络依赖
./scripts/feeds install kmod-nf-conntrack kmod-nf-ipt kmod-ipt-core

# 9. 清理临时文件（可选）
cd ..
rm -rf openwrt-luci

echo "✅ 配置完成！已集成OpenWrt 24.10官方luci-app-dockerman + 完整Docker组件"
