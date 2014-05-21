-define(STRUCT_PPC_THREAD_STATE(E), <<
    SRR0:32/E, SRR1:32/E,
    R0:32/E, R1:32/E, R2:32/E, R3:32/E,
    R4:32/E, R5:32/E, R6:32/E, R7:32/E,
    R8:32/E, R9:32/E, R10:32/E, R11:32/E,
    R12:32/E, R13:32/E, R14:32/E, R15:32/E,
    R16:32/E, R17:32/E, R18:32/E, R19:32/E,
    R20:32/E, R21:32/E, R22:32/E, R23:32/E,
    R24:32/E, R25:32/E, R26:32/E, R27:32/E,
    R28:32/E, R29:32/E, R30:32/E, R31:32/E,
    CR:32/E, XER:32/E, LR:32/E, CTR:32/E, MQ:32/E,
    VRSAVE:32/E
>>).

-define(STRUCT_PPC_THREAD_STATE64(E), <<
    SRR0:64/E, SRR1:64/E,
    R0:64/E, R1:64/E, R2:64/E, R3:64/E,
    R4:64/E, R5:64/E, R6:64/E, R7:64/E,
    R8:64/E, R9:64/E, R10:64/E, R11:64/E,
    R12:64/E, R13:64/E, R14:64/E, R15:64/E,
    R16:64/E, R17:64/E, R18:64/E, R19:64/E,
    R20:64/E, R21:64/E, R22:64/E, R23:64/E,
    R24:64/E, R25:64/E, R26:64/E, R27:64/E,
    R28:64/E, R29:64/E, R30:64/E, R31:64/E,
    CR:64/E, XER:64/E, LR:64/E, CTR:64/E,
    VRSAVE:64/E
>>).

-define(STRUCT_PPC_FLOAT_STATE(E), <<
    F0:64/E-float, F1:64/E-float, F2:64/E-float, F3:64/E-float,
    F4:64/E-float, F5:64/E-float, F6:64/E-float, F7:64/E-float,
    F8:64/E-float, F9:64/E-float, F10:64/E-float, F11:64/E-float,
    F12:64/E-float, F13:64/E-float, F14:64/E-float, F15:64/E-float,
    F16:64/E-float, F17:64/E-float, F18:64/E-float, F19:64/E-float,
    F20:64/E-float, F21:64/E-float, F22:64/E-float, F23:64/E-float,
    F24:64/E-float, F25:64/E-float, F26:64/E-float, F27:64/E-float,
    F28:64/E-float, F29:64/E-float, F30:64/E-float, F31:64/E-float,
    FPSCRPAD:32/E, FPSCR:32/E
>>).

-define(STRUCT_PPC_VECTOR_STATE(B, E), << 
    VR0_0:B/E, VR0_1:B/E, VR0_2:B/E, VR0_3:B/E,
    VR1_0:B/E, VR1_1:B/E, VR1_2:B/E, VR1_3:B/E,
    VR2_0:B/E, VR2_1:B/E, VR2_2:B/E, VR2_3:B/E,
    VR3_0:B/E, VR3_1:B/E, VR3_2:B/E, VR3_3:B/E,
    VR4_0:B/E, VR4_1:B/E, VR4_2:B/E, VR4_3:B/E,
    VR5_0:B/E, VR5_1:B/E, VR5_2:B/E, VR5_3:B/E,
    VR6_0:B/E, VR6_1:B/E, VR6_2:B/E, VR6_3:B/E,
    VR7_0:B/E, VR7_1:B/E, VR7_2:B/E, VR7_3:B/E,
    VR8_0:B/E, VR8_1:B/E, VR8_2:B/E, VR8_3:B/E,
    VR9_0:B/E, VR9_1:B/E, VR9_2:B/E, VR9_3:B/E,
    VR10_0:B/E, VR10_1:B/E, VR10_2:B/E, VR10_3:B/E,
    VR11_0:B/E, VR11_1:B/E, VR11_2:B/E, VR11_3:B/E,
    VR12_0:B/E, VR12_1:B/E, VR12_2:B/E, VR12_3:B/E,
    VR13_0:B/E, VR13_1:B/E, VR13_2:B/E, VR13_3:B/E,
    VR14_0:B/E, VR14_1:B/E, VR14_2:B/E, VR14_3:B/E,
    VR15_0:B/E, VR15_1:B/E, VR15_2:B/E, VR15_3:B/E,
    VR16_0:B/E, VR16_1:B/E, VR16_2:B/E, VR16_3:B/E,
    VR17_0:B/E, VR17_1:B/E, VR17_2:B/E, VR17_3:B/E,
    VR18_0:B/E, VR18_1:B/E, VR18_2:B/E, VR18_3:B/E,
    VR19_0:B/E, VR19_1:B/E, VR19_2:B/E, VR19_3:B/E,
    VR20_0:B/E, VR20_1:B/E, VR20_2:B/E, VR20_3:B/E,
    VR21_0:B/E, VR21_1:B/E, VR21_2:B/E, VR21_3:B/E,
    VR22_0:B/E, VR22_1:B/E, VR22_2:B/E, VR22_3:B/E,
    VR23_0:B/E, VR23_1:B/E, VR23_2:B/E, VR23_3:B/E,
    VR24_0:B/E, VR24_1:B/E, VR24_2:B/E, VR24_3:B/E,
    VR25_0:B/E, VR25_1:B/E, VR25_2:B/E, VR25_3:B/E,
    VR26_0:B/E, VR26_1:B/E, VR26_2:B/E, VR26_3:B/E,
    VR27_0:B/E, VR27_1:B/E, VR27_2:B/E, VR27_3:B/E,
    VR28_0:B/E, VR28_1:B/E, VR28_2:B/E, VR28_3:B/E,
    VR29_0:B/E, VR29_1:B/E, VR29_2:B/E, VR29_3:B/E,
    VR30_0:B/E, VR30_1:B/E, VR30_2:B/E, VR30_3:B/E,
    VR31_0:B/E, VR31_1:B/E, VR31_2:B/E, VR31_3:B/E,
    VSCR0:B/E, VSCR1:B/E, VSCR2:B/E, VSCR3:B/E,

    PAD5_0:32/E, PAD5_1:32/E, PAD5_2:32/E, PAD5_3:32/E,
    VRVALID:32/E, PAD6_0:32/E, PAD6_1:32/E, PAD6_2:32/E,
    PAD6_3:32/E, PAD6_4:32/E, PAD6_5:32/E, PAD6_6:32/E
>>).

-define(STRUCT_PPC_EXCEPTION_STATE(E), <<
    DAR:32/E, DSISR:32/E, EXCEPTION:32/E, PAD0:32/E,
    PAD1_0:32/E, PAD1_1:32/E, PAD1_2:32/E, PAD1_3:32/E
>>).

-define(STRUCT_PPC_EXCEPTION_STATE64(E), <<
    DAR:64/E, DSISR:32/E, EXCEPTION:32/E,
    PAD1_0:32/E, PAD1_1:32/E, PAD1_2:32/E, PAD1_3:32/E
>>).

% struct x86_thread_state {
%     x86_state_hdr_t         tsh;
%     union {
%         x86_thread_state32_t    ts32;
%         x86_thread_state64_t    ts64;
%     } uts;
% };

% struct x86_float_state {
%     x86_state_hdr_t         fsh;
%     union {
%         x86_float_state32_t fs32;
%         x86_float_state64_t fs64;
%     } ufs;
% };

% struct x86_exception_state {
%     x86_state_hdr_t         esh;
%     union {
%         x86_exception_state32_t es32;
%         x86_exception_state64_t es64;
%     } ues;
% };

% struct x86_debug_state {
%     x86_state_hdr_t         dsh;
%     union {
%         x86_debug_state32_t ds32;
%         x86_debug_state64_t ds64;
%     } uds;
% };

% struct x86_avx_state {
%     x86_state_hdr_t         ash;
%     union {
%         x86_avx_state32_t   as32;
%         x86_avx_state64_t   as64;
%     } ufs;
% };

% _STRUCT_X86_THREAD_STATE32
% {
%     unsigned int    eax;
%     unsigned int    ebx;
%     unsigned int    ecx;
%     unsigned int    edx;
%     unsigned int    edi;
%     unsigned int    esi;
%     unsigned int    ebp;
%     unsigned int    esp;
%     unsigned int    ss;
%     unsigned int    eflags;
%     unsigned int    eip;
%     unsigned int    cs;
%     unsigned int    ds;
%     unsigned int    es;
%     unsigned int    fs;
%     unsigned int    gs;
% };

% _STRUCT_FP_CONTROL
% {
%     unsigned short      invalid :1,
%                     denorm  :1,
%                 zdiv    :1,
%                 ovrfl   :1,
%                 undfl   :1,
%                 precis  :1,
%                     :2,
%                 pc  :2,
% #define FP_PREC_24B     0
% #define FP_PREC_53B     2
% #define FP_PREC_64B     3
%                 rc  :2,
% #define FP_RND_NEAR     0
% #define FP_RND_DOWN     1
% #define FP_RND_UP       2
% #define FP_CHOP         3
%                 /*inf*/ :1,
%                     :3;
% };

% _STRUCT_FP_STATUS
% {
%     unsigned short      invalid :1,
%                     denorm  :1,
%                 zdiv    :1,
%                 ovrfl   :1,
%                 undfl   :1,
%                 precis  :1,
%                 stkflt  :1,
%                 errsumm :1,
%                 c0  :1,
%                 c1  :1,
%                 c2  :1,
%                 tos :3,
%                 c3  :1,
%                 busy    :1;
% };

% _STRUCT_MMST_REG
% {
%     char    mmst_reg[10];
%     char    mmst_rsrv[6];
% };

% _STRUCT_XMM_REG
% {
%   char        xmm_reg[16];;
% };

% _STRUCT_X86_FLOAT_STATE32
% {
%     int             fpu_reserved[2];
%     _STRUCT_FP_CONTROL  fpu_fcw;        /* x87 FPU control word */
%     _STRUCT_FP_STATUS   fpu_fsw;        /* x87 FPU status word */
%     __uint8_t       fpu_ftw;        /* x87 FPU tag word */
%     __uint8_t       fpu_rsrv1;      /* reserved */ 
%     __uint16_t      fpu_fop;        /* x87 FPU Opcode */
%     __uint32_t      fpu_ip;         /* x87 FPU Instruction Pointer offset */
%     __uint16_t      fpu_cs;         /* x87 FPU Instruction Pointer Selector */
%     __uint16_t      fpu_rsrv2;      /* reserved */
%     __uint32_t      fpu_dp;         /* x87 FPU Instruction Operand(Data) Pointer offset */
%     __uint16_t      fpu_ds;         /* x87 FPU Instruction Operand(Data) Pointer Selector */
%     __uint16_t      fpu_rsrv3;      /* reserved */
%     __uint32_t      fpu_mxcsr;      /* MXCSR Register state */
%     __uint32_t      fpu_mxcsrmask;      /* MXCSR mask */
%     _STRUCT_MMST_REG    fpu_stmm0;      /* ST0/MM0   */
%     _STRUCT_MMST_REG    fpu_stmm1;      /* ST1/MM1  */
%     _STRUCT_MMST_REG    fpu_stmm2;      /* ST2/MM2  */
%     _STRUCT_MMST_REG    fpu_stmm3;      /* ST3/MM3  */
%     _STRUCT_MMST_REG    fpu_stmm4;      /* ST4/MM4  */
%     _STRUCT_MMST_REG    fpu_stmm5;      /* ST5/MM5  */
%     _STRUCT_MMST_REG    fpu_stmm6;      /* ST6/MM6  */
%     _STRUCT_MMST_REG    fpu_stmm7;      /* ST7/MM7  */
%     _STRUCT_XMM_REG     fpu_xmm0;       /* XMM 0  */
%     _STRUCT_XMM_REG     fpu_xmm1;       /* XMM 1  */
%     _STRUCT_XMM_REG     fpu_xmm2;       /* XMM 2  */
%     _STRUCT_XMM_REG     fpu_xmm3;       /* XMM 3  */
%     _STRUCT_XMM_REG     fpu_xmm4;       /* XMM 4  */
%     _STRUCT_XMM_REG     fpu_xmm5;       /* XMM 5  */
%     _STRUCT_XMM_REG     fpu_xmm6;       /* XMM 6  */
%     _STRUCT_XMM_REG     fpu_xmm7;       /* XMM 7  */
%     char            fpu_rsrv4[14*16];   /* reserved */
%     int             fpu_reserved1;
% };

% _STRUCT_X86_AVX_STATE32
% {
%     int             fpu_reserved[2];
%     _STRUCT_FP_CONTROL  fpu_fcw;        /* x87 FPU control word */
%     _STRUCT_FP_STATUS   fpu_fsw;        /* x87 FPU status word */
%     __uint8_t       fpu_ftw;        /* x87 FPU tag word */
%     __uint8_t       fpu_rsrv1;      /* reserved */ 
%     __uint16_t      fpu_fop;        /* x87 FPU Opcode */
%     __uint32_t      fpu_ip;         /* x87 FPU Instruction Pointer offset */
%     __uint16_t      fpu_cs;         /* x87 FPU Instruction Pointer Selector */
%     __uint16_t      fpu_rsrv2;      /* reserved */
%     __uint32_t      fpu_dp;         /* x87 FPU Instruction Operand(Data) Pointer offset */
%     __uint16_t      fpu_ds;         /* x87 FPU Instruction Operand(Data) Pointer Selector */
%     __uint16_t      fpu_rsrv3;      /* reserved */
%     __uint32_t      fpu_mxcsr;      /* MXCSR Register state */
%     __uint32_t      fpu_mxcsrmask;      /* MXCSR mask */
%     _STRUCT_MMST_REG    fpu_stmm0;      /* ST0/MM0   */
%     _STRUCT_MMST_REG    fpu_stmm1;      /* ST1/MM1  */
%     _STRUCT_MMST_REG    fpu_stmm2;      /* ST2/MM2  */
%     _STRUCT_MMST_REG    fpu_stmm3;      /* ST3/MM3  */
%     _STRUCT_MMST_REG    fpu_stmm4;      /* ST4/MM4  */
%     _STRUCT_MMST_REG    fpu_stmm5;      /* ST5/MM5  */
%     _STRUCT_MMST_REG    fpu_stmm6;      /* ST6/MM6  */
%     _STRUCT_MMST_REG    fpu_stmm7;      /* ST7/MM7  */
%     _STRUCT_XMM_REG     fpu_xmm0;       /* XMM 0  */
%     _STRUCT_XMM_REG     fpu_xmm1;       /* XMM 1  */
%     _STRUCT_XMM_REG     fpu_xmm2;       /* XMM 2  */
%     _STRUCT_XMM_REG     fpu_xmm3;       /* XMM 3  */
%     _STRUCT_XMM_REG     fpu_xmm4;       /* XMM 4  */
%     _STRUCT_XMM_REG     fpu_xmm5;       /* XMM 5  */
%     _STRUCT_XMM_REG     fpu_xmm6;       /* XMM 6  */
%     _STRUCT_XMM_REG     fpu_xmm7;       /* XMM 7  */
%     char            fpu_rsrv4[14*16];   /* reserved */
%     int             fpu_reserved1;
%     char            __avx_reserved1[64];
%     _STRUCT_XMM_REG     __fpu_ymmh0;        /* YMMH 0  */
%     _STRUCT_XMM_REG     __fpu_ymmh1;        /* YMMH 1  */
%     _STRUCT_XMM_REG     __fpu_ymmh2;        /* YMMH 2  */
%     _STRUCT_XMM_REG     __fpu_ymmh3;        /* YMMH 3  */
%     _STRUCT_XMM_REG     __fpu_ymmh4;        /* YMMH 4  */
%     _STRUCT_XMM_REG     __fpu_ymmh5;        /* YMMH 5  */
%     _STRUCT_XMM_REG     __fpu_ymmh6;        /* YMMH 6  */
%     _STRUCT_XMM_REG     __fpu_ymmh7;        /* YMMH 7  */
% };

% _STRUCT_X86_EXCEPTION_STATE32
% {
%     __uint16_t  trapno;
%     __uint16_t  cpu;
%     __uint32_t  err;
%     __uint32_t  faultvaddr;
% };

% _STRUCT_X86_DEBUG_STATE32
% {
%     unsigned int    dr0;
%     unsigned int    dr1;
%     unsigned int    dr2;
%     unsigned int    dr3;
%     unsigned int    dr4;
%     unsigned int    dr5;
%     unsigned int    dr6;
%     unsigned int    dr7;
% };

% _STRUCT_X86_THREAD_STATE64
% {
%     __uint64_t  rax;
%     __uint64_t  rbx;
%     __uint64_t  rcx;
%     __uint64_t  rdx;
%     __uint64_t  rdi;
%     __uint64_t  rsi;
%     __uint64_t  rbp;
%     __uint64_t  rsp;
%     __uint64_t  r8;
%     __uint64_t  r9;
%     __uint64_t  r10;
%     __uint64_t  r11;
%     __uint64_t  r12;
%     __uint64_t  r13;
%     __uint64_t  r14;
%     __uint64_t  r15;
%     __uint64_t  rip;
%     __uint64_t  rflags;
%     __uint64_t  cs;
%     __uint64_t  fs;
%     __uint64_t  gs;
% };

% _STRUCT_X86_FLOAT_STATE64
% {
%     int             fpu_reserved[2];
%     _STRUCT_FP_CONTROL  fpu_fcw;        /* x87 FPU control word */
%     _STRUCT_FP_STATUS   fpu_fsw;        /* x87 FPU status word */
%     __uint8_t       fpu_ftw;        /* x87 FPU tag word */
%     __uint8_t       fpu_rsrv1;      /* reserved */ 
%     __uint16_t      fpu_fop;        /* x87 FPU Opcode */

%     /* x87 FPU Instruction Pointer */
%     __uint32_t      fpu_ip;         /* offset */
%     __uint16_t      fpu_cs;         /* Selector */

%     __uint16_t      fpu_rsrv2;      /* reserved */

%     /* x87 FPU Instruction Operand(Data) Pointer */
%     __uint32_t      fpu_dp;         /* offset */
%     __uint16_t      fpu_ds;         /* Selector */

%     __uint16_t      fpu_rsrv3;      /* reserved */
%     __uint32_t      fpu_mxcsr;      /* MXCSR Register state */
%     __uint32_t      fpu_mxcsrmask;      /* MXCSR mask */
%     _STRUCT_MMST_REG    fpu_stmm0;      /* ST0/MM0   */
%     _STRUCT_MMST_REG    fpu_stmm1;      /* ST1/MM1  */
%     _STRUCT_MMST_REG    fpu_stmm2;      /* ST2/MM2  */
%     _STRUCT_MMST_REG    fpu_stmm3;      /* ST3/MM3  */
%     _STRUCT_MMST_REG    fpu_stmm4;      /* ST4/MM4  */
%     _STRUCT_MMST_REG    fpu_stmm5;      /* ST5/MM5  */
%     _STRUCT_MMST_REG    fpu_stmm6;      /* ST6/MM6  */
%     _STRUCT_MMST_REG    fpu_stmm7;      /* ST7/MM7  */
%     _STRUCT_XMM_REG     fpu_xmm0;       /* XMM 0  */
%     _STRUCT_XMM_REG     fpu_xmm1;       /* XMM 1  */
%     _STRUCT_XMM_REG     fpu_xmm2;       /* XMM 2  */
%     _STRUCT_XMM_REG     fpu_xmm3;       /* XMM 3  */
%     _STRUCT_XMM_REG     fpu_xmm4;       /* XMM 4  */
%     _STRUCT_XMM_REG     fpu_xmm5;       /* XMM 5  */
%     _STRUCT_XMM_REG     fpu_xmm6;       /* XMM 6  */
%     _STRUCT_XMM_REG     fpu_xmm7;       /* XMM 7  */
%     _STRUCT_XMM_REG     fpu_xmm8;       /* XMM 8  */
%     _STRUCT_XMM_REG     fpu_xmm9;       /* XMM 9  */
%     _STRUCT_XMM_REG     fpu_xmm10;      /* XMM 10  */
%     _STRUCT_XMM_REG     fpu_xmm11;      /* XMM 11 */
%     _STRUCT_XMM_REG     fpu_xmm12;      /* XMM 12  */
%     _STRUCT_XMM_REG     fpu_xmm13;      /* XMM 13  */
%     _STRUCT_XMM_REG     fpu_xmm14;      /* XMM 14  */
%     _STRUCT_XMM_REG     fpu_xmm15;      /* XMM 15  */
%     char            fpu_rsrv4[6*16];    /* reserved */
%     int             fpu_reserved1;
% };

% _STRUCT_X86_AVX_STATE64
% {
%     int             fpu_reserved[2];
%     _STRUCT_FP_CONTROL  fpu_fcw;        /* x87 FPU control word */
%     _STRUCT_FP_STATUS   fpu_fsw;        /* x87 FPU status word */
%     __uint8_t       fpu_ftw;        /* x87 FPU tag word */
%     __uint8_t       fpu_rsrv1;      /* reserved */ 
%     __uint16_t      fpu_fop;        /* x87 FPU Opcode */

%     /* x87 FPU Instruction Pointer */
%     __uint32_t      fpu_ip;         /* offset */
%     __uint16_t      fpu_cs;         /* Selector */

%     __uint16_t      fpu_rsrv2;      /* reserved */

%     /* x87 FPU Instruction Operand(Data) Pointer */
%     __uint32_t      fpu_dp;         /* offset */
%     __uint16_t      fpu_ds;         /* Selector */

%     __uint16_t      fpu_rsrv3;      /* reserved */
%     __uint32_t      fpu_mxcsr;      /* MXCSR Register state */
%     __uint32_t      fpu_mxcsrmask;      /* MXCSR mask */
%     _STRUCT_MMST_REG    fpu_stmm0;      /* ST0/MM0   */
%     _STRUCT_MMST_REG    fpu_stmm1;      /* ST1/MM1  */
%     _STRUCT_MMST_REG    fpu_stmm2;      /* ST2/MM2  */
%     _STRUCT_MMST_REG    fpu_stmm3;      /* ST3/MM3  */
%     _STRUCT_MMST_REG    fpu_stmm4;      /* ST4/MM4  */
%     _STRUCT_MMST_REG    fpu_stmm5;      /* ST5/MM5  */
%     _STRUCT_MMST_REG    fpu_stmm6;      /* ST6/MM6  */
%     _STRUCT_MMST_REG    fpu_stmm7;      /* ST7/MM7  */
%     _STRUCT_XMM_REG     fpu_xmm0;       /* XMM 0  */
%     _STRUCT_XMM_REG     fpu_xmm1;       /* XMM 1  */
%     _STRUCT_XMM_REG     fpu_xmm2;       /* XMM 2  */
%     _STRUCT_XMM_REG     fpu_xmm3;       /* XMM 3  */
%     _STRUCT_XMM_REG     fpu_xmm4;       /* XMM 4  */
%     _STRUCT_XMM_REG     fpu_xmm5;       /* XMM 5  */
%     _STRUCT_XMM_REG     fpu_xmm6;       /* XMM 6  */
%     _STRUCT_XMM_REG     fpu_xmm7;       /* XMM 7  */
%     _STRUCT_XMM_REG     fpu_xmm8;       /* XMM 8  */
%     _STRUCT_XMM_REG     fpu_xmm9;       /* XMM 9  */
%     _STRUCT_XMM_REG     fpu_xmm10;      /* XMM 10  */
%     _STRUCT_XMM_REG     fpu_xmm11;      /* XMM 11 */
%     _STRUCT_XMM_REG     fpu_xmm12;      /* XMM 12  */
%     _STRUCT_XMM_REG     fpu_xmm13;      /* XMM 13  */
%     _STRUCT_XMM_REG     fpu_xmm14;      /* XMM 14  */
%     _STRUCT_XMM_REG     fpu_xmm15;      /* XMM 15  */
%     char            fpu_rsrv4[6*16];    /* reserved */
%     int             fpu_reserved1;
%     char            __avx_reserved1[64];
%     _STRUCT_XMM_REG     __fpu_ymmh0;        /* YMMH 0  */
%     _STRUCT_XMM_REG     __fpu_ymmh1;        /* YMMH 1  */
%     _STRUCT_XMM_REG     __fpu_ymmh2;        /* YMMH 2  */
%     _STRUCT_XMM_REG     __fpu_ymmh3;        /* YMMH 3  */
%     _STRUCT_XMM_REG     __fpu_ymmh4;        /* YMMH 4  */
%     _STRUCT_XMM_REG     __fpu_ymmh5;        /* YMMH 5  */
%     _STRUCT_XMM_REG     __fpu_ymmh6;        /* YMMH 6  */
%     _STRUCT_XMM_REG     __fpu_ymmh7;        /* YMMH 7  */
%     _STRUCT_XMM_REG     __fpu_ymmh8;        /* YMMH 8  */
%     _STRUCT_XMM_REG     __fpu_ymmh9;        /* YMMH 9  */
%     _STRUCT_XMM_REG     __fpu_ymmh10;       /* YMMH 10  */
%     _STRUCT_XMM_REG     __fpu_ymmh11;       /* YMMH 11  */
%     _STRUCT_XMM_REG     __fpu_ymmh12;       /* YMMH 12  */
%     _STRUCT_XMM_REG     __fpu_ymmh13;       /* YMMH 13  */
%     _STRUCT_XMM_REG     __fpu_ymmh14;       /* YMMH 14  */
%     _STRUCT_XMM_REG     __fpu_ymmh15;       /* YMMH 15  */
% };

% _STRUCT_X86_EXCEPTION_STATE64
% {
%     __uint16_t  trapno;
%     __uint16_t  cpu;
%     __uint32_t  err;
%     __uint64_t  faultvaddr;
% };

% _STRUCT_X86_DEBUG_STATE64
% {
%     __uint64_t  dr0;
%     __uint64_t  dr1;
%     __uint64_t  dr2;
%     __uint64_t  dr3;
%     __uint64_t  dr4;
%     __uint64_t  dr5;
%     __uint64_t  dr6;
%     __uint64_t  dr7;
% };

% struct arm_state_hdr {
%     uint32_t flavor;
%     uint32_t count;
% };

% struct arm_unified_thread_state {
%     arm_state_hdr_t ash;
%     union {
%         arm_thread_state32_t ts_32;
%         arm_thread_state64_t ts_64;
%     } uts;
% };

% _STRUCT_ARM_EXCEPTION_STATE
% {
%     __uint32_t  exception; /* number of arm exception taken */
%     __uint32_t  fsr; /* Fault status */
%     __uint32_t  far; /* Virtual Fault Address */
% };

% _STRUCT_ARM_EXCEPTION_STATE64
% {
%     __uint64_t  far; /* Virtual Fault Address */
%     __uint32_t  esr; /* Exception syndrome */
%     __uint32_t  exception; /* number of arm exception taken */
% };

% _STRUCT_ARM_THREAD_STATE
% {
%     __uint32_t  r[13];  /* General purpose register r0-r12 */
%     __uint32_t  sp;     /* Stack pointer r13 */
%     __uint32_t  lr;     /* Link register r14 */
%     __uint32_t  pc;     /* Program counter r15 */
%     __uint32_t  cpsr;       /* Current program status register */
% };

% _STRUCT_ARM_THREAD_STATE64
% {
%     __uint64_t    x[29];    /* General purpose registers x0-x28 */
%     __uint64_t    fp;       /* Frame pointer x29 */
%     __uint64_t    lr;       /* Link register x30 */
%     __uint64_t    sp;       /* Stack pointer x31 */
%     __uint64_t    pc;       /* Program counter */
%     __uint32_t    cpsr;     /* Current program status register */
% };

% _STRUCT_ARM_VFP_STATE
% {
%     __uint32_t        r[64];
%     __uint32_t        fpscr;
% };

% #if defined(__arm64__)
% _STRUCT_ARM_NEON_STATE64
% {
%     __uint128_t     q[32];
%     uint32_t        fpsr;
%     uint32_t        fpcr;

% };
% _STRUCT_ARM_NEON_STATE
% {
%     __uint128_t     q[16];
%     uint32_t        fpsr;
%     uint32_t        fpcr;

% };
% #elif defined(__arm__)
% /*
%  * No 128-bit intrinsic for ARM; leave it opaque for now.
%  */
% _STRUCT_ARM_NEON_STATE64
% {
%     char opaque[(32 * 16) + (2 * sizeof(__uint32_t))];
% } __attribute__((aligned(16)));

% _STRUCT_ARM_NEON_STATE
% {
%     char opaque[(16 * 16) + (2 * sizeof(__uint32_t))];
% } __attribute__((aligned(16)));

% #endif

% _STRUCT_ARM_DEBUG_STATE
% {
%     __uint32_t        bvr[16];
%     __uint32_t        bcr[16];
%     __uint32_t        wvr[16];
%     __uint32_t        wcr[16];
% };

% _STRUCT_ARM_LEGACY_DEBUG_STATE
% {
%     __uint32_t        bvr[16];
%     __uint32_t        bcr[16];
%     __uint32_t        wvr[16];
%     __uint32_t        wcr[16];
% };

% _STRUCT_ARM_DEBUG_STATE32
% {
%     __uint32_t        bvr[16];
%     __uint32_t        bcr[16];
%     __uint32_t        wvr[16];
%     __uint32_t        wcr[16];
%     __uint64_t    mdscr_el1; /* Bit 0 is SS (Hardware Single Step) */
% };

% _STRUCT_ARM_DEBUG_STATE64
% {
%     __uint64_t        bvr[16];
%     __uint64_t        bcr[16];
%     __uint64_t        wvr[16];
%     __uint64_t        wcr[16];
%     __uint64_t    mdscr_el1; /* Bit 0 is SS (Hardware Single Step) */
% };
