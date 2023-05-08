;
; LAB3_1.asm
;
; Created: 11/04/2023 12:45:08 CH
; Author : Admin
;


; Replace with your application code
.ORG		0
RJMP		MAIN
.ORG		0X40
MAIN:	
LDI			R16,		0 ;BR=9600,UBRR0=103,U2X0=1
STS			UBRR0H,		R16
LDI			R16,		103
STS			UBRR0L,		R16
LDI			R16,		(1<<U2X1) ;x2 BR
STS			UCSR0A,		R16
LDI			R16,		(1<<TXEN0)|(1<<RXEN0);cho phép phát,8 bit data
STS			UCSR0B,		R16
LDI			R16,		(3<<UCSZ00); UART 8 bit,1 stop bit, 
STS			UCSR0C,		R16 ; không parity


START:
RCALL		REC_CHR
RCALL		TRANS_CHR
RJMP		START



;-----------------------------------
TRANS_CHR: 
LDS			R16,		UCSR0A ;??c c? UDRE0
SBRS		R16,		UDRE0 ;UDRE0=1 s?n sàng phát
RJMP		TRANS_CHR ;ch? c? UDRE0=1
STS			UDR0,		R17 ;phát data c?t trong R17
RET

REC_CHR:
LDS			R16,		UCSR0A
SBRS		R16,		RXC0	
RJMP		REC_CHR
LDS			R17,		UDR0
RET


