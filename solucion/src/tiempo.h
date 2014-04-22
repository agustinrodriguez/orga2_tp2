#ifndef __TIEMPO_H__
#define __TIEMPO_H__


#define MEDIR_TIEMPO(var)                                   \
{                                                           \
    __asm__ __volatile__ (                                  \
        "xor rdx, rdx\n\t"                                  \
        "xor rax, rax\n\t"                                  \
        "lfence\n\t"                                        \
        "rdtsc\n\t"                                         \
        "sal rdx, 32\n\t"                                   \
        "or rax, rdx\n\t"                                   \
        "mov %0, rax\n\t"                                   \
        : "=r" (var)                                        \
        : /* no input */                                    \
        : "rax", "rdx"                                      \
    );                                                      \
}


#define MEDIR_TIEMPO_START(start)                           \
{                                                           \
    /* warm up ... */                                       \
    MEDIR_TIEMPO(start);                                    \
    MEDIR_TIEMPO(start);                                    \
    MEDIR_TIEMPO(start);                                    \
}

#define MEDIR_TIEMPO_STOP(end)                              \
{                                                           \
    MEDIR_TIEMPO(end);                                      \
}

#endif /* !__TIEMPO_H__ */
