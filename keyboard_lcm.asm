	LOCK EQU P3.3
;LOCK = 0(OPEN) LOCK = 1(LOCKED)
	BIG_LOCK EQU P3.4
;BIGLOCK = 0(OPEN) BIGLOCK = 1(NEED THE ADMIN)(LOCKED)
	WAKE_UP EQU P3.5
	
	BIT_COUNT EQU 19H
;計算位數
	COUNT EQU 20H
;計算錯了幾次

	MSG_LINE EQU 21H
	MSG_ROW	EQU 22H
;確定哪一條訊息要輸出

	HIDDEN_FLAG EQU 23H.0
;選擇要不要隱藏密碼輸出
	ID_SETTING EQU	23H.1
;ID設定模式0 =>一班輸入 1=>設定模式
	PSD_SETTING EQU	23H.2
;PSD設定模式0 =>一班輸入 1=>設定模式
 
ORG   	0000H						;告訴編譯器程式碼從0000H開始放
AJMP  	SLEEP					;跳到MAIN的地方執行(避開中斷向量位址)
ORG		0003H		
AJMP 	INTERRUPT
ORG   	0050H						;告訴編譯器程式碼從0050H開始放

SLEEP:

	;SETB	WAKE_UP
	;MOV		A, P3
	;CJNE	A, #00100000B, SLEEP
	JMP		INITIAL


INITIAL:							;初始化數值
	MOV 	COUNT, #0
	MOV 	R7, #0
	MOV		R6, #0
	MOV		R5, #0
	MOV 	R4, #0
	MOV		R3, #0
	MOV		R2, #0	
	MOV		R1, #0
	MOV		R0, #0	
;====預設密碼0123
	MOV 	40H, #0
	MOV		41H, #0
	MOV		42H, #0
	MOV		43H, #0
;輸入的DATA	
	MOV 	44H, #0
	MOV		45H, #0
	MOV		46H, #0
	MOV		47H, #0	
;輸入的ID
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
;一開始先顯示 HELLO

								;決定DELAY時間
	MOV		R2, #250
	CALL	LCM_DELAY
	
	MOV 	A, #00111011B		;功能設定:8 bit/二列顯示/5*7點矩陣字型
	CALL	COMMAND				;8位元資料存取 二列字 5*7
	
	MOV		A, #00001110B		;開觀螢幕	p13
	CALL	COMMAND				;D=1, DDRAM 顯示  CURSOR 顯示  CURSOR閃爍
	
	MOV		A,#00000110B		;AC自動+1，顯示幕不動
	CALL	COMMAND
	
	MOV		A, #00000001B		;CLAER DD RAM, DD RAM 全部放入空白字碼 AC clear 為0
	CALL	COMMAND				;
	
	MOV		R2, #0FFH			;1.64US
	CALL	LCM_DELAY
	
	MOV		A, #11000000B			;設定AC 位置為00H; 設定DDRAM 位址
	CALL	COMMAND

;顯示第0條訊息(BELLO!XD!)
	MOV		MSG_LINE, #0
	CALL	SEND_TEXT
	CALL 	CLEAR_ALL_LINE
	
	
	MOV		A, #11000000B			;設定AC 位置為40H; 設定DDRAM 位址
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
;掃描之後的進入點FUNC
FUNC:

	JB 		PSD_SETTING, INPUT_PASSWORD
	MOV 	A, R5
	ADD		A, R4

	
	CJNE	R4, #8, FUNC1
;處理第四列 更新DATA(I/ II/ III/ IV)

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
;輸入的放在44H 45H 46H 47H
;先放後顯示(JMP SHOW)	
;需要有一個計數值(知道要放在第幾位)
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
;輸入的放在44H 45H 46H 47H
;先放後顯示(JMP SHOW)	
;需要有一個計數值(知道要放在第幾位)
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
;輸入的放在44H 45H 46H 47H
;先放後顯示(JMP SHOW)	
;需要有一個計數值(知道要放在第幾位)

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
;放入空白字元 20H
	MOV		A, #020H
	CALL	SENDDATA2

	MOV		A, #00010011B
	CALL	COMMAND
	DEC		BIT_COUNT
	
	LJMP	ROW1	



	
ENTER:
; 比較和預設的密碼有沒有一樣
;預設的放在40H 41H 42H 43H
;輸入的放在44H 45H 46H 47H
	;MOV		MSG_LINE, #7
	;CALL	SEND_TEXT
;判斷第一位
	MOV 	A, 40H
	SUBB	A, 44H
	JNZ		ALARM
;判斷第2位
	MOV 	A, 41H
	SUBB	A, 45H
	JNZ		ALARM
;判斷第3位
	MOV 	A, 42H
	SUBB	A, 46H
	JNZ		ALARM
;判斷第4位
	MOV 	A, 43H
	SUBB	A, 47H
	JNZ		ALARM
;密碼正確(打開)
	SETB	LOCK
	
	CALL	CLEAR_ALL_LINE	
	
	
	MOV		A, #11000000B			;設定AC 位置為00H; 設定DDRAM 位址*(第2行顯示訊息:)
	CALL	COMMAND

	MOV		MSG_LINE, #1
	CALL	SEND_TEXT
;進入第二塊8051 板子的中斷 (MOTOR 打開們)
	CALL 	LCM_DELAY
	JMP		ROW1
	
	

CLEAR_ALL_LINE:
	MOV		A, #00000001B			;CLAER DD RAM, DD RAM 全部放入空白字碼 AC clear 為0
	CALL	COMMAND
	
RET
	
ALARM:
	MOV		A, #11000000B			;設定AC 位置為00H; 設定DDRAM 位址*(第2行顯示訊息:)
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
;鎖死
;跳過XXXX 等待鎖匠
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
; 跳到等待中斷	

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
	MOV		P3, #00000101B			;E=1 R/W = 0;RS = 1:( E = 1 START LCM DISPLAY//// R/W = 0;RS = 1=>DD RAM & CG RAM 資料寫入
	MOV		P3, #00000001B			;E=0 R/W = 0;RS = 1:( E = 0 END LCM DISPLAY ///// R/W = 0;RS = 1=>DD RAM & CG RAM 資料寫入
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
;選擇 TABLE
	MOV		A, #10000000B			;設定AC 位置為00H; 設定DDRAM 位址*(第一行顯示訊息:)
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

	CLR		A					; 設定A(查表用) 初始值 = 0
	MOVC	A, @A+DPTR		; 建立查表 第一次抓值(DPTR=0)	: A = 0's ASCII CODE 第二次抓值(DPTR=1): A = 1's ASCII CODE  第三次抓值(DPTR=2): A = 1 第四次抓值: A = 1 ......
	JZ		HOME				; 中止符號\\if (A == 0) JMP 	
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


