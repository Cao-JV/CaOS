; CaOS
; 16bit set up, 32bit jump
;
; CopyRight (c) 2023, Cao Smith
[bits 16]
enable_protected_mode:
    
       Cli                                                       ; Disable interrupts
       Cld                                                       ; Clear the direction flag

       Lgdt [global_descriptor_table_descriptor_protected_mode]  ; Load global descriptor table

       Mov EAX, CR0                                             ; Store first byte of Control Register in EAX register
       Or  EAX, 0x1                                             ; Flip the byte
       Mov CR0, EAX   
       Jmp CODE_SEGMENT_PROTECTED_MODE:protected_mode_init      ; FAR jump to initializer, forces flush

; 32bit Sector-padding
[bits 32]
protected_mode_init:
        ; Set segment registers to point at the new 32bit Data Segment
         Mov EAX, DATA_SEGMENT                
         Mov DS, EAX
         Mov SS, EAX
         Mov ES, EAX
         Mov FS, EAX
         Mov GS, EAX

        Mov EBP, 0x9000                                 ; Set Stack Base Pointer Memory Address Location
        Mov ESP, EBP                                    ; Set Stack current pointer Memory Address Location to Base

        Call CODE_SEGMENT_PROTECTED_MODE:boot_protected ; Protected Mode (32bit) boot
