#!/bin/bash
set -e

# 切换到OpenWrt源码目录
cd openwrt || exit 1

# 更新feeds（仅无缓存时执行）
if [ ! -d "./feeds/luci" ]; then
    ./scripts/feeds update -a
fi
./scripts/feeds install -a

# 精准拉取luci-app-homeproxy
if [ ! -d "./package/luci-app-homeproxy" ]; then
    git clone --depth 1 --branch openwrt-24.10 https://github.com/immortalwrt/luci.git package/immortalwrt-luci-tmp
    mkdir -p package/luci-app-homeproxy
    cp -rf package/immortalwrt-luci-tmp/applications/luci-app-homeproxy/* package/luci-app-homeproxy/
    rm -rf package/immortalwrt-luci-tmp
fi

# 集成lisaac原版luci-app-dockerman
if [ ! -d "./package/luci-app-dockerman" ]; then
    git clone --depth 1 https://github.com/lisaac/luci-lib-docker.git package/luci-lib-docker
    git clone --depth 1 https://github.com/lisaac/luci-app-dockerman.git package/luci-app-dockerman
fi

# 添加Passwall源
sed -i '1i src-git passwall_pkgs https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' feeds.conf.default
sed -i '2i src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' feeds.conf.default
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> feeds.conf.default

# 重新安装feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 加载编译配置
if [ -f "../fanchmwrt.config" ]; then
    cp ../fanchmwrt.config .config
else
    make menuconfig
fi

# 启用ccache缓存
export CCACHE_DIR=$(pwd)/ccache
export USE_CCACHE=1

# 预生成依赖文件
make defconfig
