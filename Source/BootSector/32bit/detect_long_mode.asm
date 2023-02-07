; CaOS
; Long Mode Detection - Check for 64bit chip
;
; CopyRight (c) 2023, Cao Smith

[BITS 32]

detect_long_mode:
    Pushad                                  ; Push on stack Double. Registers in order: EAX, ECX, EDX, EBX, EBP, ESP (original value), EBP, ESI, and EDI (if the current operand-size attribute is 32)

    ; Look for CPUID
    Pushfd                                  ; Save FLAG values to Stack
    Pop EAX                                 ; Put the FLAG values in EAX

    Mov ECX, EAX                            ; Save EAX register value to ECX register value

    Xor EAX, (1 << 21)                      ; Flip ID FLAG bit 

    Push EAX                                ; Put new FLAG value on stack
    Popfd                                   ; Set FLAG value from stack (EAX)

    Pushfd                                  ; Put FLAG value on stack (Again, to compare)
    Pop EAX                                 ; Store FLAG value in EAX

    Push ECX                                ; Put ECX on Stack (Old Version of Flags)
    Popfd                                   ; Set FLAG to original value (ECX)

    Cmp EAX, ECX                            ; Compare ECX to EAX (Flags after bit set to Flags before)
    Je  .error_no_cpuid                     ; CPUID not present - Jump to error & hang

    ; CPUID Preset - Check for extended Functionality
    Mov EAX, DD_CPUID_ARG                   ; Save CPUID Argument as Param to EAX Register
    CpuID                                   ; Run CPUID Function   
    Cmp EAX, DD_CPUID_RESPONSE              ; Compare the return value in register EAX to known value
    Jb .error_no_cpuid                      ; If response is not larger, Extended functions not support - not 64bit

    ; Long mode check
    Mov EAX, DD_CPUID_ARG                   ; Save CPUID argument as Param to EAX
    CpuID                                   ; Run CPUID funciton
    Test EDX, 1 << 29                       ; Is bit 29 of EDX register now set?
    Jz detect_long_mode.error_no_long_mode ; If not, Long Mode not present
  
  
    Popad                                   ; Restore the calling state of the registers
    Ret                                     ; Make tracks
    .error_no_cpuid:
        Mov EBX, msg_error_cpuid            ; Save CPUID error message as param to EBX
        Call print_protected                ; Print CPUID error message
        Jmp $                               ; Rot in shell
    .error_no_long_mode:
        Mov EBX, msg_long_mode              ; Save no 64bit mode message as param to EBX 
        Call print_protected                ; Print message
        Jmp $                               ; Rot in shell
msg_error_cpuid    : DB `CPUID not Present`       , 0
msg_long_mode      : DB `Long Mode not Supported` , 0

DD_CPUID_ARG        EQU 0x80000000
DD_CPUID_RESPONSE   EQU 0x80000001