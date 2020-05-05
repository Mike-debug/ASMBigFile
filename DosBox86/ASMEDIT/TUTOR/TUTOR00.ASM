;file name:     TUTOR00.ASM
;usage:         displays 'Hello World!' (3 errors)

;This example is part of ASM Edit. Copyright (c) by O Love & Tels, 1996.
;It may be freely copied, used, distributed or mentioned as long as this
;message remains. Please add your name if you modify or add something.

.286c
SEG_TUTOR       SEGMENT
                ASSUME CS:SEG_TUTOR, DS:SEG_TUTOR
                ORG     100H

TUTOR00         PROC FAR
        INIT:   JMP     START

        msg     DB 'Hello World!'       ;message                    **

        START:  MOV     DX,msg          ;get address offset         **
                MOV     AH,09H          ;sub routine (write string)
                INT     21H             ;DOS service
                RET_                    ;return to DOS              **
                DB '$'                  ;error fixup
TUTOR00         ENDP

SEG_TUTOR       ENDS
                END     INIT
