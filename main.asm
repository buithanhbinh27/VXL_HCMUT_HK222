;
; LAB2_1_3.asm
;
; Created: 27/03/2023 1:15:14 CH
; Author : Admin
;


; Replace with your application code
		.EQU		P_OUT=4					;gán ký hi?u P_OUT=5
		.EQU		TP_H=-31				;giá tr? ??t tr??c m?c 1
		.EQU		TP_L=-93				;giá tr? ??t tr??c m?c 0
		.ORG		0
		RJMP		MAIN
		.ORG		0X40

MAIN:	LDI			R16,		HIGH(RAMEND) ;
		OUT			SPH,		R16

		LDI			R16,		LOW(RAMEND)
		OUT			SPL,		R16

		LDI			R16,		(1<<P_OUT)	;??t PC5 output
		OUT			DDRB,		R16

		LDI			R17,		0X00		;Timer0 mode NOR
		OUT			TCCR0A,		R17

		LDI			R17,		0X00		;Timer0 mode NOR,d?ng 
		OUT			TCCR0B,		R17

START:	SBI			PORTB,		P_OUT		;output=1 1MC
		LDI			R17,		TP_H		;n?p TCNT0=TP_H 1MC
		RCALL		DELAY_T0				;ctc ch?y Timer0 3MC

		CBI			PORTB,		P_OUT		;output=0 1MC
		LDI			R17,		TP_L		;n?p TCNT0=TP_L 1MC
		RCALL		DELAY_T0				;3MC

		RJMP		START					;l?p vòng l?i 2MC
;------------------------------------------------------------
DELAY_T0: 
		OUT			TCNT0,		R17			;1MC
		LDI			R17,		0X03		;Timer0 ch?y, N=64 1MC
		OUT			TCCR0B,		R17			;1MC
WAIT:	IN			R17,		TIFR0		;??c c? TOV0 1MC
		SBRS		R17,		TOV0		;c? TOV0=1 thoát 2/1MC
		RJMP		WAIT					;ch? c? TOV0=1 2MC
		OUT			TIFR0,		R17			;xóa c? TOV0 1MC
		LDI			R17,		0X00		;d?ng Timer0 1MC
		OUT			TCCR0B,		R17			;1MC
		RET									;4MC
