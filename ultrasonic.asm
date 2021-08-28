;Debounce按了之後超音波隔一段時間就會發射方波訊號(Echo low->high)
;接收器收到之後(Echo high->low)





	ORG	00H
	JMP	INITIAL
	ORG	0BH		;TIMER0/計數器 T0 INTERRUPT  VECTOR
	JMP	SSET
	ORG	13H		;外部 INT1 中斷 INTERRUPT  VECTOR
	JMP	GET	
	ORG	50H
	
	
	
	
	;================================只有在一開始時初始化數值跑過一次=====================
INITIAL:
	SETB 	IT1             ;IT1 interrupt 1 type control bit =1 ->falling edge triggered for 
				;interrupt1
	MOV	IP,#00000100B   ;Interrupt Priority Register(set INT1 interrupt priority)
				;INT1是外部中斷，P3.3
	MOV	IE,#10000110B   ;Interrupt Enable Register P.239
	CLR 	P3.0            

 	CLR 	TF0		;timer0 overflow flag
	CLR	TF1		;timer1 overflow flag TF1=0 , OVERFLOW=0
	MOV	TMOD,#11100010B	;設定TIMER0為MODE2  COUNTER1為MODE2
	MOV	TH0,#227		;counter高位為227
	MOV	TL0,#227		;counter低位為227
	SETB	TR0		;開始計時    P.255 10-18

	MOV	TH1,#0		;Counter高位=0			
	MOV	TL1,#0		;Counter低位=0
	SETB	TR1		;開始計數
	CLR		P3.1
	MOV		R5, #050;
	
	
	
	;============================中斷未發生，來跑無窮迴圈============================
SHOW:
	MOV	A,R2		;百位數 
	ADD	A,#0D0H		;前4bits顯示百位，後4bits為數值
	MOV	P2,A		;七段顯示器百位
	CALL	DELAY		
	MOV	A,R1		;十位數
	ADD	A,#0B0H	    	;前bits顯示十位，後4bits為數值
	MOV	P2,A		;七段顯示器十位
	CALL	DELAY
	MOV	A,R0		;個位數
	ADD	A,#70H		;前四bits顯示個位，後4bits為數值
	MOV	P2,A		;在七段顯示器個位
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
	;=================================中斷未發生==========================
	
	
	;=================================以下為中斷發生時，會跑一次=================
SSET:
	CPL 	P3.0		 ;接到超音波，每進入中斷一次，P1.0腳位就做一次 Compliment輸出
	CLR 	TF0
	RETI
GET:	
	MOV	A,TL1		;將counter的值傳給A
	MOV	B,#100		;100存入B
	DIV	AB		;A除B
	MOV	R2,A		;A的數值傳給R2 (百位數商數)
	MOV	A,B		;餘數B傳給A
	MOV	B,#10		;10存入B	
	DIV	AB		;A除B
	MOV	R1,A		;A的數值傳給R1(十位數商數)
	MOV	R0,B		;餘數B傳給R0(個位數字)
INITIALTC:
	CLR	TF1		;overflow=0
	MOV	TH1,#0  					
	MOV	TL1,#0		
	RETI		       	
	;=============================停止中斷，回去無窮迴圈中顯示數值============
	
MOTOR:

	MOV	A, #00010001B
	MOV	R4, #0
MOTOR1:
	MOV	P1, A
	CALL	motor_DELAY
	
	RR		A					;右旋一位
	INC		R4					;計數器加一
	CJNE	R4, #130, MOTOR1		;判斷A的位移是否作了130次(90度)	
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
    	MOV   R7,#0FFH  		;R5為控制delay最外層迴圈的變數
				;R6為控制delay中層迴圈的變數
motor_DELAY1:
    	MOV   R6,#0FFH    		;R7為控制delay內層迴圈的變數
motor_DELAY2:
    	DJNZ  R6,motor_DELAY2  		;判斷R7是否為0否則跳到DELAY3
    	DJNZ  R7,motor_DELAY1  		;判斷67是否為0否則跳到DELAY2
	RET	
	
	
	
	END
