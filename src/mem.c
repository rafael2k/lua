#ifdef __ELKS__
/* malloc/free wholesale replacement for 8086 toolchain */
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#define MALLOC_ARENA_SIZE   42000U  /* size of initial arena fmemalloc (max 65520)*/
#define MALLOC_ARENA_THRESH 1024U   /* max size to allocate from arena-managed heap */

unsigned int malloc_arena_size = MALLOC_ARENA_SIZE;
unsigned int malloc_arena_thresh = MALLOC_ARENA_THRESH;

static void __far *heap;

#define FP_SEG(fp)          ((unsigned)((unsigned long)(void __far *)(fp) >> 16))

static int is_arena_ptr(void *ptr)
{
    return heap != NULL && FP_SEG(ptr) == FP_SEG(heap);
}

static void *raw_malloc(size_t size)
{
    void *p;

    if (heap == NULL) {
        heap = fmemalloc(malloc_arena_size);
        if (!heap) {
            __dprintf("FATAL: Can't fmemalloc %u\n", malloc_arena_size);
            system("meminfo > /dev/console");
            exit(1);
        }
        _fmalloc_add_heap(heap, malloc_arena_size);
    }

    if (size <= malloc_arena_thresh) {
        p = _fmalloc(size);
        if (p != NULL)
            return p;

        __dprintf("HEAP full: allocating from far memory %u\n", size);
    }

    return fmemalloc(size + sizeof(size_t));
}

void *malloc(size_t size)
{
    size_t *header;

    if (size > (size_t)-1 - sizeof(size_t))
        return NULL;

    header = raw_malloc(size);
    if (header == NULL)
        return NULL;

    if (is_arena_ptr(header))
        return header;

    *header = size;

    return header + 1;
}

void free(void *ptr)
{
    if (ptr == NULL)
        return;

    if (is_arena_ptr(ptr))
        _ffree(ptr);
    else
        fmemfree(((size_t *)ptr) - 1);
}

void *realloc(void *ptr, size_t size)
{
    void *new;
    size_t osize;

    if (ptr == 0)
        return malloc(size);

    if (size == 0) {
        free(ptr);
        return NULL;
    }

    if (is_arena_ptr(ptr))
        osize = _fmalloc_usable_size(ptr);
    else
        osize = *(((size_t *)ptr) - 1);

    if (osize > size)
        osize = size;

    new = malloc(size);
    if (new == 0) {
        __dprintf("realloc: Out of memory\n");
        return 0;
    }
    memcpy(new, ptr, osize);
    free(ptr);
    return new;
}
#endif
