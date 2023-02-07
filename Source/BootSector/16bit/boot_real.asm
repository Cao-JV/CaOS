; CaOS
; BIOS (Real Mode 16bit) Boot functions
;
; CopyRight (c) 2023, Cao Smith

boot_real:
    Mov BX, msg_boot_start_begin               ; Save boot message as param to register BX
    Call print_real                            ; Call the print function

    Mov BX, msg_boot_ver                       ; Save boot version as param to register BX
    Call print_real                            ; Call the hex number print function

    

    ; Read n sectors 0x0000(ES):0xn(BX)
    Mov BX, offset_kernel                      ; Save memory segment for Kernel to BX register
    Mov DH, byte_num_sectors                   ; Save # Sectors as param in DH
    Mov DL, [byte_boot_drive]                  ; Save bootdrive as param to DL (redundant, but safe)
    Call disk_real_load                        ; Attempt disk loading

    ; Display contents
    Mov BX, [offset_kernel]
    call printhex_real                         ;  Print values
    Mov BX, [offset_kernel + word_sector_size] ; Save value of second sector of Kernel as param to BX
    call printhex_real                         ; Print it
    Ret

    ; Inclusivity
    %INCLUDE 'Source/BootSector/16bit/error_real_handler.asm'        ; Handling for 16bit errors
    %INCLUDE 'Source/BootSector/16bit/print_real_service.asm'        ; BIOS Print functions
    %INCLUDE 'Source/BootSector/16bit/disk_real_service.asm'         ; BIOS Disk loading function
    %INCLUDE 'Source/BootSector/32bit/gdt_protected.asm'             ; Definition of 32bit protected mode Global Descriptor Table - Describes memory segmentation map


    ; Global Variables this will spill out past the Bootloader code, allowing it to grow
    ; Beyond the 1 sector confines of the bootloader.
    msg_boot_ver        : DB `v0.01`,224,225,0
    msg_boot_start_begin: DB `\r\n`, `Cao OS `    ,0
    offset_kernel       : EQU 0x7E00      ; Where to load kernel
    offset_stack        : EQU 0x0500      ; Where to place stack (* Grows Down *)
    byte_num_sectors    : EQU 5           ; How many disk sectors to load
    word_sector_size    : EQU 512         ; Size of sectors in bytes


