;
; LAB2_1.asm
;
; Created: 27/03/2023 9:46:07 CH
; Author : Admin
;


; Replace with your application code
		.EQU		LED_0 =		0XC0		;mã led 7 ?oan s? 0
		.EQU		LED_1 =		0XF9		;mã led 7 ?oan s? 1
		.EQU		LED_2 =		0XA4		;mã led 7 ?oan s? 2
		.EQU		LED_3 =		0XB0		;mã led 7 ?oan s? 3
		
		.ORG		0
		RJMP		MAIN
		.ORG		0X40

MAIN:	LDI			R16,		HIGH(RAMEND)
		OUT			SPH,		R16

		LDI			R16,		LOW(RAMEND)
		OUT			SPL,		R16
		
		LDI			R16,		0xff
		OUT			DDRB,		R16		;PORT B = OUTPUT, PORTB -> LED 7 DOAN
		LDI			R16,		0xff
		OUT			DDRC,		R16		;PORT C = OUTPUT; -> ?i?u khi?n 4 led
	
		
		LDI			R17,		0X00
		OUT			TCCR0A,		R17		;	TIMER0 MOD 0
		
		LDI			R17,		0X00
		OUT			TCCR0B,		R17		;  TIMER0 MOD 0, DUNG


;______________________________________________________
LOOP:
		LDI			R17,		0X01 ;NLED0 = 0 NLED 1 = 1
		OUT			PORTC,		R17		

		LDI			R16,		LED_0	;DATA
		OUT			PORTB,		R16

		LDI			R17,		0X00 ;NLED0 = 0 NLED1 = 0
		OUT			PORTC,		R17

		LDI			R17,		0X02;NLED0 = 0 NLED 1 = 1
		OUT			PORTC,		R17	
			
		LDI			R17,		0X07;DATA CHON DEN
		OUT			PORTB,		R17

		LDI			R17,		0X00 ;NLED0 = 0 NLED1 = 1
		OUT			PORTC,		R17



		RCALL		DELAY_20MS

		LDI			R17,		0X01 ;NLED0 = 0 NLED 1 = 1
		OUT			PORTC,		R17		

		LDI			R16,		LED_1	;DATA
		OUT			PORTB,		R16

		LDI			R17,		0X00 ;NLED0 = 0 NLED1 = 0
		OUT			PORTC,		R17

		LDI			R17,		0X02;NLED0 = 0 NLED 1 = 1
		OUT			PORTC,		R17	
			
		LDI			R17,		0X0B;DATA CHON DEN
		OUT			PORTB,		R17

		LDI			R17,		0X00 ;NLED0 = 0 NLED1 = 1
		OUT			PORTC,		R17
		RCALL		DELAY_20MS

		LDI			R17,		0X01 ;NLED0 = 0 NLED 1 = 1
		OUT			PORTC,		R17		

		LDI			R16,		LED_2	;DATA
		OUT			PORTB,		R16

		LDI			R17,		0X00 ;NLED0 = 0 NLED1 = 0
		OUT			PORTC,		R17

		LDI			R17,		0X02;NLED0 = 0 NLED 1 = 1
		OUT			PORTC,		R17	
			
		LDI			R17,		0X0D;DATA CHON DEN
		OUT			PORTB,		R17

		LDI			R17,		0X00 ;NLED0 = 0 NLED1 = 1
		OUT			PORTC,		R17
		RCALL		DELAY_20MS

		LDI			R17,		0X01 ;NLED0 = 0 NLED 1 = 1
		OUT			PORTC,		R17		

		LDI			R16,		LED_3	;DATA
		OUT			PORTB,		R16

		LDI			R17,		0X00 ;NLED0 = 0 NLED1 = 0
		OUT			PORTC,		R17
	
		LDI			R17,		0X02;NLED0 = 0 NLED 1 = 1
		OUT			PORTC,		R17	
			
		LDI			R17,		0X0E;DATA CHON DEN
		OUT			PORTB,		R17

		LDI			R17,		0X00 ;NLED0 = 0 NLED1 = 1
		OUT			PORTC,		R17
		RCALL		DELAY_20MS

		RJMP`		LOOP


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