name: fanchmwrt

on:
  repository_dispatch:
  watch:
    types: started
  workflow_dispatch:
    inputs:
      ssh:
        description: 'SSH connection to Actions'
        required: true
        default: 'false'

env:
  CONFIG_FILE: istoreos.config
  CONFIG_FILE2: fanchmwrt.config
  DIY_P1_SH: fanchmwrt.sh
  DIY_P2_SH: l2tp.sh
  DIY_P3_SH: diy-part3.sh
  SSH_ACTIONS: false
  UPLOAD_BIN_DIR: false
  UPLOAD_FIRMWARE: true
  ENABLE_L2TP_COMPONENTS: false
  UPLOAD_SOFTETHERVPN: false
  UPLOAD_COWTRANSFER: true
  UPLOAD_RELEASE: true
  UPLOAD_WETRANSFER: false
  REPO_URL: https://github.com/immortalwrt/immortalwrt
  REPO_URL2: https://github.com/fanchmwrt/fanchmwrt
  REPO_URL3: https://github.com/openwrt/openwrt
  REPO_BRANCH: openwrt-23.05
  REPO_BRANCH2: main  # 核心修正：改为fanchmwrt仓库实际存在的分支（如main）
  REPO_BRANCH3: openwrt-23.05
  DIY_SCRIPT: diy-script.sh
  CLASH_KERNEL: amd64
  CACHE_TOOLCHAIN: true
  FIRMWARE_RELEASE: true
  FIRMWARE_TAG: X86_64
  TZ: Asia/Shanghai

jobs:
  Build:
    runs-on: ubuntu-22.04

    steps:
      - name: Check Server Performance
        run: |
          echo "警告⚠"
          echo "分配的服务器性能有限，若选择的插件过多，务必注意CPU性能！"
          echo -e "已知CPU型号(降序): 7763，8370C，8272CL，8171M，E5-2673\n"
          echo "--------------------------CPU信息--------------------------"
          echo "CPU物理数量: $(cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l)"
          echo "CPU核心数量: $(nproc)"
          echo -e "CPU型号信息:$(cat /proc/cpuinfo | grep -m1 name | awk -F: '{print $2}')\n"
          echo "--------------------------内存信息--------------------------"
          echo "已安装内存详细信息:"
          echo -e "$(sudo lshw -short -C memory | grep GiB)\n"
          echo "--------------------------硬盘信息--------------------------"
          echo "硬盘数量: $(ls /dev/sd* | grep -v [1-9] | wc -l)" && df -hT

      - name: Initialization Environment
        env:
          DEBIAN_FRONTEND: noninteractive
        run: |
          sudo rm -rf /usr/share/dotnet /etc/apt/sources.list.d /usr/local/lib/android $AGENT_TOOLSDIRECTORY
          sudo -E apt-get -y purge azure-cli ghc* zulu* llvm* firefox google* dotnet* powershell openjdk* mongodb* moby* || true
          sudo -E apt-get -y update
          sudo -E apt-get -y install $(curl -fsSL is.gd/depends_ubuntu_2204)
          sudo -E systemctl daemon-reload
          sudo -E apt-get -y autoremove --purge
          sudo -E apt-get -y clean
          sudo timedatectl set-timezone "$TZ"

      - name: Combine Disks
        uses: easimon/maximize-build-space@master
        with:
          swap-size-mb: 1024
          temp-reserve-mb: 100
          root-reserve-mb: 1024

      - name: Checkout
        uses: actions/checkout@main

      - name: Clone OpenWrt Official Source (Main)
        run: |
          df -hT $GITHUB_WORKSPACE
          git clone $REPO_URL3 -b $REPO_BRANCH3 openwrt
          cd openwrt
          echo "OPENWRT_PATH=$PWD" >> $GITHUB_ENV
          COMMIT_AUTHOR=$(git show -s --date=short --format="作者: %an")
          echo "COMMIT_AUTHOR=$COMMIT_AUTHOR" >> $GITHUB_ENV
          COMMIT_DATE=$(git show -s --date=short --format="时间: %ci")
          echo "COMMIT_DATE=$COMMIT_DATE" >> $GITHUB_ENV
          COMMIT_MESSAGE=$(git show -s --date=short --format="内容: %s")
          echo "COMMIT_MESSAGE=$COMMIT_MESSAGE" >> $GITHUB_ENV
          COMMIT_HASH=$(git show -s --date=short --format="hash: %H")
          echo "COMMIT_HASH=$COMMIT_HASH" >> $GITHUB_ENV

      - name: Clone immortalwrt (Helper)
        run: |
          df -hT $GITHUB_WORKSPACE
          git clone $REPO_URL -b $REPO_BRANCH immortalwrt
          cd immortalwrt
          ./scripts/feeds update -a
          ./scripts/feeds install -a

      - name: Clone fanchmwrt (UI/Components)
        run: |
          df -hT $GITHUB_WORKSPACE
          # 核心优化：添加分支不存在的容错逻辑
          git clone $REPO_URL2 fanchmwrt-src
          cd fanchmwrt-src
          # 尝试切换到指定分支，失败则用main分支
          git checkout $REPO_BRANCH2 || git checkout main
          ./scripts/feeds update -a
          ./scripts/feeds install -a

      - name: Cache Toolchain
        if: env.CACHE_TOOLCHAIN == 'true'
        uses: HiGarfield/cachewrtbuild@main
        with:
          ccache: false
          mixkey: ${{ env.REPO_URL3 }}-${{ env.REPO_BRANCH3 }}-${{ env.DEVICE_TARGET }}-${{ env.DEVICE_SUBTARGET }}
          prefix: ${{ env.OPENWRT_PATH }}

      - name: Install Feeds (OpenWrt Official)
        run: |
          cd $OPENWRT_PATH
          ./scripts/feeds update -a
          ./scripts/feeds install -a

      - name: 运行一键部署脚本（集成fanchmwrt界面+组件）
        run: |
          chmod +x $DIY_P1_SH
          ./$DIY_P1_SH

      - name: 配置编译参数
        run: |
          cd $OPENWRT_PATH
          rm -rf .config
          [ -e ../files ] && mv ../files ./files
          [ -e ../$CONFIG_FILE2 ] && mv ../$CONFIG_FILE2 ./.config

      - name: 运行L2TP组件追加脚本
        if: env.ENABLE_L2TP_COMPONENTS == 'true' && !cancelled()
        run: |
          chmod +x ../$DIY_P2_SH
          cd $OPENWRT_PATH
          ../$DIY_P2_SH

      - name: softethervpn
        id: softethervpn
        if: env.UPLOAD_SOFTETHERVPN == 'true' && !cancelled()
        run: |
          git clone https://github.com/lexin8/Actions-OpenWrt lexin8
          cd $OPENWRT_PATH/feeds/packages/net/
          rm -rf softethervpn* || true
          cp -r $GITHUB_WORKSPACE/lexin8/softethervpn . || true
          cp -r $GITHUB_WORKSPACE/lexin8/softethervpn5 . || true

      - name: SSH connection to Actions
        uses: P3TERX/ssh2actions@v1.0.0
        if: (github.event.inputs.ssh == 'true' && github.event.inputs.ssh  != 'false') || contains(github.event.action, 'ssh')
        env:
          TELEGRAM_CHAT_ID: ${{ secrets.TELEGRAM_CHAT_ID }}
          TELEGRAM_BOT_TOKEN: ${{ secrets.TELEGRAM_BOT_TOKEN }}

      - name: 下载 package
        id: package
        run: |
          cd $OPENWRT_PATH
          make defconfig
          make download -j8
          find dl -size -1024c -exec ls -l {} \;
          find dl -size -1024c -exec rm -f {} \;

      - name: 开始编译固件
        id: compile
        run: |
          cd $OPENWRT_PATH
          echo -e "$(nproc) thread compile"
          make -j$(nproc) || make -j1 || make -j1 V=s
          echo "::set-output name=status::success"

      - name: 搜索固件
        run: |
          cd $OPENWRT_PATH/bin/
          find . -name "*squashfs*"

      - name: 整理固件文件
        id: organize
        if: env.UPLOAD_FIRMWARE == 'true' && !cancelled()
        run: |
          cd $OPENWRT_PATH/bin/
          TARGET_DIR=$(find . -name "*squashfs*"  | head -n 1 | xargs dirname)
          if [ -z "$TARGET_DIR" ]; then
              echo "错误：未找到squashfs固件目录"
              exit 1
          fi
          cd $TARGET_DIR
          ls
          rm -rf packages || true
          find . -name "*ext4*" | xargs rm -rf || true
          find . -name "*root*" | xargs rm -rf || true
          tar czvf $(date +%Y.%m.%d.%H)_OpenWrt.tar.gz config.buildinfo *.img.gz
          ls | grep -v OpenWrt.tar.gz | xargs rm -f || true
          ls
          echo "::set-output name=FIRMWARE::$PWD"
          echo "::set-output name=status::success"

      - name: 上传固件到Artifact
        uses: actions/upload-artifact@master
        if: steps.organize.outputs.status == 'success' && !cancelled()
        with:
          name: OpenWrt_firmware_${{ env.FIRMWARE_TAG }}_${{ github.run_id }}
          path: ${{ steps.organize.outputs.FIRMWARE }}
