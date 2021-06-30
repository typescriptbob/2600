    processor 6502
    include "vcs.h"
    include "macro.h"

    ORG $F000

Reset

    ldx #0
    lda #0
Clear
    sta 0,x
    inx
    bne Clear

StartOfFrame

   ; Start of vertical blank processing


        lda #2
        sta VSYNC       ; start vsync
        ; 3 scanlines of VSYNCH signal...
        sta WSYNC
        sta WSYNC
        sta WSYNC
        lda #0
        sta VSYNC       ; stop vsync


        ldy $1e ;  // yellow - should not be visible
        sty COLUBK

        lda #1
        sta VBLANK ; start vertical blank
        ldx #37
Blank32
        sta WSYNC
        dex
        bne Blank32

        lda #1
        sta VBLANK ; stop vertical blank

        ldy #$00 ;
        sty COLUBK

        cld             ; BASTARD!!!!!! random behaviour without this!!!!
        lda #$67        ; number of blocks
Loop
        ldx #$02        ; number of lines
Block1
        sta WSYNC
        dex
        bne Block1

        iny
        iny
        sty COLUBK

        sec
        sbc #1
        bne Loop

        ldy #$0E ; white
        sty COLUBK          ; draw white while VSYNC generating

        sta WSYNC           ; end on line end

        ldx #30
Overscan
        sta WSYNC
        dex
        bne Overscan
        jmp StartOfFrame




        ldx #40
WaitForFrame
        sta WSYNC
        dex
        bne WaitForFrame

        ldx 45
        stx COLUBK

        ldx 192
WaitForBlock
        sta WSYNC
        dex
        bne WaitForBlock

        jmp StartOfFrame

        ORG $FFFA
        .word Reset          ; NMI
        .word Reset          ; RESET
        .word Reset          ; IRQ
    END