#pragma once
#include "ml_runtimelib.h"
#include <stdarg.h>
#include <stddef.h>

#ifdef __riscv
    #include "riscv/platform_spec_gc.h"
    #define GC
#endif

#ifdef GC

void gc_on_load();

typedef enum { COLOR_UNPROCESSED = 0, COLOR_PROCESSED = 1 } color_t;

    #define START_COLOR COLOR_UNPROCESSED

void add_global_vars_to_gc(int64_t n, va_list globs);

void compact();

void print_gc_info();

void* gc_malloc(size_t);

#endif