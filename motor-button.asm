;************************************
;Lab08 ���D
;����ؼСG�Шϥ� 1 �ۿE�ϡA�������F�������� 45 �סA�A�f������ 90 �סA�Q�ιq�u�j�b���F�Y�W�Ψ�L�Хܤ�k�A���U�Хi�H�ݲM�����F����ʤ�V�Ψ��סC
;�w�鱵�u�GP1.0~P1.7������L�Ҳ�JP03_1~JP03_8�AP2.0~P2.3�̧Ǳ���IN_A~IN_D
;�Ƶ��G
;Stepper motor 
;Stride Angle : 5.625degree/64step
;Frequency : 100Hz
;************************************

;STATUS = 1(DOOR OPEN)
;STATUS = 0(DOOR CLOSE)
;LOCK = 0(UNLOCK)
;LOCK = 1(LOCKED)
;BIGLOCK = 0()
;BIGLOCK = 1(SUPER LOCKED)
	LOCK EQU P3.0
	WAKE_UP EQU P3.4
    

  	ORG   0000H	;�i�D�sĶ���{���X�q0000H�}�l��
  	AJMP  INIT	;����INIT���a�����(�׶}���_�V�q��})
   	ORG   0050H	;�i�D�sĶ���{���X�q0050H�}�l��
INIT:
	MOV	A,#011H
	CLR	LOCK
	SETB WAKE_UP	
	JMP	STATE
	
STATE:
	JB LOCK, OPEN
	JMP	STATE

OPEN:
	MOV	R0,#128	;�@����45��
RIGHT:
	RR	A   	;�����F���ɰw����
	MOV	P1,A
	MOV	R5,#1
	CALL	DELAY
	DJNZ	R0,RIGHT;�O�_�w�g��45��

	MOV	R5,#0FFH	;����ɥ����@�q�ɶ�
	CALL	DELAY
	MOV	R5,#0FFH	;����ɥ����@�q�ɶ�
	CALL	DELAY
	
CLOSE:
	MOV	R0,#128	;�@����90��
LEFT:
	RL	A  	;�����F�f�ɰw����
	MOV	P1,A
	MOV	R5,#1
	CALL	DELAY

	DJNZ	R0,LEFT	;�O�_�w�g��90��

	MOV	R5,#100	;����ɥ����@�q�ɶ�
	CALL	DELAY
	CLR     LOCK
	JMP 	STATE	;���^START�A���s����

DELAY:
	MOV	R6,#100
DELAY1:
	MOV	R7,#100
DELAY2:

	DJNZ	R7,DELAY2
	DJNZ	R6,DELAY1
	DJNZ	R5,DELAY
	RET

end
