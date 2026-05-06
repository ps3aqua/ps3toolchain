#!/bin/sh -e
# gdb-SPU.sh by Naomi Peori (naomi@peori.ca)

GDB="gdb-8.3.1"

if [ ! -d ${GDB} ]; then

  ## Download the source code.
  if [ ! -f ${GDB}.tar.gz ]; then wget --continue https://ftp.gnu.org/gnu/gdb/${GDB}.tar.gz; fi

  ## Unpack the source code.
  tar xfz ${GDB}.tar.gz

  ## Patch the source code.
  cat ../patches/${GDB}-PS3.patch | patch -p1 -d ${GDB}

  ## Replace config.guess and config.sub
  cp ../assets/config.guess ../assets/config.sub .

fi

if [ ! -d ${GDB}/build-spu ]; then

  ## Create the build directory.
  mkdir ${GDB}/build-spu

fi

## Enter the build directory.
cd ${GDB}/build-spu

## Configure the build.
../configure --prefix="$PS3DEV/spu" --target="spu" \
    --disable-nls \
    --disable-sim \
    --disable-werror \
    --without-python \
    --with-system-zlib

## Compile and install.
PROCS="$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)" || ret=$?
if [ ! -z $ret ]; then PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"; fi
${MAKE:-make} -j $PROCS && ${MAKE:-make} libdir=host-libs/lib install
