#ifndef TYPES_H
#define TYPES_H

// Basic type definitions for Level OS
typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long long uint64_t;

typedef signed char int8_t;
typedef signed short int16_t;
typedef signed int int32_t;
typedef signed long long int64_t;

typedef uint32_t size_t;
typedef uint32_t uintptr_t;

// Boolean type
typedef enum
{
    false = 0,
    true = 1
} bool;

// NULL pointer
#ifndef NULL
#define NULL ((void *)0)
#endif

// Common macros
#define PACKED __attribute__((packed))
#define UNUSED __attribute__((unused))
#define ALIGNED(x) __attribute__((aligned(x)))

#endif // TYPES_H