; CaOS
; Error handling routine
; Or - Print & Crash 
; A collection of disk-related utilities useful to booting a system
;
; CopyRight (c) 2023, Cao Smith

; Params:
; AH - Error Code
; BX - Message to Display

error:
    Mov BX, [error_message] ; Save error_message as param in BX register
    Call bios_print         ; Print the message
    Xor BX, BX              ; Clear BX Register
    Mov BH, AH              ; Save AH as a param in the BH register
    Call bios_print_hex     ; Print that value
    .fucked_up: Jmp $       ; Ponder life choices

; Data

error_message: db `\r\nError!`