; BIOS routine to load a file from disk to memory
;
; Cao Smith 2023
; Part of CaoOS: An X86-64 Toy System

[BITS 16]                   ; Always show your bits, avoids ambiguity


; Read DH # of sectors into ES:BX
; Read from Drive DL
; Sectors to Read CL
; BX Memory Address to Write to
disk_load:
    Pusha                   ; Save all the (4 of the) registers
    Push BX                 ; Do extra BX stack save
    
    Mov BX, 0x55AA          ; Save extensions ID as param in BX
    Mov AH, 0x41            ; Set disk utils extension check function
    Int 0x13                ; Raise int to execute extension check function
    Jc disk_load.error      ; Jump on error
  
    Cmp BX, 0xAA55          ; Is BX still the extensions ID?
    Jnz  disk_load.extensions_missing

    Mov BX, msg_extensions_present  ; Save extensions detected message as param to BX
    Call bios_print         ; Print to Screen


    Pop BX                  ; Restore BX to calling value
 ;   Call bios_print_hex
    Push DX 

    Mov AH, 0x02            ; BIOS Disk Read function
    Mov AL, DH             ; Disk Read expects # of sectors to read to be in AL, disk_load params are in DX
    Mov CH, 0x00            ; Disk Read Expects Cylinder # to read from
    Mov DH, 0x00            ; Disk Read Expects Cylinder Head # to read with
    Mov CL, 0x02            ; Need to read from next sector on

    INT 0x13                ; Raise the ATA Utility interrupt, with AH set to 02, will read disk based on set params
    jc disk_load.error      ; If the carrier flag in CPU set, something fucked up
    Pop DX                  ; Restore from stack the number of sectors requested for read
 ;   mov bx, dx
    call bios_print_hex
    Cmp AL, DH              ; Compare # of sectors read to # of sectors requested for read
    jne disk_load.error     ; If not equal, something fucked up        
    
    Mov BX, msg_success     ; Put Success Message into register BX
    Call bios_print         ; Print the message to screen

    Popa                    ; Restore initial register values
    Ret                     ; Blow this popsicle stand

    .extensions_missing:
        Mov BX, msg_extensions_missing ; Save extensions missing messge as param to BX
        call bios_print                ; Write it to screen
    
    ; Fuck up handling
    .error:
        Mov BX, msg_fail    ; Put Failure Message into Register BX
        Call bios_print     ; Print Message to screen
        
        Shr AX, 8           ; Error Code stored in AH, Shift into AL to clear AH
        Mov BX, AX          ; Save AX as a param in the BX register
        Call bios_print_hex ; Print code to Screen

        Jmp $               ; Reflect on life choices


    msg_success: db `Loaded!\r\n`,0
    msg_fail: db `\r\nFailed to load Kernel!\r\n`,0

    msg_extensions_present: db `Disk functions present`,0
    msg_extensions_missing: db `Disk functions mising`,0