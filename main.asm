;
; LAB2_1_2.asm
;
; Created: 27/03/2023 11:25:01 SA
; Author : Admin
;


; Replace with your application code
		.EQU		P_OUT		= 3
		.EQU		OUTPUT_DDR	= DDRB
		.EQU		OUTPUT_PORT	= PORTB
		.ORG		0
		RJMP		MAIN
		.ORG		0X40

MAIN:	LDI			R16,		HIGH(RAMEND)
		OUT			SPH,		R16

		LDI			R16,		LOW(RAMEND)
		OUT			SPL,		R16

		LDI			R16,		(1<<P_OUT) ;??t PB3 output
		OUT			OUTPUT_DDR,	R16

		LDI			R17,		$03			;giá tr? so sánh
		OUT			OCR0A,		R17 ;n?p vào OCR0A

		LDI			R17,		0X02 ;Timer0 mode CTC
		OUT			TCCR0A,		R17

		LDI			R17,		0X03;Timer0 ch?y,h? s? chia N=
		OUT			TCCR0B,		R17

START:	IN			R17,		TIFR0; ??c c? TOV0 1MC
		SBRS		R17,		OCF0A; c? OCF0A=1 thoát 2/1MC
		RJMP		START				;ch? c? OCF0A=0 2MC
		OUT			TIFR0,		R17	;xóa c? OCF0A 1MC
		IN			R17,		OUTPUT_PORT;??c PortB 1MC
		EOR			R17,		R16 ;??o bit PB1 1MC
		OUT			OUTPUT_PORT,	R17;xu?t ra PortB 1MC
		RJMP		START			;l?p vòng l?i 2MC