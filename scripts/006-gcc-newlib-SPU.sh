#!/bin/sh -e
# gcc-newlib-SPU.sh by Naomi Peori (naomi@peori.ca)

GCC="gcc-7.5.0"
NEWLIB="4.2.0.20211231"

if [ ! -d "${GCC}-SPU" ]; then

  ## Download the source code.
  if [ ! -f ${GCC}.tar.xz ]; then wget --continue https://ftp.gnu.org/gnu/gcc/${GCC}/${GCC}.tar.xz; fi
  if [ ! -f newlib-${NEWLIB}.tar.gz ]; then wget --continue https://sourceware.org/pub/newlib/newlib-${NEWLIB}.tar.gz; fi

  ## Unpack the source code.
  rm -Rf ${GCC}-tmp && mkdir -p ${GCC}-tmp && tar xfJ ${GCC}.tar.xz -C ${GCC}-tmp && mv ${GCC}-tmp/${GCC} ${GCC}-SPU && rm -Rf ${GCC}-tmp
  rm -Rf newlib-ps3-${NEWLIB} && tar xfz newlib-${NEWLIB}.tar.gz

  ## Patch the source code.
  cat ../patches/${GCC}-PS3.patch | patch -p1 -d ${GCC}-SPU
  cat ../patches/newlib-${NEWLIB}-PS3.patch | patch -p1 -d newlib-${NEWLIB}

  ## Enter the source code directory.
  cd ${GCC}-SPU

  ## Create the newlib symlinks.
  ln -s ../newlib-${NEWLIB}/newlib newlib
  ln -s ../newlib-${NEWLIB}/libgloss libgloss

  ## Download the prerequisites.
  ./contrib/download_prerequisites

  ## Leave the source code directory.
  cd ..

fi

if [ ! -d ${GCC}-SPU/build-spu ]; then

  ## Create the build directory.
  mkdir ${GCC}-SPU/build-spu

fi

## Enter the build directory.
cd ${GCC}-SPU/build-spu

## Configure the build.
CFLAGS_FOR_TARGET="-Os -fpic -ffast-math -ftree-vectorize -funroll-loops -fschedule-insns -mdual-nops -mwarn-reloc" \
../configure --prefix="$PS3DEV/spu" --target="spu" \
    --disable-dependency-tracking \
    --disable-libcc1 \
    --disable-libssp \
    --disable-multilib \
    --disable-nls \
    --disable-shared \
    --disable-win32-registry \
    --enable-languages="c,c++" \
    --enable-lto \
    --enable-threads \
    --with-newlib \
    --enable-newlib-multithread \
    --with-pic

## Compile and install.
PROCS="$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)" || ret=$?
if [ ! -z $ret ]; then PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"; fi
${MAKE:-make} -j $PROCS all && ${MAKE:-make} install
