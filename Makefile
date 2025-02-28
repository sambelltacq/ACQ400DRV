# Cross compiler makefile for FIFO DMA example
#KERN_SRC=~/PROJECTS/ACQ400/linux-xlnx
obj-m += xilinx_devcfg.o
obj-m += dmaengine314.o
obj-m += pl330.o
obj-m += xilinx_axidma.o
obj-m += acq420fmc.o
#obj-m += dmatest_pgm.o
obj-m += debugfs2.o
obj-m += pl330_fs.o

obj-m += bolo8_drv.o
obj-m += acq425_drv.o
obj-m += acq480.o
obj-m += acq400t.o
#obj-m += acq4xx_fs.o
obj-m += mgt400.o
obj-m += regfs.o
obj-m += acq400_dspfs.o

obj-m += pigcelf.o
obj-m += dmadescfs.o
obj-m += radcelf.o
obj-m += ad9854.o
obj-m += ad9512.o
obj-m += ad9510.o
obj-m += ads62p49.o
obj-m += ao428.o
obj-m += z7_eth1_1000X_en.o
obj-m += acq465.o
obj-m += acq494.o

#obj-m += acq400-spi-bytebang.o

DC := $(shell date +%y%m%d%H%M%S)
SEQ=10


CPPFLAGS += -O3 -Wall
CXXFLAGS += -std=c++11


acq420fmc-objs := acq400_drv.o  acq400_ui.o acq400_fs.o dma_shims.o \
	acq400_core.o acq400_init_defaults.o \
	acq400_debugfs.o acq400_sysfs.o acq400_lists.o \
	acq400_proc.o hbm.o zynq-timer.o \
	bolo8_core.o bolo_ui.o bolo8_sysfs.o \
	dio432_drv.o  ao424_drv.o acq400_sewfifo.o \
	dio_sysfs.o xo_workers.o xo_sysfs.o \
	wr_sysfs.o acq423_sysfs.o acq480_sysfs.o v2f_sysfs.o \
	acq400_xilinx_axidma.o acq400_deltrg.o \
	acq400_set.o acq400_sysfs_utils.o  \
	acq400_axi_chain.o acq400_axi_oneshot.o \
	radcelf_sysfs.o acq400_reg_cache.o  spadcop.o \
	acq400_wrdrv.o
	
dmadescfs-objs := dmadescfs_drv.o

regfs-objs := regfs_drv.o
	
dmaengine314-objs := dmaengine.o of-dma.o

mgt400-objs := mgt400_drv.o mgt400_sysfs.o mgt400_procfs.o mgt400_debugfs.o \
	acq400_reg_cache.o mgt400_sysfs_utils.o mgt400_core.o

acq480-objs := acq480_drv.o hbm.o zynq_peripheral_spi_shim.o

acq465-objs := acq465_drv.o hbm.o zynq_peripheral_spi_shim.o

acq494-objs := acq494_gpx2_drv.o zynq_peripheral_spi_shim.o

pigcelf-objs := pigcelf_drv.o zynq_peripheral_spi_shim.o

radcelf-objs := radcelf_drv.o zynq_peripheral_spi_shim.o

ao428-objs := ao428_drv.o

acq400t-objs := acq400t_drv.o

dmatest_pgm-objs := dmatest.o zynq-timer.o

APPS := mmap acq400_stream permute acq435_decode \
	acq400_knobs udp_client is_ramp mmaptest wavegen \
	dsp_coprocessor ramp acq400_stream_disk \
	acq480_knobs acq465_knobs transition_counter acq435_rtm_trim anatrg \
	muxdec dmadescfs_test tblock2file acq400_sls bb bbq_send_ai  \
	fix_state bpaste clocks_to_first_edge \
	mgtdram_descgen bigcat egu2int dawg watchdog_PIL \
	dump_regs subr \
	soft_atd spad_update \
	wr_reset wrtd soft_wrtd wrtt_mon multicast \
	mr_offload trigger_at bb_stream reduce \
	channel_mapping slowmon_hw reg_rw hudp_config tai_server \
	awg_composer scripts/mod_id.sh
	
# data_sink	
# dropped
# multi_event 

LIBINC = acq-util.h Buffer.h ES.h
LIBACQSO = libacq.so
LIBACQSONAME = libacq.so.1


ifeq (arm, ${ARCH})
ARCHD = linux-arm
LIBS = ./lib/$(ARCHD)/$(LIBACQSONAME)
LDFLAGS += -L./lib/$(ARCHD)
LDFLAGS += -L../acq400_buildroot/output/target/lib/
LDFLAGS += -L../acq400_buildroot/output/target/usr/lib/

$(info ARCH $(ARCH) ARCHD $(ARCHD))
libs: $(LIBS) ../include
all: modules libs apps

else
ARCH = linux-x86_64
ARCHD = linux-x86_64
LIBS = ./lib/$(ARCHD)/$(LIBACQSONAME)
LDFLAGS += -L./lib/$(ARCHD)

libs: $(LIBS) ../include

all: libs

endif


date:
	echo $(DC)

packageko:
	./make.packageko $(DC)


opkg_clean:
	rm -Rf opkg

opkg:
	mkdir -p opkg/usr/local/bin \
		opkg/usr/share opkg/usr/local/CARE opkg/usr/local/map \
		opkg/usr/local/init/pl330dbg opkg/usr/local/cal \
		opkg/etc/profile.d opkg/etc/sysconfig opkg/etc/acq400 \
		opkg/usr/local/lib

opkgcp:
	cp cal/* opkg/usr/local/cal
	cp -a $(APPS) scripts/* opkg/usr/local/bin
	cp -a lib/$(ARCHD)/*.so* opkg/usr/local/lib
	cp -a doc opkg/usr/share
	cp bos.sh opkg/etc/profile.d
	cp -r CARE/* opkg/usr/local/CARE
	cp acq435_decode  scripts/streamtonowhere opkg/usr/local/CARE
	cp init/* opkg/usr/local/init
	cp map/* opkg/usr/local/map
	cp pl330dbg/* opkg/usr/local/init/pl330dbg
	cp sysconfig/* opkg/etc/sysconfig
	rm -f opkg/usr/local/bin/mgt_offload
	ln -s /usr/local/CARE/mgt_offload_groups opkg/usr/local/bin/mgt_offload
	

EMLOGD=../DRIVERS-OOK/emlog

emlog:
	(cd $(EMLOGD);make all)
	cp $(EMLOGD)/nbcat  $(EMLOGD)/mkemlog opkg/usr/local/bin
	$(CROSS_COMPILE)strip --strip-debug opkg/usr/local/bin/nbcat opkg/usr/local/bin/mkemlog

	
package: all opkg_clean opkg opkgcp emlog packageko
	echo do NOT rm -Rf opkg/*
	mkdir -p release ../PACKAGES
	tar czf release/$(SEQ)-acq420-$(DC).tgz -C opkg .
	@echo created package release/$(SEQ)-acq420-$(DC).tgz
	rm -f ../PACKAGES/$(SEQ)-acq420*
	git tag -a -m $(SEQ)-acq420-$(DC).tgz r$(DC) 
	cp release/$(SEQ)-acq420-$(DC).tgz ../PACKAGES/
	

tarball:
	echo Please make sure directory is clean first ..
	tar cvzf acq420fmc-$(DC).tgz --exclude=release/* *


apps: $(APPS)

modules:
	make -C $(KERN_SRC) ARCH=arm M=`pwd` modules
	$(CROSS_COMPILE)strip --strip-debug *.ko
	
clean:
	@rm -rf *.o *~ core .depend .*.cmd *.ko *.mod.c .tmp_versions $(LIBS) $(APPS) \
		Module.symvers modules.order *.so *.so.1*
	
mmap: mmap.o
	$(CC) -o $@ $^ $(LDFLAGS) -lpopt

dsp_coprocessor: dsp_coprocessor.o
	$(CC) -o $@ $^ $(LDFLAGS) -lpopt -lrt -lm

mmaptest: mmaptest.o
	$(CC) -o $@ $^ $(LDFLAGS) -lpopt

acq400_sls: acq400_sls.o
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lpopt	-lacq

watchdog_PIL: watchdog_PIL.o
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lpopt
			
udp_client: udp_client.o
	$(CC) -o $@ $^ $(LDFLAGS) -lpopt
	
acq400_stream: acq400_stream.o  hex_char_to_bin.o
	$(CXX) -o $@ $^ $(LDFLAGS) -lacq  -lpopt -lpthread -lrt

bb: bb.o tcp_server.o
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lacq  -lpopt -lpthread -lrt

bb_stream: bb_stream.o tcp_server.o
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lacq  -lpopt -lpthread -lrt

multi_event: multi_event.o
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lacq  -lpopt -lpthread -lrt

wr_reset: wr_reset.o Env.o
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lpopt
	
bbq_send_ai: bbq_send_ai.o Socket.o
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lacq  -lpopt -lpthread -lrt
data_sink: data_sink.o Socket.o
	$(CXX) -O3 -o $@ $^ $(LDFLAGS)  -lpopt -lpthread -lrt
	
subr: subr.o
	$(CXX) -O3 -o $@ $^ $(LDFLAGS)  -lpopt -lpthread -lrt
	#$(CXX) -O3 -o $@ $^ $(LDFLAGS)  -lpopt -lpthread -lrt -lacq
		
phased_array: phased_array.o
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lacq  -lpopt -lpthread -lrt
	
dawg: dawg.o
	$(CXX) -O3 -o dawg dawg.o $(LDFLAGS) -lacq -lpopt -lrt
	
tblock2file: tblock2file.o 
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lacq  -lpopt -lacq -lpthread -lrt

is_ramp: is_ramp.o
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lpopt
	
acq400_knobs: acq400_knobs.o tcp_server.o Env.o
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lacq  -lpopt

anatrg: anatrg.o 
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lpopt -lacq

soft_atd: soft_atd.o 
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lpopt -lacq
	
multisitecheckramp: multisitecheckramp.cpp
	$(CXX) -std=c++11 -O3 -o $@ $^ $(LDFLAGS) -lpopt
	
acq480_knobs: acq480_knobs.o ads5294.o  knobs.o
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lpopt
	
acq465_knobs: acq465_knobs.o knobs.o
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lpopt
		
wavegen: wavegen.o
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lpopt -lacq -lm
	
acq435_decode: acq435_decode.o
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lpopt -lpthread
	
acq400_axi_dma_test_harness: acq400_axi_dma_test_harness.o
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lpopt -lpthread

acq435_rtm_trim: acq435_rtm_trim.o
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lpopt -lpthread
	
bigmac: bigmac.o
	$(CXX) -mcpu=cortex-a9 -mfloat-abi=softfp -mfpu=neon \
		-DHASNEON \
		-O3 -o bigmac bigmac.o $(LDFLAGS) -lpopt
bigcat: bigcat.cpp
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lpopt -lpthread

lilmac: lilmac.o
	$(CXX) -O3 -o lilmac lilmac.o $(LDFLAGS) -lpopt

hudp_config: hudp_config.o knobs.o
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lpopt -lacq

mr_offload: mr_offload.o knobs.o connect_to.o
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lpopt

channel_mapping: channel_mapping.o knobs.o 
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lpopt
	
muxdec: muxdec.o
	$(CXX) -O3 -o muxdec muxdec.o $(LDFLAGS) -lacq

bpaste: bpaste.o
	$(CXX) -O3 -o bpaste bpaste.o
	
bigmac.x86: bigmac.o
	$(CXX) -O3 -o $@ $^ -lpopt	
	
mgtdram_descgen: 	mgtdram_descgen.o
	$(CXX) -O3 -o $@ $^ $(LDFLAGS) -lpopt

wrtd: 	wrtd.o Multicast.o  knobs.o
	$(CXX) -std=c++11 -O3 -o $@ $^ $(LDFLAGS) -lpopt -lacq -lrt
	
spad_update:	spad_update.o knobs.o
	$(CXX) -std=c++11 -O3 -o $@ $^ $(LDFLAGS) -lpopt -lacq -lrt	
	
soft_wrtd: 	soft_wrtd.o Multicast.o  knobs.o
	$(CXX) -std=c++11 -O3 -o $@ $^ $(LDFLAGS) -lpopt -lacq -lrt
	
soft_wrtd_x86: 	soft_wrtd.cpp Multicast.cpp  knobs.cpp -lrt
	$(CXX) -std=c++11 -O3 -o $@ $^ -lpopt
	
soft_wrtd_x86_clean: 
	rm -f soft_wrtd_x86 soft_wrtd.o Multicast.o  knobs.o
		
multicast: 	multicast.o Multicast.o
	$(CXX) -std=c++11 -O3 -o $@ $^ $(LDFLAGS) -lpopt
		
trigger_at: trigger_at.o knobs.o
	$(CXX) -std=c++11 -O3 -o $@ $^ $(LDFLAGS) -lpopt
	
clocks_to_first_edge: clocks_to_first_edge.o knobs.o
	$(CXX) -std=c++11 -O3 -o $@ $^ $(LDFLAGS)	
	
slowmon_hw: slowmon_hw.o knobs.o
	$(CXX) -std=c++11 -O3 -o $@ $^ $(LDFLAGS) -lpopt
	
awg_composer: awg_composer.o knobs.o
	$(CXX) -std=c++11 -O3 -o $@ $^ $(LDFLAGS) -lpopt	
			
rtpackage:
	tar cvzf dmadescfs-$(DC).tgz dmadescfs* scripts/load.dmadescfs

LIBSRCS = acq-util.c knobs.cpp acq_rt.cpp Buffer.cpp ES.cpp

../include:
	mkdir -p ../include
	cp $(LIBINC) ../include

./lib/$(ARCHD)/$(LIBACQSONAME): $(LIBSRCS)
	mkdir -p ./lib/$(ARCHD)
	$(CXX) -shared -Wl,-soname,$(LIBACQSONAME) -fPIC -o $@ $^
	cd ./lib/$(ARCHD); ln -fs $(LIBACQSONAME) $(LIBACQSO)
	echo lib for local use:
	ls -l ./lib/$(ARCHD)
	mkdir -p ../lib/$(ARCHD); cp -a ./lib/$(ARCHD)/*  ../lib/$(ARCHD)
	echo lib for external use
	ls -l ../lib/$(ARCHD)

scripts/mod_id.sh: acq400_mod_id.h
	echo update scripts/mod_id.sh
	./make_mod_id.sh
zynq:
	./make.zynq
		
