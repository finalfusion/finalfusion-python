from libc.stdint cimport uint32_t, uint64_t

cdef extern from "portable_endian.h":
    cdef uint32_t htole32(uint32_t x);
    cdef uint64_t htole64(uint64_t x);
