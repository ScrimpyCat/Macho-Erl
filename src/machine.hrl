%cpu_type
-define(CPU_ARCH_MASK,  16#ff000000).
-define(CPU_ARCH_ABI64, 16#01000000).

-define(CPU_TYPE_ANY,       -1).
-define(CPU_TYPE_VAX,       1).
-define(CPU_TYPE_MC680x0,   6).
-define(CPU_TYPE_X86,       7).
-define(CPU_TYPE_I386,      ?CPU_TYPE_X86).
-define(CPU_TYPE_X86_64,    (?CPU_TYPE_X86 bor ?CPU_ARCH_ABI64)).
-define(CPU_TYPE_MIPS,      8).
-define(CPU_TYPE_MC98000,   10).
-define(CPU_TYPE_HPPA,      11).
-define(CPU_TYPE_ARM,       12).
-define(CPU_TYPE_ARM64,     (?CPU_TYPE_ARM bor ?CPU_ARCH_ABI64)).
-define(CPU_TYPE_MC88000,   13).
-define(CPU_TYPE_SPARC,     14).
-define(CPU_TYPE_I860,      15).
%-define(CPU_TYPE_ALPHA,    16).
-define(CPU_TYPE_POWERPC,   18).
-define(CPU_TYPE_POWERPC64, (?CPU_TYPE_POWERPC bor ?CPU_ARCH_ABI64)).


%cpu_subtype
-define(CPU_SUBTYPE_MASK,   16#ff000000).
-define(CPU_SUBTYPE_LIB64,  16#80000000).

-define(CPU_SUBTYPE_MULTIPLE,       -1).
-define(CPU_SUBTYPE_LITTLE_ENDIAN,  0).
-define(CPU_SUBTYPE_BIG_ENDIAN,     1).
%VAX
-define(CPU_SUBTYPE_VAX_ALL,    0).
-define(CPU_SUBTYPE_VAX780,     1).
-define(CPU_SUBTYPE_VAX785,     2).
-define(CPU_SUBTYPE_VAX750,     3).
-define(CPU_SUBTYPE_VAX730,     4).
-define(CPU_SUBTYPE_UVAXI,      5).
-define(CPU_SUBTYPE_UVAXII,     6).
-define(CPU_SUBTYPE_VAX8200,    7).
-define(CPU_SUBTYPE_VAX8500,    8).
-define(CPU_SUBTYPE_VAX8600,    9).
-define(CPU_SUBTYPE_VAX8650,    10).
-define(CPU_SUBTYPE_VAX8800,    11).
-define(CPU_SUBTYPE_UVAXIII,    12).
%680x0
-define(CPU_SUBTYPE_MC680x0_ALL,    1).
-define(CPU_SUBTYPE_MC68030,        1).
-define(CPU_SUBTYPE_MC68040,        2).
-define(CPU_SUBTYPE_MC68030_ONLY,   3).
%I386
-define(CPU_SUBTYPE_INTEL(F, M), (F + (M bsl 4))).

-define(CPU_SUBTYPE_I386_ALL,       ?CPU_SUBTYPE_INTEL(3, 0)).
-define(CPU_SUBTYPE_386,            ?CPU_SUBTYPE_INTEL(3, 0)).
-define(CPU_SUBTYPE_486,            ?CPU_SUBTYPE_INTEL(4, 0)).
-define(CPU_SUBTYPE_486SX,          ?CPU_SUBTYPE_INTEL(4, 8)).
-define(CPU_SUBTYPE_586,            ?CPU_SUBTYPE_INTEL(5, 0)).
-define(CPU_SUBTYPE_PENT,           ?CPU_SUBTYPE_INTEL(5, 0)).
-define(CPU_SUBTYPE_PENTPRO,        ?CPU_SUBTYPE_INTEL(6, 1)).
-define(CPU_SUBTYPE_PENTII_M3,      ?CPU_SUBTYPE_INTEL(6, 3)).
-define(CPU_SUBTYPE_PENTII_M5,      ?CPU_SUBTYPE_INTEL(6, 5)).
-define(CPU_SUBTYPE_CELERON,        ?CPU_SUBTYPE_INTEL(7, 6)).
-define(CPU_SUBTYPE_CELERON_MOBILE, ?CPU_SUBTYPE_INTEL(7, 7)).
-define(CPU_SUBTYPE_PENTIUM_3,      ?CPU_SUBTYPE_INTEL(8, 0)).
-define(CPU_SUBTYPE_PENTIUM_3_M,    ?CPU_SUBTYPE_INTEL(8, 1)).
-define(CPU_SUBTYPE_PENTIUM_3_XEON, ?CPU_SUBTYPE_INTEL(8, 2)).
-define(CPU_SUBTYPE_PENTIUM_M,      ?CPU_SUBTYPE_INTEL(9, 0)).
-define(CPU_SUBTYPE_PENTIUM_4,      ?CPU_SUBTYPE_INTEL(10, 0)).
-define(CPU_SUBTYPE_PENTIUM_4_M,    ?CPU_SUBTYPE_INTEL(10, 1)).
-define(CPU_SUBTYPE_ITANIUM,        ?CPU_SUBTYPE_INTEL(11, 0)).
-define(CPU_SUBTYPE_ITANIUM_2,      ?CPU_SUBTYPE_INTEL(11, 1)).
-define(CPU_SUBTYPE_XEON,           ?CPU_SUBTYPE_INTEL(12, 0)).
-define(CPU_SUBTYPE_XEON_MP,        ?CPU_SUBTYPE_INTEL(12, 1)).

-define(CPU_SUBTYPE_INTEL_FAMILY(X),    (X band 15)).
-define(CPU_SUBTYPE_INTEL_FAMILY_MAX,   15).

-define(CPU_SUBTYPE_INTEL_MODEL(X),     (X bsr 4)).
-define(CPU_SUBTYPE_INTEL_MODEL_ALL,    0).
%x86
-define(CPU_SUBTYPE_X86_ALL,    3).
-define(CPU_SUBTYPE_X86_64_ALL, 3).
-define(CPU_SUBTYPE_X86_ARCH1,  4).
%MIPS
-define(CPU_SUBTYPE_MIPS_ALL,       0).
-define(CPU_SUBTYPE_MIPS_R2300,     1).
-define(CPU_SUBTYPE_MIPS_R2600,     2).
-define(CPU_SUBTYPE_MIPS_R2800,     3).
-define(CPU_SUBTYPE_MIPS_R2000a,    4).
-define(CPU_SUBTYPE_MIPS_R2000,     5).
-define(CPU_SUBTYPE_MIPS_R3000a,    6).
-define(CPU_SUBTYPE_MIPS_R3000,     7).
%MC98000 (PowerPC)
-define(CPU_SUBTYPE_MC98000_ALL,    0).
-define(CPU_SUBTYPE_MC98601,        1).
%HPPA
-define(CPU_SUBTYPE_HPPA_ALL,       0).
-define(CPU_SUBTYPE_HPPA_7100,      0).
-define(CPU_SUBTYPE_HPPA_7100LC,    1).
%MC88000
-define(CPU_SUBTYPE_MC88000_ALL,    0).
-define(CPU_SUBTYPE_MC88100,        1).
-define(CPU_SUBTYPE_MC88110,        2).
%SPARC
-define(CPU_SUBTYPE_SPARC_ALL,  0).
%I860
-define(CPU_SUBTYPE_I860_ALL,   0).
-define(CPU_SUBTYPE_I860_860,   1).
%PowerPC
-define(CPU_SUBTYPE_POWERPC_ALL,    0).
-define(CPU_SUBTYPE_POWERPC_601,    1).
-define(CPU_SUBTYPE_POWERPC_602,    2).
-define(CPU_SUBTYPE_POWERPC_603,    3).
-define(CPU_SUBTYPE_POWERPC_603e,   4).
-define(CPU_SUBTYPE_POWERPC_603ev,  5).
-define(CPU_SUBTYPE_POWERPC_604,    6).
-define(CPU_SUBTYPE_POWERPC_604e,   7).
-define(CPU_SUBTYPE_POWERPC_620,    8).
-define(CPU_SUBTYPE_POWERPC_750,    9).
-define(CPU_SUBTYPE_POWERPC_7400,   10).
-define(CPU_SUBTYPE_POWERPC_7450,   11).
-define(CPU_SUBTYPE_POWERPC_970,    100).
%ARM
-define(CPU_SUBTYPE_ARM_ALL,    0).
-define(CPU_SUBTYPE_ARM_V4T,    5).
-define(CPU_SUBTYPE_ARM_V6,     6).
-define(CPU_SUBTYPE_ARM_V5TEJ,  7).
-define(CPU_SUBTYPE_ARM_XSCALE, 8).
-define(CPU_SUBTYPE_ARM_V7,     9).
-define(CPU_SUBTYPE_ARM_V7F,    10).
-define(CPU_SUBTYPE_ARM_V7S,    11).
-define(CPU_SUBTYPE_ARM_V7K,    12).
-define(CPU_SUBTYPE_ARM_V6M,    14).
-define(CPU_SUBTYPE_ARM_V7M,    15).
-define(CPU_SUBTYPE_ARM_V7EM,   16).
-define(CPU_SUBTYPE_ARM_V8,     13).

-define(CPU_SUBTYPE_ARM64_ALL,  0).
-define(CPU_SUBTYPE_ARM64_V8,   1).


%thread status flavours
-define(PPC_THREAD_STATE,       1).
-define(PPC_FLOAT_STATE,        2).
-define(PPC_EXCEPTION_STATE,    3).
-define(PPC_VECTOR_STATE,       4).
-define(PPC_THREAD_STATE64,     5).
-define(PPC_EXCEPTION_STATE64,  6).

-define(x86_THREAD_STATE32,     1).
-define(x86_FLOAT_STATE32,      2).
-define(x86_EXCEPTION_STATE32,  3).
-define(x86_THREAD_STATE64,     4).
-define(x86_FLOAT_STATE64,      5).
-define(x86_EXCEPTION_STATE64,  6).
-define(x86_THREAD_STATE,       7).
-define(x86_FLOAT_STATE,        8).
-define(x86_EXCEPTION_STATE,    9).
-define(x86_DEBUG_STATE32,      10).
-define(x86_DEBUG_STATE64,      11).
-define(x86_DEBUG_STATE,        12).
-define(x86_THREAD_STATE_NONE,  13).
-define(x86_SAVED_STATE32,      14).
-define(x86_SAVED_STATE64,      15).
-define(x86_AVX_STATE32,        16).
-define(x86_AVX_STATE64,        17).
-define(x86_AVX_STATE,          18).

-define(ARM_THREAD_STATE,           1).
-define(ARM_UNIFIED_THREAD_STATE,   ?ARM_THREAD_STATE).
-define(ARM_VFP_STATE,              2).
-define(ARM_EXCEPTION_STATE,        3).
-define(ARM_DEBUG_STATE,            4).
-define(THREAD_STATE_NONE,          5).
-define(ARM_THREAD_STATE64,         6).
-define(ARM_EXCEPTION_STATE64,      7).
-define(ARM_THREAD_STATE32,         9).
-define(ARM_DEBUG_STATE32,          14).
-define(ARM_DEBUG_STATE64,          15).
-define(ARM_NEON_STATE,             16).
-define(ARM_NEON_STATE64,           17).
