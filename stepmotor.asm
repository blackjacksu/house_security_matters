ORG	0000H
	JMP		START1;
	ORG	0050H

START1:

	MOV	A, #00010001B
	MOV	R1, #0
MAIN1:
	MOV	P1, A
	CALL	DELAY
	
	RR		A					;�k�ۤ@��
	INC		R1					;�p�ƾ��[�@
	CJNE	R1, #130, MAIN1		;�P�_A���첾�O�_�@�F130��(90��)


START2:

	MOV	A, #00010001B
	MOV	R1, #0
MAIN2:
	MOV	P1, A
	CALL	DELAY
	
	RL		A					;���ۤ@��
	INC		R1					;�p�ƾ��[�@
	CJNE	R1, #60, MAIN2		;�P�_A���첾�O�_�@�F60��(45��)

	JMP		START1

DELAY:
    	MOV   R7,#0FFH  		;R5������delay�̥~�h�j�骺�ܼ�
				;R6������delay���h�j�骺�ܼ�
DELAY1:
    	MOV   R6,#0FFH    		;R7������delay���h�j�骺�ܼ�
DELAY2:
    	DJNZ  R6,DELAY2  		;�P�_R7�O�_��0�_�h����DELAY3
    	DJNZ  R7,DELAY1  		;�P�_67�O�_��0�_�h����DELAY2
	RET
END
