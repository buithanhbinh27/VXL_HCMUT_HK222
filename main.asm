;
; LAB2_2.asm
;
; Created: 27/03/2023 11:10:08 CH
; Author : Admin
;


; Replace with your application code


		.ORG		0
		RJMP		MAIN
		.ORG		0X40
		.EQU		DATA_0      = 7
		.EQU		DATA_1      = 11
		.EQU		DATA_2      = 13
		.EQU		DATA_3      = 14

		.EQU		OUTPUT_DDR	=	DDRB
		.EQU		OUTPUT_PORT =	PORTB
		.EQU		OUTPUT_PIN	=	PINB

		.EQU		INPUT_DDR	=	DDRD
		.EQU		INPUT_PORT =	PORTD
		.EQU		INPUT_PIN	=	PIND

		;PINA 0-1 DIEU KHIEN NLED0 NLED1
MAIN:	LDI			R16,		HIGH(RAMEND)
		OUT			SPH,		R16

		LDI			R16,		LOW(RAMEND)
		OUT			SPL,		R16
		
		LDI			R16,		0x00
		OUT			INPUT_DDR,		R16			
		LDI			R16,		0XFF
		OUT			INPUT_PORT,		R16
		
		LDI			R16,		0xFF
		OUT			OUTPUT_DDR,		R16			;PORT B = OUTPUT

		LDI			R16,		0xFF
		OUT			DDRA,		R16			;PORT A = OUTPUT
		
		
		LDI			R17,		0X00
		OUT			TCCR0A,		R17			;TIMER0 MOD 0
		
		LDI			R17,		0X00
		OUT			TCCR0B,		R17			;TIMER0 MOD 0, DUNG

;______________________________________________________
;R17 = THANH GHI RAC
;R22 = DATA
;R24 = DATA CHON DEN
;HAM OUT_LED
;SBC= R21:R20, SC = 0A, TS = R21:R20, DS = R22	R17 = THANH GHI RAC		HAM DIV16_8
;INPUT = R22 OUTPUT = R22    HAM GET_LED


LOOP:	IN			R16,		INPUT_PIN		
		COM			R16					
		MOV			R2,			R16
TT:
		LDI			R17,		9
		MUL		`	R17,		R16

		MOV			R20,		R0
		MOV			R21,		R1
		
		RCALL		DIV16_8
		RCALL		GET_LED
		LDI			R24,		DATA_3
		RCALL		OUT_LED
		RCALL		DELAY_20MS

		RCALL		DIV16_8
		RCALL		GET_LED
		LDI			R24,		DATA_2
		RCALL		OUT_LED
		RCALL		DELAY_20MS

		RCALL		DIV16_8
		RCALL		GET_LED
		LDI			R24,		DATA_1
		RCALL		OUT_LED
		RCALL		DELAY_20MS

		RCALL		DIV16_8
		RCALL		GET_LED
		LDI			R24,		DATA_0
		RCALL		OUT_LED
		RCALL		DELAY_20MS
		
;________________________
		IN			R16,		INPUT_PIN
		COM			R16
		CP			R16,		R2
		BREQ		TT

		RJMP		LOOP
;___________________________________________________
LED_7:	.DB			0XC0,0XF9,0XA4,0XB0,0X99,0X92,0X82,0X8F,0X80,0X90
;___________________________________________________
DELAY_20MS:
		LDI			R17,		-10
		OUT			TCNT0,		R17

		LDI			R17,		0X03
		OUT			TCCR0B,		R17			;N=8 -> T =  1ms

WAIT:	IN			R17,		TIFR0
		SBRS		R17,		TOV0
		RJMP		WAIT
		OUT			TIFR0,		R17
		LDI			R17,		0X00
		OUT			TCCR0B,		R17
		RET
;____________________________________________________
;SBC= R21:R20, SC = 0A, TS = R21:R20, DS = R22	R17 = THANH GHI RAC
DIV16_8:	
		LDI			R17,		16
		CLR			R22
TIEP:	LSL			R20
		ROL			R21
		ROL			R22
		BRCS		GTH					; C=1 TRU DUOC
		CPI			R22,		10		; DS V SC?
		BRCS		LTH
GTH:	SUBI		R22,		10
		SBR			R20,		1
LTH:	DEC			R17
		BRNE		TIEP
		RET
;R
;________________________________________________________
GET_LED:
		LDI			ZH,			HIGH(LED_7<<1) ; Z tr? ??a ch? ??u b?ng tra mã 7 ?o?n
		LDI			ZL,			LOW(LED_7<<1) ;trong flash ROM
		ADD			R30,		R22 ;c?ng offset vào ZL
		LDI			R22,		0
		ADC			R31,		R17 ;c?ng carry vào ZH
		LPM			R22,		Z ;l?y mã 7 ?o?n
		RET
;INPUT = R22 OUTPUT = R22
;___________________________________________________________
		
OUT_LED:		
		LDI			R17,		0X01 ;NLED0 = 0 NLED 1 = 1
		OUT			PORTA,		R17		
									;DATA
		OUT			OUTPUT_PORT,		R22
		
		LDI			R17,		0X00 ;NLED0 = 0 NLED1 = 0
		OUT			PORTA,		R17

		LDI			R17,		0X02;NLED0 = 0 NLED 1 = 1
		OUT			PORTA,		R17	
			
		OUT			OUTPUT_PORT,		R24	;DATA CHON DEN

		LDI			R17,		0X00 ;NLED0 = 0 NLED1 = 1
		OUT			PORTA,		R17
		RET
;R17 = THANH GHI RAC
;R23 = DATA
;R24 = DATA CHON DEN
