DATA    SEGMENT
        MY8255_A   EQU  1ff0H
        MY8255_B   EQU  1ff2H
        MY8255_C   EQU  1ff4H
        MY8255_MODE     EQU      1ff6H
        LED  DB 3FH, 06H, 5BH, 4FH, 66H, 6DH, 7DH, 07H, 7FH, 6FH
        BUFFER   DB  6 DUP(?)
        datbuf      db   01h,03h
DATA    ENDS

stack segment  stack 'stack'
	stackbuffer  db     200 dup (?)
stack  ends

CODE    SEGMENT
        ASSUME  CS:CODE, DS:DATA, ss:stack

;片选数码管  参数输出到C口的值
SELECTDIG  MACRO  DIGTION
          PUSH     DX 
          PUSH     AX
          MOV     DX, MY8255_C
          MOV     AL, DIGTION
          OUT     DX, AL
          POP       AX
          POP       DX
          ENDM

;先显示的零数
SHALFCOUNT  PROC NEAR
       MOV    BUFFER[0], AH             ;buffer[0]:PC1
       MOV    BUFFER[1], AL	      ;	
       PUSH    BX
       PUSH    DX
SHOWFF:
       MOV   AL,  [SI]
       MOV   BL,  [DI]
  
        SELECTDIG  BUFFER[0]
        MOV     AL, AL
        MOV     DX, MY8255_B
        OUT     DX, AL
        CALL    DELAY
        SELECTDIG BUFFER[1]
        MOV     AL, BL
        MOV     DX, MY8255_B
        OUT     DX, AL
       CALL    BIGDELAY
       CALL    BIGDELAY
       INC     SI
       LOOP   SHOWFF
       POP     DX
       POP     BX
       RET
SHALFCOUNT ENDP

QHALFCOUNT  PROC 
       MOV    BUFFER[0], AH
       MOV    BUFFER[1], AL
       PUSH    BX
       PUSH    DX
SHOWFFQ:
       MOV   AL,  [SI]
       MOV   BL,  [DI]
 
       SELECTDIG  BUFFER[0]
        MOV     AL, AL
        MOV     DX, MY8255_B
        OUT     DX, AL
        CALL    DELAY
        SELECTDIG BUFFER[1]
        MOV     AL, BL
        MOV     DX, MY8255_B
        OUT     DX, AL
        CALL    DELAY 
       INC     SI
       LOOP   SHOWFFQ
       POP     DX
       POP     BX
       ret
QHALFCOUNT ENDP

SLOWSPEED PROC NEAR
        PUSH  DX
        PUSH DI
        MOV   BUFFER[0],  AH    
        MOV   BUFFER[1],  AL     
        MOV   BUFFER[2],  BH
        MOV   BUFFER[3],  BL
LOOPDECADE:
        PUSH CX
        MOV  CX, 10
        MOV  DI, OFFSET LED
LOOPUNIT:
        SELECTDIG BUFFER[3]
        MOV  AL, [DI]
        MOV  DX, MY8255_B
        MOV  BL, AL
        OUT  DX, AL
        INC  DI
       CALL DELAY
        SELECTDIG BUFFER[2]
        MOV  AL, [SI]
        MOV  DX, MY8255_B
        OUT  DX, AL
      CALL BIGDELAY
      CALL BIGDELAY
        CMP  BL, BUFFER[1]
        JZ   CMPDECADE
LOOPBACK:
        LOOP LOOPUNIT
        POP  CX
        INC  SI
        LOOP LOOPDECADE
CMPDECADE:
        CMP  AL, BUFFER[0]
        JZ   EXIT
        JNZ  LOOPBACK
EXIT:
        POP  DI
        POP  DX
        RET
SLOWSPEED   ENDP
   
QUICKSPEED  PROC NEAR
        MOV   BUFFER[0],  AH    ;shi wei
        MOV   BUFFER[1],  AL     ;ge wei
        MOV   BUFFER[2],  BH     ; xian shi  shi wei
        MOV   BUFFER[3],  BL      ;xian shi  ge wei
        PUSH  DX
        PUSH DI
LOOPDECADEQ:
        PUSH CX
        MOV  CX, 10
        MOV  DI, OFFSET LED
LOOPUNITQ:
        SELECTDIG BUFFER[3]
        MOV  AL, [DI]
        MOV  DX, MY8255_B
        MOV  BL, AL
        OUT  DX, AL
        INC  DI
        CALL DELAY
        SELECTDIG BUFFER[2]
        MOV  AL, [SI]
        MOV  DX, MY8255_B
        OUT  DX, AL
        CALL DELAY
        CMP  BL, BUFFER[1]
        JZ   CMPDECADEQ
LOOPBACKQ:
        LOOP LOOPUNITQ
        POP  CX
        INC  SI
        LOOP LOOPDECADEQ
CMPDECADEQ:
        CMP  AL, BUFFER[0]
        JZ   EXITQ
        JNZ  LOOPBACKQ
EXITQ:
        POP  DI
        POP  DX
        RET
QUICKSPEED ENDP
     
GREEN  PROC NEAR
        PUSH  AX
        PUSH  DX
        MOV CX, 1
LOOPGREEN:
        SELECTDIG  41H
        MOV     AL, 6DH
        MOV     DX, MY8255_B
        OUT 	DX, AL
        CALL     DELAY
      
       SELECTDIG  42H
        MOV     AL, 3FH
        MOV     DX, MY8255_B
        OUT      DX, AL
        CALL    DELAY

       MOV  DX, MY8255_A
        IN  AL, DX
        CMP  AL, 00000001B
        JNZ   GREENSTART
         INC CX
        LOOP  LOOPGREEN

        POP    DX
        POP   AX
GREENSTART:
	JMP  LOOP1
        RET 
GREEN  ENDP 
   
YELLOW  PROC NEAR
        PUSH  AX
        PUSH  DX
        MOV   CX, 1
LOOPYELL:
        SELECTDIG  21H
        MOV     DX, MY8255_B
        MOV     AL, 7DH
        OUT 	DX, AL
        CALL     DELAY
        SELECTDIG  22H
        MOV     DX, MY8255_B
        MOV     AL, 5BH
        OUT 	DX, AL
        CALL    DELAY

        MOV   DX, MY8255_A
        IN       AL,  DX
        CMP   AL, 00000010B
        JNZ      YELLSTART
        INC      CX
        LOOP    LOOPYELL
        POP    DX
        POP    AX
YELLSTART:
        JMP    LOOP1
        RET
YELLOW ENDP

RED   PROC  NEAR
        PUSH  AX
        PUSH  DX
       MOV CX , 1
LOOPRED:
        SELECTDIG  11H
        MOV     DX, MY8255_B
        MOV     AL, 06H
        OUT 	DX, AL
        CALL     DELAY
  
        SELECTDIG  12H
        MOV     DX, MY8255_B
        MOV     AL, 6DH
        OUT 	DX, AL
        CALL    DELAY
   
        MOV   DX, MY8255_A
        IN       AL,  DX
        CMP   AL, 00000100B
        JNZ     REDSTART
        INC  CX
        LOOP     LOOPRED
        POP    DX
        POP    AX
REDSTART:
	JMP LOOP1
        RET
RED  ENDP

ENDNUM  PROC NEAR
        MOV   BUFFER[0], AL
        MOV   BUFFER[1], AH
        MOV   BUFFER[2], BL
        MOV   BUFFER[3], CL
        MOV   BUFFER[4], CH
        PUSH DX
        MOV CX, 1
LOOPSHOW:
         SELECTDIG BUFFER[3]
         MOV AL, BUFFER[0]
         MOV DX, MY8255_B
         OUT DX, AL
         CALL  DELAY
         SELECTDIG BUFFER[4]
          MOV AL,BUFFER[1]
          MOV DX, MY8255_B
          OUT DX, AL
         CALL  DELAY
        MOV  DX, MY8255_A
        IN AL, DX
        CMP AL, BUFFER[2]
         JNZ LOOPSTART
         INC   CX
        LOOP  LOOPSHOW
LOOPSTART:
        JMP   LOOP1
        POP DX
        RET
ENDNUM  ENDP

;慢刹车
DOWNSPEED PROC NEAR
	PUSH DX
	PUSH AX
DOWNFIRST: 
	SELECTDIG BUFFER[0]               ;显示单独的个位倒序循环
	MOV 	AL, [SI]                  ;个位 
	MOV     DX, MY8255_B
	OUT 	DX, AL
            CALL       DELAY
	SELECTDIG BUFFER[1]               ;十位
	MOV 	AL, [DI]
	MOV 	DX, MY8255_B
	OUT 	DX, AL
                 CALL       BIGDELAY
                 CALL       BIGDELAY
               CMP         SI, 00H
	JZ 	DOWNSECOND
	DEC 	SI
	JMP     DOWNFIRST
DOWNSECOND:
                MOV 	CX, DI                 ;十位
                DEC        DI
DOWNDECADE:
	PUSH    CX
	MOV 	SI, OFFSET LED + 9      ;个位
	MOV 	CX, 10
DOWNUNIT:
	SELECTDIG BUFFER[0]
	MOV  	AL, [SI]
	MOV 	DX, MY8255_B
	OUT 	DX, AL
       CALL    DELAY
	SELECTDIG  BUFFER[1]
	MOV 	AL, [DI]
	MOV 	DX, MY8255_B
	OUT 	DX, AL
      CALL  BIGDELAY
      CALL  BIGDELAY
	DEC 	SI
	LOOP    DOWNUNIT
	POP 	CX
	DEC 	DI
	LOOP 	DOWNDECADE
	POP         AX
	POP 	BX
RETURN:
	RET
DOWNSPEED  ENDP

;刹车
QDOWNSPEED PROC NEAR
	PUSH DX
	PUSH AX
QDOWNFIRST: 
	SELECTDIG BUFFER[0]               ;显示单独的个位倒序循环
	MOV 	AL, [SI]                  ;个位 
	MOV     DX, MY8255_B
	OUT 	DX, AL
            CALL       DELAY
	SELECTDIG BUFFER[1]               ;十位
	MOV 	AL, [DI]
	MOV 	DX, MY8255_B
	OUT 	DX, AL
                      CALL        DELAY
               CMP         SI, 00H
	JZ 	QDOWNSECOND
	DEC 	SI
	JMP     QDOWNFIRST
QDOWNSECOND:
                MOV 	CX, DI                 ;十位
                DEC        DI
QDOWNDECADE:
	PUSH    CX
	MOV 	SI, OFFSET LED + 9      ;个位
	MOV 	CX, 10
QDOWNUNIT:
	SELECTDIG BUFFER[0]
	MOV  	AL, [SI]
	MOV 	DX, MY8255_B
	OUT 	DX, AL
               CALL    DELAY
	SELECTDIG  BUFFER[1]
	MOV 	AL, [DI]
	MOV 	DX, MY8255_B
	OUT 	DX, AL
                CALL    DELAY
	DEC 	SI
	LOOP        QDOWNUNIT
	POP 	CX
	DEC 	DI
	LOOP 	QDOWNDECADE
	POP         AX
	POP 	BX
QRETURN:
	RET
QDOWNSPEED  ENDP

URGENCY PROC NEAR
	PUSH    	AX
	PUSH 	DX
	SELECTDIG  01H
 	MOV 	AL,  3FH
   	MOV 	DX,  MY8255_B
	OUT 	DX, AL
	SELECTDIG  02H
	MOV	AL, 3FH
	MOV	DX, MY8255_B
	OUT	DX, AL
	POP 	DX
	POP	AX
	RET
URGENCY  ENDP

START:
        MOV     AX, DATA
        MOV     DS, AX
        mov      ax, stack
        mov      ss, ax

        MOV     DX, MY8255_MODE       ;send control word
        MOV     AL, 90H                            ;10010000b
        OUT     DX, AL

LOOP1: 
        MOV     DX, MY8255_A      ;read from a
        IN      AL, DX
        MOV     BL,AL
        CMP     BL, 11111110B    ;judge pa0
        JZ         JUST_GREEN
        CMP     BL, 11111101B
        JZ          JUST_YELLOW
        CMP     BL, 11111011B
        JZ          JUST_RED   
        CMP BL, 0F5H
        JZ     SEC_UP_S1
        CMP BL, 0EDH
        JZ     SEC_UP_F1
        CMP BL, 0F6H
        JZ      FIR_UP_S1
        CMP BL, 0EEH
        JZ      FIR_UP_F1
        CMP BL,0F3H
        JZ THIRD_UP_S1
        CMP BL, 0EBH
        JZ  THIRD_UP_F1
        CMP BL, 0DEH
         JZ FIR_DOWN_S1
         CMP BL, 0BEH
          JZ FIR_DOWN_F1
          CMP BL, 0DDH
          JZ SEC_DOWN_S1
          CMP BL, 0BDH
           JZ SEC_DOWN_F1
           CMP BL, 0DBH
           JZ THIRD_DOWN_S1
          CMP BL, 0BBH
          JZ THIRD_DOWN_F1
          cmp bl, 00h
          jz   byebye1
          CALL  URGENCY
          JMP     LOOP1
byebye1:
         jmp   byebye
JUST_GREEN:
        CALL  GREEN
JUST_YELLOW:
       CALL   YELLOW
JUST_RED:
        CALL   RED
SEC_UP_S1:
        JMP   SEC_UP_S
SEC_UP_F1:          
        JMP   SEC_UP_F
FIR_UP_S1:
        JMP   FIR_UP_S
FIR_UP_F1:
        JMP FIR_UP_F
THIRD_UP_S1:
        JMP THIRD_UP_S
THIRD_UP_F1:
        JMP THIRD_UP_F
FIR_DOWN_F1:
        JMP  FIR_DOWN_F
FIR_DOWN_S1:
        JMP  FIR_DOWN_S
SEC_DOWN_F1:
        JMP   SEC_DOWN_F
SEC_DOWN_S1:
        JMP    SEC_DOWN_S
THIRD_DOWN_F1:
        JMP    THIRD_DOWN_F
THIRD_DOWN_S1:
        JMP    THIRD_DOWN_S

FIR_UP_S:
        MOV   SI, 5
        MOV   DI, 0
        MOV   CX , 5
        MOV   AH, 41H
        MOV   AL,  42H
        CALL   SHALFCOUNT

        MOV   CX,  2
        MOV   SI,  OFFSET LED + 1
        MOV    AH,  5BH
        MOV    AL , 6DH
        MOV    BH,  42H
        MOV    BL,   41H

        MOV   BUFFER[0],  AH    
        MOV   BUFFER[1],  AL     
        MOV   BUFFER[2],  BH
        MOV   BUFFER[3],  BL
LOOPDECADE1:
        PUSH CX
        MOV  CX, 10
        MOV  DI, OFFSET LED
LOOPUNIT1:
        SELECTDIG BUFFER[3]
        MOV  AL, [DI]
        MOV  DX, MY8255_B
        MOV  BL, AL
        OUT  DX, AL
        INC  DI
       CALL DELAY
        SELECTDIG BUFFER[2]
        MOV  AL, [SI]
        MOV  DX, MY8255_B
        OUT  DX, AL
      CALL BIGDELAY
      CALL  BIGDELAY
        CMP  BL, BUFFER[1]
        JZ   CMPDECADE1
LOOPBACK1:
        LOOP LOOPUNIT1
        POP  CX
        INC  SI
        LOOP LOOPDECADE1
CMPDECADE1:
        CMP  AL, BUFFER[0]
        JZ   EXIT1
        JNZ  LOOPBACK1
EXIT1:
      
        MOV    AH, 5BH
        MOV    AL,  6DH
        MOV    BL, 0F6H
        MOV    CH, 42H
        MOV    CL,  41H
        CALL    ENDNUM 
   
FIR_UP_F:
        MOV   SI, 5
        MOV   DI, 0
        MOV   CX , 5
        MOV   AH, 41H
        MOV   AL,  42H
        CALL   QHALFCOUNT

        MOV   CX,  2
        MOV   SI,  OFFSET LED + 1
        MOV    AH,  5BH
        MOV    AL , 6DH
        MOV    BH,  42H
        MOV    BL,   41H

        MOV   BUFFER[0],  AH    
        MOV   BUFFER[1],  AL     
        MOV   BUFFER[2],  BH
        MOV   BUFFER[3],  BL
LOOPDECADE2:
        PUSH CX
        MOV  CX, 10
        MOV  DI, OFFSET LED
LOOPUNIT2:
        SELECTDIG BUFFER[3]
        MOV  AL, [DI]
        MOV  DX, MY8255_B
        MOV  BL, AL
        OUT  DX, AL
        INC  DI
       CALL DELAY
        SELECTDIG BUFFER[2]
        MOV  AL, [SI]
        MOV  DX, MY8255_B
        OUT  DX, AL
      CALL    DELAY
        CMP  BL, BUFFER[1]
        JZ   CMPDECADE2
LOOPBACK2:
        LOOP LOOPUNIT2
        POP  CX
        INC  SI
        LOOP LOOPDECADE2
CMPDECADE2:
        CMP  AL, BUFFER[0]
        JZ   EXIT2
        JNZ  LOOPBACK2
EXIT2:
      
        MOV    AH, 5BH
        MOV    AL,  6DH
        MOV    BL, 0EEH
        MOV    CH, 42H
        MOV    CL,  41H
        CALL    ENDNUM 
 
SEC_UP_S:
        MOV   SI, 6
        MOV   DI, 2
        MOV   CX , 4
        MOV   AH, 21H
        MOV   AL,  22H
        CALL   SHALFCOUNT

        MOV   CX,  2
        MOV   SI,  OFFSET LED + 3
        MOV    AH,  6DH
        MOV    AL , 3FH
        MOV    BH,  22H
        MOV    BL,  21H
        CALL SLOWSPEED  

        MOV    AH, 6DH
        MOV    AL,  3FH
        MOV    BL, 0F5H
        MOV    CH, 22H
        MOV    CL, 21H
        CALL    ENDNUM 
 
SEC_UP_F:
        MOV   SI, 6
        MOV   DI, 2
        MOV   CX , 4
        MOV   AH, 21H
        MOV   AL,  22H
        CALL   QHALFCOUNT

        MOV   CX,  2
        MOV   SI,  OFFSET LED + 3
        MOV    AH,  6DH
        MOV    AL , 3FH
        MOV    BH,  22H
        MOV    BL,  21H
        CALL   QUICKSPEED  

        MOV    AH, 6DH
        MOV    AL, 3FH
        MOV    BL, 0EDH
        MOV    CH, 22H
        MOV    CL, 21H
        CALL    ENDNUM 

THIRD_UP_S:
        MOV   SI, 1
        MOV   DI, 5
        MOV   CX , 9
        MOV   AH, 11H
        MOV   AL,  12H
        CALL   SHALFCOUNT

        MOV   CX,  3
        MOV   SI,  OFFSET LED + 6
        MOV    AH,  6FH
        MOV    AL , 3FH
        MOV    BH,  12H
        MOV    BL,  11H
        CALL SLOWSPEED  

        MOV    AH, 6FH
        MOV    AL, 3FH
        MOV    BL, 0F3H
        MOV    CH, 12H
        MOV    CL, 11H
        CALL    ENDNUM 

THIRD_UP_F:
        MOV   SI, 1
        MOV   DI, 5
        MOV   CX , 9
        MOV   AH, 11H
        MOV   AL,  12H
        CALL  QHALFCOUNT

        MOV   CX,  3
        MOV   SI,  OFFSET LED + 6
        MOV    AH,  6FH
        MOV    AL , 3FH
        MOV    BH,  12H
        MOV    BL,  11H
        CALL   QUICKSPEED  

          MOV    AH, 6FH
        MOV    AL, 3FH
        MOV    BL, 0EBH
        MOV    CH, 12H
        MOV    CL, 11H
        CALL    ENDNUM 

FIR_DOWN_F:
        MOV   BUFFER[0], 41H
        MOV    BUFFER[1], 42H
        MOV    SI, OFFSET LED + 5
        MOV    DI, OFFSET LED + 2
        CALL   QDOWNSPEED

        MOV    AL, 3FH
        MOV    AH, 3FH
        MOV    BL, 0BEH
        MOV    CH, 42H
        MOV    CL,  41H
        CALL    ENDNUM 


FIR_DOWN_S:
        MOV   BUFFER[0], 41H
        MOV    BUFFER[1], 42H
        MOV    SI, OFFSET LED + 5
        MOV    DI, OFFSET LED + 2
        CALL   DOWNSPEED
     
        MOV    AL, 3FH
        MOV    AH, 3FH
        MOV    BL, 0DEH
        MOV    CH, 42H
        MOV    CL,  41H
        CALL    ENDNUM 

SEC_DOWN_F:
        MOV    BUFFER[0], 21H
        MOV    BUFFER[1], 22H
        MOV    SI, OFFSET LED 
        MOV    DI, OFFSET LED + 5
        CALL     QDOWNSPEED

        MOV    AL, 3FH
        MOV    AH, 3FH
        MOV    BL, 0BDH
        MOV    CH, 22H
        MOV    CL,  21H
        CALL    ENDNUM 

SEC_DOWN_S:
         MOV    BUFFER[0], 21H
        MOV    BUFFER[1], 22H
        MOV    SI,  OFFSET LED
        MOV    DI,  OFFSET LED + 5
        CALL     DOWNSPEED
 
        MOV    AL, 3FH
        MOV    AH, 3FH
        MOV    BL, 0DDH
        MOV    CH, 22H
        MOV    CL,  21H
        CALL    ENDNUM 

THIRD_DOWN_F:
        MOV   BUFFER[0], 11H
        MOV   BUFFER[1], 12H
        MOV   SI,  OFFSET LED
        MOV   DI, OFFSET LED + 9
        CALL    QDOWNSPEED

        MOV    AL, 3FH
        MOV    AH, 3FH
        MOV    BL, 0BBH
        MOV    CH, 12H
        MOV    CL,  11H
        CALL    ENDNUM 

THIRD_DOWN_S:
        MOV   BUFFER[0], 11H
        MOV   BUFFER[1], 12H
        MOV   SI,  OFFSET LED
        MOV   DI, OFFSET LED + 9
        CALL    DOWNSPEED 
            
        MOV    AL, 3FH
        MOV    AH, 3FH
        MOV    BL, 0DBH
        MOV    CH, 12H
        MOV    CL,  11H
        CALL    ENDNUM 

DELAY   PROC
        PUSH  CX
        MOV   CX, 7555H
C1:

        LOOP  C1
        POP   CX
        RET
DELAY   ENDP

BIGDELAY   PROC
        PUSH  CX
        MOV   CX, 0FFFFH
C2:

        LOOP  C2
        POP   CX
        RET
BIGDELAY   ENDP

byebye:
         mov   al, 00000011b
         mov   dx, my8255_c
         out     dx, al
         mov   ah, 4ch
        int 21h
CODE    ENDS
        END     START




