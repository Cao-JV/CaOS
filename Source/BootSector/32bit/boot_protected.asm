; CaOS
; BIOS (Real Mode 16bit) Boot functions
;
; CopyRight (c) 2023, Cao Smith

; Protected Mode (32bit) boot
[bits 32]
boot_protected:
    Mov EBX, msg_protected_mode ; Save protected mode message as param to EBX register
    Call print_protected        ; Print message

jmp $

%INCLUDE 'Source/BootSector/32bit/print_protected_service.asm'
%INCLUDE 'Source/BootSector/64bit/gdt_long.asm'
;Data 32bit
msg_protected_mode: DB `32bit Protected Mode loaded\r\n`, 0
