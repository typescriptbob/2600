
    processor 6502
    include "vcs.h"

    MAC TIMER_WAIT
.waitTimer
        LDA INTIM
        BNE .waitTimer
        STA WSYNC
    ENDM

    MAC TIMER_VBLANK
        lda #45
        STA TIM64T
    ENDM

    MAC TIMER_FRAME
        lda #230
        STA TIM64T
    ENDM

    MAC TIMER_OVERSCAN
        lda #40
        STA TIM64T
    ENDM