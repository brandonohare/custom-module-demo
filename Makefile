# Brandon O'Hare 2022 | Linux Module Demo

all:
	make -C /lib/modules/`uname -r`/build M=$(PWD) modules

object-m += moduleDemo.o

clean:
	rm -rf *.o *.ko *.mod.c .an* .lab* .tmp_version Module.symvers Modules.markers modules.order .*.cmd *.mod