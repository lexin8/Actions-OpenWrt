  
#!/bin/bash
#============================================================
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#============================================================

# Modify default IP
sed -i 's/192.168.1.1/192.168.10.253/g' package/base-files/files/bin/config_generate

# Delete default password
# sed -i "/CYXluq4wUazHjmCDBCqXF/d" package/default-settings/files/zzz-default-settings

# 修改主机名字，把OpenWrt-123修改你喜欢的就行（不能使用中文）
# sed -i '/uci commit system/i\uci set system.@system[0].hostname='OpenWrt-123'' package/default-settings/files/zzz-default-settings

# 内核显示增加自己个性名称（281677160 build $(TZ=UTC-8 date "+%Y.%m.%d") @ 这些为后期增加）
sed -i "s/R22.5.5/R22.5.5 build $(TZ=UTC-8 date "+%Y-%m-%d") /g" package/lean/default-settings/files/zzz-default-settings

# 修改 argon 为默认主题,可根据你喜欢的修改成其他的（不选择那些会自动改变为默认主题的主题才有效果）
# sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 修改内核版本
#sed -i 's/KERNEL_PATCHVER:=4.14/KERNEL_PATCHVER:=4.19/g' target/linux/x86/Makefile

# 修改插件名字（修改名字后不知道会不会对插件功能有影响，自己多测试）
# sed -i '/msgstr/ { s/ShadowSocksR Plus+ 设置/科学上网设置/g;  s/ShadowSocksR/科学上网/g; }' package/helloworld/luci-app-ssr-plus/po/zh-cn/ssr-plus.po
# sed -i 's/"ShadowSocksR Plus+"/"科学上网"/g' package/helloworld/luci-app-ssr-plus/luasrc/controller/shadowsocksr.lua
# sed -i "s#ShadowsocksR Plus+ #科学上网程序#g" package/helloworld/luci-app-ssr-plus/luasrc/view/shadowsocksr/status.htm
# sed -i 's/"PassWall"/"正确翻墙姿势✔"/g' feeds/diy1/luci-app-passwall/po/zh-cn/passwall.po

find . -name ssr-plus.po | xargs sed -i '/msgstr/ { s/ShadowSocksR Plus+ 设置/科学上网设置/g;  s/ShadowSocksR/科学上网Plus+/g; }'
find . -name shadowsocksr.lua | xargs sed -i 's/"ShadowSocksR Plus+"/"科学上网Plus+"/g'
find . -name status.htm | xargs sed -i "s#ShadowsocksR Plus+ #科学上网程序#g"
#find . -name passwall.po | xargs sed -i 's/"PassWall"/"帕斯沃"/g'
find . -name vssr.lua | xargs sed -i "s/Hello World/科学上网国旗版/g"
find . -name vssr.po | xargs sed -i '/msgstr/s/Hello World/SSR+国旗版/g'

sed -i 's/os.date(),/os.date("%Y-%m-%d %H:%M:%S"),/g' package/lean/autocore/files/x86/index.htm
sed -i 's/os.date(),/os.date("%Y-%m-%d %H:%M:%S"),/g' package/lean/autocore/files/arm/index.htm

# sed -i 's/PassWall/正确翻墙翻墙✔/g' package/openwrt-packages/luci-app-passwall/Makefile
# sed -i 's/"BaiduPCS Web"/"百度网盘"/g' package/lean/luci-app-baidupcs-web/luasrc/controller/baidupcs-web.lua
# sed -i 's/cbi("qbittorrent"),_("qBittorrent")/cbi("qbittorrent"),_("BT下载")/g' package/lean/luci-app-qbittorrent/luasrc/controller/qbittorrent.lua
# sed -i 's/"aMule设置"/"电驴下载"/g' package/lean/luci-app-amule/po/zh-cn/amule.po
# sed -i 's/"网络存储"/"存储"/g' package/lean/luci-app-amule/po/zh-cn/amule.po
# sed -i 's/"网络存储"/"存储"/g' package/lean/luci-app-vsftpd/po/zh-cn/vsftpd.po
# sed -i 's/"Turbo ACC 网络加速"/"网络加速"/g' package/lean/luci-app-flowoffload/po/zh-cn/flowoffload.po
# sed -i 's/"Turbo ACC 网络加速"/"网络加速"/g' package/lean/luci-app-sfe/po/zh-cn/sfe.po
# sed -i 's/"实时流量监测"/"流量"/g' package/lean/luci-app-wrtbwmon/po/zh-cn/wrtbwmon.po
# sed -i 's/"KMS 服务器"/"KMS激活"/g' package/lean/luci-app-vlmcsd/po/zh-cn/vlmcsd.zh-cn.po
# sed -i 's/"USB 打印服务器"/"打印服务"/g' package/lean/luci-app-usb-printer/po/zh-cn/usb-printer.po
# sed -i 's/"网络存储"/"存储"/g' package/lean/luci-app-usb-printer/po/zh-cn/usb-printer.po
# sed -i 's/TTYD 终端/命令窗/g' feeds/luci/transplant/luci-app-ttyd/po/zh-cn/terminal.po
# sed -i 's/"Web 管理"/"Web管理"/g' package/lean/luci-app-webadmin/po/zh-cn/webadmin.po
# sed -i 's/"管理权"/"改密码"/g' feeds/luci/modules/luci-base/po/zh-cn/base.po
# sed -i 's/"带宽监控"/"监视"/g' feeds/luci/applications/luci-app-nlbwmon/po/zh-cn/nlbwmon.po

#system menu
# sed -i 's/"Web 管理"/"Web管理"/g' `grep "Web 管理" -rl ./`
# sed -i 's/"管理权"/"密码设置"/g' feeds/luci/modules/luci-base/po/zh-cn/base.po
# sed -i 's/"重启"/"立即重启"/g' feeds/luci/modules/luci-base/po/zh-cn/base.po
# sed -i 's/"系统"/"系统设置"/g' feeds/luci/modules/luci-base/po/zh-cn/base.po
# sed -i 's/"挂载点"/"挂载路径"/g' feeds/luci/modules/luci-base/po/zh-cn/base.po
sed -i 's/"启动项"/"启动管理"/g' feeds/luci/modules/luci-base/po/zh-cn/base.po
# sed -i 's/"软件包"/"软件管理"/g' feeds/luci/modules/luci-base/po/zh-cn/base.po
# sed -i 's/"TTYD 终端"/"命令终端"/g' package/lean/luci-app-ttyd/po/zh-cn/terminal.po
# sed -i 's/"Argon 主题设置"/"主题设置"/g' `grep "Argon 主题设置" -rl ./`

#others
# sed -i 's/"网络存储"/"存储"/g' `grep "网络存储" -rl ./`
# sed -i 's/"Turbo ACC 网络加速"/"网络加速"/g' package/lean/luci-app-turboacc/po/zh-cn/turboacc.po
# sed -i 's/"实时流量监测"/"流量"/g' `grep "实时流量监测" -rl ./`
# sed -i 's/"USB 打印服务器"/"打印服务"/g' `grep "USB 打印服务器" -rl ./`
# sed -i 's/"带宽监控"/"监控"/g' `grep "带宽监控" -rl ./`

#services menu
# sed -i 's/"阿里云盘 WebDAV"/"阿里云盘"/g' `grep "阿里云盘 WebDAV" -rl ./`
# sed -i 's/"DDNS.to内网穿透"/"DDNSTO"/g' `grep "DDNS.to内网穿透" -rl ./`
# sed -i 's/"解锁网易云灰色歌曲"/"网易音乐"/g' package/lean/luci-app-unblockmusic/po/zh-cn/unblockmusic.po
# sed -i 's/天翼家庭云\/云盘提速/天翼云盘/g' package/lean/luci-app-familycloud/luasrc/controller/familycloud.lua
# sed -i 's/"KMS 服务器"/"KMS激活"/g' `grep "KMS 服务器" -rl ./`
# sed -i 's/"UU游戏加速器"/"UU加速器"/g' `grep "UU游戏加速器" -rl ./`
# sed -i 's/"Frp 内网穿透"/"Frp 客户端"/g' `grep "Frp 内网穿透" -rl ./`
# sed -i 's/UU游戏加速器/UU加速器/g' package/lean/luci-app-uugamebooster/po/zh-cn/uuplugin.po
# sed -i 's/ShadowSocksR Plus+/SSR Plus+/g' package/waynesg/luci-app-ssr-plus/luci-app-ssr-plus/luasrc/controller/shadowsocksr.lua
# sed -i 's/msgstr "UPnP"/msgstr "UPnP服务"/g' feeds/luci/applications/luci-app-upnp/po/zh-cn/upnp.po
# sed -i 's/"Adblock Plus+"/"广告过滤"/g' `grep "Adblock Plus+" -rl ./`
# sed -i 's/"Rclone"/"Rclone挂载"/g' package/lean/luci-app-rclone/luasrc/controller/rclone.lua
