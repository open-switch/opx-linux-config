#!/usr/bin/env bash
set -euo pipefail
set -x

work="$(readlink -f "$(dirname "$0")")"

version="$(cat "$work/VERSION")"
debian_with_opx="${version##*-}"

: "${UPSTREAM:=${version%%-*}}"
: "${DEBIAN:=${debian_with_opx%opx*}}"
: "${OPX:=${debian_with_opx#*opx}}"
: "${PARALLELISM:=$(grep -c ^processor /proc/cpuinfo)}"

# Enable source packages
sudo sed -i 's/deb \(.*\)/&\ndeb-src \1/' /etc/apt/sources.list
if [[ -e /etc/apt/sources.list.d/20extra.list ]]; then
  sudo sed -i 's/deb \(.*\)/&\ndeb-src \1/' /etc/apt/sources.list.d/20extra.list
fi

sudo apt update
sudo apt-get build-dep -y "linux=${UPSTREAM}-${DEBIAN}"
apt-get source "linux=${UPSTREAM}-${DEBIAN}"

cd "linux-${UPSTREAM}"
fakeroot make -f debian/rules.gen "setup_${ARCH}_none_${ARCH}"
cp "${work}/${UPSTREAM}-${DEBIAN}.config" "debian/build/build_${ARCH}_none_${ARCH}/.config"
sed -i "s,${UPSTREAM}-${DEBIAN},${UPSTREAM}-${DEBIAN}opx${OPX}," debian/changelog

echo "--- Kernel image build"
time DEBIAN_KERNEL_USE_CCACHE=true DEBIAN_KERNEL_JOBS=$PARALLELISM \
  fakeroot make  "-j$PARALLELISM" -f debian/rules.gen "binary-arch_${ARCH}_none_${ARCH}"

echo "--- Kernel headers common build"
fakeroot make  "-j$PARALLELISM" -f debian/rules.gen "binary-arch_${ARCH}_none_real"
