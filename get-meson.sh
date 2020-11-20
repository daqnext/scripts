#!/bin/bash
# Copyright 2020 Daqnext Foundation Ltd.

## Update this with any new relase!
VERSION_STABLE="0.1.1"
##

ARCH=$(uname -m)
SERVICE_URL="https://meson.network/meson-binaries?architecture=$ARCH"

check_os() {
  if [ "$(uname)" = "Linux" ] ; then
  PKG="linux"   # linux is my default 

  elif [ "$(uname)" = "Darwin" ] ; then
    PKG="darwin"
    echo "Running on Apple"
  else
    echo "Unknown operating system"
    echo "Please select your operating system"
    echo "Choices:"
    echo "       linux - any linux distro"
    echo "       darwin - MacOS"
    read -r PKG
  fi
}

get_package() {
  LOOKUP_URL="$SERVICE_URL&os=$PKG&version=v$VERSION_STABLE"
  MD=$(curl -S "${LOOKUP_URL}")
  DOWNLOAD_FILE=$(echo "$MD" | grep -oE 'https://[^)]+')
}

check_upgrade() {
  echo "$DOWNLOAD_FILE"
  NEW_VERSION=$(echo "$DOWNLOAD_FILE" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | tr -d 'v')

  # Determine old (installed) Version 
  meson_bin=$(which meson)

  if [ -z "$meson_bin" ] ; then
    OLD_VERSION="0.0.0"
  else
    OLD_VERSION=$(meson --version | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | tr -d 'v')
  fi

  if [ "$NEW_VERSION" = "$OLD_VERSION" ] ; then
    echo "Meson $NEW_VERSION already installed"
    exit 1
  fi

  if  version_gt "$NEW_VERSION" "$OLD_VERSION"  ; then
    echo "Upgrading meson from $OLD_VERSION to $NEW_VERSION"
  else
    echo "Existing version of meson: $OLD_VERSION is newer than the version you attempting to install: $NEW_VERSION"
    exit 1
  fi
}

install() {
  TMPDIR=$(mktemp -d) && cd "$TMPDIR" || exit
  curl -Ss -O "$DOWNLOAD_FILE"
#  TODO: check_sha256

  if [ "$PKG" = "linux" ] ; then
    sudo cp "$TMPDIR"/meson /usr/bin && sudo chmod +x /usr/bin/meson
  fi

  if [ "$PKG" = "darwin" ] ; then
    sudo cp "$TMPDIR"/meson /usr/local/bin && sudo chmod +x /usr/local/bin/meson
  fi
}

version_gt() {
    printf '%s\n' "$@"
	test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1";
}

cleanup() {
  rm "$TMPDIR"/*
  rmdir "$TMPDIR"
}

## MAIN ##

cat << "EOF"
+====================================================================================+
|      __  __                         _   _      _                      _
|     |  \/  |                       | \ | |    | |                    | |
|     | \  / | ___  ___  ___  _ __   |  \| | ___| |___      _____  _ __| | __
|     | |\/| |/ _ \/ __|/ _ \| '_ \  | . ` |/ _ \ __\ \ /\ / / _ \| '__| |/ /
|     | |  | |  __/\__ \ (_) | | | | | |\  |  __/ |_ \ V  V / (_) | |  |   <
|     |_|  |_|\___||___/\___/|_| |_| |_| \_|\___|\__| \_/\_/ \___/|_|  |_|\_\
=====================================================================================+

EOF
sleep 1

## curl installed? 
if ! which curl &> /dev/null ; then
    echo '"curl" binary not found, please install and retry'
    exit 1
fi
##

check_os
get_package
check_upgrade
install
cleanup
