;************************************
;Lab08 基本題
;實驗目標：請使用 1 相激磁，先讓馬達順時鐘轉 45 度，再逆時鐘轉 90 度，利用電線綁在馬達頭上或其他標示方法，讓助教可以看清楚馬達的轉動方向及角度。
;硬體接線：P1.0~P1.7接至鍵盤模組JP03_1~JP03_8，P2.0~P2.3依序接至IN_A~IN_D
;備註：
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
    

  	ORG   0000H	;告訴編譯器程式碼從0000H開始放
  	AJMP  INIT	;跳到INIT的地方執行(避開中斷向量位址)
   	ORG   0050H	;告訴編譯器程式碼從0050H開始放
INIT:
	MOV	A,#011H
	CLR	LOCK
	SETB WAKE_UP	
	JMP	STATE
	
STATE:
	JB LOCK, OPEN
	JMP	STATE

OPEN:
	MOV	R0,#128	;共需轉45度
RIGHT:
	RR	A   	;讓馬達順時針旋轉
	MOV	P1,A
	MOV	R5,#1
	CALL	DELAY
	DJNZ	R0,RIGHT;是否已經轉45度

	MOV	R5,#0FFH	;反轉時先停一段時間
	CALL	DELAY
	MOV	R5,#0FFH	;反轉時先停一段時間
	CALL	DELAY
	
CLOSE:
	MOV	R0,#128	;共需轉90度
LEFT:
	RL	A  	;讓馬達逆時針旋轉
	MOV	P1,A
	MOV	R5,#1
	CALL	DELAY

	DJNZ	R0,LEFT	;是否已經轉90度

	MOV	R5,#100	;反轉時先停一段時間
	CALL	DELAY
	CLR     LOCK
	JMP 	STATE	;跳回START，重新執行

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
