	LOCK EQU P3.3
;LOCK = 0(OPEN) LOCK = 1(LOCKED)
	BIG_LOCK EQU P3.4
;BIGLOCK = 0(OPEN) BIGLOCK = 1(NEED THE ADMIN)(LOCKED)
	WAKE_UP EQU P3.5
	
	BIT_COUNT EQU 19H
;�p����
	COUNT EQU 20H
;�p����F�X��

	MSG_LINE EQU 21H
	MSG_ROW	EQU 22H
;�T�w���@���T���n��X

	HIDDEN_FLAG EQU 23H.0
;��ܭn���n���ñK�X��X
	ID_SETTING EQU	23H.1
;ID�]�w�Ҧ�0 =>�@�Z��J 1=>�]�w�Ҧ�
	PSD_SETTING EQU	23H.2
;PSD�]�w�Ҧ�0 =>�@�Z��J 1=>�]�w�Ҧ�
 
ORG   	0000H						;�i�D�sĶ���{���X�q0000H�}�l��
AJMP  	SLEEP					;����MAIN���a�����(�׶}���_�V�q��})
ORG		0003H		
AJMP 	INTERRUPT
ORG   	0050H						;�i�D�sĶ���{���X�q0050H�}�l��

SLEEP:

	;SETB	WAKE_UP
	;MOV		A, P3
	;CJNE	A, #00100000B, SLEEP
	JMP		INITIAL


INITIAL:							;��l�Ƽƭ�
	MOV 	COUNT, #0
	MOV 	R7, #0
	MOV		R6, #0
	MOV		R5, #0
	MOV 	R4, #0
	MOV		R3, #0
	MOV		R2, #0	
	MOV		R1, #0
	MOV		R0, #0	
;====�w�]�K�X0123
	MOV 	40H, #0
	MOV		41H, #0
	MOV		42H, #0
	MOV		43H, #0
;��J��DATA	
	MOV 	44H, #0
	MOV		45H, #0
	MOV		46H, #0
	MOV		47H, #0	
;��J��ID
	MOV 	48H, #0
	MOV		49H, #0
	MOV		50H, #0
	MOV		54H, #0
	CLR		LOCK
	CLR		BIG_LOCK
	MOV 	DPTR, #TABLE_1
	MOV		MSG_LINE, #0
	MOV		MSG_ROW, #0
	
	MOV 	BIT_COUNT, #0
	CLR		HIDDEN_FLAG
	CLR		ID_SETTING
	CLR		PSD_SETTING
START:
;�@�}�l����� HELLO

								;�M�wDELAY�ɶ�
	MOV		R2, #250
	CALL	LCM_DELAY
	
	MOV 	A, #00111011B		;�\��]�w:8 bit/�G�C���/5*7�I�x�}�r��
	CALL	COMMAND				;8�줸��Ʀs�� �G�C�r 5*7
	
	MOV		A, #00001110B		;�}�[�ù�	p13
	CALL	COMMAND				;D=1, DDRAM ���  CURSOR ���  CURSOR�{�{
	
	MOV		A,#00000110B		;AC�۰�+1�A��ܹ�����
	CALL	COMMAND
	
	MOV		A, #00000001B		;CLAER DD RAM, DD RAM ������J�ťզr�X AC clear ��0
	CALL	COMMAND				;
	
	MOV		R2, #0FFH			;1.64US
	CALL	LCM_DELAY
	
	MOV		A, #11000000B			;�]�wAC ��m��00H; �]�wDDRAM ��}
	CALL	COMMAND

;��ܲ�0���T��(BELLO!XD!)
	MOV		MSG_LINE, #0
	CALL	SEND_TEXT
	CALL 	CLEAR_ALL_LINE
	
	
	MOV		A, #11000000B			;�]�wAC ��m��40H; �]�wDDRAM ��}
	CALL	COMMAND

	MOV		MSG_LINE, #8
	CALL	SEND_TEXT
	SETB	PSD_SETTING
	JMP		ROW1
	

	
;------------------------------SCAN-SCAN------------------------------

ROW1:
	MOV		P1, #7FH
	CALL	KEYB_DLY
	MOV		A, P1
	ANL		A, #0FH
	MOV		R4, #0
	CJNE	A, #0FH, COL1
ROW2:
	MOV		P1, #0BFH
	CALL	KEYB_DLY
	MOV		A, P1
	ANL		A, #0FH
	
	MOV		R4, #4
	CJNE	A, #0FH, COL1
ROW3:
	MOV		P1, #0DFH
	CALL	KEYB_DLY
	MOV		A, P1
	ANL		A, #0FH
	MOV		R4, #8
	CJNE	A, #0FH, COL1
ROW4:
	MOV		P1, #0EFH
	CALL	KEYB_DLY
	MOV		A, P1
	ANL		A, #0FH
	MOV		R4, #12
	CJNE	A, #0FH, COL1
	JMP 	COL1
;-------------------------------------
COL1:
	CJNE	A, #0EH, COL2
	MOV		R5, #0
	JMP		FUNC
COL2:
	CJNE	A, #0DH, COL3
	MOV		R5, #1
	JMP		FUNC
COL3:
	CJNE	A, #0BH, COL4
	MOV		R5, #2
	JMP		FUNC
COL4:
	CJNE	A, #07H, ROW1
	MOV		R5, #3
	JMP		FUNC	
;-----------------------------SCAN-SCAN------------------------------


;=============================DEAL WITH THE FUNCTION BUTTON(ENTER/CLEAR)===============
;���y���᪺�i�J�IFUNC
FUNC:

	JB 		PSD_SETTING, INPUT_PASSWORD
	MOV 	A, R5
	ADD		A, R4

	
	CJNE	R4, #8, FUNC1
;�B�z�ĥ|�C ��sDATA(I/ II/ III/ IV)

;R4 = 8     R5 =  0(8)  1(9)   2(ENTER)    3(CLEAR)
	CJNE 	R5, #2, FUNC2
;R4 = 8		R5 = 2(ENTER)
	JMP 	ENTER
	
FUNC1:
	CJNE	R4, #12, INPUT_NUMBER
;R4 = 12     R5 =  0(RESET_ADMIN)  1(RESET_NORMAL)   2()    3()
	CJNE	R5, #0, FUNC4
;R4 = 12     R5 =  0(RESET_ADMIN) 	
	JMP		RESET_ADMIN
	
	
	
FUNC2:
;R4 = 8     R5 =  0(8)  1(9)   3(CLEAR)
	CJNE	R5, #3, FUNC3 
;R4 = 8		R5 = 3(CLEAR)
	JMP		CLEAR
FUNC3:
;R4 = 8     R5 =  0(8)  1(9)
	JMP		INPUT_NUMBER	
FUNC4:
;R4 = 12     R5 = 1(RESET_NORMAL)   2()    3()
	CJNE	R5, #1, FUNC5
	
;R4 = 12     R5 = 1(RESET_NORMAL)
	JMP		RESET_NORMAL
FUNC5:
;R4 = 12     R5 = 2()    3()
	CJNE	R5, #2, ENTER
;R4 = 12     R5 = 2() 
	JMP		HIDE_PSD

	
;==============================STORE THE INPUT PASSWORD IN THE MEMORY	
INPUT_NUMBER:
;0-9
;��J����b44H 45H 46H 47H
;��������(JMP SHOW)	
;�ݭn���@�ӭp�ƭ�(���D�n��b�ĴX��)
	MOV 	A, BIT_COUNT
	JZ		NUM0
	DEC		A
	JZ		NUM1
	DEC		A
	JZ		NUM2
	JMP		NUM3


NUM0:
; BIT_COUNT = 0
	MOV		44H, A
	JMP 	SHOW
NUM1:
; BIT_COUNT = 1
	MOV		45H, A
	JMP 	SHOW
NUM2:
; BIT_COUNT = 2
	MOV		46H, A
	JMP 	SHOW
NUM3:
; BIT_COUNT = 3
	MOV		47H, A
	CLR		BIT_COUNT	
	JMP 	SHOW
	
;==============================STORE THE INPUT ID IN THE MEMORY	
INPUT_ID_NUMBER:
;0-9
;��J����b44H 45H 46H 47H
;��������(JMP SHOW)	
;�ݭn���@�ӭp�ƭ�(���D�n��b�ĴX��)
	CLR		HIDDEN_FLAG

	MOV 	A, BIT_COUNT
	JZ		ID_NUM0
	DEC		A
	JZ		ID_NUM1
	JMP		ID_NUM2
	

ID_NUM0:
; BIT_COUNT = 0
	MOV		48H, A
	JMP 	SHOW
ID_NUM1:
; BIT_COUNT = 1
	MOV		49H, A
	JMP 	SHOW
ID_NUM2:
; BIT_COUNT = 2
	MOV		50H, A
	CLR		BIT_COUNT

	JMP 	SHOW
	
	
INPUT_PASSWORD:
;0-9
;��J����b44H 45H 46H 47H
;��������(JMP SHOW)	
;�ݭn���@�ӭp�ƭ�(���D�n��b�ĴX��)

	MOV 	A, BIT_COUNT
	JZ		PSD_NUM0
	DEC		A
	JZ		PSD_NUM1
	DEC		A
	JZ		PSD_NUM2
	JMP		PSD_NUM3

PSD_NUM0:
; BIT_COUNT = 0
	MOV		40H, A
	JMP 	SHOW
PSD_NUM1:
; BIT_COUNT = 1
	MOV		41H, A
	JMP 	SHOW
PSD_NUM2:
; BIT_COUNT = 1
	MOV		42H, A
	JMP 	SHOW	
	
PSD_NUM3:
; BIT_COUNT = 2
	MOV		43H, A
	CLR		BIT_COUNT

	JMP 	SHOW
		
	
;==================================DEAL WITH THE FUNCTION BUTTON(ENTER/CLEAR)===========





CLEAR:
;CLEAR PREVIOUS BIT
;AC--
	
	MOV		A, #00010011B
	CALL	COMMAND
;��J�ťզr�� 20H
	MOV		A, #020H
	CALL	SENDDATA2

	MOV		A, #00010011B
	CALL	COMMAND
	DEC		BIT_COUNT
	
	LJMP	ROW1	



	
ENTER:
; ����M�w�]���K�X���S���@��
;�w�]����b40H 41H 42H 43H
;��J����b44H 45H 46H 47H
	;MOV		MSG_LINE, #7
	;CALL	SEND_TEXT
;�P�_�Ĥ@��
	MOV 	A, 40H
	SUBB	A, 44H
	JNZ		ALARM
;�P�_��2��
	MOV 	A, 41H
	SUBB	A, 45H
	JNZ		ALARM
;�P�_��3��
	MOV 	A, 42H
	SUBB	A, 46H
	JNZ		ALARM
;�P�_��4��
	MOV 	A, 43H
	SUBB	A, 47H
	JNZ		ALARM
;�K�X���T(���})
	SETB	LOCK
	
	CALL	CLEAR_ALL_LINE	
	
	
	MOV		A, #11000000B			;�]�wAC ��m��00H; �]�wDDRAM ��}*(��2����ܰT��:)
	CALL	COMMAND

	MOV		MSG_LINE, #1
	CALL	SEND_TEXT
;�i�J�ĤG��8051 �O�l�����_ (MOTOR ���}��)
	CALL 	LCM_DELAY
	JMP		ROW1
	
	

CLEAR_ALL_LINE:
	MOV		A, #00000001B			;CLAER DD RAM, DD RAM ������J�ťզr�X AC clear ��0
	CALL	COMMAND
	
RET
	
ALARM:
	MOV		A, #11000000B			;�]�wAC ��m��00H; �]�wDDRAM ��}*(��2����ܰT��:)
	CALL	COMMAND

	MOV		MSG_LINE, #4
	CALL	SEND_TEXT
	CALL	CLEAR_ALL_LINE
	
	MOV 	A, COUNT
	INC		A
	MOV		COUNT, A
	
	MOV		MSG_LINE, #5
	CALL	SEND_TEXT	
	CALL	CLEAR_ALL_LINE
	
	MOV		MSG_LINE, #2
	CALL	SEND_TEXT	

	
	MOV		COUNT, A
	CJNE	A, #3, SHOME
	
	CALL	CLEAR_ALL_LINE
	
	JMP		SUPER_LOCK

SHOME:
	LJMP 	ROW1
	

RESET_NORMAL:

	LJMP	INITIAL
	
	
RESET_ADMIN:


	LJMP	INITIAL
	
HIDE_PSD:
	
	CPL		HIDDEN_FLAG
	
	LJMP	ROW1
	
	
	
	
SUPER_LOCK:
;�ꦺ
;���LXXXX ������K
; MOV	A, BIGLOCK
; JNZ	SUPER_LOCK
	SETB	BIG_LOCK
	MOV		MSG_LINE, #6
	CALL	SEND_TEXT

	MOV		A, #11000000B
	CALL 	COMMAND
	CALL	CLEAR_ALL_LINE
	
	MOV		MSG_LINE, #7
	CALL	SEND_TEXT
	CALL	CLEAR_ALL_LINE	

	JMP  	INTERRUPT_INITIAL
INTERRUPT_INITIAL:
;=====INTITIAL INTERRUPT
	SETB	IT0
	SETB	EX0
	CLR		IE0
	SETB	PX0
	SETB	EA
	MOV		A, #0
	JMP		THEFT
	
THEFT:
;WAITING FOR INTERRUPT
; ���쵥�ݤ��_	

	JZ		SHOME
	JMP		THEFT	

INTERRUPT:
	CLR		A
	CLR		BIG_LOCK
	RETI

	
	
	
	
;==============================================================
SHOW:
	JB		HIDDEN_FLAG, HIDE_SHOW
	INC		BIT_COUNT
	MOV 	A, R5
	ADD		A, R4
	ADD 	A, #30H
	MOV 	54H, A
	JMP		LOOP
HIDE_SHOW:
	MOV		54H, #02AH
	JMP 	LOOP
	
LOOP:
	MOV 	A, 54H	
	CALL 	SENDDATA2
	JB		PSD_SETTING, MAIN1
	JMP		ROW1

;===============================================================
;MAIN

MAIN1:
	CLR		PSD_SETTING
	MOV		MSG_LINE, #3
	CALL	SEND_TEXT
	JMP		ROW2


;==========================
COMMAND:

	MOV		P2, A
	MOV		P3, #00000100B			;E=1 R/W = 0;RS = 0:SHOW LCM DISPLAY 
	MOV		R2, #2
	CALL	LCM_DELAY
	MOV		P3, #00000000B			;E=0 R/W = 0;RS = 0: END OF LCM DISPLAY
	MOV		R2, #2
	CALL	LCM_DELAY	
RET

SENDDATA2:
	MOV		P2, A
	MOV		P3, #00000101B			;E=1 R/W = 0;RS = 1:( E = 1 START LCM DISPLAY//// R/W = 0;RS = 1=>DD RAM & CG RAM ��Ƽg�J
	MOV		P3, #00000001B			;E=0 R/W = 0;RS = 1:( E = 0 END LCM DISPLAY ///// R/W = 0;RS = 1=>DD RAM & CG RAM ��Ƽg�J
	CALL 	LCM_DELAY
	MOV		P3, #00000000B			;E=0 R/W = 0;RS = 0
	MOV		R2, #250				;SET DELAY = 40.4us
	MOV		R3, #25
ldelay:
	CALL	LCM_DELAY
	DJNZ	R3, ldelay	
RET


SEND_TEXT:
;SEND TABLE_1~6 TO LCM
;��� TABLE
	MOV		A, #10000000B			;�]�wAC ��m��00H; �]�wDDRAM ��}*(�Ĥ@����ܰT��:)
	CALL	COMMAND

	MOV		A, MSG_LINE
	JZ		TEXT_0
	DEC		A 
	JZ		TEXT_1
	DEC		A
	JZ		TEXT_2
	DEC		A
	JZ		TEXT_3
	DEC		A
	JZ		TEXT_4
	DEC		A
	JZ		TEXT_5
	DEC 	A
	JZ		TEXT_6
	DEC		A
	JZ		TEXT_7
	DEC		A
	JZ		TEXT_8
	
	JNZ		TEXT_9
	
TEXT_0:
	MOV 	DPTR, #TABLE_0
	JMP		SHOW_MSG	
TEXT_1:
	MOV 	DPTR, #TABLE_1
	JMP		SHOW_MSG
TEXT_2:
	MOV 	DPTR, #TABLE_2
	JMP		SHOW_MSG	
TEXT_3:
	MOV 	DPTR, #TABLE_3
	JMP		SHOW_MSG
TEXT_4:
	MOV 	DPTR, #TABLE_4
	JMP		SHOW_MSG	
TEXT_5:
	MOV 	DPTR, #TABLE_5
	JMP		SHOW_MSG
TEXT_6:
	MOV 	DPTR, #TABLE_6
	JMP		SHOW_MSG
TEXT_7:
	MOV 	DPTR, #TABLE_7
	JMP		SHOW_MSG
TEXT_8:
	MOV 	DPTR, #TABLE_8
	JMP		SHOW_MSG
TEXT_9:
	MOV 	DPTR, #TABLE_9
	JMP		SHOW_MSG	
	
SHOW_MSG:

	CLR		A					; �]�wA(�d���) ��l�� = 0
	MOVC	A, @A+DPTR		; �إ߬d�� �Ĥ@�����(DPTR=0)	: A = 0's ASCII CODE �ĤG�����(DPTR=1): A = 1's ASCII CODE  �ĤT�����(DPTR=2): A = 1 �ĥ|�����: A = 1 ......
	JZ		HOME				; ����Ÿ�\\if (A == 0) JMP 	
	CALL 	SENDDATA2		; 
	INC		DPTR
	JMP		SHOW_MSG
HOME:
	NOP
RET
	
	
;========================R6, R7 IS USED BY DELAY TIME
;========================DELAY FOR KEYBOARD====================
KEYB_DELAY:
    MOV   R7,#100  		
KEYB_DELAY1:
    MOV   R6,#150  
KEYB_DELAY2:
    DJNZ  R6,KEYB_DELAY2  
    DJNZ  R7,KEYB_DELAY1  
RET

KEYB_DLY:
    MOV   R7,#0FFH 
KEYB_DLY1:
    MOV   R6,#0FFH
	NOP
KEYB_DLY2:
	NOP
    DJNZ  R6,KEYB_DLY2
	NOP
    DJNZ  R7,KEYB_DLY1 
RET
	
	
;==========================DELAY FOR LEM==========================	
LCM_DELAY:						;20.2us
	MOV	R6, #20
LCM_DELAY1:
	MOV	R7, #5
LCM_DELAY2:
	DJNZ	R7, LCM_DELAY2
	DJNZ	R6, lCM_DELAY1
	DJNZ	R2, LCM_DELAY
RET
TABLE_0:
	DB 	" HELLO!", 0	
TABLE_1:
	DB	" Welcome Home!!", 0
TABLE_2:
	DB 	" ID:", 0
TABLE_3:
	DB 	" Password:", 0
TABLE_4:	
	DB	" PSD INCORRECT", 0
TABLE_5:	
	DB	" TRY AGAIN", 0	
TABLE_6:	
	DB	" U R PROHIBIT", 0
TABLE_7:
	DB 	" WAIT 4 LOCKSMITH", 0
TABLE_8:
	DB 	" SET PSD:", 0
TABLE_9:
	DB 	" SET ID:", 0	
	
	
END


