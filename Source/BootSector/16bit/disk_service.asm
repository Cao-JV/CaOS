; CaOS
; BIOS BIOS (Real Mode/16bit) disk routines 
; A collection of disk-related utilities useful to booting a system
;
; CopyRight (c) 2023, Cao Smith
[BITS 16]                   ; Always show your bits, avoids ambiguity


detect_disk_type:
    Push BX
    
    Mov BX, msg_boot_disk_detect
    Call bios_print
    
    Cmp BYTE [byte_boot_drive], BYTE_BOOT_DRIVE_HDD
    Je .hdd

    Cmp BYTE [byte_boot_drive], BYTE_BOOT_DRIVE_FDD
    Je .fdd

    .hdd:
        Mov BX, msg_hdd
        Call bios_print
        Jmp .end
    .fdd:
        Mov BX, msg_fdd
        call bios_print
        Jmp .end
    .end:
        Pop BX
        ret
detect_disk_extensions:
    Push BX 

    Mov BX, msg_ata_extensions_check
    Call bios_print

    Cmp DL, BYTE_BOOT_DRIVE_FDD 
    Je .no_extensions  

    Mov BX, word_disk_ext_check         ; Save extensions ID as param in BX
    Mov AH, 0x41                        ; Set disk utils extension check function
    Int 0x13                            ; Raise int to execute extension check function
    Jc error                            ; Jump on error
  
    Cmp BX, word_boot_sector_sig        ; Is BX the BootLoader ID?
    Jnz  .no_extensions                 ; If not there are no extensions

    Mov BX, msg_yes                     ; Save extensions detected message as param to BX
    Call bios_print                     ; Print to Screen
    
    Mov BYTE [byte_has_disk_extensions], 1
    Jmp .end
    .no_extensions:
        Mov BX, msg_no
        Call bios_print
    .set_simple_read:
        Mov BYTE [byte_has_disk_extensions], 0
        Jmp .end
    .end:
        Pop BX
        ret

disk_read:
    Pusha                   ; Save all the (4 of the) registers
    Push DX 

    Mov AH, 0x02            ; BIOS Disk Read function
    Mov AL, DH              ; Disk Read expects # of sectors to read to be in AL, disk_load params are in DX
    Mov CH, 0x00            ; Disk Read Expects Cylinder # to read from
    Mov DH, 0x00            ; Disk Read Expects Cylinder Head # to read with
    Mov CL, 0x02            ; Need to read from next sector on
    
    INT BYTE_DISK_INTERRUPT   ; Raise the ATA Utility interrupt, with AH set to 02, will read disk based on set params
    jc error               ; If the carrier flag in CPU set, something fucked up
    Pop DX                  ; Restore from stack the number of sectors requested for read
   ; call bios_print_hex
    Cmp AL, DH              ; Compare # of sectors read to # of sectors requested for read
    jne error               ; If not equal, something fucked up        
    
    Mov BX, msg_success     ; Put Success Message into register BX
    Call bios_print         ; Print the message to screen

    Popa                    ; Restore initial register values
    ret                     ; Blow this popsicle joint
 
    
; Read DH # of sectors into ES:BX
; Read from Drive DL
; Sectors to Read CL
; BX Memory Address to Write to
disk_load:
    Push BX                     ; Push a copy of BX register to stack

    Call detect_disk_type       ; Attempt to determine loading medium
    Call detect_disk_extensions ; attempt to determine if boot medium has extended disk I/O
    Mov BX,msg_loading          ; Save disk loading messge as param to BX
    Call bios_print             ; Print message

    Pop BX                      ; Restore BX to caller's value

    Call disk_read              ; Attempt to read disk data to memory

    Ret                         ; Blow this popsicle stand


; Data Labels
    msg_boot_disk_detect    : DB `\r\n`,250,` Drive:`                     ,0
    msg_ata_extensions_check: DB `\r\n`,250,` Ext :`                      ,0
    msg_loading             : DB `\r\n`,250,` Load`                       ,0
        
    msg_success             : DB `ed!\r\n`                                ,0
    msg_yes                 : DB `Yes`                                    ,0
    msg_no                  : DB `No`                                     ,0
    msg_fdd                 : DB `FDD`                                    ,0
    msg_hdd                 : DB `HDD`                                    ,0
    byte_boot_drive         : DB 0            ; Disk to load from
    byte_has_disk_extensions: DB 0            ; Are the disk extensions available?
    
; Data defines   
    BYTE_BOOT_DRIVE_FDD     : EQU 0x00        ; First floppy value
    BYTE_BOOT_DRIVE_HDD     : EQU 0x80        ; First HDD value
    BYTE_DISK_WRITE         : EQU 0x02        ; Disk Service Function Standard Write
    BYTE_DISK_WRITE_EXTENDED: EQU 0x42        ; Disk Service Function Extended Write 
    BYTE_DISK_INTERRUPT     : EQU 0x13        ; BIOS Disk Utility Interrupt Number
    word_boot_sector_sig    : EQU 0xAA55      ; The signature BIOS looks for to identify BootSector also:
                                              ;  Value returned if Disk Extensions present
    word_disk_ext_check     : EQU 0x55AA      ; Value of disk util check for extensions function
    