# Makefile for Mesh potato Asterisk channel driver
# David Rowe May 20 2009

export STAGING_DIR:=../../staging_dir/

#CC=../../staging_dir/toolchain-mips_gcc4.1.2/bin/mips-linux-uclibc-gcc
#CC=../../staging_dir/toolchain-mips_r2_gcc-4.5-linaro_uClibc-0.9.32/bin/mips-openwrt-linux-uclibc-gcc
CC=../../staging_dir/toolchain-mips_gcc-4.5-linaro_uClibc-0.9.32/bin/mips-openwrt-linux-uclibc-gcc
  
#ECHO_PATH=../../build_dir/mips/oslec-0.1/spandsp-0.0.3/src/
ECHO_PATH=../../build_dir/target-mips_uClibc-0.9.32/oslec-0.1/spandsp-0.0.3/src/

INCLUDE=-I../../build_dir/target-mips_uClibc-0.9.32/asterisk-1.4.11/include
INCLUDE+=-I$(ECHO_PATH)/spandsp

ASTCFLAGS=-pipe  -Wall -Wstrict-prototypes -Wmissing-prototypes -Wmissing-declarations $(DEBUG) $(INCLUDE) -D_REENTRANT -D_GNU_SOURCE -DLOW_MEMORY -O3 -mips32 -mtune=mips32 -funit-at-a-time -fhonour-copts -fPIC -DAST_MODULE=\"chan_mp\"

SOLINK=-shared -Xlinker -x
CFLAGS=$(ASTCFLAGS)

all: chan_mp.so 

chan_mp.so: chan_mp.o echo.o
	$(CC) $(SOLINK) -o $@ chan_mp.o echo.o -ldl

gentone: gentone.c
	gcc gentone.c -o gentone -lm -Wall

busy.h: gentone
	./gentone busy 480 620

ringtone.h: gentone
	./gentone ringtone 440 480

dialtone.h: gentone
	./gentone dialtone 350 440

echo.o: $(ECHO_PATH)/echo.c
	$(CC) $(CFLAGS) $(ECHO_PATH)/echo.c -c -o echo.o

chan_mp.o: chan_mp.c busy.h ringtone.h dialtone.h
	$(CC) -c $(CFLAGS) -o $@ chan_mp.c


