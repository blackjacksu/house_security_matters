ORG		00H
	JMP		MAIN
	ORG		50H
MAIN:					;��l�Ƽƭ�
	MOV		R3, #0
	MOV		R2, #0	
	MOV		R1, #0
	MOV		R0, #0	
	CLR		55H
	
	CLR		53H			;�d���FLAG=0
	CLR		52H			;�ʦ��FLAG
	CLR		51H			;�Q���FLAG
	CLR		50H			;�Ӧ��FLAG
;------------------------------SCAN-SCAN------------------------------
ROW1:
	MOV		P1, #7FH
	CALL	DLY
	MOV		A, P1
	ANL		A, #0FH
	MOV		R4, #0
	CJNE	A, #0FH, COL1
ROW2:
	MOV		P1, #0BFH
	CALL	DLY
	MOV		A, P1
	ANL		A, #0FH
	MOV		R4, #4
	CJNE	A, #0FH, COL1
ROW3:
	MOV		P1, #0DFH
	CALL	DLY
	MOV		A, P1
	ANL		A, #0FH
	MOV		R4, #8
	CJNE	A, #0FH, COL1
ROW4:
	MOV		P1, #0EFH
	CALL	DLY
	MOV		A, P1
	ANL		A, #0FH
	MOV		R4, #12
	CJNE	A, #0FH, COL1 
;-------------------------------------
	JMP 	START3
;-------------------------------------
COL1:
	CJNE	A, #0EH, COL2
	MOV		R5, #0
	JMP		SHOW
COL2:
	CJNE	A, #0DH, COL3
	MOV		R5, #1
	JMP		SHOW
COL3:
	CJNE	A, #0BH, COL4
	MOV		R5, #2
	JMP		SHOW
COL4:
	CJNE	A, #07H, ROW1
	MOV		R5, #3
	JMP		SHOW	
;-----------------------------SCAN-SCAN------------------------------
;-----------------------------KEYBOARD INPUT------------------------------
SHOW:
	CJNE	R4, #12, ENTER1			;�O�_���ĥ|�C
	JMP	SHOW0
ENTER1:
	MOV 	A, R4
	ADD	A, R5
	CJNE 	A, #11, CONFIRM1	
	CLR	55H				;ENTER:���T�{���X�оɤU
	JMP	SHOW5
	
CONFIRM1:				;���T�{���X�оԥ�
	CJNE	A, #10, SHOW5
	SETB 	55H
	
	
	JMP		SHOW5;
SHOW0:
;�B�z�ĥ|�C ��sDATA(I/ II/ III/ IV)
;R4 = 12       R5 =  0  1   2    3
	CJNE	R5, #0, SHOW1
	
	SETB	53H
	JMP  	START3
	
SHOW1:
	CJNE 	R5, #1, SHOW2
	SETB	52H
	
	JMP		START3
	
SHOW2:
	CJNE 	R5, #2, SHOW3
	
	SETB 	51H
	JMP		START3
	
SHOW3:
	CJNE	R5, #3, START3
	
	SETB 	50H
	JMP		START3
;-----------------------------------�B�z�ĥ|�C���
	
	
SHOW5:							;���U1 ___ ���U2
	
	JB		53H, CLR1000		;�P�_�d���flag�O�_�|�_=>�O���ܥhCLR1000�M��
	JB		52H, CLR100
	JB		51H, CLR10
	JB		50H, CLR1
	JB		55H, START3			;�Y�O���� ���L�첾
	MOV 	A, R4
	ADD		A, R5
	CJNE		A, #11, MAIN2
	JMP		ROW1
MAIN2:
;Shift------------------;�p�G���S����Хܯ��ۡA�~�]�첾
	MOV		B, R2				;0	   0   0
	MOV		R3, B
	
	MOV		B, R1				;0	   0   0
	MOV		R2, B
	MOV		B, R0				;0     0   1
	MOV		R1, B
	
	MOV		R0, A				;1     1   2
	JMP		START3
	
;---------------------------------�^�_��Ъ����A
CLR1000:
	CLR 	53H
	MOV		R3, A
	JMP 	START3
	
CLR100:
	CLR 	52H
	MOV		R2, A
	JMP 	START3
CLR10:
	CLR 	51H
	MOV		R1, A
	JMP 	START3
CLR1:
	CLR 	50H
	MOV		R0, A
	JMP 	START3
;---------------------------------�^�_��Ъ����A
	
	
START3:	 						;��ܤd���
	JB 		53H, START2
	MOV		A, R3
	MOV		DPTR, #TABLE3
	MOVC	A, @A+DPTR
	MOV		P2, A
	CALL	DELAY
START2:	 						;��ܦʦ��
	
	JB 		52H, START1
	MOV		A, R2
	MOV		DPTR, #TABLE2
	MOVC	A, @A+DPTR
	MOV		P2, A
	CALL	DELAY
	
	
START1:	 						;��ܤQ���
	
	JB 		51H, START0
	MOV		A, R1
	MOV		DPTR, #TABLE1
	MOVC	A, @A+DPTR
	MOV		P2, A
	CALL	DELAY
	
START0:	 						;��ܭӦ��
	
	JB		50H, HELP			;TARGET OUT OF RANGE??????????
	MOV		A, R0
	MOV		DPTR, #TABLE0
	MOVC	A, @ A+DPTR
	MOV		P2, A
	CALL	DELAY
	JMP		ROW1
	
HELP:
	JMP		ROW1
TABLE0:
	DB	70H,71H,72H,73H
	DB	74H,75H,76H,77H
	DB	78H,79H
TABLE1:
	DB	0B0H,0B1H,0B2H,0B3H
	DB	0B4H,0B5H,0B6H,0B7H
	DB	0B8H,0B9H
TABLE2:
	DB	0D0H,0D1H,0D2H,0D3H
	DB	0D4H,0D5H,0D6H,0D7H
	DB	0D8H,0D9H
TABLE3:
	DB	0E0H,0E1H,0E2H,0E3H
	DB	0E4H,0E5H,0E6H,0E7H
	DB	0E8H,0E9H
	
DELAY:
    MOV   R7,#100  		;R5������delay�̥~�h�j�骺�ܼ�
				;R6������delay���h�j�骺�ܼ�
DELAY1:
    MOV   R6,#150    		;R7������delay���h�j�骺�ܼ�
DELAY2:
    DJNZ  R6,DELAY2  		;�P�_R7�O�_��0�_�h����DELAY3
    DJNZ  R7,DELAY1  		;�P�_67�O�_��0�_�h����DELAY2
RET
DLY:
    MOV   R7,#0FFH  		;R5������delay�̥~�h�j�骺�ܼ�
				;R6������delay���h�j�骺�ܼ�
DLY1:
    MOV   R6,#0FFH	;R7������delay���h�j�骺�ܼ�
	NOP
DLY2:
	NOP
    DJNZ  R6,DLY2	;�P�_R7�O�_��0�_�h����DELAY3
	NOP
    DJNZ  R7,DLY1  		;�P�_67�O�_��0�_�h����DELAY2
	RET
END
