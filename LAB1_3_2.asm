
		.EQU		LCDPORT			= PORTA		; SET SIGNAL PORT REG TO PORTA
`		.EQU		LCDPORTDIR		= DDRA		; SET SIGNAL PORT DIR REG TO PORTA
		.EQU		LCDPORTPIN		= PINA		; SET CLEAR SIGNAL PORT PIN REG TO PORTA
		.EQU		LCD_RS			= PINA0
		.EQU		LCD_RW			= PINA1
		.EQU		LCD_EN			= PINA2
		.EQU		LCD_D7			= PINA7
		.EQU		LCD_D6			= PINA6
		.EQU		LCD_D5			= PINA5
		.EQU		LCD_D4			= PINA4
		.EQU		NULL			= $00		;ASCII END
		
		.EQU		OUTPUT_DDR		= DDRB	
		.EQU		OUTPUT_PORT	= PORTB		
		
		.EQU		INPUT_DDR		= DDRD	
		.EQU		INPUT_PORT		= PORTD	
		.EQU		INPUT_PIN		= PIND	
		.ORG		0X00
		RJMP		START
		.ORG		0X40

START:	RCALL		LCD_Init
		LDI			R16,			0XFF
		OUT			OUTPUT_DDR,	R16

		LDI			R16,			0X00
		OUT			INPUT_DDR,		R16
		LDI			R16,			0XFF
		OUT			INPUT_PORT,		R16
		
		LDI			ZH,				HIGH(TAB<<1)		
		LDI			ZL,				LOW(TAB<<1)
LINE1:	LPM			R16,			Z+					
		CPI			R16,			NULL					
		BREQ		TT					
		RCALL		LCD_Send_Data				
		RJMP		LINE1					
TT:
		LDI			R25,			0X00
TT2:		
		SBIC		PIND,			0
		RJMP		TT2
		RCALL		ANTI
		INC			R25
		OUT			OUTPUT_PORT,	R25
		
		
		LDI			R16,		$8A
		RCALL		LCD_Send_Command
		MOV			R20,		R25
		RCALL		DIV8_8
		MOV			R16,		R22
		RCALL		LCD_Send_Data

		LDI			R16,		$89
		RCALL		LCD_Send_Command
	
		RCALL		DIV8_8
		MOV			R16,		R22
		RCALL		LCD_Send_Data

		LDI			R16,		$88
		RCALL		LCD_Send_Command
	
		RCALL		DIV8_8
		MOV			R16,		R22
		RCALL		LCD_Send_Data

		RJMP		TT2



;__________________________________________________________________
; SUBROUTINE TO SEND COMMAND TO LCD
;COMMAND CODE IN R16
;LCD_D7..LCD_D4 CONNECT TO PA7..PA4
;LCD_RS CONNECT TO PA0
;LCD_RW CONNECT TO PA1-
;LCD_EN CONNECT TO PA2
LCD_SEND_COMMAND:
		PUSH		R17
		CALL		LCD_WAIT_BUSY	; CHECK IF LCD IS BUSY 
		MOV			R17,			R16		;SAVE THE COMMAND				
		 ; SET RS LOW TO SELECT COMMAND REGISTER
		; SET RW LOW TO WRITE TO LCD
		ANDI		R17,			0XF0
    ; SEND COMMAND TO LCD
		OUT			LCDPORT,		R17  
		NOP
		NOP
    ; PULSE ENABLE PIN
		SBI			LCDPORT,		LCD_EN
		NOP
		NOP
		CBI			LCDPORT,		LCD_EN
		SWAP		R16
		ANDI		R16,			0XF0
    ; SEND COMMAND TO LCD
		OUT			LCDPORT,		R16   
    ; PULSE ENABLE PIN
		SBI			LCDPORT,		LCD_EN
		NOP
		NOP
		CBI			LCDPORT,		LCD_EN
		POP			R17
		RET
;_________________________________________________________________
LCD_SEND_DATA:
		PUSH		R17
		CALL		LCD_WAIT_BUSY	;CHECK IF LCD IS BUSY
		MOV			R17,			R16		;SAVE THE COMMAND				
    ; SET RS HIGH TO SELECT DATA REGISTER
    ; SET RW LOW TO WRITE TO LCD
		ANDI		R17,			0XF0
		ORI			R17,			0X01
    ; SEND DATA TO LCD
		OUT			LCDPORT,		R17   
		NOP
    ; PULSE ENABLE PIN
		SBI			LCDPORT,		LCD_EN
		NOP
		CBI			LCDPORT,		LCD_EN
    ; DELAY FOR COMMAND EXECUTION
	;SEND THE LOWER NIBBLE
		NOP
		SWAP		R16
		ANDI		R16,			0XF0
	; SET RS HIGH TO SELECT DATA REGISTER
    ; SET RW LOW TO WRITE TO LCD
		ANDI		R16,			0XF0
		ORI			R16,			0X01
    ; SEND COMMAND TO LCD
		OUT			LCDPORT,		R16
		NOP
    ; PULSE ENABLE PIN
		SBI			LCDPORT,		LCD_EN
		NOP
		CBI			LCDPORT,		LCD_EN
		POP			R17
		RET
;_______________________________________________________
LCD_WAIT_BUSY:
		PUSH		R16
		LDI			R16,			0B00000111  ; SET PA7-PA4 AS INPUT, PA2-PA0 AS OUTPUT
		OUT			LCDPORTDIR,		R16
		LDI			R16,			0B11110010	; SET RS=0, RW=1 FOR READ THE BUSY FLAG
		OUT			LCDPORT,		R16
		NOP
LCD_WAIT_BUSY_LOOP:
		SBI			LCDPORT,		LCD_EN
		NOP
		NOP
		IN			R16,			LCDPORTPIN
		CBI			LCDPORT,		LCD_EN
		NOP
		SBI			LCDPORT,		LCD_EN
		NOP
		NOP
		CBI			LCDPORT,		LCD_EN
		NOP
		ANDI		R16,			0X80
		CPI			R16,			0X80
		BREQ		LCD_WAIT_BUSY_LOOP
		LDI			R16,			0B11110111  ; SET PA7-PA4 AS OUTPUT, PA2-PA0 AS OUTPUT
		OUT			LCDPORTDIR,		R16
		LDI			R16,			0B00000000	; SET RS=0, RW=1 FOR READ THE BUSY FLAG
		OUT			LCDPORT,		R16	
		POP			R16
		RET

	;INIT THE LCD
;LCD_D7..LCD_D4 CONNECT TO PA7..PA4
;LCD_RS CONNECT TO PA0
;LCD_RW CONNECT TO PA1
;LCD_EN CONNECT TO PA2

LCD_INIT:
    ; SET UP DATA DIRECTION REGISTER FOR PORT A
		LDI			R16,			0B11110111  ; SET PA7-PA4 AS OUTPUTS, PA2-PA0 AS OUTPUT
		OUT			LCDPORTDIR,		R16
    ; WAIT FOR LCD TO POWER UP
		CALL		DELAY_10MS
		CALL		DELAY_10MS
    
    ; SEND INITIALIZATION SEQUENCE
		LDI			R16,			0X02    ; FUNCTION SET: 4-BIT INTERFACE
		CALL		LCD_SEND_COMMAND
		LDI			R16,			0X28    ; FUNCTION SET: ENABLE 5X7 MODE FOR CHARS 
		CALL		LCD_SEND_COMMAND
		LDI			R16,			0X0C    ; DISPLAY CONTROL: DISPLAY OFF, CURSOR ON
		CALL		LCD_SEND_COMMAND
		LDI			R16,			0X01    ; CLEAR DISPLAY
		CALL		LCD_SEND_COMMAND
		LDI			R16, 0X80    ; CLEAR DISPLAY
		CALL		LCD_SEND_COMMAND
		RET

;___________________________________________________________
DELAY_10MS:
		
		LDI			R17,			80
L2:	
		LDI			R18,			250	
L1:
		NOP
		DEC			R18
		BRNE		L1
	
		DEC			R17
		BRNE		L2

		RET
;_____________________________________________
;____________________________________________________
;SBC= R21, SC = 0A, TS = R20, DS = R22	R17 = THANH GHI RAC
DIV8_8:	
				LDI			R17,		8
				CLR			R22
TIEP:			LSL			R20
				ROL			R22
				BRCS		GTH					; C=1 TRU DUOC
				CPI			R22,		10		; DS V SC?
				BRCS		LTH
GTH:			SUBI		R22,		10
				SBR			R20,		1
LTH:			DEC			R17
				BRNE		TIEP
				
				LDI			R17,		48
				ADD			R22,		R17
				RET
;R
;________________________________________________________
ANTI:
WAIT_0:			LDI			R16,		50			;s? l?n nh?n d?ng SW nh?n
BACK1:			SBIC		PIND,		0			;g?i ctc nh?n d?ng SW
				RJMP		WAIT_0
				DEC			R16						;??m s? l?n nh?n d?ng SW
				BRNE		BACK1					;l?p vòng cho ?? s? l?n ??m
WAIT_1:			LDI			R16,		50			;s? l?n nh?n d?ng SW nh
BACK2:			SBIS		PIND,		0					;g?i ctc nh?n d?ng SW
				RJMP		WAIT_1
				DEC			R16						;??m s? l?n nh?n d?ng SW
				BRNE		BACK2					;l?p vòng cho ?? s? l			
				RET

				.ORG	0X0200
;-------------------------------------------------------------
TAB:	.DB "SO LAN: 000",$00

