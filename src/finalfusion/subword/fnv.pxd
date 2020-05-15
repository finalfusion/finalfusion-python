from libc.stdint cimport uint32_t, uint64_t

cdef extern from "fnv.h":
    ctypedef uint64_t Fnv64_t;
    cdef Fnv64_t FNV1A_64_INIT;
    Fnv64_t fnv_64a_buf(void* buf, size_t len, Fnv64_t hashval);

    ctypedef uint32_t Fnv32_t;
    cdef Fnv32_t FNV1_32_INIT;
    Fnv32_t fnv_32a_buf(void* buf, size_t len, Fnv32_t hashval)
