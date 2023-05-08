;
; LAB3_3.asm
;
; Created: 11/04/2023 1:43:11 CH
; Author : Admin
;


; Replace with your application code
;
; LAB3_1.asm
;
; Created: 11/04/2023 12:45:08 CH
; Author : Admin
;


; Replace with your application code
.ORG		0

.EQU		SS			=	4
.EQU		MOSI		=	5
.EQU		MISO		=	6
.EQU		SCK			=	7
.EQU		LATCH		=	0
.EQU		nCLR		=	1
RJMP		MAIN
.ORG		0X40
MAIN:	
;________________________________________________________________
//KHAI BAO CHE DO UART
LDI			R16,		0 ;BR=9600,UBRR0=103,U2X0=1
STS			UBRR1H,		R16
LDI			R16,		103
STS			UBRR1L,		R16
LDI			R16,		(1<<U2X1) ;x2 BR
STS			UCSR1A,		R16
LDI			R16,		(1<<RXEN1)|(1<<TXEN1);cho phép phát,8 bit data
STS			UCSR1B,		R16
LDI			R16,		(3<<UCSZ00); UART 8 bit,1 stop bit, 
STS			UCSR1C,		R16 ; không parity
;________________________________________________________________
//kHAI BAO CHE DO SPI
LDI			R16,		(1<<SS)|(1<<MOSI)|(1<<SCK)|(1<<0)|(1<<1)
; SS,MOSI,SCK output,MISO input
OUT			DDRB,		R16
SBI			PORTB,		SS ;d?ng truy?n SPI
LDI			R16,		(1<<SPE0)|(1<<MSTR0)
;SPI Master,MSB tr??c,l?y m?u c?nh lên c?nh tr??c, 
;fck=500Khz,cho phép SPI
OUT			SPCR0,		R16

;________________________________________________________________
SBI			PORTB,		1
START:

RCALL		REC_CHR
RCALL		TRANS_CHR
RCALL		SPI_TRANS
RJMP		START



;-----------------------------------
REC_CHR:
LDS			R16,		UCSR1A
SBRS		R16,		RXC1	
RJMP		REC_CHR
LDS			R17,		UDR1
RET
;-----------------------------------
TRANS_CHR: 
LDS			R16,		UCSR1A ;??c c? UDRE0
SBRS		R16,		UDRE1 ;UDRE0=1 s?n sàng phát
RJMP		TRANS_CHR ;ch? c? UDRE0=1
STS			UDR1,		R17 ;phát data c?t trong R17
RET
;-----------------------------------

SPI_TRANS:
OUT			SPDR0,			R17 ;ghi data ra SPI
WAIT_SPI:
IN			R16,			SPSR0 ;??c c? SPIF0
SBRS		R16,			SPIF0 ;c? SPIF0=1 truy?n SPI xong
RJMP		WAIT_SPI			;ch? c? SPIF0=1
SBI			PORTB,			LATCH
CBI			PORTB,			LATCH
RET
