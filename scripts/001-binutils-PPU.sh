#!/bin/sh -e
# binutils-PPU.sh by Naomi Peori (naomi@peori.ca)

BINUTILS="binutils-2.42"

if [ ! -d ${BINUTILS} ]; then

  ## Download the source code.
  if [ ! -f ${BINUTILS}.tar.bz2 ]; then wget --continue https://ftp.gnu.org/gnu/binutils/${BINUTILS}.tar.bz2; fi

  ## Download an up-to-date config.guess and config.sub
  if [ ! -f config.guess ]; then wget --continue https://git.savannah.gnu.org/cgit/config.git/plain/config.guess; fi
  if [ ! -f config.sub ]; then wget --continue https://git.savannah.gnu.org/cgit/config.git/plain/config.sub; fi

  ## Unpack the source code.
  tar xfj ${BINUTILS}.tar.bz2

  ## Patch the source code.
  if [ -f ../patches/${BINUTILS}-PS3-PPU.patch ]; then cat ../patches/${BINUTILS}-PS3-PPU.patch | patch -p1 -d ${BINUTILS}; fi

  ## Replace config.guess and config.sub
  cp config.guess config.sub ${BINUTILS}

fi

if [ ! -d ${BINUTILS}/build-ppu ]; then

  ## Create the build directory.
  mkdir ${BINUTILS}/build-ppu

fi

## Enter the build directory.
cd ${BINUTILS}/build-ppu

## Configure the build.
../configure --prefix="$PS3DEV/ppu" --target="powerpc64-ps3-elf" \
    --disable-nls \
    --disable-shared \
    --disable-debug \
    --disable-dependency-tracking \
    --disable-werror \
    --enable-64-bit-bfd \
    --with-gcc \
    --with-gnu-as \
    --with-gnu-ld

## Compile and install.
PROCS="$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)" || ret=$?
if [ ! -z $ret ]; then PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"; fi
${MAKE:-make} -j $PROCS && ${MAKE:-make} libdir=$(pwd)/host-libs/lib install
