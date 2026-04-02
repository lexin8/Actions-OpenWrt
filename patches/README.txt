Overlay for GitHub Actions CI (see ../.github/workflows/FanchmWrt.yml).

- patches/fanchmwrt/package/fcm/ — copy onto $OPENWRT_PATH/package/fcm/ after cloning fanchmwrt.
- patches/luci-app-fwx-dashboard-setting/ — copy setting.htm into feeds/fanchmwrt/... after ./scripts/feeds update -a.

Commit this entire FanchmWrt-workflow folder as the root of your Actions repo (or merge into your existing repo).
