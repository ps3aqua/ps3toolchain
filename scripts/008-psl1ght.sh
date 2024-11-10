#!/bin/sh -e
# psl1ght.sh by Naomi Peori (naomi@peori.ca)

PSL1GHT_VERSION=${PSL1GHT_VERSION:="dcc440c636d21cb475a324e5fd85706f4b7befe8"}

## Download the source code.
wget "https://github.com/ps3aqua/PSL1GHT/archive/${PSL1GHT_VERSION}.tar.gz" -O psl1ght-${PSL1GHT_VERSION}.tar.gz

## Unpack the source code.
rm -Rf psl1ght && mkdir psl1ght && tar --strip-components=1 --directory=psl1ght -xzf psl1ght-${PSL1GHT_VERSION}.tar.gz

## Create the build directory.
cd psl1ght

## Compile and install.
PROCS="$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)" || ret=$?
if [ ! -z $ret ]; then PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"; fi
${MAKE:-make} install-ctrl && ${MAKE:-make} -j $PROCS && ${MAKE:-make} install
