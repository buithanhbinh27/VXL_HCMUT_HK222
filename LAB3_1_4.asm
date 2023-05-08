;
; LAB3_1_4.asm
;
; Created: 4/11/2023 4:21:50 PM
; Author : khoin
;


; Replace with your application code
;SPI_def		
		.equ	SS				= PB4
		.equ    MOSI            = PB5
		.equ	MISO			= PB6
        .equ    SCK             = PB7
;EEPR_code_def
		.equ	WIP				= 0			;write in process bit
		.equ	PE				= 0x42		;page erase
		.equ	WREN			= 0X06		;enable write  code
		;.equ	WRDI			= 0x07		;disable write code			/optinal
		.equ	RDSR			= 0x05		;read status register code
		.equ	WRSR			= 0x01		;write status register code
		.equ	SPI_RD			= 0x03		;read mem code
		.equ	SPI_WR			= 0x02		;write mem code
;EEPR_mem_def
		.equ	MEM_BYTE3		= 0x00		;address byte3 from bit 23-16
		.equ	MEM_BYTE21		= 0x0100	;address byte2,1 from bit 15-0
;Port_def
        .equ    DDR_SPI         = DDRB
        .equ    PORT_SPI        = PORTB
        .equ    DDR_LED			= DDRA
		.equ	PORT_LED		= PORTA
		.def	COUNT			= R20		;byte receiver count
;----
        .org    0x00
        rcall	USART_Init					;initiate usart
        rcall	SPI_Init					;initiate spi
		ser		R16
		out		DDR_LED,R16				
		clr		R16
		out		PORT_LED,R16				;output:port_led, reset =0
start: 	ldi		count,0						;reset count = 0
		rcall	USART_ReceiveChar			;get 1 byte from UART
		rcall	EEPR_RDInit					;read count_data stored in EEPROM
		rcall	EEPR_PEInit					;erase page in EEPROM
		rcall	EEPR_WRInit					;write count to EEPROM
		out		PORT_LED,COUNT				;prtout count to barled
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
        ldi     R16, (1 << RXEN0) ;| (1 << TXEN0)
        sts     UCSR0B, R16
        ret
;----------------------------------------------------
;Receive byte from USART and load to R16
USART_ReceiveChar: 
        push r17 
        ;Wait for the transmitter to be ready 
USART_ReceiveChar_Wait: 
		lds     R17, UCSR0A 
		sbrs    R17, RXC0       ;check USART Receive Complete bit 
		rjmp    USART_ReceiveChar_Wait       
        lds     R16, UDR0       ;get data 
        pop     R17 
        ret
;--------------------------------------------------
SPI_Init:
        ;Set control pins as output
        ldi     R17, (1 << MOSI) | (1 << SCK) | (1 << SS) 
        out     DDR_SPI, R17
        ;Enable SPI, , set clock rate fosc/16
        ldi     R17, (1 << SPE0) | (1 << MSTR0) | (1 << SPR00)
        out     SPCR0, R17
		;ldi		R16,(1<<SPI2X0)		; sck=fosc/8		
		;sts		SPSR0,R16								//optional
        sbi		PORT_SPI,SS		;stop spi
        ret
;-------------------------------------------------
;input	R16
;output R18
SPI_Trans:
        push    R17
        ;Start transmission of data (R16)
        out     SPDR0, R16
        ;Wait for transmission to complete
Wait_SPI:
		in      R17, SPSR0
		sbrs    R17, SPIF0
		rjmp    Wait_SPI
		in		R18, SPDR0
        pop     R17
        ret
;--------------------------------------------------
EEPR_WRInit:
		ldi		R16,WREN					;write enable	
		cbi		PORT_SPI,SS					;enable spi
		rcall	SPI_Trans	
		sbi		PORT_SPI,SS					;unenable spi		
		ldi		R16,SPI_WR					;write mem 
		cbi		PORT_SPI,SS					;enable spi
		rcall	SPI_Trans	
		ldi		R16,MEM_BYTE3			
		rcall	SPI_Trans
		ldi		R16,high(MEM_BYTE21)
		rcall	SPI_Trans
		ldi		R16,low(MEM_BYTE21)			
		rcall	SPI_Trans
MEM_WR:	mov		R16,count					;get count stored from eepr to R16 
		inc		R16
		rcall	SPI_Trans
		sbi		PORT_SPI,SS					;unenable spi
WR_FIN:	ldi		R16,RDSR	
		cbi		PORT_SPI,SS					;enable spi
		rcall	SPI_TRANS	
		sbrc	R18,WIP						;check wip bit
		rjmp	WR_FIN						;still write, keep checking
		sbi		PORT_SPI,SS					;unenable spi
		ret
;----------------------------------------------------
EEPR_RDInit:
		ldi		R16,SPI_RD
		cbi		PORT_SPI,SS					;enable spi
		rcall	SPI_Trans
		ldi		R16,MEM_BYTE3
		rcall	SPI_Trans
		ldi		R16,high(MEM_BYTE21)
		rcall	SPI_Trans
		ldi		R16,low(MEM_BYTE21)
		rcall	SPI_Trans
MEM_RD:	ldi		R16,0xFF					;dump data  
		rcall	SPI_Trans
		mov		count,R18					;st r18 to cnt
		sbi		PORT_SPI,SS					;unenable spi
		ret
;------------------------------------------------------
EEPR_PEInit:
		ldi		R16,WREN					;write enable	
		cbi		PORT_SPI,SS					;enable spi
		rcall	SPI_Trans	
		sbi		PORT_SPI,SS					;unenable spi		
		ldi		R16,PE						;page erase
		cbi		PORT_SPI,SS					;enable spi
		rcall	SPI_Trans	
		ldi		R16,MEM_BYTE3			
		rcall	SPI_Trans
		ldi		R16,high(MEM_BYTE21)
		rcall	SPI_Trans
		ldi		R16,low(MEM_BYTE21)			
		rcall	SPI_Trans
		sbi		PORT_SPI,SS					;unenable spi
WR_FIN1:ldi		R16,RDSR	
		cbi		PORT_SPI,SS					;enable spi
		rcall	SPI_TRANS	
		sbrc	R18,WIP						;check wip bit
		rjmp	WR_FIN1						;still write, keep checking
		sbi		PORT_SPI,SS					;unenable spi
		ret