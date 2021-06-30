    processor 6502
    include "vcs.h"
    include "macro.h"
    include "timers.h"

    SEG.U vars
    ORG $80   ; start of RAM

SCANLINE_N ds 1





    SEG
    ORG $F000

Reset
    CLEAN_START

StartOfFrame
    lda #2
    sta VBLANK      ; blank signal
    VERTICAL_SYNC

    TIMER_VBLANK
    JSR LoopPre
    TIMER_WAIT


    lda #0
    sta VBLANK      ; unblank signal

    lda #0
    sta SCANLINE_N
    STA WSYNC       ; wait for the horizontal blanking

    TIMER_FRAME
ScanLine
    STA WSYNC
    JSR DoScanLine

    inc SCANLINE_N
    lda SCANLINE_N
    cmp #192
    bne ScanLine

    STA WSYNC
    ldx #$0E    ; white for the block of lines not rendered. If visible FRAME_TIMER is too long
    stx COLUBK

    TIMER_WAIT

    lda #2
    sta VBLANK      ; blank signal

    TIMER_OVERSCAN
    JSR LoopPost
    TIMER_WAIT

    JMP StartOfFrame


LoopPre
    ldx #$C2    ; green
    stx COLUBK
    lda #$0C
    sta COLUPF             ; set the playfield color

    RTS;

; scan line is in SCANLINE_N
; set playfield and sprites based on scanline
;
DoScanLine


    lda SCANLINE_N
    cmp #35
    bmi .clear               ; draw before line 10
    ;cmp #90
    jmp .draw
.clear
    lda #$00
    sta PF0                ; as the playfield shape
    sta PF1                ; as the playfield shape
    sta PF2                ; as the playfield shape
    RTS
.draw
    lda #$A0
    sta PF0                ; as the playfield shape
    lda #$55
    sta PF1                ; as the playfield shape
    lda #$AA
    sta PF2                ; as the playfield shape
    RTS


; if timing is correct this color is not seen because it should be called in non-visible overscan area

LoopPost
    ldx #$76    ; blue
    stx COLUBK

    lda #0
    sta PF0                ; clear
    sta PF1                ; clear
    sta PF2                ; clear

    RTS



    ORG $FFFA
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
END