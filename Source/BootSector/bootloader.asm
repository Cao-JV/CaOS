; CaOS
; BIOS (Real/Protected/Long Mode/16/32/64bit) Bootloader
;
; CopyRight (c) 2023, Cao Smith

%define Origin 0X7C00                     ; Define Origin of BootLoader in Memory

; Processes assume a 0000:0000 memory address start, requiring manual calculation 
; every call to find correct segments, since it's unlikely to be loaded there
; Assembler also provides a global "process" offset
[ORG Origin] 


[BITS 16]
Setup:
    ; Setup
    Cli
    Cld

Init:
    Xor AX, AX                                 ; Explicitly set DS and ES to 0
    Mov DS, AX
    Mov ES, AX                                 ; Config for Real Mode - X86x start mode
    Mov SS, AX                                 ; Set Stack Segment to 0
   
    Mov BP, offset_stack                       ; Set Stack Base
    Mov SP, BP                                 ; Stack Pointer = Stack Base
    Mov [byte_boot_drive], DL                  ; Save boot drive from DL - set by BIOS
Boot:
    Call boot_real                             ; Execute Real Mode boot
    Jmp enable_protected_mode                  ; Execute Protected Mode switch 
    Jmp $


    %INCLUDE 'Source/BootSector/16bit/boot_real.asm'
    %INCLUDE 'Source/BootSector/enable_protected_mode.asm'

; A boot loader must be in Cylinder 0, Head 0, Sector 1, occupy the entirety & identify as bootloader
Times 510 - ($ - $$) DB 0x00    ; Pad program to place magic number where expected (Byte 510 to Byte 512)
boot_code: DW 0xAA55            ; Magic Number - this differentiates bootloader from random files

; Boot Sector 2 - Protected Mode include
 %INCLUDE 'Source/BootSector/32bit/boot_protected.asm'
 
Times 512 - ($ - boot_protected) db 0xCA


; Boot Sector 3
Times 256 DW 0xA7C7
; Boot Sector 4
Times 256 DW 0xBADD
