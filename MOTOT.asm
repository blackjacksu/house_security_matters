ORG	0000H
	JMP		START1;
	ORG	0050H

START1:

	MOV	A, #00010001B
	MOV	R1, #0
MAIN1:
	MOV	P1, A
	CALL	DELAY
	
	RR		A					;右旋一位
	INC		R1					;計數器加一
	CJNE	R1, #130, MAIN1		;判斷A的位移是否作了130次(90度)


START2:

	MOV	A, #00010001B
	MOV	R1, #0
MAIN2:
	MOV	P1, A
	CALL	DELAY
	
	RL		A					;左旋一位
	INC		R1					;計數器加一
	CJNE	R1, #60, MAIN2		;判斷A的位移是否作了60次(45度)

	JMP		START1

DELAY:
    	MOV   R7,#0FFH  		;R5為控制delay最外層迴圈的變數
				;R6為控制delay中層迴圈的變數
DELAY1:
    	MOV   R6,#0FFH    		;R7為控制delay內層迴圈的變數
DELAY2:
    	DJNZ  R6,DELAY2  		;判斷R7是否為0否則跳到DELAY3
    	DJNZ  R7,DELAY1  		;判斷67是否為0否則跳到DELAY2
	RET
END
