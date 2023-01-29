; BIOS based BootLoader
;
; Cao Smith 2023
; Part of CaoOS: An X86-64 Toy System

%define Origin 0X7C00          ; Define Origin of BootLoader in Memory

; Processes assume a 0000:0000 memory address start, requiring manual calculation 
; every call to find correct segments, since it's unlikely to be loaded there
; Assembler also provides a global "process" offset
[ORG Origin]                   ; BIOS will put us here, so setup the offset


[BITS 16]                       ; Config for Real Mode - The default X86-xx start mode

Mov BX, boot_msg                ; Save boot message as param to register BX
call bios_print                 ; Call the print function

boot_loader_neverends: Jmp $	; Tells the Code to just keep loading this instruction. Ad inifinitum.


; Declarations

; Inclusivity
%INCLUDE 'Source/BootSector/16bit/print_service.asm'

; Data Delcarations
boot_msg: DB `\r\n`, 250, 254, `[Cao OS]`,254, 250, `\r\n`,0 ; Start-up Message



; A boot loader must be in Cylinder 0, Head 0, Sector 1, occupy the entirety & identify as bootloader
Times 510 - ($ - $$) DB 0x00 ; Pad program to place magic number where expected (Byte 510 to Byte 512)
boot_code: DW 0xAA55         ; Magic Number - this differentiates bootloader from random files