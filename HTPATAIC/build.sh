#!/bin/sh

BASE="adventure"
EXT=".c"
COSMO="/home/matt/cosmopolitan"
if [ "$1" != opt ]; then
  echo "Debug build"
  ${COSMO}/o/third_party/gcc/bin/x86_64-linux-musl-gcc -g -Og -Wall -fsanitize=address -fsanitize=undefined -static -fno-pie -no-pie -mno-red-zone -nostdlib -nostdinc -fno-omit-frame-pointer -pg -mnop-mcount -o ${BASE}.com.dbg ${BASE}${EXT} -Wl,--gc-sections -fuse-ld=bfd -Wl,--script=${COSMO}/o/dbg/ape/ape.lds  -include ${COSMO}/o/cosmopolitan.h ${COSMO}/o/dbg/libc/crt/crt.o ${COSMO}/o/dbg/ape/ape.o ${COSMO}/o/dbg/cosmopolitan.a -fdebug-prefix-map=${COSMO}=
  exec objcopy -S -O binary ${BASE}.com.dbg ${BASE}.com
else
  echo "Optimized build"
  ${COSMO}/o/third_party/gcc/bin/x86_64-linux-musl-gcc -O2 -Wall -fsanitize=address -fsanitize=undefined -static -fno-pie -no-pie -mno-red-zone -nostdlib -nostdinc -o ${BASE}_opt.com.dbg ${BASE}${EXT}-Wl,--gc-sections -fuse-ld=bfd -Wl,--script=${COSMO}/o/ape/ape.lds  -include ${COSMO}/o/cosmopolitan.h ${COSMO}/o/libc/crt/crt.o ${COSMO}/o/ape/ape.o ${COSMO}/o/cosmopolitan.a &&
  objcopy -S -O binary ${BASE}_opt.com.dbg ${BASE}_opt.com
  exec rm ${BASE}_opt.com.dbg
fi
