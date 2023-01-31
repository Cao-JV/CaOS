; CaOS
; BIOS (Real Mode/16bit) Teletype routine
;
; CopyRight (c) 2023, Cao Smith


[BITS 16]       ; Address length will be 16 when invoked (at boot time)


; Define the function to print using BIOS
; BX = argument [String Pointer]
bios_print:

    Pusha     ; Save the registers to stack


    Mov AH, 0x0E     ; Set AH (the HIGH half of AX) to the BIOS teletype services, executed at INT10


    ; Loop over the memory address in BX, until null-terminated string
    .loop:
        Cmp byte[BX], 0     ; Compare the current byte being pointed to be BX to the null-terminator value
        Je bios_print_exit

        Mov AL, byte[BX]    ; Put the character of the sting in the low half of AX
        Int 0x10            ; Call interupt 10h - Parameter is in AH already
        Inc BX              ; Increment pointer to next char

        Jmp bios_print.loop

bios_print_exit:
    Popa                    ; Restore the AX & BX register values to pre-print call values

    Ret                     ; Blow this popsicle joint

