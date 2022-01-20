# Brandon O'Hare 2022 | Linux Module Demo
obj-m += moduleDemo.o

all:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
	rm -rf *.o *.ko *.mod.c .an* .lab* .tmp_version Module.symvers Modules.markers modules.order .*.cmd *.mod *.dwo