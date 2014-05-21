%filetype
-define(MH_OBJECT,      16#1).
-define(MH_EXECUTE,     16#2).
-define(MH_FVMLIB,      16#3).
-define(MH_CORE,        16#4).
-define(MH_PRELOAD,     16#5).
-define(MH_DYLIB,       16#6).
-define(MH_DYLINKER,    16#7).
-define(MH_BUNDLE,      16#8).
-define(MH_DYLIB_STUB,  16#9).
-define(MH_DSYM,        16#a).
-define(MH_KEXT_BUNDLE, 16#b).


%flags
-define(MH_NOUNDEFS,                16#1).
-define(MH_INCRLINK,                16#2).
-define(MH_DYLDLINK,                16#4).
-define(MH_BINDATLOAD,              16#8).
-define(MH_PREBOUND,                16#10).
-define(MH_SPLIT_SEGS,              16#20).
-define(MH_LAZY_INIT,               16#40).
-define(MH_TWOLEVEL,                16#80).
-define(MH_FORCE_FLAT,              16#100).
-define(MH_NOMULTIDEFS,             16#200).
-define(MH_NOFIXPREBINDING,         16#400).
-define(MH_PREBINDABLE,             16#800).
-define(MH_ALLMODSBOUND,            16#1000). 
-define(MH_SUBSECTIONS_VIA_SYMBOLS, 16#2000).
-define(MH_CANONICAL,               16#4000).
-define(MH_WEAK_DEFINES,            16#8000).
-define(MH_BINDS_TO_WEAK,           16#10000).

-define(MH_ALLOW_STACK_EXECUTION,   16#20000).
-define(MH_ROOT_SAFE,               16#40000).

-define(MH_SETUID_SAFE,             16#80000).

-define(MH_NO_REEXPORTED_DYLIBS,    16#100000).
-define(MH_PIE,                     16#200000).
-define(MH_DEAD_STRIPPABLE_DYLIB,   16#400000).
-define(MH_HAS_TLV_DESCRIPTORS,     16#800000).

-define(MH_NO_HEAP_EXECUTION,       16#1000000).


%load_command
-define(LC_REQ_DYLD,    16#80000000).

-define(LC_SEGMENT,                 16#1). 
-define(LC_SYMTAB,                  16#2). 
-define(LC_SYMSEG,                  16#3). 
-define(LC_THREAD,                  16#4). 
-define(LC_UNIXTHREAD,              16#5).
-define(LC_LOADFVMLIB,              16#6).
-define(LC_IDFVMLIB,                16#7). 
-define(LC_IDENT,                   16#8). 
-define(LC_FVMFILE,                 16#9). 
-define(LC_PREPAGE,                 16#a).
-define(LC_DYSYMTAB,                16#b). 
-define(LC_LOAD_DYLIB,              16#c).
-define(LC_ID_DYLIB,                16#d). 
-define(LC_LOAD_DYLINKER,           16#e).
-define(LC_ID_DYLINKER,             16#f).
-define(LC_PREBOUND_DYLIB,          16#10).
-define(LC_ROUTINES,                16#11).
-define(LC_SUB_FRAMEWORK,           16#12).
-define(LC_SUB_UMBRELLA,            16#13).
-define(LC_SUB_CLIENT,              16#14).
-define(LC_SUB_LIBRARY,             16#15).
-define(LC_TWOLEVEL_HINTS,          16#16).
-define(LC_PREBIND_CKSUM,           16#17).
-define(LC_LOAD_WEAK_DYLIB,         (16#18 bor ?LC_REQ_DYLD)).
-define(LC_SEGMENT_64,              16#19).
-define(LC_ROUTINES_64,             16#1a).
-define(LC_UUID,                    16#1b).
-define(LC_RPATH,                   (16#1c bor ?LC_REQ_DYLD)).
-define(LC_CODE_SIGNATURE,          16#1d).
-define(LC_SEGMENT_SPLIT_INFO,      16#1e).
-define(LC_REEXPORT_DYLIB,          (16#1f bor ?LC_REQ_DYLD)).
-define(LC_LAZY_LOAD_DYLIB,         16#20).
-define(LC_ENCRYPTION_INFO,         16#21).
-define(LC_DYLD_INFO,               16#22).
-define(LC_DYLD_INFO_ONLY,          (16#22 bor ?LC_REQ_DYLD)).
-define(LC_LOAD_UPWARD_DYLIB,       (16#23 bor ?LC_REQ_DYLD)).
-define(LC_VERSION_MIN_MACOSX,      16#24).
-define(LC_VERSION_MIN_IPHONEOS,    16#25).
-define(LC_FUNCTION_STARTS,         16#26).
-define(LC_DYLD_ENVIRONMENT,        16#27).
-define(LC_MAIN,                    (16#28 bor ?LC_REQ_DYLD)).
-define(LC_DATA_IN_CODE,            16#29).
-define(LC_SOURCE_VERSION,          16#2A).
-define(LC_DYLIB_CODE_SIGN_DRS,     16#2B).
-define(LC_ENCRYPTION_INFO_64,      16#2C).


%segment flags
-define(SG_HIGHVM,              16#1).
-define(SG_FVMLIB,              16#2).
-define(SG_NORELOC,             16#4).
-define(SG_PROTECTED_VERSION_1, 16#8).