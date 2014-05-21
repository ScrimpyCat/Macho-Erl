-module(macho).
-export([parse/1]).
-export([parse_file/1]).

-include("machine.hrl").
-include("loader.hrl").
-include("thread_structs.hrl").


parse(File) ->
    { ok, IoDevice } = file:open(File, [read, raw, binary, { read_ahead, 1024 }]),
    MachO = parse_file(IoDevice),
    file:close(IoDevice),
    MachO.



parse_file(IoDevice) ->
    { ok, <<Magic:32/little>> } = file:read(IoDevice, 4),
    parse_file(IoDevice, Magic).

parse_file(IoDevice, 16#feedface) -> % Mach-O header 32 bits - little endian
    { ok, <<CPUType:32/little,
            CPUSubType:32/little,
            FileType:32/little,
            NLoadCommands:32/little,
            SizeOfCommands:32/little,
            Flags:32/little>> } = file:read(IoDevice, 4 * 6),
    { ok, LoadCommands } = file:read(IoDevice, SizeOfCommands),
    Arch = get_cpu_type(CPUType, CPUSubType),
    { mach_header, little, erlang:append_element(Arch, get_cpu_subtype_capabilities(CPUSubType)), get_file_type(FileType), separate_load_commands(Arch, little, LoadCommands, NLoadCommands), get_mach_header_flags(Flags) };
parse_file(IoDevice, 16#feedfacf) -> % Mach-O header 64 bits - little endian
    { ok, <<CPUType:32/little,
            CPUSubType:32/little,
            FileType:32/little,
            NLoadCommands:32/little,
            SizeOfCommands:32/little,
            Flags:32/little,
            _Reserved:32/little>> } = file:read(IoDevice, 4 * 7),
    { ok, LoadCommands } = file:read(IoDevice, SizeOfCommands),
    Arch = get_cpu_type(CPUType, CPUSubType),
    { mach_header_64, little, erlang:append_element(Arch, get_cpu_subtype_capabilities(CPUSubType)), get_file_type(FileType), separate_load_commands(Arch, little, LoadCommands, NLoadCommands), get_mach_header_flags(Flags) };
parse_file(IoDevice, 16#cefaedfe) -> % Mach-O header 32 bits - big endian
        { ok, <<CPUType:32/big,
            CPUSubType:32/big,
            FileType:32/big,
            NLoadCommands:32/big,
            SizeOfCommands:32/big,
            Flags:32/big>> } = file:read(IoDevice, 4 * 6),
    { ok, LoadCommands } = file:read(IoDevice, SizeOfCommands),
    Arch = get_cpu_type(CPUType, CPUSubType),
    { mach_header, big, erlang:append_element(Arch, get_cpu_subtype_capabilities(CPUSubType)), get_file_type(FileType), separate_load_commands(Arch, big, LoadCommands, NLoadCommands), get_mach_header_flags(Flags) };
parse_file(IoDevice, 16#cffaedfe) -> % Mach-O header 64 bits - big endian
    { ok, <<CPUType:32/big,
        CPUSubType:32/big,
        FileType:32/big,
        NLoadCommands:32/big,
        SizeOfCommands:32/big,
        Flags:32/big,
        _Reserved:32/big>> } = file:read(IoDevice, 4 * 7),
    { ok, LoadCommands } = file:read(IoDevice, SizeOfCommands),
    Arch = get_cpu_type(CPUType, CPUSubType),
    { mach_header_64, big, erlang:append_element(Arch, get_cpu_subtype_capabilities(CPUSubType)), get_file_type(FileType), separate_load_commands(Arch, big, LoadCommands, NLoadCommands), get_mach_header_flags(Flags) };
parse_file(IoDevice, 16#bebafeca) -> % Mach-O fat header
    { ok, <<NFatArchs:32/big>> } = file:read(IoDevice, 4),
    { ok, FatArchs } = file:read(IoDevice, 4 * 5 * NFatArchs),
    { fat, lists:map(fun(Offset) ->
        file:position(IoDevice, Offset),
        parse_file(IoDevice)
    end, [Offset || <<_:32/big, _:32/big, Offset:32/big, _:32/big, _:32/big, _/binary>> <= FatArchs]) }.



separate_load_commands(Arch, Endianness, Data, N) when is_binary(Data) -> lists:reverse(separate_load_commands(Arch, Endianness, Data, N, [])).

separate_load_commands(_, _, _, 0, List) -> List;
separate_load_commands(Arch, little, Data = <<CMDType:32/little, CMDSize:32/little, _/binary>>, N, List) ->
    CMDDataSize = CMDSize - 8,
    <<_:32/little, _:32/little, CMDData:CMDDataSize/binary-unit:8, Next/binary>> = Data,
    separate_load_commands(Arch, little, Next, N - 1, [required_load_command(CMDType, parse_load_command(Arch, little, <<CMDType:32/little, CMDSize:32/little, CMDData:CMDDataSize/binary-unit:8>>))|List]);
separate_load_commands(Arch, big, Data = <<CMDType:32/big, CMDSize:32/big, _/binary>>, N, List) ->
    CMDDataSize = CMDSize - 8,
    <<_:32/big, _:32/big, CMDData:CMDDataSize/binary-unit:8, Next/binary>> = Data,
    separate_load_commands(Arch, big, Next, N - 1, [required_load_command(CMDType, parse_load_command(Arch, big, <<CMDType:32/big, CMDSize:32/big, CMDData:CMDDataSize/binary-unit:8>>))|List]).



required_load_command(CMD, LoadCommand) when CMD band ?LC_REQ_DYLD == ?LC_REQ_DYLD -> { required, LoadCommand };
required_load_command(_, LoadCommand) -> LoadCommand.

parse_load_command(_Arch, little, <<?LC_SEGMENT:32/little, _CMDSize:32/little, SegName:16/binary-unit:8, VMAddr:32/little, VMSize:32/little, FileOff:32/little, FileSize:32/little, MaxProt:32/little, InitProt:32/little, NSects:32/little, Flags:32/little, _Sections/binary>>) ->
    { segment_command, <<SegName:16/binary-unit:8>>, { vm, VMAddr, VMSize }, { file, FileOff, FileSize }, { prot, MaxProt, InitProt }, NSects, get_segment_flags(Flags) };
parse_load_command(_Arch, big, <<?LC_SEGMENT:32/big, _CMDSize:32/big, SegName:16/binary-unit:8, VMAddr:32/big, VMSize:32/big, FileOff:32/big, FileSize:32/big, MaxProt:32/big, InitProt:32/big, NSects:32/big, Flags:32/big, _Sections/binary>>) ->
    { segment_command, <<SegName:16/binary-unit:8>>, { vm, VMAddr, VMSize }, { file, FileOff, FileSize }, { prot, MaxProt, InitProt }, NSects, get_segment_flags(Flags) };

parse_load_command(_Arch, little, <<?LC_SYMTAB:32/little, _CMDSize:32/little, SymOff:32/little, NSyms:32/little, StrOff:32/little, StrSize:32/little>>) -> { symtab_command, { sym, SymOff, NSyms }, { str, StrOff, StrSize } };
parse_load_command(_Arch, big, <<?LC_SYMTAB:32/big, _CMDSize:32/big, SymOff:32/big, NSyms:32/big, StrOff:32/big, StrSize:32/big>>) -> { symtab_command, { sym, SymOff, NSyms }, { str, StrOff, StrSize } };

parse_load_command(_Arch, little, <<?LC_SYMSEG:32/little, _CMDSize:32/little, _/binary>>) -> symseg_command;

parse_load_command(Arch, little, <<?LC_THREAD:32/little, _CMDSize:32/little, ThreadData/binary>>) -> { thread_command, thread, get_thread_info(Arch, little, ThreadData) };
parse_load_command(Arch, big, <<?LC_THREAD:32/big, _CMDSize:32/big, ThreadData/binary>>) -> { thread_command, thread, get_thread_info(Arch, big, ThreadData) };

parse_load_command(Arch, little, <<?LC_UNIXTHREAD:32/little, _CMDSize:32/little, ThreadData/binary>>) -> { thread_command, unixthread, get_thread_info(Arch, little, ThreadData) };
parse_load_command(Arch, big, <<?LC_UNIXTHREAD:32/big, _CMDSize:32/big, ThreadData/binary>>) -> { thread_command, unixthread, get_thread_info(Arch, big, ThreadData) };

parse_load_command(_Arch, little, <<?LC_LOADFVMLIB:32/little, _CMDSize:32/little, _/binary>>) -> loadfvmlib_command;
parse_load_command(_Arch, little, <<?LC_IDFVMLIB:32/little, _CMDSize:32/little, _/binary>>) -> idfvmlib_command;
parse_load_command(_Arch, little, <<?LC_IDENT:32/little, _CMDSize:32/little, _/binary>>) -> ident_command;
parse_load_command(_Arch, little, <<?LC_FVMFILE:32/little, _CMDSize:32/little, _/binary>>) -> fvmfile_command;
parse_load_command(_Arch, little, <<?LC_PREPAGE:32/little, _CMDSize:32/little, _/binary>>) -> prepage_command;

parse_load_command(_Arch, little, <<?LC_DYSYMTAB:32/little, _CMDSize:32/little, ILocalSym:32/little, NLocalSym:32/little, IExtDefSym:32/little, NExtDefSym:32/little, IUndefSym:32/little, NUndefSym:32/little, TOCOff:32/little, NTOC:32/little, ModTabOff:32/little, NModTab:32/little, ExtRefSymOff:32/little, NExtRefSyms:32/little, IndirectSymOff:32/little, NIndirectSymOff:32/little, ExtRelOff:32/little, NExtRel:32/little, LocRelOff:32/little, NLocRel:32/little>>) ->
    { dysymtab_command, { local_sym, ILocalSym, NLocalSym }, { ext_def_sym, IExtDefSym, NExtDefSym }, { undef_sym, IUndefSym, NUndefSym }, { toc, TOCOff, NTOC }, { mod_tab, ModTabOff, NModTab }, { ext_ref_sym, ExtRefSymOff, NExtRefSyms }, { indrect_sym, IndirectSymOff, NIndirectSymOff }, { ext_rel, ExtRelOff, NExtRel }, { loc_rel, LocRelOff, NLocRel } };
parse_load_command(_Arch, big, <<?LC_DYSYMTAB:32/big, _CMDSize:32/big, ILocalSym:32/big, NLocalSym:32/big, IExtDefSym:32/big, NExtDefSym:32/big, IUndefSym:32/big, NUndefSym:32/big, TOCOff:32/big, NTOC:32/big, ModTabOff:32/big, NModTab:32/big, ExtRefSymOff:32/big, NExtRefSyms:32/big, IndirectSymOff:32/big, NIndirectSymOff:32/big, ExtRelOff:32/big, NExtRel:32/big, LocRelOff:32/big, NLocRel:32/big>>) ->
    { dysymtab_command, { local_sym, ILocalSym, NLocalSym }, { ext_def_sym, IExtDefSym, NExtDefSym }, { undef_sym, IUndefSym, NUndefSym }, { toc, TOCOff, NTOC }, { mod_tab, ModTabOff, NModTab }, { ext_ref_sym, ExtRefSymOff, NExtRefSyms }, { indrect_sym, IndirectSymOff, NIndirectSymOff }, { ext_rel, ExtRelOff, NExtRel }, { loc_rel, LocRelOff, NLocRel } };

parse_load_command(_Arch, little, <<?LC_LOAD_DYLIB:32/little, _CMDSize:32/little, _Name:32/little, Timestamp:32/little, CurrentVersionZ:8, CurrentVersionY:8, CurrentVersionX:16/little, CompatibilityVersionZ:8, CompatibilityVersionY:8, CompatibilityVersionX:16/little, PathName/binary>>) -> { dylib_command, load_dylib, PathName, Timestamp, { CurrentVersionX, CurrentVersionY, CurrentVersionZ }, { CompatibilityVersionX, CompatibilityVersionY, CompatibilityVersionZ } };
parse_load_command(_Arch, big, <<?LC_LOAD_DYLIB:32/big, _CMDSize:32/big, _Name:32/big, Timestamp:32/big, CurrentVersionX:16/big, CurrentVersionY:8, CurrentVersionZ:8, CompatibilityVersionX:16/big, CompatibilityVersionY:8, CompatibilityVersionZ:8, PathName/binary>>) -> { dylib_command, load_dylib, PathName, Timestamp, { CurrentVersionX, CurrentVersionY, CurrentVersionZ }, { CompatibilityVersionX, CompatibilityVersionY, CompatibilityVersionZ } };

parse_load_command(_Arch, little, <<?LC_ID_DYLIB:32/little, _CMDSize:32/little, _Name:32/little, Timestamp:32/little, CurrentVersionZ:8, CurrentVersionY:8, CurrentVersionX:16/little, CompatibilityVersionZ:8, CompatibilityVersionY:8, CompatibilityVersionX:16/little, PathName/binary>>) -> { dylib_command, id_dylib, PathName, Timestamp, { CurrentVersionX, CurrentVersionY, CurrentVersionZ }, { CompatibilityVersionX, CompatibilityVersionY, CompatibilityVersionZ } };
parse_load_command(_Arch, big, <<?LC_ID_DYLIB:32/big, _CMDSize:32/big, _Name:32/big, Timestamp:32/big, CurrentVersionX:16/big, CurrentVersionY:8, CurrentVersionZ:8, CompatibilityVersionX:16/big, CompatibilityVersionY:8, CompatibilityVersionZ:8, PathName/binary>>) -> { dylib_command, id_dylib, PathName, Timestamp, { CurrentVersionX, CurrentVersionY, CurrentVersionZ }, { CompatibilityVersionX, CompatibilityVersionY, CompatibilityVersionZ } };

parse_load_command(_Arch, little, <<?LC_LOAD_DYLINKER:32/little, _CMDSize:32/little, Name:32/little, _/binary>>) -> { dylinker_command, load_dylinker, Name };
parse_load_command(_Arch, big, <<?LC_LOAD_DYLINKER:32/big, _CMDSize:32/big, Name:32/big, _/binary>>) -> { dylinker_command, load_dylinker, Name };

parse_load_command(_Arch, little, <<?LC_ID_DYLINKER:32/little, _CMDSize:32/little, Name:32/little, _/binary>>) -> { dylinker_command, id_dylinker, Name };
parse_load_command(_Arch, big, <<?LC_ID_DYLINKER:32/big, _CMDSize:32/big, Name:32/big, _/binary>>) -> { dylinker_command, id_dylinker, Name };

parse_load_command(_Arch, little, <<?LC_PREBOUND_DYLIB:32/little, _CMDSize:32/little, _/binary>>) -> prebound_dylib_command;
parse_load_command(_Arch, little, <<?LC_ROUTINES:32/little, _CMDSize:32/little, _/binary>>) -> routines_command;
parse_load_command(_Arch, little, <<?LC_SUB_FRAMEWORK:32/little, _CMDSize:32/little, _/binary>>) -> sub_framework_command;
parse_load_command(_Arch, little, <<?LC_SUB_UMBRELLA:32/little, _CMDSize:32/little, _/binary>>) -> sub_umbrella_command;
parse_load_command(_Arch, little, <<?LC_SUB_CLIENT:32/little, _CMDSize:32/little, _/binary>>) -> sub_client_command;
parse_load_command(_Arch, little, <<?LC_SUB_LIBRARY:32/little, _CMDSize:32/little, _/binary>>) -> sub_library_command;

parse_load_command(_Arch, little, <<?LC_TWOLEVEL_HINTS:32/little, _CMDSize:32/little, Offset:32/little, NHints:32/little>>) -> { twolevel_hints_command, { hints, Offset, NHints } };
parse_load_command(_Arch, big, <<?LC_TWOLEVEL_HINTS:32/big, _CMDSize:32/big, Offset:32/big, NHints:32/big>>) -> { twolevel_hints_command, { hints, Offset, NHints } };

parse_load_command(_Arch, little, <<?LC_PREBIND_CKSUM:32/little, _CMDSize:32/little, _/binary>>) -> prebind_cksum_command;

parse_load_command(_Arch, little, <<?LC_LOAD_WEAK_DYLIB:32/little, _CMDSize:32/little, _Name:32/little, Timestamp:32/little, CurrentVersionZ:8, CurrentVersionY:8, CurrentVersionX:16/little, CompatibilityVersionZ:8, CompatibilityVersionY:8, CompatibilityVersionX:16/little, PathName/binary>>) -> { dylib_command, load_weak_dylib, PathName, Timestamp, { CurrentVersionX, CurrentVersionY, CurrentVersionZ }, { CompatibilityVersionX, CompatibilityVersionY, CompatibilityVersionZ } };
parse_load_command(_Arch, big, <<?LC_LOAD_WEAK_DYLIB:32/big, _CMDSize:32/big, _Name:32/big, Timestamp:32/big, CurrentVersionX:16/big, CurrentVersionY:8, CurrentVersionZ:8, CompatibilityVersionX:16/big, CompatibilityVersionY:8, CompatibilityVersionZ:8, PathName/binary>>) -> { dylib_command, load_weak_dylib, PathName, Timestamp, { CurrentVersionX, CurrentVersionY, CurrentVersionZ }, { CompatibilityVersionX, CompatibilityVersionY, CompatibilityVersionZ } };

parse_load_command(_Arch, little, <<?LC_SEGMENT_64:32/little, _CMDSize:32/little, SegName:8/binary-unit:16, VMAddr:64/little, VMSize:64/little, FileOff:64/little, FileSize:64/little, MaxProt:32/little, InitProt:32/little, NSects:32/little, Flags:32/little, _Sections/binary>>) ->
    { segment_command_64, <<SegName:8/binary-unit:16>>, { vm, VMAddr, VMSize }, { file, FileOff, FileSize }, { prot, MaxProt, InitProt }, NSects, get_segment_flags(Flags) };
parse_load_command(_Arch, big, <<?LC_SEGMENT_64:32/big, _CMDSize:32/big, SegName:8/binary-unit:16, VMAddr:64/big, VMSize:64/big, FileOff:64/big, FileSize:64/big, MaxProt:32/big, InitProt:32/big, NSects:32/big, Flags:32/big, _Sections/binary>>) ->
    { segment_command_64, <<SegName:8/binary-unit:16>>, { vm, VMAddr, VMSize }, { file, FileOff, FileSize }, { prot, MaxProt, InitProt }, NSects, get_segment_flags(Flags) };

parse_load_command(_Arch, little, <<?LC_ROUTINES_64:32/little, _/binary>>) -> routines_64_command;

parse_load_command(_Arch, little, <<?LC_UUID:32/little, _CMDSize:32/little, UUID:8/binary-unit:16>>) -> { uuid_command, UUID };
parse_load_command(_Arch, big, <<?LC_UUID:32/big, _CMDSize:32/big, UUID:8/binary-unit:16>>) -> { uuid_command, UUID };

parse_load_command(_Arch, little, <<?LC_RPATH:32/little, _CMDSize:32/little, _/binary>>) -> rpath_command;

parse_load_command(_Arch, little, <<?LC_CODE_SIGNATURE:32/little, _CMDSize:32/little, DataOff:32/little, DataSize:32/little>>) -> { linkedit_data_command, code_signature, { data, DataOff, DataSize } };
parse_load_command(_Arch, big, <<?LC_CODE_SIGNATURE:32/big, _CMDSize:32/big, DataOff:32/big, DataSize:32/big>>) -> { linkedit_data_command, code_signature, { data, DataOff, DataSize } };

parse_load_command(_Arch, little, <<?LC_SEGMENT_SPLIT_INFO:32/little, _CMDSize:32/little, DataOff:32/little, DataSize:32/little>>) -> { linkedit_data_command, segment_split_info, { data, DataOff, DataSize } };
parse_load_command(_Arch, big, <<?LC_SEGMENT_SPLIT_INFO:32/big, _CMDSize:32/big, DataOff:32/big, DataSize:32/big>>) -> { linkedit_data_command, segment_split_info, { data, DataOff, DataSize } };

parse_load_command(_Arch, little, <<?LC_REEXPORT_DYLIB:32/little, _CMDSize:32/little, _Name:32/little, Timestamp:32/little, CurrentVersionZ:8, CurrentVersionY:8, CurrentVersionX:16/little, CompatibilityVersionZ:8, CompatibilityVersionY:8, CompatibilityVersionX:16/little, PathName/binary>>) -> { dylib_command, reexport_dylib, PathName, Timestamp, { CurrentVersionX, CurrentVersionY, CurrentVersionZ }, { CompatibilityVersionX, CompatibilityVersionY, CompatibilityVersionZ } };
parse_load_command(_Arch, big, <<?LC_REEXPORT_DYLIB:32/big, _CMDSize:32/big, _Name:32/big, Timestamp:32/big, CurrentVersionX:16/big, CurrentVersionY:8, CurrentVersionZ:8, CompatibilityVersionX:16/big, CompatibilityVersionY:8, CompatibilityVersionZ:8, PathName/binary>>) -> { dylib_command, reexport_dylib, PathName, Timestamp, { CurrentVersionX, CurrentVersionY, CurrentVersionZ }, { CompatibilityVersionX, CompatibilityVersionY, CompatibilityVersionZ } };

parse_load_command(_Arch, little, <<?LC_LAZY_LOAD_DYLIB:32/little, _CMDSize:32/little, _Name:32/little, Timestamp:32/little, CurrentVersionZ:8, CurrentVersionY:8, CurrentVersionX:16/little, CompatibilityVersionZ:8, CompatibilityVersionY:8, CompatibilityVersionX:16/little, PathName/binary>>) -> { dylib_command, lazy_load_dylib, PathName, Timestamp, { CurrentVersionX, CurrentVersionY, CurrentVersionZ }, { CompatibilityVersionX, CompatibilityVersionY, CompatibilityVersionZ } };
parse_load_command(_Arch, little, <<?LC_LAZY_LOAD_DYLIB:32/big, _CMDSize:32/big, _Name:32/big, Timestamp:32/big, CurrentVersionX:16/big, CurrentVersionY:8, CurrentVersionZ:8, CompatibilityVersionX:16/big, CompatibilityVersionY:8, CompatibilityVersionZ:8, PathName/binary>>) -> { dylib_command, lazy_load_dylib, PathName, Timestamp, { CurrentVersionX, CurrentVersionY, CurrentVersionZ }, { CompatibilityVersionX, CompatibilityVersionY, CompatibilityVersionZ } };

parse_load_command(_Arch, little, <<?LC_ENCRYPTION_INFO:32/little, _CMDSize:32/little, _/binary>>) -> encryption_info_command;

parse_load_command(_Arch, little, <<?LC_DYLD_INFO:32/little, _CMDSize:32/little, RebaseOff:32/little, RebaseSize:32/little, BindOff:32/little, BindSize:32/little, WeakBindOff:32/little, WeakBindSize:32/little, LazyBindOff:32/little, LazyBindSize:32/little, ExportOff:32/little, ExportSize:32/little>>) ->
    { dyld_info_command, { rebase, RebaseOff, RebaseSize }, { bind, BindOff, BindSize }, { weak_bind, WeakBindOff, WeakBindSize }, { lazy_bind, LazyBindOff, LazyBindSize }, { export, ExportOff, ExportSize } };
parse_load_command(_Arch, big, <<?LC_DYLD_INFO:32/big, _CMDSize:32/big, RebaseOff:32/big, RebaseSize:32/big, BindOff:32/big, BindSize:32/big, WeakBindOff:32/big, WeakBindSize:32/big, LazyBindOff:32/big, LazyBindSize:32/big, ExportOff:32/big, ExportSize:32/big>>) ->
    { dyld_info_command, { rebase, RebaseOff, RebaseSize }, { bind, BindOff, BindSize }, { weak_bind, WeakBindOff, WeakBindSize }, { lazy_bind, LazyBindOff, LazyBindSize }, { export, ExportOff, ExportSize } };

parse_load_command(_Arch, little, <<?LC_DYLD_INFO_ONLY:32/little, _CMDSize:32/little, RebaseOff:32/little, RebaseSize:32/little, BindOff:32/little, BindSize:32/little, WeakBindOff:32/little, WeakBindSize:32/little, LazyBindOff:32/little, LazyBindSize:32/little, ExportOff:32/little, ExportSize:32/little>>) ->
    { dyld_info_command, { rebase, RebaseOff, RebaseSize }, { bind, BindOff, BindSize }, { weak_bind, WeakBindOff, WeakBindSize }, { lazy_bind, LazyBindOff, LazyBindSize }, { export, ExportOff, ExportSize } };
parse_load_command(_Arch, big, <<?LC_DYLD_INFO_ONLY:32/big, _CMDSize:32/big, RebaseOff:32/big, RebaseSize:32/big, BindOff:32/big, BindSize:32/big, WeakBindOff:32/big, WeakBindSize:32/big, LazyBindOff:32/big, LazyBindSize:32/big, ExportOff:32/big, ExportSize:32/big>>) ->
    { dyld_info_command, { rebase, RebaseOff, RebaseSize }, { bind, BindOff, BindSize }, { weak_bind, WeakBindOff, WeakBindSize }, { lazy_bind, LazyBindOff, LazyBindSize }, { export, ExportOff, ExportSize } };

parse_load_command(_Arch, little, <<?LC_LOAD_UPWARD_DYLIB:32/little, _CMDSize:32/little, _Name:32/little, Timestamp:32/little, CurrentVersionZ:8, CurrentVersionY:8, CurrentVersionX:16/little, CompatibilityVersionZ:8, CompatibilityVersionY:8, CompatibilityVersionX:16/little, PathName/binary>>) -> { dylib_command, load_upward_dylib_command, PathName, Timestamp, { CurrentVersionX, CurrentVersionY, CurrentVersionZ }, { CompatibilityVersionX, CompatibilityVersionY, CompatibilityVersionZ } };
parse_load_command(_Arch, big, <<?LC_LOAD_UPWARD_DYLIB:32/big, _CMDSize:32/big, _Name:32/big, Timestamp:32/big, CurrentVersionX:16/big, CurrentVersionY:8, CurrentVersionZ:8, CompatibilityVersionX:16/big, CompatibilityVersionY:8, CompatibilityVersionZ:8, PathName/binary>>) -> { dylib_command, load_upward_dylib_command, PathName, Timestamp, { CurrentVersionX, CurrentVersionY, CurrentVersionZ }, { CompatibilityVersionX, CompatibilityVersionY, CompatibilityVersionZ } };

parse_load_command(_Arch, little, <<?LC_VERSION_MIN_MACOSX:32/little, _CMDSize:32/little, VersionZ:8, VersionY:8, VersionX:16/little, SDKZ:8, SDKY:8, SDKX:16/little>>) -> { version_min_macosx_command, { VersionX, VersionY, VersionZ }, { SDKX, SDKY, SDKZ } };
parse_load_command(_Arch, big, <<?LC_VERSION_MIN_MACOSX:32/big, _CMDSize:32/big, VersionX:16/big, VersionY:8, VersionZ:8, SDKX:16/big, SDKY:8, SDKZ:8>>) -> { version_min_macosx_command, { VersionX, VersionY, VersionZ }, { SDKX, SDKY, SDKZ } };

parse_load_command(_Arch, little, <<?LC_VERSION_MIN_IPHONEOS:32/little, _CMDSize:32/little, VersionZ:8, VersionY:8, VersionX:16/little, SDKZ:8, SDKY:8, SDKX:16/little>>) -> { version_min_iphoneos_command, { VersionX, VersionY, VersionZ }, { SDKX, SDKY, SDKZ } };
parse_load_command(_Arch, big, <<?LC_VERSION_MIN_IPHONEOS:32/big, _CMDSize:32/big, VersionX:16/big, VersionY:8, VersionZ:8, SDKX:16/big, SDKY:8, SDKZ:8>>) -> { version_min_iphoneos_command, { VersionX, VersionY, VersionZ }, { SDKX, SDKY, SDKZ } };

parse_load_command(_Arch, little, <<?LC_FUNCTION_STARTS:32/little, _CMDSize:32/little,  DataOff:32/little, DataSize:32/little>>) -> { linkedit_data_command, function_starts, { data, DataOff, DataSize } };
parse_load_command(_Arch, big, <<?LC_FUNCTION_STARTS:32/big, _CMDSize:32/big,  DataOff:32/big, DataSize:32/big>>) -> { linkedit_data_command, function_starts, { data, DataOff, DataSize } };

parse_load_command(_Arch, little, <<?LC_DYLD_ENVIRONMENT:32/little, _CMDSize:32/little, Name:32/little, _/binary>>) -> { dylinker_command, dyld_environment, Name };
parse_load_command(_Arch, big, <<?LC_DYLD_ENVIRONMENT:32/big, _CMDSize:32/big, Name:32/big, _/binary>>) -> { dylinker_command, dyld_environment, Name };

parse_load_command(_Arch, little, <<?LC_MAIN:32/little, _CMDSize:32/little, EntryOff:64/little, StackSize:64/little>>) -> { entry_point_command, EntryOff, StackSize };
parse_load_command(_Arch, big, <<?LC_MAIN:32/big, _CMDSize:32/big, EntryOff:64/big, StackSize:64/big>>) -> { entry_point_command, EntryOff, StackSize };

parse_load_command(_Arch, little, <<?LC_DATA_IN_CODE:32/little, _CMDSize:32/little, DataOff:32/little, DataSize:32/little>>) -> { linkedit_data_command, data_in_code, { data, DataOff, DataSize } };
parse_load_command(_Arch, big, <<?LC_DATA_IN_CODE:32/big, _CMDSize:32/big, DataOff:32/big, DataSize:32/big>>) -> { linkedit_data_command, data_in_code, { data, DataOff, DataSize } };

parse_load_command(_Arch, little, <<?LC_SOURCE_VERSION:32/little, _CMDSize:32/little, VersionE:10/little, VersionD:10/little, VersionC:10/little, VersionB:10/little, VersionA:24/little>>) -> { source_version_command, { VersionA, VersionB, VersionC, VersionD, VersionE } };
parse_load_command(_Arch, big, <<?LC_SOURCE_VERSION:32/big, _CMDSize:32/big, VersionA:24/big, VersionB:10/big, VersionC:10/big, VersionD:10/big, VersionE:10/big>>) -> { source_version_command, { VersionA, VersionB, VersionC, VersionD, VersionE } };

parse_load_command(_Arch, little, <<?LC_DYLIB_CODE_SIGN_DRS:32/little, _CMDSize:32/little, DataOff:32/little, DataSize:32/little>>) -> { linkedit_data_command, dylib_code_sign_drs, { data, DataOff, DataSize } };
parse_load_command(_Arch, big, <<?LC_DYLIB_CODE_SIGN_DRS:32/big, _CMDSize:32/big, DataOff:32/big, DataSize:32/big>>) -> { linkedit_data_command, dylib_code_sign_drs, { data, DataOff, DataSize } };

parse_load_command(_Arch, little, <<?LC_ENCRYPTION_INFO_64:32/little, _CMDSize:32/little, _/binary>>) -> encryption_info_64_command;
parse_load_command(_Arch, _Endianness, LoadCommand) -> { error, LoadCommand }.



get_cpu_subtype_capabilities(Flags) -> get_cpu_subtype_capabilities_(Flags band ?CPU_SUBTYPE_MASK, []).

-define(GET_CPU_SUBTYPE_CAPABILITY(F, Name), get_cpu_subtype_capabilities_(Flags, List) when Flags band F == F -> get_cpu_subtype_capabilities_(Flags band bnot F, [Name|List])).

?GET_CPU_SUBTYPE_CAPABILITY(?CPU_SUBTYPE_LIB64, lib64);
get_cpu_subtype_capabilities_(_Flags, List) -> List.



get_cpu_type(CPUType, CPUSubType) when CPUSubType band ?CPU_SUBTYPE_MASK > 0 -> get_cpu_type(CPUType, CPUSubType band bnot ?CPU_SUBTYPE_MASK);

get_cpu_type(?CPU_TYPE_VAX, ?CPU_SUBTYPE_VAX_ALL) -> { cpu_type_vax, cpu_subtype_vax_all };
get_cpu_type(?CPU_TYPE_VAX, ?CPU_SUBTYPE_VAX780) -> { cpu_type_vax, cpu_subtype_vax780 };
get_cpu_type(?CPU_TYPE_VAX, ?CPU_SUBTYPE_VAX785) -> { cpu_type_vax, cpu_subtype_vax785 };
get_cpu_type(?CPU_TYPE_VAX, ?CPU_SUBTYPE_VAX750) -> { cpu_type_vax, cpu_subtype_vax750 };
get_cpu_type(?CPU_TYPE_VAX, ?CPU_SUBTYPE_VAX730) -> { cpu_type_vax, cpu_subtype_vax730 };
get_cpu_type(?CPU_TYPE_VAX, ?CPU_SUBTYPE_UVAXI) -> { cpu_type_vax, cpu_subtype_uvaxi };
get_cpu_type(?CPU_TYPE_VAX, ?CPU_SUBTYPE_UVAXII) -> { cpu_type_vax, cpu_subtype_uvaxii };
get_cpu_type(?CPU_TYPE_VAX, ?CPU_SUBTYPE_VAX8200) -> { cpu_type_vax, cpu_subtype_vax8200 };
get_cpu_type(?CPU_TYPE_VAX, ?CPU_SUBTYPE_VAX8500) -> { cpu_type_vax, cpu_subtype_vax8500 };
get_cpu_type(?CPU_TYPE_VAX, ?CPU_SUBTYPE_VAX8600) -> { cpu_type_vax, cpu_subtype_vax8600 };
get_cpu_type(?CPU_TYPE_VAX, ?CPU_SUBTYPE_VAX8650) -> { cpu_type_vax, cpu_subtype_vax8650 };
get_cpu_type(?CPU_TYPE_VAX, ?CPU_SUBTYPE_VAX8800) -> { cpu_type_vax, cpu_subtype_vax8800 };
get_cpu_type(?CPU_TYPE_VAX, ?CPU_SUBTYPE_UVAXIII) -> { cpu_type_vax, cpu_subtype_uvaxiii };
get_cpu_type(?CPU_TYPE_VAX, _CPUSubType) -> { cpu_type_vax, cpu_subtype_invalid };

get_cpu_type(?CPU_TYPE_MC680x0, ?CPU_SUBTYPE_MC680x0_ALL) -> { cpu_type_mc680x0, cpu_subtype_mc680x0_all };
% get_cpu_type(?CPU_TYPE_MC680x0, ?CPU_SUBTYPE_MC68030) -> { cpu_type_mc680x0, cpu_subtype_mc68030 };
get_cpu_type(?CPU_TYPE_MC680x0, ?CPU_SUBTYPE_MC68040) -> { cpu_type_mc680x0, cpu_subtype_mc68040 };
get_cpu_type(?CPU_TYPE_MC680x0, ?CPU_SUBTYPE_MC68030_ONLY) -> { cpu_type_mc680x0, cpu_subtype_mc68030_only };
get_cpu_type(?CPU_TYPE_MC680x0, _CPUSubType) -> { cpu_type_mc680x0, cpu_subtype_invalid };

get_cpu_type(?CPU_TYPE_MIPS, ?CPU_SUBTYPE_MIPS_ALL) -> { cpu_type_mips, cpu_subtype_mips_all };
get_cpu_type(?CPU_TYPE_MIPS, ?CPU_SUBTYPE_MIPS_R2300) -> { cpu_type_mips, cpu_subtype_mips_r2300 };
get_cpu_type(?CPU_TYPE_MIPS, ?CPU_SUBTYPE_MIPS_R2600) -> { cpu_type_mips, cpu_subtype_mips_r2600 };
get_cpu_type(?CPU_TYPE_MIPS, ?CPU_SUBTYPE_MIPS_R2800) -> { cpu_type_mips, cpu_subtype_mips_r2800 };
get_cpu_type(?CPU_TYPE_MIPS, ?CPU_SUBTYPE_MIPS_R2000a) -> { cpu_type_mips, cpu_subtype_mips_r2000a };
get_cpu_type(?CPU_TYPE_MIPS, ?CPU_SUBTYPE_MIPS_R2000) -> { cpu_type_mips, cpu_subtype_mips_r2000 };
get_cpu_type(?CPU_TYPE_MIPS, ?CPU_SUBTYPE_MIPS_R3000a) -> { cpu_type_mips, cpu_subtype_mips_r3000a };
get_cpu_type(?CPU_TYPE_MIPS, ?CPU_SUBTYPE_MIPS_R3000) -> { cpu_type_mips, cpu_subtype_mips_r3000 };
get_cpu_type(?CPU_TYPE_MIPS, _CPUSubType) -> { cpu_type_mips, cpu_subtype_invalid };

get_cpu_type(?CPU_TYPE_MC98000, ?CPU_SUBTYPE_MC98000_ALL) -> { cpu_type_mc98000, cpu_subtype_mc98000_all };
get_cpu_type(?CPU_TYPE_MC98000, ?CPU_SUBTYPE_MC98601) -> { cpu_type_mc98000, cpu_subtype_mc98601 };
get_cpu_type(?CPU_TYPE_MC98000, _CPUSubType) -> { cpu_type_mc98000, cpu_subtype_invalid };

get_cpu_type(?CPU_TYPE_HPPA, ?CPU_SUBTYPE_HPPA_ALL) -> { cpu_type_hppa, cpu_subtype_hppa_all };
% get_cpu_type(?CPU_TYPE_HPPA, ?CPU_SUBTYPE_HPPA_7100) -> { cpu_type_hppa, cpu_subtype_hppa_7100 };
get_cpu_type(?CPU_TYPE_HPPA, ?CPU_SUBTYPE_HPPA_7100LC) -> { cpu_type_hppa, cpu_subtype_hppa_7100lc };
get_cpu_type(?CPU_TYPE_HPPA, _CPUSubType) -> { cpu_type_hppa, cpu_subtype_invalid };

get_cpu_type(?CPU_TYPE_MC88000, ?CPU_SUBTYPE_MC88000_ALL) -> { cpu_type_mc88000, cpu_subtype_mc88000_all };
get_cpu_type(?CPU_TYPE_MC88000, ?CPU_SUBTYPE_MC88100) -> { cpu_type_mc88000, cpu_subtype_mc88100 };
get_cpu_type(?CPU_TYPE_MC88000, ?CPU_SUBTYPE_MC88110) -> { cpu_type_mc88000, cpu_subtype_mc88110 };
get_cpu_type(?CPU_TYPE_MC88000, _CPUSubType) -> { cpu_type_mc88000, cpu_subtype_invalid };

get_cpu_type(?CPU_TYPE_SPARC, ?CPU_SUBTYPE_SPARC_ALL) -> { cpu_type_sparc, cpu_subtype_sparc_all };
get_cpu_type(?CPU_TYPE_SPARC, _CPUSubType) -> { cpu_type_sparc, cpu_subtype_invalid };

get_cpu_type(?CPU_TYPE_I860, ?CPU_SUBTYPE_I860_ALL) -> { cpu_type_i860, cpu_subtype_i860_all };
get_cpu_type(?CPU_TYPE_I860, ?CPU_SUBTYPE_I860_860) -> { cpu_type_i860, cpu_subtype_i860_860 };
get_cpu_type(?CPU_TYPE_I860, _CPUSubType) -> { cpu_type_i860, cpu_subtype_invalid };

get_cpu_type(?CPU_TYPE_X86, ?CPU_SUBTYPE_X86_ALL) -> { cpu_type_x86, cpu_subtype_x86_all };
% get_cpu_type(?CPU_TYPE_X86, ?CPU_SUBTYPE_386) -> { cpu_type_x86, cpu_subtype_386 };
get_cpu_type(?CPU_TYPE_X86, ?CPU_SUBTYPE_486) -> { cpu_type_x86, cpu_subtype_486 };
get_cpu_type(?CPU_TYPE_X86, ?CPU_SUBTYPE_486SX) -> { cpu_type_x86, cpu_subtype_486sx };
% get_cpu_type(?CPU_TYPE_X86, ?CPU_SUBTYPE_586) -> { cpu_type_x86, cpu_subtype_586 };
get_cpu_type(?CPU_TYPE_X86, ?CPU_SUBTYPE_PENT) -> { cpu_type_x86, cpu_subtype_pent };
get_cpu_type(?CPU_TYPE_X86, ?CPU_SUBTYPE_PENTPRO) -> { cpu_type_x86, cpu_subtype_pentpro };
get_cpu_type(?CPU_TYPE_X86, ?CPU_SUBTYPE_PENTII_M3) -> { cpu_type_x86, cpu_subtype_pentii_m3 };
get_cpu_type(?CPU_TYPE_X86, ?CPU_SUBTYPE_PENTII_M5) -> { cpu_type_x86, cpu_subtype_pentii_m5 };
get_cpu_type(?CPU_TYPE_X86, ?CPU_SUBTYPE_CELERON) -> { cpu_type_x86, cpu_subtype_celeron };
get_cpu_type(?CPU_TYPE_X86, ?CPU_SUBTYPE_CELERON_MOBILE) -> { cpu_type_x86, cpu_subtype_celeron_mobile };
get_cpu_type(?CPU_TYPE_X86, ?CPU_SUBTYPE_PENTIUM_3) -> { cpu_type_x86, cpu_subtype_pentium_3 };
get_cpu_type(?CPU_TYPE_X86, ?CPU_SUBTYPE_PENTIUM_3_M) -> { cpu_type_x86, cpu_subtype_pentium_3_m };
get_cpu_type(?CPU_TYPE_X86, ?CPU_SUBTYPE_PENTIUM_3_XEON) -> { cpu_type_x86, cpu_subtype_pentium_3_xeon };
get_cpu_type(?CPU_TYPE_X86, ?CPU_SUBTYPE_PENTIUM_M) -> { cpu_type_x86, cpu_subtype_pentium_m };
get_cpu_type(?CPU_TYPE_X86, ?CPU_SUBTYPE_PENTIUM_4) -> { cpu_type_x86, cpu_subtype_pentium_4 };
get_cpu_type(?CPU_TYPE_X86, ?CPU_SUBTYPE_PENTIUM_4_M) -> { cpu_type_x86, cpu_subtype_pentium_4_m };
get_cpu_type(?CPU_TYPE_X86, ?CPU_SUBTYPE_ITANIUM) -> { cpu_type_x86, cpu_subtype_itanium };
get_cpu_type(?CPU_TYPE_X86, ?CPU_SUBTYPE_ITANIUM_2) -> { cpu_type_x86, cpu_subtype_itanium_2 };
get_cpu_type(?CPU_TYPE_X86, ?CPU_SUBTYPE_XEON) -> { cpu_type_x86, cpu_subtype_xeon };
get_cpu_type(?CPU_TYPE_X86, ?CPU_SUBTYPE_XEON_MP) -> { cpu_type_x86, cpu_subtype_xeon_mp };
get_cpu_type(?CPU_TYPE_X86, _CPUSubType) -> { cpu_type_x86, cpu_subtype_invalid };

get_cpu_type(?CPU_TYPE_ARM, ?CPU_SUBTYPE_ARM_ALL) -> { cpu_type_arm, cpu_subtype_arm_all };
get_cpu_type(?CPU_TYPE_ARM, ?CPU_SUBTYPE_ARM_V4T) -> { cpu_type_arm, cpu_subtype_arm_v4t };
get_cpu_type(?CPU_TYPE_ARM, ?CPU_SUBTYPE_ARM_V6) -> { cpu_type_arm, cpu_subtype_arm_v6 };
get_cpu_type(?CPU_TYPE_ARM, ?CPU_SUBTYPE_ARM_V5TEJ) -> { cpu_type_arm, cpu_subtype_arm_v5tej };
get_cpu_type(?CPU_TYPE_ARM, ?CPU_SUBTYPE_ARM_XSCALE) -> { cpu_type_arm, cpu_subtype_arm_xscale };
get_cpu_type(?CPU_TYPE_ARM, ?CPU_SUBTYPE_ARM_V7) -> { cpu_type_arm, cpu_subtype_arm_v7 };
get_cpu_type(?CPU_TYPE_ARM, ?CPU_SUBTYPE_ARM_V7F) -> { cpu_type_arm, cpu_subtype_arm_v7f };
get_cpu_type(?CPU_TYPE_ARM, ?CPU_SUBTYPE_ARM_V7S) -> { cpu_type_arm, cpu_subtype_arm_v7s };
get_cpu_type(?CPU_TYPE_ARM, ?CPU_SUBTYPE_ARM_V7K) -> { cpu_type_arm, cpu_subtype_arm_v7k };
get_cpu_type(?CPU_TYPE_ARM, ?CPU_SUBTYPE_ARM_V6M) -> { cpu_type_arm, cpu_subtype_arm_v6m };
get_cpu_type(?CPU_TYPE_ARM, ?CPU_SUBTYPE_ARM_V7M) -> { cpu_type_arm, cpu_subtype_arm_v7m };
get_cpu_type(?CPU_TYPE_ARM, ?CPU_SUBTYPE_ARM_V7EM) -> { cpu_type_arm, cpu_subtype_arm_v7em };
get_cpu_type(?CPU_TYPE_ARM, ?CPU_SUBTYPE_ARM_V8) -> { cpu_type_arm, cpu_subtype_arm_v8 };
get_cpu_type(?CPU_TYPE_ARM, _CPUSubType) -> { cpu_type_arm, cpu_subtype_invalid };

get_cpu_type(?CPU_TYPE_POWERPC, ?CPU_SUBTYPE_POWERPC_ALL) -> { cpu_type_powerpc, cpu_subtype_powerpc_all };
get_cpu_type(?CPU_TYPE_POWERPC, ?CPU_SUBTYPE_POWERPC_601) -> { cpu_type_powerpc, cpu_subtype_powerpc_601 };
get_cpu_type(?CPU_TYPE_POWERPC, ?CPU_SUBTYPE_POWERPC_602) -> { cpu_type_powerpc, cpu_subtype_powerpc_602 };
get_cpu_type(?CPU_TYPE_POWERPC, ?CPU_SUBTYPE_POWERPC_603) -> { cpu_type_powerpc, cpu_subtype_powerpc_603 };
get_cpu_type(?CPU_TYPE_POWERPC, ?CPU_SUBTYPE_POWERPC_603e) -> { cpu_type_powerpc, cpu_subtype_powerpc_603e };
get_cpu_type(?CPU_TYPE_POWERPC, ?CPU_SUBTYPE_POWERPC_603ev) -> { cpu_type_powerpc, cpu_subtype_powerpc_603ev };
get_cpu_type(?CPU_TYPE_POWERPC, ?CPU_SUBTYPE_POWERPC_604) -> { cpu_type_powerpc, cpu_subtype_powerpc_604 };
get_cpu_type(?CPU_TYPE_POWERPC, ?CPU_SUBTYPE_POWERPC_604e) -> { cpu_type_powerpc, cpu_subtype_powerpc_604e };
get_cpu_type(?CPU_TYPE_POWERPC, ?CPU_SUBTYPE_POWERPC_620) -> { cpu_type_powerpc, cpu_subtype_powerpc_620 };
get_cpu_type(?CPU_TYPE_POWERPC, ?CPU_SUBTYPE_POWERPC_750) -> { cpu_type_powerpc, cpu_subtype_powerpc_750 };
get_cpu_type(?CPU_TYPE_POWERPC, ?CPU_SUBTYPE_POWERPC_7400) -> { cpu_type_powerpc, cpu_subtype_powerpc_7400 };
get_cpu_type(?CPU_TYPE_POWERPC, ?CPU_SUBTYPE_POWERPC_7450) -> { cpu_type_powerpc, cpu_subtype_powerpc_7450 };
get_cpu_type(?CPU_TYPE_POWERPC, ?CPU_SUBTYPE_POWERPC_970) -> { cpu_type_powerpc, cpu_subtype_powerpc_970 };
get_cpu_type(?CPU_TYPE_POWERPC, _CPUSubType) -> { cpu_type_powerpc, cpu_subtype_invalid };

get_cpu_type(?CPU_TYPE_X86_64, ?CPU_SUBTYPE_X86_64_ALL) -> { cpu_type_x86_64, cpu_subtype_x86_64_all };
get_cpu_type(?CPU_TYPE_X86_64, _CPUSubType) -> { cpu_type_x86_64, cpu_subtype_invalid };

get_cpu_type(?CPU_TYPE_ARM64, ?CPU_SUBTYPE_ARM64_ALL) -> { cpu_type_arm64, cpu_subtype_arm64_all };
get_cpu_type(?CPU_TYPE_ARM64, ?CPU_SUBTYPE_ARM64_V8) -> { cpu_type_arm64, cpu_subtype_arm64_v8 };
get_cpu_type(?CPU_TYPE_ARM64, _CPUSubType) -> { cpu_type_arm64, cpu_subtype_invalid };

get_cpu_type(?CPU_TYPE_POWERPC64, ?CPU_SUBTYPE_POWERPC_ALL) -> { cpu_type_powerpc64, cpu_subtype_powerpc_all };
get_cpu_type(?CPU_TYPE_POWERPC64, ?CPU_SUBTYPE_POWERPC_601) -> { cpu_type_powerpc64, cpu_subtype_powerpc_601 };
get_cpu_type(?CPU_TYPE_POWERPC64, ?CPU_SUBTYPE_POWERPC_602) -> { cpu_type_powerpc64, cpu_subtype_powerpc_602 };
get_cpu_type(?CPU_TYPE_POWERPC64, ?CPU_SUBTYPE_POWERPC_603) -> { cpu_type_powerpc64, cpu_subtype_powerpc_603 };
get_cpu_type(?CPU_TYPE_POWERPC64, ?CPU_SUBTYPE_POWERPC_603e) -> { cpu_type_powerpc64, cpu_subtype_powerpc_603e };
get_cpu_type(?CPU_TYPE_POWERPC64, ?CPU_SUBTYPE_POWERPC_603ev) -> { cpu_type_powerpc64, cpu_subtype_powerpc_603ev };
get_cpu_type(?CPU_TYPE_POWERPC64, ?CPU_SUBTYPE_POWERPC_604) -> { cpu_type_powerpc64, cpu_subtype_powerpc_604 };
get_cpu_type(?CPU_TYPE_POWERPC64, ?CPU_SUBTYPE_POWERPC_604e) -> { cpu_type_powerpc64, cpu_subtype_powerpc_604e };
get_cpu_type(?CPU_TYPE_POWERPC64, ?CPU_SUBTYPE_POWERPC_620) -> { cpu_type_powerpc64, cpu_subtype_powerpc_620 };
get_cpu_type(?CPU_TYPE_POWERPC64, ?CPU_SUBTYPE_POWERPC_750) -> { cpu_type_powerpc64, cpu_subtype_powerpc_750 };
get_cpu_type(?CPU_TYPE_POWERPC64, ?CPU_SUBTYPE_POWERPC_7400) -> { cpu_type_powerpc64, cpu_subtype_powerpc_7400 };
get_cpu_type(?CPU_TYPE_POWERPC64, ?CPU_SUBTYPE_POWERPC_7450) -> { cpu_type_powerpc64, cpu_subtype_powerpc_7450 };
get_cpu_type(?CPU_TYPE_POWERPC64, ?CPU_SUBTYPE_POWERPC_970) -> { cpu_type_powerpc64, cpu_subtype_powerpc_970 };
get_cpu_type(?CPU_TYPE_POWERPC64, _CPUSubType) -> { cpu_type_powerpc64, cpu_subtype_invalid };

get_cpu_type(?CPU_TYPE_ANY, ?CPU_SUBTYPE_MULTIPLE) -> { cpu_type_any, cpu_subtype_multiple };
get_cpu_type(?CPU_TYPE_ANY, ?CPU_SUBTYPE_LITTLE_ENDIAN) -> { cpu_type_any, cpu_subtype_little_endian };
get_cpu_type(?CPU_TYPE_ANY, ?CPU_SUBTYPE_BIG_ENDIAN) -> { cpu_type_any, cpu_subtype_big_endian };
get_cpu_type(?CPU_TYPE_ANY, _CPUSubType) -> { cpu_type_any, cpu_subtype_invalid };

get_cpu_type(_CPUType, _CPUSubType) -> { cpu_type_invalid, cpu_subtype_invalid }.



get_file_type(?MH_OBJECT) -> object;
get_file_type(?MH_EXECUTE) -> execute;
get_file_type(?MH_FVMLIB) -> fvmlib;
get_file_type(?MH_CORE) -> core;
get_file_type(?MH_PRELOAD) -> preload;
get_file_type(?MH_DYLIB) -> dylib;
get_file_type(?MH_DYLINKER) -> dylinker;
get_file_type(?MH_BUNDLE) -> bundle;
get_file_type(?MH_DYLIB_STUB) -> dylib_stub;
get_file_type(?MH_DSYM) -> dsym;
get_file_type(?MH_KEXT_BUNDLE) -> kext_bundle;
get_file_type(_FileType) -> file_type_invalid.



get_mach_header_flags(Flags) -> get_mach_header_flags_(Flags, []).

-define(GET_MACH_HEADER_FLAG(F, Name), get_mach_header_flags_(Flags, List) when Flags band F == F -> get_mach_header_flags_(Flags band bnot F, [Name|List])).

?GET_MACH_HEADER_FLAG(?MH_NO_HEAP_EXECUTION, no_heap_execution);
?GET_MACH_HEADER_FLAG(?MH_HAS_TLV_DESCRIPTORS, has_tlv_descriptors);
?GET_MACH_HEADER_FLAG(?MH_DEAD_STRIPPABLE_DYLIB, dead_strippable_dylib);
?GET_MACH_HEADER_FLAG(?MH_PIE, pie);
?GET_MACH_HEADER_FLAG(?MH_NO_REEXPORTED_DYLIBS, no_reexported_dylibs);
?GET_MACH_HEADER_FLAG(?MH_SETUID_SAFE, setuid_safe);
?GET_MACH_HEADER_FLAG(?MH_ROOT_SAFE, root_safe);
?GET_MACH_HEADER_FLAG(?MH_ALLOW_STACK_EXECUTION, allow_stack_execution);
?GET_MACH_HEADER_FLAG(?MH_BINDS_TO_WEAK, binds_to_weak);
?GET_MACH_HEADER_FLAG(?MH_WEAK_DEFINES, weak_defines);
?GET_MACH_HEADER_FLAG(?MH_CANONICAL, canonical);
?GET_MACH_HEADER_FLAG(?MH_SUBSECTIONS_VIA_SYMBOLS, subsections_via_symbols);
?GET_MACH_HEADER_FLAG(?MH_ALLMODSBOUND, allmodsbound);
?GET_MACH_HEADER_FLAG(?MH_PREBINDABLE, prebindable);
?GET_MACH_HEADER_FLAG(?MH_NOFIXPREBINDING, nofixprebinding);
?GET_MACH_HEADER_FLAG(?MH_NOMULTIDEFS, nomultidefs);
?GET_MACH_HEADER_FLAG(?MH_FORCE_FLAT, force_flat);
?GET_MACH_HEADER_FLAG(?MH_TWOLEVEL, twolevel);
?GET_MACH_HEADER_FLAG(?MH_LAZY_INIT, lazy_init);
?GET_MACH_HEADER_FLAG(?MH_SPLIT_SEGS, split_segs);
?GET_MACH_HEADER_FLAG(?MH_PREBOUND, prebound);
?GET_MACH_HEADER_FLAG(?MH_BINDATLOAD, bindatload);
?GET_MACH_HEADER_FLAG(?MH_DYLDLINK, dyldlink);
?GET_MACH_HEADER_FLAG(?MH_INCRLINK, incrlink);
?GET_MACH_HEADER_FLAG(?MH_NOUNDEFS, noundefs);
get_mach_header_flags_(_Flags, List) -> List.



get_segment_flags(Flags) -> get_segment_flags_(Flags, []).

-define(GET_SEGMENT_FLAG(F, Name), get_segment_flags_(Flags, List) when Flags band F == F -> get_segment_flags_(Flags band bnot F, [Name|List])).

?GET_SEGMENT_FLAG(?SG_PROTECTED_VERSION_1, protected_version_1);
?GET_SEGMENT_FLAG(?SG_NORELOC, noreloc);
?GET_SEGMENT_FLAG(?SG_FVMLIB, fvmlib);
?GET_SEGMENT_FLAG(?SG_HIGHVM, highvm);
get_segment_flags_(_Flags, List) -> List.



get_thread_info(Arch, Endianness, ThreadData) when is_binary(ThreadData) -> lists:reverse(get_thread_info(Arch, Endianness, ThreadData, [])).

get_thread_info(Arch, big, <<Flavour:32/big, Count:32/big, Data:Count/binary-unit:32, Next/binary>>, List) ->
    Flav = get_thread_flavour(Arch, Flavour),
    get_thread_info(Arch, big, Next, [{ Flav, Count, get_thread_state(big, Flav, Data) }|List]);
get_thread_info(Arch, little, <<Flavour:32/little, Count:32/little, Data:Count/binary-unit:32, Next/binary>>, List) ->
    Flav = get_thread_flavour(Arch, Flavour),
    get_thread_info(Arch, little, Next, [{ Flav, Count, get_thread_state(little, Flav, Data) }|List]);
get_thread_info(_, _, _, List) -> List.



get_thread_flavour({ cpu_type_powerpc, _ }, ?PPC_THREAD_STATE) -> ppc_thread_state;
get_thread_flavour({ cpu_type_powerpc, _ }, ?PPC_EXCEPTION_STATE) -> ppc_exception_state;
get_thread_flavour({ cpu_type_powerpc, _ }, ?PPC_FLOAT_STATE) -> ppc_float_state;
get_thread_flavour({ cpu_type_powerpc, _ }, ?PPC_VECTOR_STATE) -> ppc_vector_state;

get_thread_flavour({ cpu_type_powerpc64, _ }, ?PPC_THREAD_STATE64) -> ppc_thread_state64;
get_thread_flavour({ cpu_type_powerpc64, _ }, ?PPC_EXCEPTION_STATE64) -> ppc_exception_state64;
get_thread_flavour({ cpu_type_powerpc64, _ }, ?PPC_FLOAT_STATE) -> ppc_float_state;
get_thread_flavour({ cpu_type_powerpc64, _ }, ?PPC_VECTOR_STATE) -> ppc_vector_state;

get_thread_flavour({ cpu_type_x86, _ }, ?x86_THREAD_STATE32) -> x86_thread_state32;
get_thread_flavour({ cpu_type_x86, _ }, ?x86_FLOAT_STATE32) -> x86_float_state32;
get_thread_flavour({ cpu_type_x86, _ }, ?x86_EXCEPTION_STATE32) -> x86_exception_state32;
get_thread_flavour({ cpu_type_x86, _ }, ?x86_THREAD_STATE) -> x86_thread_state;
get_thread_flavour({ cpu_type_x86, _ }, ?x86_FLOAT_STATE) -> x86_float_state;
get_thread_flavour({ cpu_type_x86, _ }, ?x86_EXCEPTION_STATE) -> x86_exception_state;
get_thread_flavour({ cpu_type_x86, _ }, ?x86_DEBUG_STATE32) -> x86_debug_state32;
get_thread_flavour({ cpu_type_x86, _ }, ?x86_DEBUG_STATE) -> x86_debug_state;
get_thread_flavour({ cpu_type_x86, _ }, ?x86_THREAD_STATE_NONE) -> x86_thread_state_none;
get_thread_flavour({ cpu_type_x86, _ }, ?x86_SAVED_STATE32) -> x86_saved_state32;
get_thread_flavour({ cpu_type_x86, _ }, ?x86_AVX_STATE32) -> x86_avx_state32;
get_thread_flavour({ cpu_type_x86, _ }, ?x86_AVX_STATE) -> x86_avx_state;

get_thread_flavour({ cpu_type_x86_64, _ }, ?x86_THREAD_STATE64) -> x86_thread_state64;
get_thread_flavour({ cpu_type_x86_64, _ }, ?x86_FLOAT_STATE64) -> x86_float_state64;
get_thread_flavour({ cpu_type_x86_64, _ }, ?x86_EXCEPTION_STATE64) -> x86_exception_state64;
get_thread_flavour({ cpu_type_x86_64, _ }, ?x86_THREAD_STATE) -> x86_thread_state;
get_thread_flavour({ cpu_type_x86_64, _ }, ?x86_FLOAT_STATE) -> x86_float_state;
get_thread_flavour({ cpu_type_x86_64, _ }, ?x86_EXCEPTION_STATE) -> x86_exception_state;
get_thread_flavour({ cpu_type_x86_64, _ }, ?x86_DEBUG_STATE64) -> x86_debug_state64;
get_thread_flavour({ cpu_type_x86_64, _ }, ?x86_DEBUG_STATE) -> x86_debug_state;
get_thread_flavour({ cpu_type_x86_64, _ }, ?x86_THREAD_STATE_NONE) -> x86_thread_state_none;
get_thread_flavour({ cpu_type_x86_64, _ }, ?x86_SAVED_STATE64) -> x86_saved_state64;
get_thread_flavour({ cpu_type_x86_64, _ }, ?x86_AVX_STATE64) -> x86_avx_state64;
get_thread_flavour({ cpu_type_x86_64, _ }, ?x86_AVX_STATE) -> x86_avx_state;

get_thread_flavour({ cpu_type_arm, _ }, ?ARM_THREAD_STATE) -> arm_thread_state;
get_thread_flavour({ cpu_type_arm, _ }, ?ARM_VFP_STATE) -> arm_vfp_state;
get_thread_flavour({ cpu_type_arm, _ }, ?ARM_EXCEPTION_STATE) -> arm_exception_state;
get_thread_flavour({ cpu_type_arm, _ }, ?ARM_DEBUG_STATE) -> arm_debug_state;
get_thread_flavour({ cpu_type_arm, _ }, ?THREAD_STATE_NONE) -> thread_state_none;
get_thread_flavour({ cpu_type_arm, _ }, ?ARM_THREAD_STATE64) -> arm_thread_state64;
get_thread_flavour({ cpu_type_arm, _ }, ?ARM_EXCEPTION_STATE64) -> arm_exception_state64;
get_thread_flavour({ cpu_type_arm, _ }, ?ARM_THREAD_STATE32) -> arm_thread_state32;
get_thread_flavour({ cpu_type_arm, _ }, ?ARM_DEBUG_STATE32) -> arm_debug_state32;
get_thread_flavour({ cpu_type_arm, _ }, ?ARM_DEBUG_STATE64) -> arm_debug_state64;
get_thread_flavour({ cpu_type_arm, _ }, ?ARM_NEON_STATE) -> arm_neon_state;
get_thread_flavour({ cpu_type_arm, _ }, ?ARM_NEON_STATE64) -> arm_neon_state64;

get_thread_flavour({ cpu_type_arm64, _ }, ?ARM_THREAD_STATE) -> arm_thread_state;
get_thread_flavour({ cpu_type_arm64, _ }, ?ARM_VFP_STATE) -> arm_vfp_state;
get_thread_flavour({ cpu_type_arm64, _ }, ?ARM_EXCEPTION_STATE) -> arm_exception_state;
get_thread_flavour({ cpu_type_arm64, _ }, ?ARM_DEBUG_STATE) -> arm_debug_state;
get_thread_flavour({ cpu_type_arm64, _ }, ?THREAD_STATE_NONE) -> thread_state_none;
get_thread_flavour({ cpu_type_arm64, _ }, ?ARM_THREAD_STATE64) -> arm_thread_state64;
get_thread_flavour({ cpu_type_arm64, _ }, ?ARM_EXCEPTION_STATE64) -> arm_exception_state64;
get_thread_flavour({ cpu_type_arm64, _ }, ?ARM_THREAD_STATE32) -> arm_thread_state32;
get_thread_flavour({ cpu_type_arm64, _ }, ?ARM_DEBUG_STATE32) -> arm_debug_state32;
get_thread_flavour({ cpu_type_arm64, _ }, ?ARM_DEBUG_STATE64) -> arm_debug_state64;
get_thread_flavour({ cpu_type_arm64, _ }, ?ARM_NEON_STATE) -> arm_neon_state;
get_thread_flavour({ cpu_type_arm64, _ }, ?ARM_NEON_STATE64) -> arm_neon_state64;

get_thread_flavour(_Arch, _Flavour) -> invalid_thread_flavour.



-define(PACKAGE_PPC_THREAD_STATE, {
    { srr0, SRR0 }, { srr1, SRR1 },
    { r0, R0 }, { r1, R1 }, { r2, R2 }, { r3, R3 },
    { r4, R4 }, { r5, R5 }, { r6, R6 }, { r7, R7 },
    { r8, R8 }, { r9, R9 }, { r10, R10 }, { r11, R11 },
    { r12, R12 }, { r13, R13 }, { r14, R14 }, { r15, R15 },
    { r16, R16 }, { r17, R17 }, { r18, R18 }, { r19, R19 },
    { r20, R20 }, { r21, R21 }, { r22, R22 }, { r23, R23 },
    { r24, R24 }, { r25, R25 }, { r26, R26 }, { r27, R27 },
    { r28, R28 }, { r29, R29 }, { r30, R30 }, { r31, R31 },
    { cr, CR }, { xer, XER }, { lr, LR }, { ctr, CTR }, { mq, MQ },
    { vrsave, VRSAVE }
}).

-define(PACKAGE_PPC_THREAD_STATE64, {
    { srr0, SRR0 }, { srr1, SRR1 },
    { r0, R0 }, { r1, R1 }, { r2, R2 }, { r3, R3 },
    { r4, R4 }, { r5, R5 }, { r6, R6 }, { r7, R7 },
    { r8, R8 }, { r9, R9 }, { r10, R10 }, { r11, R11 },
    { r12, R12 }, { r13, R13 }, { r14, R14 }, { r15, R15 },
    { r16, R16 }, { r17, R17 }, { r18, R18 }, { r19, R19 },
    { r20, R20 }, { r21, R21 }, { r22, R22 }, { r23, R23 },
    { r24, R24 }, { r25, R25 }, { r26, R26 }, { r27, R27 },
    { r28, R28 }, { r29, R29 }, { r30, R30 }, { r31, R31 },
    { cr, CR }, { xer, XER }, { lr, LR }, { ctr, CTR },
    { vrsave, VRSAVE }
}).

-define(PACKAGE_PPC_FLOAT_STATE, {
    { fpregs, [F0, F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, F15, F16, F17, F18, F19, F20, F21, F22, F23, F24, F25, F26, F27, F28, F29, F30, F31] },
    { fpscr_pad, FPSCRPAD }, { fpscr, FPSCR }
}).

-define(PACKAGE_PPC_VECTOR_STATE, {
    { save_vr, [[VR0_0, VR0_1, VR0_2, VR0_3],
                [VR1_0, VR1_1, VR1_2, VR1_3],
                [VR2_0, VR2_1, VR2_2, VR2_3],
                [VR3_0, VR3_1, VR3_2, VR3_3],
                [VR4_0, VR4_1, VR4_2, VR4_3],
                [VR5_0, VR5_1, VR5_2, VR5_3],
                [VR6_0, VR6_1, VR6_2, VR6_3],
                [VR7_0, VR7_1, VR7_2, VR7_3],
                [VR8_0, VR8_1, VR8_2, VR8_3],
                [VR9_0, VR9_1, VR9_2, VR9_3],
                [VR10_0, VR10_1, VR10_2, VR10_3],
                [VR11_0, VR11_1, VR11_2, VR11_3],
                [VR12_0, VR12_1, VR12_2, VR12_3],
                [VR13_0, VR13_1, VR13_2, VR13_3],
                [VR14_0, VR14_1, VR14_2, VR14_3],
                [VR15_0, VR15_1, VR15_2, VR15_3],
                [VR16_0, VR16_1, VR16_2, VR16_3],
                [VR17_0, VR17_1, VR17_2, VR17_3],
                [VR18_0, VR18_1, VR18_2, VR18_3],
                [VR19_0, VR19_1, VR19_2, VR19_3],
                [VR20_0, VR20_1, VR20_2, VR20_3],
                [VR21_0, VR21_1, VR21_2, VR21_3],
                [VR22_0, VR22_1, VR22_2, VR22_3],
                [VR23_0, VR23_1, VR23_2, VR23_3],
                [VR24_0, VR24_1, VR24_2, VR24_3],
                [VR25_0, VR25_1, VR25_2, VR25_3],
                [VR26_0, VR26_1, VR26_2, VR26_3],
                [VR27_0, VR27_1, VR27_2, VR27_3],
                [VR28_0, VR28_1, VR28_2, VR28_3],
                [VR29_0, VR29_1, VR29_2, VR29_3],
                [VR30_0, VR30_1, VR30_2, VR30_3],
                [VR31_0, VR31_1, VR31_2, VR31_3]] },
    { save_vscr, [VSCR0, VSCR1, VSCR2, VSCR3] },
    { save_pad5, [PAD5_0, PAD5_1, PAD5_2, PAD5_3] },
    { save_vrvalid, VRVALID },
    { save_pad6, [PAD6_0, PAD6_1, PAD6_2, PAD6_3, PAD6_4, PAD6_5, PAD6_6] }
}).

-define(PACKAGE_PPC_EXCEPTION_STATE, {
    { dar, DAR },
    { dsisr, DSISR },
    { exception, EXCEPTION },
    { pad0, PAD0 },
    { pad1, [PAD1_0, PAD1_1, PAD1_2, PAD1_3]}
}).

-define(PACKAGE_PPC_EXCEPTION_STATE64, {
    { dar, DAR },
    { dsisr, DSISR },
    { exception, EXCEPTION },
    { pad1, [PAD1_0, PAD1_1, PAD1_2, PAD1_3]}
}).


get_thread_state(little, ppc_thread_state, ?STRUCT_PPC_THREAD_STATE(little)) -> ?PACKAGE_PPC_THREAD_STATE;
get_thread_state(big, ppc_thread_state, ?STRUCT_PPC_THREAD_STATE(big)) -> ?PACKAGE_PPC_THREAD_STATE;

get_thread_state(little, ppc_thread_state64, ?STRUCT_PPC_THREAD_STATE64(little)) -> ?PACKAGE_PPC_THREAD_STATE64;
get_thread_state(big, ppc_thread_state64, ?STRUCT_PPC_THREAD_STATE64(big)) -> ?PACKAGE_PPC_THREAD_STATE64;

get_thread_state(little, ppc_float_state, ?STRUCT_PPC_FLOAT_STATE(little)) -> ?PACKAGE_PPC_FLOAT_STATE;
get_thread_state(big, ppc_float_state, ?STRUCT_PPC_FLOAT_STATE(big)) -> ?PACKAGE_PPC_FLOAT_STATE;

get_thread_state(little, ppc_float_state, ?STRUCT_PPC_VECTOR_STATE(32, little)) -> ?PACKAGE_PPC_VECTOR_STATE;
get_thread_state(big, ppc_float_state, ?STRUCT_PPC_VECTOR_STATE(32, big)) -> ?PACKAGE_PPC_VECTOR_STATE;

get_thread_state(little, ppc_float_state, ?STRUCT_PPC_VECTOR_STATE(64, little)) -> ?PACKAGE_PPC_VECTOR_STATE;
get_thread_state(big, ppc_float_state, ?STRUCT_PPC_VECTOR_STATE(64, big)) -> ?PACKAGE_PPC_VECTOR_STATE;

get_thread_state(little, ppc_exception_state, ?STRUCT_PPC_EXCEPTION_STATE(little)) -> ?PACKAGE_PPC_EXCEPTION_STATE;
get_thread_state(big, ppc_exception_state, ?STRUCT_PPC_EXCEPTION_STATE(big)) -> ?PACKAGE_PPC_EXCEPTION_STATE;

get_thread_state(little, ppc_exception_state64, ?STRUCT_PPC_EXCEPTION_STATE64(little)) -> ?PACKAGE_PPC_EXCEPTION_STATE64;
get_thread_state(big, ppc_exception_state64, ?STRUCT_PPC_EXCEPTION_STATE64(big)) -> ?PACKAGE_PPC_EXCEPTION_STATE64;

get_thread_state(_Endianness, _Flavour, State) -> State.
