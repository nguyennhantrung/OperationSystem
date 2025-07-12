# General Purpose Registers
64-bit	32-bit	16-bit	8 high bits	8 low bits	Description
RAX	    EAX	    AX	    AH	        AL	        Accumulator
RBX	    EBX	    BX	    BH	        BL	        Base
RCX	    ECX	    CX	    CH	        CL	        Counter
RDX	    EDX	    DX	    DH	        DL	        Data
RSI	    ESI	    SI	    N/A	        SIL	        Source
RDI	    EDI	    DI	    N/A	        DIL	        Destination
RSP	    ESP	    SP	    N/A	        SPL	        Stack Pointer
RBP	    EBP	    BP	    N/A	        BPL	        Stack Base Pointer

# Pointer Registers
64-bit	32-bit	16-bit	    Description
RIP	    EIP	IP	Instruction Pointer

# Segment Registers
16-bit	Description
CS	    Code Segment
DS	    Data Segment
ES	    Extra Segment
SS	    Stack Segment
FS	    General Purpose F Segment
GS	    General Purpose G Segment

# EFLAGS Register
Bit	    Label	Description
0	    CF	    Carry flag
2	    PF	    Parity flag
4	    AF	    Auxiliary flag
6	    ZF	    Zero flag
7	    SF	    Sign flag
8	    TF	    Trap flag
9	    IF	    Interrupt enable flag
10	    DF	    Direction flag
11	    OF	    Overflow flag
12-13	IOPL	I/O privilege level
14	    NT	    Nested task flag
16	    RF	    Resume flag
17	    VM	    Virtual 8086 mode flag
18	    AC	    Alignment check
19	    VIF	    Virtual interrupt flag
20	    VIP	    Virtual interrupt pending
21	    ID	    Able to use CPUID instruction
Unlisted bits are reserved.

# Control Registers
## CR0
Bit	Label	Description
0	PE	    Protected Mode Enable
1	MP	    Monitor co-processor
2	EM	    x87 FPU Emulation
3	TS	    Task switched
4	ET	    Extension type
5	NE	    Numeric error
16	WP	    Write protect
18	AM	    Alignment mask
29	NW	    Not-write through
30	CD	    Cache disable
31	PG	    Paging
NOTE: This register is the only control register that can be written and read via 2 ways unlike the other that can be accessed only via the MOV instruction

## CR1
Reserved, the CPU will throw a #UD exception when trying to access it.

## CR2
Bit	        Label		Description
0-31 (63)	PFLA		Page Fault Linear Address

## CR3
Bit	        Label	    Description						PAE	    			Long Mode
3	        PWT			Page-level Write-Through		(Not used)	        (Not used if bit 17 of CR4 is 1)
4	        PCD			Page-level Cache Disable		(Not used)	        (Not used if bit 17 of CR4 is 1)
12-31 (63)	PDBR		Page Directory Base Register	Base of PDPT		Base of PML4T/PML5T
Bits 0-11 of the physical base address are assumed to be 0. Bits 3 and 4 of CR3 are only used when accessing a PDE in 32-bit paging without PAE.

## CR4
Bit	Label		Description
0	VME			Virtual 8086 Mode Extensions
1	PVI			Protected-mode Virtual Interrupts
2	TSD			Time Stamp Disable
3	DE			Debugging Extensions
4	PSE			Page Size Extension
5	PAE			Physical Address Extension
6	MCE			Machine Check Exception
7	PGE			Page Global Enabled
8	PCE			Performance-Monitoring Counter enable
9	OSFXSR		Operating system support for FXSAVE and FXRSTOR instructions
10	OSXMMEXCPT	Operating System Support for Unmasked SIMD Floating-Point Exceptions
11	UMIP		User-Mode Instruction Prevention (if set, #GP on SGDT, SIDT, SLDT, SMSW, and STR instructions when CPL > 0)
12	LA57		57-bit linear addresses (if set, the processor uses 5-level paging otherwise it uses uses 4-level paging)
13	VMXE		Virtual Machine Extensions Enable
14	SMXE		Safer Mode Extensions Enable
16	FSGSBASE	Enables the instructions RDFSBASE, RDGSBASE, WRFSBASE, and WRGSBASE
17	PCIDE		PCID Enable
18	OSXSAVE		XSAVE and Processor Extended States Enable
20	SMEP		Supervisor Mode Execution Protection Enable
21	SMAP		Supervisor Mode Access Prevention Enable
22	PKE			Protection Key Enable
23	CET			Control-flow Enforcement Technology
24	PKS			Enable Protection Keys for Supervisor-Mode Pages

## CR5 - CR7
Reserved, same case as CR1.

## CR8
Bit		Label	Description
0-3		TPL		Task Priority Level

# Extended Control Registers
## XCR0
Bit	Label			Description
0	X87				x87 FPU/MMX support (must be 1)
1	SSE				XSAVE support for MXCSR and XMM registers
2	AVX				AVX enabled and XSAVE support for upper halves of YMM registers
3	BNDREG			MPX enabled and XSAVE support for BND0-BND3 registers
4	BNDCSR			MPX enabled and XSAVE support for BNDCFGU and BNDSTATUS registers
5	opmask			AVX-512 enabled and XSAVE support for opmask registers k0-k7
6	ZMM_Hi256		AVX-512 enabled and XSAVE support for upper halves of lower ZMM registers
7	Hi16_ZMM		AVX-512 enabled and XSAVE support for upper ZMM registers
9	PKRU			XSAVE support for PKRU register
XCR0 can only be accessed if bit 18 of CR4 is set to 1. XGETBV and XSETBV instructions are used to access XCR0.

# Debug Registers
## DR0 - DR3
Contain linear addresses of up to 4 breakpoints. If paging is enabled, they are translated to physical addresses.

## DR6
It permits the debugger to determine which debug conditions have occurred.
Bits 0 through 3 indicates, when set, that it's associated breakpoint condition was met when a debug exception was generated.
Bit 13 indicates that the next instruction in the instruction stream accesses one of the debug registers.
Bit 14 indicates (when set) that the debug exception was triggered by the single-step execution mode (enabled with TF bit in EFLAGS).
Bit 15 indicates (when set) that the debug instruction resulted from a task switch where T flag in the TSS of target task was set.
Bit 16 indicates (when clear) that the debug exception or breakpoint exception occured inside an RTM region.

## DR7
Bit		Description
0		Local DR0 breakpoint
1		Global DR0 breakpoint
2		Local DR1 breakpoint
3		Global DR1 breakpoint
4		Local DR2 breakpoint
5		Global DR2 breakpoint
6		Local DR3 breakpoint
7		Global DR3 breakpoint
16-17	Conditions for DR0
18-19	Size of DR0 breakpoint
20-21	Conditions for DR1
22-23	Size of DR1 breakpoint
24-25	Conditions for DR2
26-27	Size of DR2 breakpoint
28-29	Conditions for DR3
30-31	Size of DR3 breakpoint
A local breakpoint bit deactivates on hardware task switches, while a global does not.
Condition 00b means execution break, 01b means a write watchpoint, and 11b means an R/W watchpoint. 10b is reserved for I/O R/W (unsupported).

# Test Registers
Name		Description
TR3 - TR5	Undocumented
TR6			Test command register
TR7			Test data register

# Protected Mode Registers
## GDTR
Bits	Label	Description
0-15	Limit	(Size of GDT) - 1
16-47	Base	Starting address of GDT
Stores the segment selector of the GDT.
## LDTR
Bits	Label	Description
0-15	Limit	(Size of LDT) - 1
16-47	Base	Starting address of LDT
Stores the segment selector of the LDT.
## IDTR
Bits	Label	Description
0-15	Limit	(Size of IDT) - 1
16-47	Base	Starting address of IDT
Stores the segment selector of the IDT.