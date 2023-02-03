; CaOS
; Memory Mapped Device - Print
;
; CopyRight (c) 2023, Cao Smith

[bits 32]

; Print a null terminated string
; Param EBX - memory address of string to print
; Two bytes are needed to display on screen
; Character to print (ASC)
; Text Attributes
print32:    
    Pusha   ; Save the registers to the stack
    Mov EDX, WORD_VID_MEM   ; Cue EDX to begining of Video Memory Segment

    .loop:
        Mov AL, [EBX]               ; Set AL Register to current value at EBX memory address
        
        Cmp AL, 0                   ; Is AL 0?
        Je print32.end              ; End the function

        Mov AH, BYTE_CLASSIC_COLOUR ; Set AH Register to text attributes 
        Mov [EDX], AX               ; Set Video memory address EDX value to AX values

        Add EBX, 1                  ; Advance EBX memory location to next Character to print
        Add EDX, 2                  ; Advance Video Memory Address Location to next Character Cell (remember to skip attribute byte)

        Jmp print32.loop            ; Stuck in the cycle
    .end:
        Popa                        ; Restore registers from Stack
        RET                         ; Blow this popsicle
; DATA
WORD_VID_MEM        EQU 0xB8000  ; This is the segment of memory dedicated to text display
BYTE_CLASSIC_COLOUR EQU 0x0F     ; Grey-On-Black chars

