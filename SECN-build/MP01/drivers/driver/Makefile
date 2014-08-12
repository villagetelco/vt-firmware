# Makefile for Mesh Potato kernel mode driver
# David Rowe 17 May 2009

PWD   := $(shell pwd)
KDIR  := ../../build_dir/linux-atheros/linux-2.6.37.6/
# TOOLS := $(PWD)/../../staging_dir/toolchain-mips_gcc4.1.2/bin/
TOOLS := $(PWD)/../../staging_dir/toolchain-mips_gcc-4.5-linaro_uClibc-0.9.32/bin/
export PATH:= $(TOOLS):$(PATH)
export STAGING_DIR:= $(PWD)/../../staging_dir/toolchain-mips_gcc-4.5-linaro_uClibc-0.9.32/bin/

obj-m := mp.o 8250mp.o 

all: 
	make -C $(KDIR) SUBDIRS=$(PWD) CROSS_COMPILE="mips-openwrt-linux-uclibc-" ARCH="mips" KBUILD_HAVE_NLS=no CONFIG_SHELL="/bin/bash" CC="mips-openwrt-linux-uclibc-gcc" modules


