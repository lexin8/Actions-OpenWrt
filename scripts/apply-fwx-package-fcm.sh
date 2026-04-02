#!/usr/bin/env bash
set -euo pipefail
# Usage: apply-fwx-package-fcm.sh <OPENWRT_PATH> <GITHUB_WORKSPACE>
OW="${1:?OPENWRT_PATH}"
WS="${2:?GITHUB_WORKSPACE}"
SRC="${WS}/patches/fanchmwrt/package/fcm"
if [[ ! -d "${SRC}/fwx/src" ]]; then
  echo "::error::Missing ${SRC} — add patches/fanchmwrt/package/fcm to this repo"
  exit 1
fi
cp -a "${SRC}/." "${OW}/package/fcm/"
echo "Applied overlay: package/fcm (kmod-fwx + fwxd sources)."
