;**********************************
;** ZX SPECTRUM SYSTEM VARIABLES **
;**********************************

; The standard memory.
;
; +---------+-----------+------------+--------------+-------------+--
; | BASIC   |  Display  | Attributes | ZX Printer   |    System   | 
; |  ROM    |   File    |    File    |   Buffer     |  Variables  | 
; +---------+-----------+------------+--------------+-------------+--
; ^         ^           ^            ^              ^             ^
; $0000   $4000       $5800        $5B00          $5C00         $5CB6 = CHANS 
;
;
;  --+----------+---+---------+-----------+---+------------+--+---+--
;    | Channel  |$80|  Basic  | Variables |$80| Edit Line  |NL|$80|
;    |   Info   |   | Program |   Area    |   | or Command |  |   |
;  --+----------+---+---------+-----------+---+------------+--+---+--
;    ^              ^         ^               ^                   ^
;  CHANS           PROG      VARS           E_LINE              WORKSP
;
;
;                             ---5-->         <---2---  <--3---
;  --+-------+--+------------+-------+-------+---------+-------+-+---+------+
;    | INPUT |NL| Temporary  | Calc. | Spare | Machine | Gosub |?|$3E| UDGs |
;    | data  |  | Work Space | Stack |       |  Stack  | Stack | |   |      |
;  --+-------+--+------------+-------+-------+---------+-------+-+---+------+
;    ^                       ^       ^       ^                   ^   ^      ^
;  WORKSP                  STKBOT  STKEND   sp               RAMTOP UDG  P_RAMT
;                                                                         

; Modified so we can move code around before assembly to make it fit into CP/M. 

equ VIDEO_BASE			,$4000 ; Set the Video Base ( Typically $4000 ) so we can create virtual video later - though will eventually remove this completely ( or might make it virtual )
equ ATTRIBUTE_BASE		,VIDEO_BASE+$1800 ; Set the Attribute Base ( Typically $5800 ) so we can move them around later if virtual.
equ ZX_PRINTER_BUFFER	,VIDEO_BASE+$1B00 ; Set the location of the ZX Printer Buffer. 256 bytes long. 
equ SYSTEM_BASE			,VIDEO_BASE+$1C00 ; Set the System Base ( Typically $5C00 ) for system variables so we can move it around later.

equ	KSTATE_0	,	SYSTEM_BASE+$0000	; 23552 ; (IY+$C6) ; Used in reading the keyboard.
equ	KSTATE_4	,	SYSTEM_BASE+$0004	; 23556 ; (IY+$CA)
equ	LASTK		,	SYSTEM_BASE+$0008	; 23560 ; (IY+$CE) ; Stores newly pressed key.
equ	REPDEL		,	SYSTEM_BASE+$0009	; 23561 ; (IY+$CF) ; Time (in 50ths of a second in 60ths of a second in N. America) that a key must be held down before it repeats. This starts off at 35, but you can POKE in other values.
equ	REPPER		,	SYSTEM_BASE+$000A	; 23562 ; (IY+$D0) ; Delay (in 50ths of a second in 60ths of a second in N. America) between successive repeats of a key held down: initially 5.
equ	DEFADD		,	SYSTEM_BASE+$000B	; 23563 ; (IY+$D1) ; Address of arguments of user defined function if one is being evaluated; otherwise 0.
equ DEFADD_hi	,	SYSTEM_BASE+$000C	; 23564 ; (IY+$D2) ; Used by routine V_TEST_FN:
equ	KDATA		,	SYSTEM_BASE+$000D	; 23565 ; (IY+$D3) ; Stores 2nd byte of colour controls entered from keyboard .
equ	TVDATA_LO	,	SYSTEM_BASE+$000E	; 23566 ; (IY+$D4) ; Stores bytes of colour, AT and TAB controls going to television.
equ	TVDATA_HI	,	SYSTEM_BASE+$000F	; 23567 ; (IY+$D5)
equ	STRMS_FD	,	SYSTEM_BASE+$0010	; 23568 ; (IY+$D6) ; Addresses of channels attached to streams.
equ	STRMS_00	,	SYSTEM_BASE+$0016	; 23574 ; (IY+$DC)
equ	CHARS		,	SYSTEM_BASE+$0036	; 23606 ; (IY+$FC) ; 256 less than address of character set (which starts with space and carries on to the copyright symbol). Normally in ROM, but you can set up your own in RAM and make CHARS point to it.
equ	RASP_PIP	,	SYSTEM_BASE+$0038	; 23608 ; (IY+$FE) ; Length of warning buzz.
equ	ERR_NR		,	SYSTEM_BASE+$003A	; 23610 ; (IY+$00) ; 1 less than the report code. Starts off at 255 (for 1) so PEEK 23610 gives 255.
equ	FLAGS		,	SYSTEM_BASE+$003B	; 23611 ; (IY+$01) ; Various flags to control the BASIC system. See *
equ	TV_FLAG		,	SYSTEM_BASE+$003C	; 23612 ; (IY+$02) ; Flags associated with the television. See **
equ	ERR_SP		,	SYSTEM_BASE+$003D	; 23613 ; (IY+$03) ; Address of item on machine stack to be used as error return.
equ	LIST_SP		,	SYSTEM_BASE+$003F	; 23615 ; (IY+$05) ; Address of return address from automatic listing.
equ	MODE		,	SYSTEM_BASE+$0041	; 23617 ; (IY+$07) ; Specifies K, L, C. E or G cursor.
equ	NEWPPC		,	SYSTEM_BASE+$0042	; 23618 ; (IY+$08) ; Line to be jumped to.
equ	NSPPC		,	SYSTEM_BASE+$0044	; 23620 ; (IY+$0A) ; Statement number in line to be jumped to. Poking first NEWPPC and then NSPPC forces a jump to a specified statement in a line.
equ	PPC			,	SYSTEM_BASE+$0045	; 23621 ; (IY+$0B) ; Line number of statement currently being executed.
equ	SUBPPC		,	SYSTEM_BASE+$0047	; 23623 ; (IY+$0D) ; Number within line of statement being executed.
equ	BORDCR		,	SYSTEM_BASE+$0048	; 23624 ; (IY+$0E) ; Border colour * 8; also contains the attributes normally used for the lower half of the screen.
equ	E_PPC		,	SYSTEM_BASE+$0049	; 23625 ; (IY+$0F) ; Number of current line (with program cursor).
equ	E_PPC_HI	,	SYSTEM_BASE+$004A	; 23626 ; (IY+$10)
equ	VARS		,	SYSTEM_BASE+$004B	; 23627 ; (IY+$11) ; Address of variables.
equ	DEST		,	SYSTEM_BASE+$004D	; 23629 ; (IY+$13) ; Address of variable in assignment.
equ	CHANS		,	SYSTEM_BASE+$004F	; 23631 ; (IY+$15) ; Address of channel data.
equ	CURCHL		,	SYSTEM_BASE+$0051	; 23633 ; (IY+$17) ; Address of information currently being used for input and output.
equ	PROG		,	SYSTEM_BASE+$0053	; 23635 ; (IY+$19) ; Address of BASIC program.
equ	NXTLIN		,	SYSTEM_BASE+$0055	; 23637 ; (IY+$1B) ; Address of next line in program.
equ	DATADD		,	SYSTEM_BASE+$0057	; 23639 ; (IY+$1D) ; Address of terminator of last DATA item.
equ	E_LINE		,	SYSTEM_BASE+$0059	; 23641 ; (IY+$1F) ; Address of command being typed in.
equ	K_CUR		,	SYSTEM_BASE+$005B	; 23643 ; (IY+$21) ; Address of cursor.
equ	CH_ADD		,	SYSTEM_BASE+$005D	; 23645 ; (IY+$23) ; Address of the next character to be interpreted: the character after the argument of PEEK, or the NEWLINE at the end of a POKE statement.
equ	X_PTR		,	SYSTEM_BASE+$005F	; 23647 ; (IY+$25) ; Address of the character after the ? marker.
equ	WORKSP		,	SYSTEM_BASE+$0061	; 23649 ; (IY+$27) ; Address of temporary work space.
equ	STKBOT		,	SYSTEM_BASE+$0063	; 23651 ; (IY+$29) ; Address of bottom of calculator stack.
equ	STKEND		,	SYSTEM_BASE+$0065	; 23653 ; (IY+$2B) ; Address of start of spare space.
equ	STKEND_HI	,	SYSTEM_BASE+$0066	; 23654 ; (IY+$2C)
equ	BREG		,	SYSTEM_BASE+$0067	; 23655 ; (IY+$2D) ; Calculator's b register.
equ	MEM			,	SYSTEM_BASE+$0068	; 23656 ; (IY+$2E) ; Address of area used for calculator's memory. (Usually MEMBOT, but not always.)
equ	FLAGS2		,	SYSTEM_BASE+$006A	; 23658 ; (IY+$30) ; More flags. See ***
equ	DF_SZ		,	SYSTEM_BASE+$006B	; 23659 ; (IY+$31) ; The number of lines (including one blank line) in the lower part of the screen.
equ	S_TOP		,	SYSTEM_BASE+$006C	; 23660 ; (IY+$32) ; The number of the top program line in automatic listings.
equ	OLDPPC		,	SYSTEM_BASE+$006E	; 23662 ; (IY+$34) ; Line number to which CONTINUE jumps.
equ	OSPPC		,	SYSTEM_BASE+$0070	; 23664 ; (IY+$36) ; Number within line of statement to which CONTINUE jumps.
equ	FLAGX		,	SYSTEM_BASE+$0071	; 23665 ; (IY+$37) ; Various flags. See ****
equ	STRLEN		,	SYSTEM_BASE+$0072	; 23666 ; (IY+$38) ; Length of string type destination in assignment.
equ	T_ADDR		,	SYSTEM_BASE+$0074	; 23668 ; (IY+$3A) ;  	.
equ	SEED		,	SYSTEM_BASE+$0076	; 23670 ; (IY+$3C) ; The seed for RND. This is the variable that is set by RANDOMIZE.
equ	FRAMES1		,	SYSTEM_BASE+$0078	; 23672 ; (IY+$3E) ; 3 byte (least significant first), frame counter. Incremented every 20ms.
equ	UDG			,	SYSTEM_BASE+$007B	; 23675 ; (IY+$41) ; Address of 1st user defined graphic You can change this for instance to save space by having fewer user defined graphics.
equ	COORDS		,	SYSTEM_BASE+$007D	; 23677 ; (IY+$43) ; x-coordinate of last point plotted.
equ	COORDS_Y	,	SYSTEM_BASE+$007E	; 23678 ; (IY+$44) ; y-coordinate of last point plotted.
equ	PR_CC		,	SYSTEM_BASE+$0080	; 23680 ; (IY+$46) ; Full address of next position for LPRINT to print at (in ZX printer buffer). Legal values $5B00 - $5B1F. [Not used in 128K mode or when certain peripherals are attached]
equ	ECHO_E		,	SYSTEM_BASE+$0082	; 23682 ; (IY+$48) ; 33 column number and 24 line number (in lower half) of end of input buffer.
equ	DF_CC		,	SYSTEM_BASE+$0084	; 23684 ; (IY+$4A) ; Address in display file of PRINT position.
equ	DFCCL		,	SYSTEM_BASE+$0086	; 23686 ; (IY+$4C) ; Like DF_CC for lower part of screen.
equ	S_POSN		,	SYSTEM_BASE+$0088	; 23688 ; (IY+$4E) ; 33 column number for PRINT position
equ	S_POSN_HI	,	SYSTEM_BASE+$0089	; 23689 ; (IY+$4F) ; 24 line number for PRINT position.
equ	SPOSNL		,	SYSTEM_BASE+$008A	; 23690 ; (IY+$50) ; Like S_POSN for lower part
equ	SPOSNL_HI	,	SYSTEM_BASE+$008B	; 23691 ; (IY+$51)
equ	SCR_CT		,	SYSTEM_BASE+$008C	; 23692 ; (IY+$52) ; Counts scrolls: it is always 1 more than the number of scrolls that will be done before stopping with scroll? If you keep poking this with a number bigger than 1 (say 255), the screen will scroll on and on without asking you.
equ	ATTRP_MASKP	,	SYSTEM_BASE+$008D	; 23693 ; (IY+$53) ; Permanent current colours, etc (as set up by colour statements).
equ	ATTRT_MASKT	,	SYSTEM_BASE+$008F	; 23695 ; (IY+$55) ; Temporary current colours, etc (as set up by colour items).
equ	MASK_T		,	SYSTEM_BASE+$0090	; 23696 ; (IY+$56) ; Like MASK_P, but temporary.
equ	P_FLAG		,	SYSTEM_BASE+$0091	; 23697 ; (IY+$57) ; More flags.
equ	MEM_0		,	SYSTEM_BASE+$0092	; 23698 ; (IY+$58) ; Calculator's memory area; used to store numbers that cannot conveniently be put on the calculator stack.
equ	MEM_3		,	SYSTEM_BASE+$00A1	; 23713 ; (IY+$67)
equ	MEM_4		,	SYSTEM_BASE+$00A6	; 23718 ; (IY+$6C)
equ	MEM_4_4		,	SYSTEM_BASE+$00AA	; 23722 ; (IY+$70)
equ	MEM_5_0		,	SYSTEM_BASE+$00AB	; 23723 ; (IY+$71)
equ	MEM_5_1		,	SYSTEM_BASE+$00AC	; 23724 ; (IY+$72)
equ	NMIADD		,	SYSTEM_BASE+$00B0	; 23728 ; (IY+$76) ; This is the address of a user supplied NMI address which is read by the standard ROM when a peripheral activates the NMI. Probably intentionally disabled so that the effect is to perform a reset if both locations hold zero, but do nothing if the locations hold a non-zero value. Interface 1's with serial number greater than 87315 will initialize these locations to 0 and 80 to allow the RS232 "T" channel to use a variable line width. 23728 is the current print position and 23729 the width - default 80.
equ	RAMTOP		,	SYSTEM_BASE+$00B2	; 23730 ; (IY+$78) ; Address of last byte of BASIC system area.
equ	P_RAMT		,	SYSTEM_BASE+$00B4	; 23732 ; (IY+$7A) ; Address of last byte of physical RAM.
;equ	SYSTEM_VARIABLES_SIZE,$00B6	; How big is the system variable space.
; NEW SYSTEM VARIABLES for CP/M SINCLAIR BASIC.
; Note the "offset" is $00B6 in total size.

equ	TOKEN_START	,	SYSTEM_BASE+$00B6	; Where we want to search for tokens to convert from text to ascii.
equ CHECKSUM	,	SYSTEM_BASE+$00B8	; 1 byte of checksum for the .TAP format files on a disk drive. 
equ DISKFLAGS	, 	SYSTEM_BASE+$00B9	; Flags for the disk.
 										; 0 ... 1 = TAP already loaded. If 0, look for a filename as a .TAP file ( no extension in CP/M ) and load it for use with subsequent loads. 
equ RECORD_LOC	,	SYSTEM_BASE+$00BA	; Record Location from 0 to 7F or 80 to FF - Two Bytes
equ FILE_BYTE	, 	SYSTEM_BASE+$00BC	; One byte where we store a byte read from the file... 

; Note: End of system variables is not $00B8
equ	SYSTEM_VARIABLES_SIZE,$00BD	; How big is the system variable space.


	
; *
; equ FLAGS	,		$5C3B	; 23611 ; (IY+$01) ; BASIC flags, particular bits meaning:
;						   ; 0 ... 1 = supress leading space for tokens
;						   ; 1 ... 1 = listing to ZX Printer
;						   ; 2 ... 1 = listing in mode 'L', 0 = listing in mode 'K'
;						   ; 3 ... 1 = keyboard mode 'L', 0 = keyboard mode 'K'
;						   ; 4 ... 48k: unused, 128k: 0 = basic48, 1 = basic128
;						   ; 5 ... 1= new key was pressed on
;						   ; 6 ... 1= numeric result of the operation, 0=string result of the operation (SCANN is set)
;						   ; 7 ... 1= syntax checking off, 0=syntax checking on
;
; **
; equ TV_FLAG	,	SYSTEM_BASE+$003C	; 23612 ; (IY+$02) ; PRINT routine flags, particular bits meaning:
;						   ; 0 ... 1=lower part of screen
;						   ; 3 ... 1=mode change in EDIT
;						   ; 4 ... 1=Autolist
;						   ; 5 ... 1=screen is clear
;
; ***
; equ FLAGS2	,	SYSTEM_BASE+$006A	; 23658 ; (IY+$30) ; BASIC flags, particular bits meaning:
; 						   ; 0 ... 1=screen is clear
;						   ; 1 ... 1=ZX Printeru buffer is not empty
;						   ; 2 ... 1=quotation mode during string processing
;						   ; 3 ... 1=caps lock
;						   ; 4 ... 1=channel 'K'
;						   ; 5 ... 1=new key was pressed on
;						   ; 6 ... unused
;						   ; 7 ... unused
;
; ****
; equ FLAGX		,	SYSTEM_BASE+$0071	; 23665 ; (IY+$37) ; BASIC flags, particular bits meaning:
; 						   ; 0 ... 1=remove string from variable before new string assign
;						   ; 1 ... 1=create variable at LET, 0=variable already exists
;						   ; 5 ... 1=INPUT mode, 0=EDIT BASIC line
; 						   ; 6 ... 1=numeric variable in INPUT, 0=string variable in INPUT mode
;						   ; 7 ... 1=input line
.end



