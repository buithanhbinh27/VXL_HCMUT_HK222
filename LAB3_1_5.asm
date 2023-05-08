;
; LAB3_1_5.asm
;
; Created: 4/10/2023 11:08:35 PM
; Author : khoin
;


; Replace with your application code

		.equ	EE_ADDR			= 0x0100
        .equ    DDR_LED			= DDRA
		.equ	PORT_LED		= PORTA
		.def	COUNT			= R20		;byte receiver count

        .org    0x00
        rcall	USART_Init					;initiate usart
		ser		R16
		out		DDR_LED,R16				
		clr		R16
		out		PORT_LED,R16				;output:port_led, reset =0
start: 	ldi		count,0						;reset count = 0
		rcall	USART_ReceiveChar			;get 1 byte from UART
		;rcall	USART_SendChar			
		rcall	EEPR_RDInit
		inc		COUNT						;inc count when uart get 1 byte
		rcall	EEPR_WRInit					
		out		PORT_LED,count				;prtout count to barled
		rjmp	start

;subroutine--------------------------------------------
USART_Init:
        ;Set baud rate to 9600 bps with 8 MHz clock
        ;Doube speed mode (U2X0 = 1)
        ;UBBR0 = fosc / (8*BAUD) - 1
        ldi     R16, low(103)
        sts     UBRR0L, R16
        ldi     R16, high(103)
        sts     UBRR0H, R16
        ldi     R16, (1 << U2X0)			;Double speed mode (U2X0 = 1)
        sts     UCSR0A, R16
        ;Set frame format: 8 data bits, no parity, 1 stop bit
        ldi     R16, (1 << UCSZ01) | (1 << UCSZ00)
        sts     UCSR0C, R16
        ;Enable (transmitter?) and receiver
        ldi     R16, (1 << RXEN0) | (1 << TXEN0)
        sts     UCSR0B, R16
        ret
;----------------------------------------------------
;Receive byte from USART and load to R16
USART_ReceiveChar: 
        push r17 
        ;Wait for the transmitter to be ready 
USART_ReceiveChar_Wait: 
		lds     R17, UCSR0A 
		sbrs    R17, RXC0					;check USART Receive Complete bit 
		rjmp    USART_ReceiveChar_Wait       
        lds     R16, UDR0					;get data 
        pop     R17 
        ret
;-------------------------------------------------------
USART_SendChar:
        push    R17
        
        ;Wait for the transmitter to be ready
        USART_SendChar_Wait: 
                lds     R17, UCSR0A 
                sbrs    R17, UDRE0      ;check USART Data Register Empty bit 
                rjmp    USART_SendChar_Wait 

        sts     UDR0, R16       ;send out
        pop     R17
        ret
;--------------------------------------------------
EEPR_RDInit:
		push	R16	
wait2:	sbic	EECR,EEPE
		rjmp	wait2						;wait for EEPR to write
		ldi		R16,high(EE_ADDR)
		out		EEARH,R16
		ldi		R16,low(EE_ADDR)			
		out		EEARL,R16					;load EE_address
		sbi		EECR,EERE
		in		count,EEDR					;rd last count from EEPR & st to count
		pop		R16
		ret
;---------------------------------------------------
EEPR_WRInit:	
		push	R16	
		ldi		R16,high(EE_ADDR)
		out		EEARH,R16
		ldi		R16,low(EE_ADDR)			
		out		EEARL,R16					;load EE_address
wait1:	sbic	EECR,EEPE
		rjmp	wait1						;wait for EEPR to write
		out		EEDR,count					;st count to EEPR
		sbi		EECR,EEMPE
		sbi		EECR,EEPE					;write enable
		pop		R16
		ret
