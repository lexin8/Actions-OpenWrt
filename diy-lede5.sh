#!/bin/bash
echo "\n----------- 开始进入指定文件夹 --------------\n";
cd package/lean/
# 添加主题
rm -rf luci-theme*
# 删除配置
grep -rnl 'luci.main.mediaurlbase' ./ | xargs sed -i '/luci.main.mediaurlbase/d'
cd ../ && cd ../ 
rm -rf feeds/diy1/v2ray
# 添加插件
git clone https://github.com/kenzok8/openwrt-packages.git kenzok8
