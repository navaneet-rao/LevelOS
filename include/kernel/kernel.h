#ifndef KERNEL_H
#define KERNEL_H

#include "lib/types.h"

// Kernel version information
#define KERNEL_VERSION_MAJOR 0
#define KERNEL_VERSION_MINOR 1
#define KERNEL_VERSION_PATCH 0
#define KERNEL_NAME "Level OS"

// Function declarations
void kernel_main(void);
void kernel_panic(const char *message);

#endif // KERNEL_H