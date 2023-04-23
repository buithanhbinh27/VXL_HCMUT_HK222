;
; LAB2_1.asm
;
; Created: 27/03/2023 10:18:06 SA
; Author : Admin
;


; Replace with your application code
		.EQU		P_OUT		= 1
		.EQU		OUTPUT_DDR	= DDRB
		.EQU		OUTPUT_PORT = PORTB
		.ORG		0
		RJMP		MAIN
		.ORG		0X40

MAIN:	LDI			R16,		HIGH(RAMEND)
		OUT			SPH,		R16

		LDI			R16,		LOW(RAMEND)
		OUT			SPL,		R16
		
		LDI			R16,		P_OUT
		OUT			OUTPUT_DDR,	R16
		
		LDI			R17,		0X00
		OUT			TCCR0A,		R17
		
		LDI			R17,		0X00
		OUT			TCCR0B,		R17
		
START:	RCALL		DELAY_1MS

		IN			R17,		OUTPUT_PORT
		EOR			R17,		R16	
		OUT			OUTPUT_PORT,R17

		RJMP		START

;___________________________________________________
DELAY_1MS:
		LDI			R17,		-62
		OUT			TCNT0,		R17

		LDI			R17,		0X03
		OUT			TCCR0B,		R17

WAIT:	IN			R17,		TIFR0
		SBRS		R17,		TOV0
		RJMP		WAIT
		OUT			TIFR0,		R17
		LDI			R17,		0X00
		OUT			TCCR0B,		R17
		RET








