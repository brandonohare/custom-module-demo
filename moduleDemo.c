#include <linux/module.h>

int my_init_module(void){
    printk("Module Loaded.\n");
    return 0;
}

void my_cleanup_module(void){
    printk("Module Unloaded.\n");
}

module_init(my_init_module);
module_exit(my_cleanup_module);
MODULE_LICENSE("GPL");