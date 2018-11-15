#!/usr/bin/env bash
set -euo pipefail
set -x

work="$(dirname "$0")"

version="$(cat "$work/VERSION")"
debian_with_opx="${version##*-}"

: "${UPSTREAM:=${version%%-*}}"
: "${DEBIAN:=${debian_with_opx%opx*}}"
: "${OPX:=${debian_with_opx#*opx}}"
: "${PARALLELISM:=$(grep -c ^processor /proc/cpuinfo)}"

# Enable source packages
sudo sed -i 's/deb \(.*\)/&\ndeb-src \1/' /etc/apt/sources.list

sudo apt update
sudo apt-get build-dep -y "linux=${UPSTREAM}-${DEBIAN}"
apt-get source "linux=${UPSTREAM}-${DEBIAN}"

cp "${work}/${UPSTREAM}-${DEBIAN}.config" "linux-${UPSTREAM}/.config"

env -u ARCH make -C "linux-${UPSTREAM}" "-j$PARALLELISM" bindeb-pkg \
  LOCALVERSION=-opx \
  KDEB_PKGVERSION="${UPSTREAM}-${DEBIAN}opx${OPX}"
