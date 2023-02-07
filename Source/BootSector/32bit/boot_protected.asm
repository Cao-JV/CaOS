; CaOS
; Protected Mode (32bit) Boot functions
;
; CopyRight (c) 2023, Cao Smith

; Protected Mode (32bit) boot
[bits 32]
boot_protected:
    Mov EBX, msg_protected_mode ; Save protected mode message as param to EBX register
    Call print_protected        ; Print message
    Call detect_long_mode       ; Check for Long Mode capable CPU

    Mov EBX, msg_long_mode_available ; Save Long Mode confirmation as Param to EBX
    Call print_protected             ; Print message

    Jmp $                            ; Endless Hesitation

%INCLUDE 'Source/BootSector/32bit/print_protected_service.asm'
%INCLUDE 'Source/BootSector/32bit/detect_long_mode.asm'
%INCLUDE 'Source/BootSector/64bit/gdt_long.asm'
;Data 32bit
msg_protected_mode      : DB `32bit Protected Mode loaded\r\n`       , 0
msg_long_mode_available  : DB `64bit Long Mode Available\r\n`   ,0