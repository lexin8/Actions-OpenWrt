#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
#拉取源码
# git clone https://github.com/lexin8/kernel opt
cd openwrt
# git reset --hard f833707a78974af47ddbe1f7e038bf62b463f633
sed -i '$a src-git luci https://github.com/immortalwrt/luci.git' feeds.conf.default
sed -i '2d' feeds.conf.default
sed -i 's/192.168.1.1/192.168.10.253/g' package/base-files/files/bin/config_generate
rm -rf feeds/packages/lang/golang
git clone https://github.com/kenzok8/golang feeds/packages/lang/golang
./scripts/feeds update -a
./scripts/feeds install -a

#cd package && git clone https://github.com/fw876/helloworld.git




