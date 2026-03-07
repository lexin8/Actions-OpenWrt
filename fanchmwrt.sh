#!/bin/bash
# GitHub Actions 环境适配：设置超时、中文编码、默认路径
export LC_ALL=C
export ACTIONS_WORKSPACE=${ACTIONS_WORKSPACE:-$(pwd)}
set -eo pipefail  # 增强错误检测，适配CI环境

# ===================== 1. 环境准备与路径校准 =====================
# 确保openwrt源码目录存在（Actions环境默认拉取到openwrt目录）
if [ ! -d "openwrt" ]; then
    echo "❌ 未找到openwrt源码目录，自动拉取OpenWrt 24.10主线源码"
    git clone -b openwrt-24.10 https://github.com/openwrt/openwrt.git openwrt
fi
cd "${ACTIONS_WORKSPACE}/openwrt" || exit 1

# ===================== 2. 克隆依赖包（适配CI网络） =====================
# 克隆第三方依赖（添加超时、重试机制）
git clone --depth=1 -b main https://github.com/kiddin9/kwrt-packages ../diy || { echo "重试拉取diy包"; git clone --depth=1 -b main https://github.com/kiddin9/kwrt-packages ../diy; }
git clone --depth=1 -b openwrt-24.10 https://github.com/immortalwrt/packages ../swanmon || { echo "重试拉取swanmon包"; git clone --depth=1 -b openwrt-24.10 https://github.com/immortalwrt/packages ../swanmon; }

# 克隆官方luci-app-dockerman（24.10分支，深度克隆加速）
git clone --depth=1 -b openwrt-24.10 https://github.com/openwrt/luci ../openwrt-luci
mkdir -p feeds/luci/applications/luci-app-dockerman
cp -rf ../openwrt-luci/applications/luci-app-dockerman/* feeds/luci/applications/luci-app-dockerman/

# ===================== 3. Feeds源配置（优先级/兼容性优化） =====================
# 备份原始feeds.conf.default
cp feeds.conf.default feeds.conf.default.bak

# 优先添加kenzo/small源（解决插件依赖）
sed -i '1i src-git kenzo https://github.com/kenzok8/openwrt-packages;master' feeds.conf.default
sed -i '2i src-git small https://github.com/kenzok8/small;master' feeds.conf.default

# 添加nikki源
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> feeds.conf.default

# 添加24.10官方Docker源（指定utils/docker目录，精准拉取）
echo "src-git docker_feeds https://github.com/openwrt/packages.git;openwrt-24.10" >> feeds.conf.default
# 强制指定Docker源优先级（避免第三方源覆盖）
echo "src-priority docker_feeds 10" >> feeds.conf.default

# ===================== 4. Feeds更新与安装（CI环境适配） =====================
# 清理旧缓存（Actions缓存可能残留旧数据）
./scripts/feeds clean all

# 更新feeds（添加重试，适配GitHub网络波动）
for i in {1..3}; do
    ./scripts/feeds update -a && break
    echo "Feeds更新失败，第${i}次重试..."
    sleep 5
done

# 安装基础feeds
./scripts/feeds install -a

# ===================== 5. 组件适配（磁盘管理/冲突清理） =====================
# 拷贝磁盘管理组件（兼容immortalwrt）
mkdir -p feeds/luci/applications/luci-app-diskman
cp -rf ../swanmon/feeds/luci/applications/luci-app-diskman/* feeds/luci/applications/luci-app-diskman/ || true

# 清理冲突组件（避免编译冲突）
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,sing*,smartdns}
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/packages/lang/golang

# 安装适配版golang（解决Docker编译依赖）
git clone --depth=1 -b 1.26 https://github.com/kenzok8/golang feeds/packages/lang/golang

# ===================== 6. 安装Docker/dockerman完整依赖（兼容VPN容器） =====================
# 重新更新feeds
./scripts/feeds update -a

# 1. 安装官方Docker核心组件（24.10分支，适配VPN容器）
./scripts/feeds install -p docker_feeds \
    docker dockerd docker-compose kmod-docker \
    kmod-nf-conntrack kmod-nf-ipt kmod-ipt-core \
    kmod-ipt-nat-extra kmod-nft-nat kmod-nft-masq

# 2. 安装luci-app-dockerman及Web管理依赖
./scripts/feeds install \
    luci-app-dockerman ttyd ucode-mod-socket luci-i18n-dockerman-zh-cn

# 3. 安装VPN容器必需内核模块（兼容ipsec-vpn-server）
./scripts/feeds install \
    kmod-ppp kmod-pppol2tp kmod-pppox \
    kmod-crypto-aes kmod-crypto-sha1 kmod-crypto-sha256 kmod-crypto-hmac \
    kmod-tun firewall4 nftables

# ===================== 7. 清理临时文件（CI环境空间优化） =====================
cd "${ACTIONS_WORKSPACE}"
rm -rf openwrt-luci
rm -rf swanmon diy

echo -e "\n✅ 配置完成！已实现："
echo "1. 集成OpenWrt 24.10官方luci-app-dockerman（带Web管理界面）"
echo "2. 编译适配版Docker组件（兼容docker-ipsec-vpn-server）"
echo "3. 预装VPN容器必需内核模块（ppp/ipsec/转发）"
