; CaOS
; BIOS (Real Mode/16bit) Teletype routine
;
; CopyRight (c) 2023, Cao Smith


[BITS 16]       ; Address length will be 16 when invoked (at boot time)


; Define the function to print using BIOS
; BX = argument [String Pointer]
print_real:

    Pusha     ; Save the registers to stack


    Mov AH, 0x0E     ; Set AH (the HIGH half of AX) to the BIOS teletype services, executed at INT10


    ; Loop over the memory address in BX, until null-terminated string
    .loop:
        Cmp byte[BX], 0     ; Compare the current byte being pointed to be BX to the null-terminator value
        Je .bios_print_exit

        Mov AL, byte[BX]    ; Put the character of the sting in the low half of AX
        Int 0x10            ; Call interupt 10h - Parameter is in AH already
        Inc BX              ; Increment pointer to next char

        Jmp print_real.loop ; Continue processing

        .bios_print_exit:
            Popa                    ; Restore the AX & BX register values to pre-print call values
            Ret                     ; Blow this popsicle joint



; Define the function to print hex numbers using BIOS
; BX = Argument [Value Pointer]
printhex_real:

    
    Pusha           ; Save the registers to the stack
    
    Mov AH, 0x0E    ; Set AH (the HIGH half of AX) to the BIOS teletype services, executed at INT10            
    
    ; Print Hex Qualifier section
    Mov AL, '0'     ; Set print param to '0' char
    INT 0x10        ; Raise interupt to execute BIOS Teletype
    Mov AL, 'x'     ; Set print param to 'x' char
    INT 0x10        ;  Raise interupt to execute BIOS Teletype
  
    Mov CX, 4       ; Initialize counter
                    ; BX is 16bits, which is 4 nibbles    
                    ; Iterate 4 times 

    ; Loop over the value in BX until counter zeroes
    .loop:
        
        Cmp CX, 0                       ; Check if counter is exhausted
        Je printhex_real.hexit         ; Exit if so

        Push BX                         ; Save the progression of BX

        Shr BX, 0x0C                    ; Shift the high nibble to the low nibble
        
        
        Cmp BX, 0x0A                    ; BX >= 10?
        jge printhex_real.high_value   ; Calculate high value
            ; BX < 10: Calculate low value
            
            Mov AL, '0'                 ; Set 0 in AL
            Add AL, BL                  ; Add lower BX to it

            jmp printhex_real.print    ; Go put it on screen

        
        .high_value:                    ; BX >= 10, Subtract base amount & add to first printable character 
            Sub BL, 0x0A                ; Cut 10 from Lower BX
            Mov AL, 'A'                 ; Make Lower AX 'A' Char (96)
            Add AL, BL                  ; Add Lower BX to lower AX
        
        
        .print:                     ; Print the current nibble to screen device
            INT 0x10                ; Raise in 10h, invokes Teletype Service

            Pop BX                  ; Restore BX
            Dec CX                  ; Decrease counter        
            shl BX, 4               ; Shift out the last nibble

    
            jmp printhex_real.loop ; Back to the loop
    

    .hexit:                         ; Done here
        Mov AL, 'h'                 ; Set lower AX to 'h' char (Hex Suffix)
        INT 0x10                    ; Raise INT, invoke Teletype service
        Popa                        ; Restore the AX & BX register values to pre-print call values
        
        Ret                         ; Blow this popsicle joint
