{
  stdenv,
  makeWrapper,
  autoPatchelfHook,

  # denpendencies
  libgcc,
  libxcrypt-legacy,
  libuuid,
  libpng12,
  libjpeg,
  libudev0-shim,
  libz,
  atk,
  bash,
  coreutils,
  ell,
  glib,
  cairo,
  ncurses5,
  pango,
  gtk2,
  gdk-pixbuf,
  freetype,
  fontconfig,
  xorg, # libSM, libX11, libXxf86vm
  ...
}:
let
  install_dir = "/opt/iNodeClient";
  libraries = [
    libgcc
    libxcrypt-legacy
    libuuid
    libpng12
    libjpeg
    libudev0-shim
    libz
    atk
    ell
    bash
    coreutils
    glib
    cairo
    ncurses5
    pango
    gtk2
    gdk-pixbuf
    freetype
    fontconfig
    xorg.libSM
    xorg.libX11
    xorg.libXxf86vm
  ];
in
stdenv.mkDerivation rec {
  pname = "inode-client";
  version = "7.3.0";

  src = fetchTarball {
    url = "https://download.h3c.com/app/cn/download.do?id=7684846";
    sha256 = "0y92bia0xcm6d8al3vzkgglcqd63z09lkssvi9ihsz6m1kabwxyl";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = libraries;

  installPhase = ''
    # 安装应用文件
    mkdir -p $out${install_dir}

    for i in $(ls $src); do
      if [ $i == "$src/clientfiles" ]; then
        continue
      fi

      cp -rv $i $out${install_dir}
    done
    cp -rv $src/.iNode $out${install_dir}

    sed -i 's|#!/bin/sh|#!/usr/bin/env sh|' $out${install_dir}/renew.ps
    chmod +x $out${install_dir}/renew.ps

    # 禁用 enablecards.ps （清空文件内容）
    sed 's|#!/bin/sh|#!/usr/bin/env sh|' $out${install_dir}/enablecards.ps | head -n 1 | tee $out${install_dir}/enablecards.ps
    chmod +x $out${install_dir}/enablecards.ps

    # 客户端配置目录
    rm -rf $out${install_dir}/clientfiles
    ln -sf /var/lib/inode/clientfiles $out${install_dir}/
    ln -sf /var/lib/inode/Data $out${install_dir}/

    mkdir -p $out/var/lib/inode/conf
    mv $out${install_dir}/conf/iNode.conf $out/var/lib/inode/conf
    rm $out${install_dir}/conf -rf
    ln -sf /var/lib/inode/conf $out${install_dir}/

    # 日志目录
    rm -rf $out${install_dir}/log
    ln -sf /var/log/inode $out${install_dir}/log

    # 快捷方式
    mkdir -p $out/share/applications
    cat $out${install_dir}/iNodeClient.desktop | sed "/^Exec=/s#@INSTALL_PATH/iNodeClient.sh#$out${install_dir}/.iNode/iNodeClient#" | sed "/^Icon=/s#@INSTALL_PATH#$out${install_dir}#" > $out/share/applications/iNodeClient.desktop

    # /etc 目录文件
    mkdir -p $out/etc/iNode
    echo INSTALL_DIR=$out${install_dir} > $out/etc/iNode/inodesys.conf

    # 运行文件
    mkdir -p $out/bin
    cat > $out/bin/${pname} <<EOF
    #!/usr/bin/env bash
    $out${install_dir}/.iNode/iNodeClient
    EOF
    chmod +x $out/bin/${pname}

    cat > $out/bin/setup <<EOF
    #!/usr/bin/env bash
    [ -d /var/lib/inode/clientfiles/7000 ] || mkdir -p /var/lib/inode/clientfiles/7000
    [ -d /var/lib/inode/Data ] || mkdir -p /var/lib/inode/Data
    [ -d /var/lib/inode/conf ] || mkdir -p /var/lib/inode/conf
    [ -e /var/lib/inode/conf/iNode.conf ] || cp $out/var/lib/inode/conf/iNode.conf /var/lib/inode/conf
    chmod 777 -R /var/lib/inode/*

    [ -d /var/log/inode/cmd ] || mkdir -p /var/log/inode/cmd 
    chmod 777 -R /var/log/inode
    EOF
    chmod +x $out/bin/setup

    cat > $out/bin/AuthenMngService <<EOF
    #!/usr/bin/env bash

    $out${install_dir}/iNodeMon \$@
    $out${install_dir}/AuthenMngService \$@
    EOF
    chmod +x $out/bin/AuthenMngService
  '';
}
