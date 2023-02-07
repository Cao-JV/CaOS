; CaOS
; Memory Segmenttation - 32bit General Descriptor Table
;
; CopyRight (c) 2023, Cao Smith

; General Descriptor Table (32bit) Layout
;
;  00 |````````|   00 |````````|
;  01 |        |   01 |        | 
;  02 |        |   02 |        | 
;  03 |        |   03 |        | 
;  04 |  Base  |   04 |        | 
;  05 |        |   05 |        | 
;  06 |        |   06 |        | 
;  07 |        |   07 |        | 
;     |--------|      |        | 
;  08 |        |   08 |        | 
;  09 | TYPE   |   09 |        | 
;  10 |        |   10 |        | 
;  11 |        |   11 |        | 
;     |--------|      |        | 
;  12 | Dsc Tp |   12 |        | 
;     |--------|      |        | 
;  13 |        |   13 |        | 
;  14 | Dsc Lv |   14 |        | 
;     |--------|      |        |  
;  15 | Sg Prs |   15 |        | 
;     |--------|      |--------| 
;  16 |        |   16 |        | 
;  17 |        |   17 |        | 
;  18 |  S Lmt |   18 |        | 
;  19 |        |   19 |        | 
;     |--------|      |        | 
;  20 |  Avail |   20 |        | 
;     |--------|      |        | 
;  21 |  64bit |   21 |        | 
;     |--------|      |        | 
;  22 | Op Sze |   22 |        | 
;     |--------|      |        | 
;  23 | Granul |   23 |        | 
;     |--------|      |        | 
;  24 |        |   24 |        | 
;  25 |        |   25 |        | 
;  26 |        |   26 |        | 
;  27 |  BASE  |   27 |  BASE  | 
;  28 |        |   28 |        | 
;  29 |        |   29 |        | 
;  30 |        |   30 |        | 
;  31 |________|   31 |________| 
;       
;      BYTE 4-7        BYTE 0-3    
;
;   BASE   - Segment Base Address               
;   S LMT  - Segment Limit
;   GRANUL - Granularity
;   OP SZE - Operation size (Default) 0=16, 1=32 bit Segment
;   64bit  - IA32e 64bit code segment
;   AVAIL  - Available for system use   
;   SG PRS - Segment Present
;   DSC LV - Descriptor Privilge Level
;   DSC TP - Descriptor Type (0 = System; 1 = Code/Data)
;   TYPE   - Segment Type

; Memory place holder
global_descriptor_table_protected_mode:
    .invalid:        ; Define an invalid descriptor entry
        DD 0x0       ; Define a null double word
        DD 0x0       ; 8 bytes' worth

    .code_segment:   ; Code segment descriptor
        DW 0xFFFF    ; LIMIT (0-15)
        DW 0x000     ; BASE  (0-15)
        DB 0x0       ; BASE (16-23)
        DB 0b10011010 ; (SG PRS 0)(DSC LV 00) (TYPE 1) (24-27)
                     ; TYPE FLAGS: (CODE 1)(CONFORMING 0)(READABLE 1)(ACCESSED 0) (28-31)
        DB 0b11001111 ; (GRANUL 1)(OP SZE 1)(64BIT 0)(AVAIL 0)
                     ; LIMIT (16-19)
        DB 0x0       ; BASE (24-31)
    .data_segment:   ; the Data Segment Descriptor
        ; Copy Code Seg, change Type FLags
        DW 0xFFFF    ; LIMIT (0-15)
        DW 0x0       ; BASE  (0-15)
        DB 0x0       ; BASE  (16-23)
        DB 0b10010010 ; (SG PRS 0)(DSC LV 00) (TYPE 1) (24-27)
                     ; TYPE FLAGS: (CODE 0)(CONFORMING 0)(READABLE 1)(ACCESSED 0) (28-31)
        DB 0b11001111 ; (GRANUL 1)(OP SZE 1)(64BIT 0)(AVAIL 0)
                     ; LIMIT (16-19)
        DB 0x0       ; BASE (24-31)
    .end:            ; Used for size calculations

global_descriptor_table_descriptor_protected_mode:
    DW global_descriptor_table_protected_mode.end - global_descriptor_table_protected_mode  - 1  ; Size of GDT minus 1
    DD global_descriptor_table_protected_mode                                     ; General Descriptor Table address

; DATA
CODE_SEGMENT_PROTECTED_MODE EQU global_descriptor_table_protected_mode.code_segment - global_descriptor_table_protected_mode
DATA_SEGMENT EQU global_descriptor_table_protected_mode.data_segment - global_descriptor_table_protected_mode