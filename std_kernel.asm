    processor 6502
    include "vcs.h"
    include "macro.h"
    include "timers.h"

WHITE   = $0E
GREEN   = $C2
BLUE    = $76
YELLOW  = $1E

    SEG.U vars
    ORG $80   ; start of RAM

SCANLINE_N  ds 1
PLAYER1_X   ds 1
PLAYER1_Y   ds 1

PLAYER1_SLICE_EVEN ds 1  ; player slice even lines
PLAYER1_SLICE_ODD  ds 1  ; player slice odd lines

    SEG
    ORG $F000

Reset
    CLEAN_START

    lda #0
    sta PLAYER1_X
    lda #56
    sta PLAYER1_Y
    lda #100
    sta PLAYER1_SLICE_EVEN   ; next player1 bitslice to draw
    lda #$44
    sta PLAYER1_SLICE_ODD

    lda #1              ; set D0 CTRLPF for reflection
    sta CTRLPF
StartOfFrame
    lda #2
    sta VBLANK      ; blank video signal
    VERTICAL_SYNC
    TIMER_VBLANK    ; init timer for VBLANK period
    JSR FramePre    ; do any setup before the frame
    TIMER_WAIT

    lda #0
    sta VBLANK      ; unblank video signal



    TIMER_FRAME     ; init timer for the visible frame
    lda #0
    STA WSYNC
ScanLine
    JSR DoScanLineLoop

    ldx #YELLOW    ; yellow for the block of lines not rendered. If visible FRAME_TIMER is too long
    stx COLUBK

    TIMER_WAIT

    lda #2
    sta VBLANK      ; blank video signal

    TIMER_OVERSCAN  ; init timer for overscan
    JSR FramePost
    TIMER_WAIT

    JMP StartOfFrame


FramePre
    ldx #GREEN
    stx COLUBK         ; bk color
    lda #WHITE
    sta COLUPF         ; set the playfield color
    RTS;

; scan line is in acc and y
; set playfield and sprites based on scanline
;
DoScanLineLoop
    lda #0
    sta SCANLINE_N
    tay
.continue
    STA WSYNC
    ldx PLAYER1_SLICE_EVEN
    stx GRP0
    tay
    and #%11111100           ; divide by 4 (to repeat 4 lines) and mult by 4 (to index into bitmap)
    tax
    lda Field0,x
    sta PF0
    lda Field1,x
    sta PF1
    lda Field2,x
    sta PF2

    ; must be done after the odd scanline
    sta WSYNC
    ldx PLAYER1_SLICE_ODD
    stx GRP0

    ; compute next player slice
    tya
    sec ; 2s complement so set carry
    sbc PLAYER1_Y
    bmi .clearPlayer
    cmp #8
    bpl .clearPlayer
    tax
    ;lda #$AA
    lda PlayerBitmap,x
    sta PLAYER1_SLICE_EVEN
    ;lda #$55
    lda PlayerBitmap+1,x

    sta PLAYER1_SLICE_ODD
    jmp .increment
.clearPlayer
    nop
    nop
    nop
    nop
    lda #0
    sta PLAYER1_SLICE_EVEN
    sta PLAYER1_SLICE_ODD
.increment
    inc SCANLINE_N
    inc SCANLINE_N
    lda SCANLINE_N
    cmp #192
    bne .continue
    ; clear playfield at end of line
    STA WSYNC
    lda #0
    sta PF0
    sta PF1
    sta PF2
    rts


; if timing is correct this color is not seen because it should be called in non-visible overscan area

FramePost
    ldx #BLUE
    stx COLUBK

    lda #0
    sta PF0                ; clear
    sta PF1                ; clear
    sta PF2                ; clear

    RTS

	org $FF00 ; *********************** GRAPHICS DATA

Playfield
    .byte %11110000,%11111111,%11111111,$00   ; lower nibble ignored and upper reversed for 1st. 3rd reversed, 4th ignored
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00111100,%00000000,$00
    .byte %00010000,%00100100,%00000000,$00
    .byte %00000000,%00100100,%00000000,$00 ; start gap
    .byte %00000000,%00100100,%00000000,$00
    .byte %00000000,%00100100,%00000000,$00
    .byte %00000000,%00100100,%00000000,$00
    .byte %00000000,%00100100,%00000000,$00
    .byte %00000000,%00100100,%00000000,$00
    .byte %00000000,%00100100,%00000000,$00
    .byte %00000000,%00100100,%00000000,$00 ; end gap
    .byte %00010000,%00100100,%00000000,$00
    .byte %00010000,%00111100,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %00010000,%00000000,%00000000,$00
    .byte %11110000,%11111111,%11111111,$00

Field0 = Playfield
Field1 = Playfield+1
Field2 = Playfield+2

PlayerBitmap
    .byte %10000001
    .byte %01000010
    .byte %00100100
    .byte %00011000
    .byte %00100111
    .byte %00100100
    .byte %00011000
    .byte %00111100

    ORG $FFFA
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
END