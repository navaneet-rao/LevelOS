/* LevelOS - String Library Header
 * Basic string manipulation functions for kernel use
 */

#ifndef LIB_STRING_H
#define LIB_STRING_H

#include "types.h"

// String functions
size_t strlen(const char* str);

// Memory functions  
void* memset(void* dest, int value, size_t count);
void* memcpy(void* dest, const void* src, size_t count);
int memcmp(const void* ptr1, const void* ptr2, size_t count);

#endif // LIB_STRING_H