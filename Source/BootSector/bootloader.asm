; BIOS based BootLoader
;
; Cao Smith 2023
; Part of CaoOS: An X86-64 Toy System

%define Origin 0X7C00
; Set Origin of BootLoader in Memory
; BIOS will put us here, so setup the offset
[ORG Origin]

; Config for Real Mode - The default X86-xx start mode
[BITS 16]

boot_loader_neverends: Jmp $		; Tells the Code to just keep loading this instruction. Ad inifinitum.

