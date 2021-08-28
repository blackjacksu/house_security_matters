;Debounce���F����W���i�j�@�q�ɶ��N�|�o�g��i�T��(Echo low->high)
;���������줧��(Echo high->low)





	ORG	00H
	JMP	INITIAL
	ORG	0BH		;TIMER0/�p�ƾ� T0 INTERRUPT  VECTOR
	JMP	SSET
	ORG	13H		;�~�� INT1 ���_ INTERRUPT  VECTOR
	JMP	GET	
	ORG	50H
	
	
	
	
	;================================�u���b�@�}�l�ɪ�l�Ƽƭȶ]�L�@��=====================
INITIAL:
	SETB 	IT1             ;IT1 interrupt 1 type control bit =1 ->falling edge triggered for 
				;interrupt1
	MOV	IP,#00000100B   ;Interrupt Priority Register(set INT1 interrupt priority)
				;INT1�O�~�����_�AP3.3
	MOV	IE,#10000110B   ;Interrupt Enable Register P.239
	CLR 	P3.0            

 	CLR 	TF0		;timer0 overflow flag
	CLR	TF1		;timer1 overflow flag TF1=0 , OVERFLOW=0
	MOV	TMOD,#11100010B	;�]�wTIMER0��MODE2  COUNTER1��MODE2
	MOV	TH0,#227		;counter���쬰227
	MOV	TL0,#227		;counter�C�쬰227
	SETB	TR0		;�}�l�p��    P.255 10-18

	MOV	TH1,#0		;Counter����=0			
	MOV	TL1,#0		;Counter�C��=0
	SETB	TR1		;�}�l�p��
	CLR		P3.1
	MOV		R5, #050;
	
	
	
	;============================���_���o�͡A�Ӷ]�L�a�j��============================
SHOW:
	MOV	A,R2		;�ʦ�� 
	ADD	A,#0D0H		;�e4bits��ܦʦ�A��4bits���ƭ�
	MOV	P2,A		;�C�q��ܾ��ʦ�
	CALL	DELAY		
	MOV	A,R1		;�Q���
	ADD	A,#0B0H	    	;�ebits��ܤQ��A��4bits���ƭ�
	MOV	P2,A		;�C�q��ܾ��Q��
	CALL	DELAY
	MOV	A,R0		;�Ӧ��
	ADD	A,#70H		;�e�|bits��ܭӦ�A��4bits���ƭ�
	MOV	P2,A		;�b�C�q��ܾ��Ӧ�
	CALL	DELAY
	
	DJNZ 	R5, SHOW;
;A=R1+R2==0 OPEN DOOR
	MOV		A, R2
	ADD     A, R1
	JZ		MOTOR
	
	
	SETB 	P3.1
	CALL 	DELAY
	CLR 	P3.1
	CALL	DELAY
	MOV		R5, #050;
	JMP	SHOW
	;=================================���_���o��==========================
	
	
	;=================================�H�U�����_�o�ͮɡA�|�]�@��=================
SSET:
	CPL 	P3.0		 ;����W���i�A�C�i�J���_�@���AP1.0�}��N���@�� Compliment��X
	CLR 	TF0
	RETI
GET:	
	MOV	A,TL1		;�Ncounter���ȶǵ�A
	MOV	B,#100		;100�s�JB
	DIV	AB		;A��B
	MOV	R2,A		;A���ƭȶǵ�R2 (�ʦ�ưӼ�)
	MOV	A,B		;�l��B�ǵ�A
	MOV	B,#10		;10�s�JB	
	DIV	AB		;A��B
	MOV	R1,A		;A���ƭȶǵ�R1(�Q��ưӼ�)
	MOV	R0,B		;�l��B�ǵ�R0(�Ӧ�Ʀr)
INITIALTC:
	CLR	TF1		;overflow=0
	MOV	TH1,#0  					
	MOV	TL1,#0		
	RETI		       	
	;=============================����_�A�^�h�L�a�j�餤��ܼƭ�============
	
MOTOR:

	MOV	A, #00010001B
	MOV	R4, #0
MOTOR1:
	MOV	P1, A
	CALL	motor_DELAY
	
	RR		A					;�k�ۤ@��
	INC		R4					;�p�ƾ��[�@
	CJNE	R4, #130, MOTOR1		;�P�_A���첾�O�_�@�F130��(90��)	
	JMP		SHOW
	
	
	
	
	
DELAY:
	MOV	R6,#20		;DELAY
DELAY1:
	MOV	R7,#30
DELAY2:
	DJNZ	R7,DELAY2
	DJNZ	R6,DELAY1
	RET
	
	
motor_DELAY:
    	MOV   R7,#0FFH  		;R5������delay�̥~�h�j�骺�ܼ�
				;R6������delay���h�j�骺�ܼ�
motor_DELAY1:
    	MOV   R6,#0FFH    		;R7������delay���h�j�骺�ܼ�
motor_DELAY2:
    	DJNZ  R6,motor_DELAY2  		;�P�_R7�O�_��0�_�h����DELAY3
    	DJNZ  R7,motor_DELAY1  		;�P�_67�O�_��0�_�h����DELAY2
	RET	
	
	
	
	END
