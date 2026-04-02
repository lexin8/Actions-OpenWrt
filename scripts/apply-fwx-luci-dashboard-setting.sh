#!/usr/bin/env bash
set -euo pipefail
# Usage: apply-fwx-luci-dashboard-setting.sh <OPENWRT_PATH> <GITHUB_WORKSPACE>
OW="${1:?OPENWRT_PATH}"
WS="${2:?GITHUB_WORKSPACE}"
LUCISRC="${WS}/patches/luci-app-fwx-dashboard-setting/luasrc/view/fwx_dashboard_setting/setting.htm"
FEED="${OW}/feeds/fanchmwrt/luci-app-fwx-dashboard-setting/luasrc/view/fwx_dashboard_setting"
if [[ ! -f "${LUCISRC}" ]]; then
  echo "::warning::LuCI patch not found: ${LUCISRC}"
  exit 0
fi
if [[ ! -d "${OW}/feeds/fanchmwrt" ]]; then
  echo "::warning::feeds/fanchmwrt missing — run after ./scripts/feeds update -a"
  exit 0
fi
mkdir -p "${FEED}"
cp -f "${LUCISRC}" "${FEED}/setting.htm"
echo "Patched luci-app-fwx-dashboard-setting/setting.htm"
