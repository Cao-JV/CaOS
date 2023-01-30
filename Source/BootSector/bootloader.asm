; CaOS
; BIOS (Real/Protected/Long Mode/16/32/64bit) Bootloader
;
; CopyRight (c) 2023, Cao Smith

%define Origin 0X7C00          ; Define Origin of BootLoader in Memory

; Processes assume a 0000:0000 memory address start, requiring manual calculation 
; every call to find correct segments, since it's unlikely to be loaded there
; Assembler also provides a global "process" offset
[ORG Origin]                   ; BIOS will put us here, so setup the offset


[BITS 16]
; Setup
    Cli
    Cld


    Xor AX, AX                  ; Explicitly set DS and ES to 0
    Mov DS, AX
    Mov ES, AX                  ; Config for Real Mode - X86x start mode
    Mov SS, AX
Mov BP, offset_stack            ; Set Stack Base
Mov SP, BP                      ; Stack Pointer = Stack Base
Mov [char_boot_drive], DL       ; Save boot drive from DL - set by BIOS


Mov BX, msg_boot_start          ; Save boot message as param to register BX
Call bios_print                 ; Call the print function

Mov BX, [msg_boot_ver]          ; Save boot version as param to register BX
Call bios_print_hex             ; Call the hex number print function

Mov BX, msg_kernel_load         ; Save the kernel loading message as param to register BX 
Call bios_print                 ; Call the print function

Mov BX, [char_boot_drive]       ; Save boot drive as param to BX
Call bios_print_hex             ; Print drive to screen

Mov BX, msg_ellipse             ; Save ellipse as param to BX
Call bios_print                 ; Print ellipse to Screen

; Read n sectors 0x0000(ES):0xn(BX)
Mov BX, offset_kernel           ; Save memory segment for Kernel to BX register
Mov DH, byte_num_sectors        ; Save # Sectors as param in DH
Mov DL, [char_boot_drive]       ; Save bootdrive as param to DL (redundant, but safe)
call disk_load                  ; Attempt disk loading

; Display contents
;CX EQU [offset_kernel]         ; Save value at kernel start as param to BX
Mov BX, [offset_kernel]
call bios_print_hex                                 ;  Print values
Mov BX, [offset_kernel + word_sector_size]          ; Save value of second sector of Kernel as param to BX
call bios_print_hex                                 ; Print it


boot_loader_neverends: Jmp $	; Tells the Code to just keep loading this instruction. Ad inifinitum.

; Declarations

; Inclusivity
%INCLUDE 'Source/BootSector/16bit/print_service.asm'        ; Print function
%INCLUDE 'Source/BootSector/16bit/printhex_service.asm'     ; Hex number printing funciton
%INCLUDE 'Source/BootSector/16bit/disk_loader.asm'          ; Disk loading function

; A boot loader must be in Cylinder 0, Head 0, Sector 1, occupy the entirety & identify as bootloader
Times 510 - ($ - $$) DB 0x00 ; Pad program to place magic number where expected (Byte 510 to Byte 512)
boot_code: DW 0xAA55         ; Magic Number - this differentiates bootloader from random files

; Global Variables this will spill out past the Bootloader code, allowing it to grow
; Beyond the 1 sector confines of the bootloader.
msg_boot_ver:       DW 0x010A
msg_boot_start:     DB `\r\n`, 250, 254, `[Cao OS]`,254, 250, `\r\n`,0 ; Start-up Message
msg_kernel_load:    DB `\r\nLoading Kernel from drive: `, 0
msg_ellipse:        DB `...`,0
char_boot_drive:    DB 0           ; Disk to load from
offset_kernel:      EQU 0x8000      ; Where to load kernel
offset_stack:       EQU 0x4000      ; Where to place stack (* Grows Down *)
byte_num_sectors:   EQU 5           ; How many disk sectors to load
word_sector_size    EQU 512         ; Size of sectors in bytes



; Make bootloader artifically big enough to fill target sectors to test
Times 256 DW 0xA7C7
Times 256 DW 0xBADD