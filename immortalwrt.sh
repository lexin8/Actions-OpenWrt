#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
#拉取源码
# git clone https://github.com/lexin8/kernel opt
cd openwrt
# git reset --hard f833707a78974af47ddbe1f7e038bf62b463f633
# sed -i '2d,6' feeds.conf.default
sed -i 's/192.168.1.1/192.168.10.253/g' package/base-files/files/bin/config_generate
# sed -i '$a src-git packages https://github.com/immortalwrt/packages.git' feeds.conf.default
# sed -i '$a src-git luci https://github.com/immortalwrt/luci.git' feeds.conf.default
# sed -i '$a src-git routing https://github.com/openwrt/routing.gitt' feeds.conf.default
# sed -i '$a src-git telephony https://github.com/openwrt/telephony.git' feeds.conf.default

./scripts/feeds update -a
./scripts/feeds install -a

# git clone https://github.com/xiaorouji/openwrt-passwall-packages.git
#cd package && git clone https://github.com/fw876/helloworld.git




