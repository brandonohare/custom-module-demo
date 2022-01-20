Custom Linux Module Demonstration
=================================

Dynamic loading of modules into Linux allows for quick development turn-around.
The following repository shows an example module and the key-signing process that is needed if your Linux system uses UEFI Secure Boot.

Install
-------

Clone the repository and change directory.
```
    $ git clone https://github.com/brandonohare/custom-module-demo.git
    $ cd custom-module-demo
```
Inside the directory are `moduleDemo.c` and `Makefile`. Modules are built using C, with one or more files. 
This will require the `module.h` functions, which can be accessed with `#include <linux/module.h>`. 

There are many module functions, but the three most important (for our basic implementation, that is) are:
     `module_init(some_init_function)` this is used to initialize the module. Returns an integer.
     `module_exit(some_exit_function)` this is used to shut down the module. Any memory allocation done by the module should be freed with this function. 
     `MODULE_LICENSE("license_name")`  the license type of you module needs to be set, as this dictates the API you can use in your module. 
    
To get access to `module.h` you have to build `moduleDemo.c` using the build script inside the kernel directory. 
This is inside `Makefile`:
```
    make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules
```
As we can see, the modules Makefile for this specific distribution is used to build modules, or `.ko` files from `.c` (or `.o`) files. 
This requires the `obj-m` flag to contain the `.o` files you want to build into the module (also inside the Makefile):
```
    obj-m += moduleDemo.c
```

Run the Makefile to generate a `.ko` file.
```
    $ make all
```
One of the output files will be `moduleDemo.ko`, which can now be loaded as a module using insmod (modprobe requires your .ko file to be stored in /lib/modules/).
```
    $ insmod moduleDemo.ko
```
Checking `dmesg` should show the following message:
```
    Module Loaded.
```
Using rmmod will remove the module, which can again be confirmed with `dmesg`
```
    $ rmmod moduleDemo
    $ dmesg
    .... (other messages)
    Module Unloaded.
```

UEFI Complications
------------------

If you are running Linux with UEFI Secure Boot, your system will not let you use the insmod command as you can only insert modules that have been signed. 
The signing process is as follows:

Install the dependencies.
```
    $ apt install mokutil openssl
```
This work is better done it's own directory. You can make one anywhere on the system you'd like.
```
    $ mkdir key-signing
    $ cd key-signing
```
Use openssl to generate a new private and public keypair, changing the mode for the private key to owner read/write access only.
```
    $ openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 36500 -subj "/CN=your_name/"
    $ chmod 600 MOK.priv
```
Use mokutil to register the key with the BIOS.
```
    $ mokutil --import MOK.der
```
After this, you will need to reboot your system. The BIOS page will load automatically, and ask if you want to enroll the new key with MOK. Follow the prompts to enroll, then select the reboot option. 

Once booted back into the system, move back to the directory where the .ko file is.
```
    $ cd /path/to/custom-moduledemo/
```
You will need to sign the module (`.ko` file) with the new key you have just created and registered with the BIOS.
```
    $ /usr/src/linux-headers-$(uname -r)/scripts/sign-file sha256 /path/to/key-signing/MOK.priv /path/to/key-signing/MOK.der moduleDemo.ko
```
You should now be able to insert and remove the module as described above. 
