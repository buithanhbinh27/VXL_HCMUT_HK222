;
; LAB3_1_2.asm
;
; Created: 4/24/2023 10:28:24 PM
; Author : khoin
;


; Replace with your application code
.DEF	REG_FLAG=R19		;REG_FLAG chua cac co bao
	.DEF	COUNT=R20			;bien dem
	.DEF	NUM_MAX=R21		;bien dat gia tri MAX
	.DEF	NUM_MIN=R22		;bien dat gia tri MIN
	.DEF	POS_CRS=R23		;bien dat vi tri con tro hien thu
	.EQU	LCD=PORTA			;PORTA hien lcd
	.EQU	LCD_DR=DDRA
	.EQU	CONT=PORTD		;PORTD dieu khien
	.EQU	CONT_DR=DDRD		
	.EQU	CONT_IN=PIND		
	.EQU	SW_FLG=0
	.EQU	RS=0				;bit RS
	.EQU	RW=1				;bit RW
	.EQU	E=2				;bit E
	.EQU	SCL=0				;ky hieu chan SCL
	.EQU	SDA=1			;ky hieu chan SDA
	.EQU	SW1=0			;ky hieu chan SW1
	.EQU	SW2=1			;ky hieu chan SW2
	.EQU	STO=7				;bit cho phep OSC RTC
	.EQU	VBATEN=3			;bit cho phep nguon du phong
	.EQU	NULL=$00			;ma ket thuc chuoi ky tu
	.EQU	CTL_BYTE=0B11011110	;byte dieu khien truy xuat
	.EQU	RTC_BUF=0X200
	.ORG	0
	RJMP	MAIN
	.ORG 	0X40
MAIN:	LDI		R16,HIGH(RAMEND)	;dua stack len vung d/c cao
	OUT		SPH,R16
	LDI		R16,LOW(RAMEND)
	OUT		SPL,R16
	LDI		R16,0XFF
	OUT		LCD_DR,R16
	LDI		R16,0X00
	OUT		LCD,R16
	CBI		CONT_DR,SW1	;chan SW1 input
	SBI		CONT,SW1		;dien tro keo len chan SW1
	CBI		CONT_DR,SW2	;chan SW2 input
	SBI		CONT,SW2		;dien tro keo len chan SW2
	LDI		R16,250		;delay 25ms
	RCALL 	DELAY_US		;ctc delay 100usxR16
	LDI		R16,250		;delay 25ms
	RCALL 	DELAY_US		;ctc delay 100usxR16
	CBI		LCD,RS		;RS=0 ghi lenh
	LDI		R17,$30		;ma lenh=$30 lan 1,RS=RW=E=0
	RCALL	OUT_LCD4		;ctc ghi ra LCD
	LDI		R16,42			;delay 4.2ms
	RCALL	DELAY_US
	CBI		LCD,RS
	LDI		R17,$30		;ma lenh=$30 lan 2
	RCALL	OUT_LCD4			
	LDI		R16,2			;delay 200?s
	RCALL	DELAY_US
	CBI		LCD,RS
	LDI		R17,$30		;ma lenh=$30 lan 3
	RCALL	OUT_LCD4
	LDI		R16,1			;delay 100us
	RCALL	DELAY_US
	CBI		LCD,RS
	LDI		R17,$20		;ma lenh=$20 
	RCALL	OUT_LCD4
	LDI		R18,$28		;Function set 2 dong font 5x8, mode 4 bit
	LDI		R19,$01		;Clear display
	LDI		R20,$0C		;display on,con tro off
	LDI		R21,$06		;Entry mode set dich phai con tro, DDRAM tang 1 d/c
;Khi nhap ky tu, man hinh khong dich
	RCALL	INIT_LCD4		;ctc khoi dong LCD 4 bit
	RCALL	TWI_INIT
START:
	LDI		REG_FLAG,0		;xoa cac co bao
	LDI		R16,1			;cho 100us
	RCALL	DELAY_US
	CBI		LCD,RS		;RS=0 ghi lenh
	LDI		R17,$01		;xoa man hinh
	RCALL	OUT_LCD
	LDI		R16,20			;cho 2ms sau lenh Clear display
	RCALL	DELAY_US
	LDI		R17,$80		;con tro bat dau o dau dong 1 
	RCALL	CURS_POS		;xuat lenh ra LCD
	LDI		ZH,HIGH(MSG1<<1); Z tro dau bang tra MSG2
	LDI		ZL,LOW(MSG1<<1)
	RCALL	MSG_DISP		;ghi MSG1 ra LCD
	LDI		R17,$C0		;con tro bat dau o dau dong 2
	RCALL	CURS_POS		;xuat lenh ra LCD
	LDI		ZH,HIGH(MSG2<<1);Z tro dau bang tra MSG2
	LDI		ZL,LOW(MSG2<<1)
	RCALL	MSG_DISP		;ghi MSG2 ra LCD
;---------------------------------------------------------
;Dat bit SQWEN=1,RS2:0=000 cho dao dong 1Hz 
;Xuat ra chan MFP
;---------------------------------------------------------
	RCALL	TWI_START		;phat xung START
	LDI		R17,(CTL_BYTE|0X00);truy xuat ghi RTC_TCCR
	RCALL	TWI_WRITE		;ghi RTC+W
	LDI		R17,0X07		;dia chi thanh ghi Control
	RCALL	TWI_WRITE
	LDI		R17,0B01000000	;MFP xuat xung 1Hz
	RCALL	TWI_WRITE
	RCALL	TWI_STOP
;--------------------------------------------------------
;Doc cac thanh ghi 0x00-0x06 RTC
;---------------------------------------------------------
START1:
	LDI		XH,HIGH(RTC_BUF);X tro dau buffer RTC
	LDI		XL,LOW(RTC_BUF)
	LDI		COUNT,7
	RCALL	TWI_START		;phat xung START
	LDI		R17,(CTL_BYTE|0X00);truy xuat ghi RTC_TCCR
	RCALL	TWI_WRITE		;ghi RTC+W
	LDI		R17,0X00		;dia chi thanh ghi 0x00
	RCALL	TWI_WRITE
	RCALL	TWI_START		;phat xung START
	LDI		R17,(CTL_BYTE|0X01);truy xuat doc RTC_TCCR
	RCALL	TWI_WRITE		;ghi RTC+R
RTC_RD:	
	RCALL	TWI_READ
	ST		X+,R17
	DEC		COUNT
	BRNE		RTC_RD
	RCALL	TWI_NAK
	RCALL	TWI_STOP
;------------------------------------------------------------------
;Hien thi thu gio:phut:giay
;------------------------------------------------------------------
START2:	
	LDI		R17,$0C		;xoa con tro 
	CBI		LCD,RS
	LDI		R16,1			;cho 100us
	RCALL	DELAY_US
	RCALL	OUT_LCD
	LDI		XH,HIGH(RTC_BUF+3);X tro buffer RTC thu
	LDI		XL,LOW(RTC_BUF+3)
	LDI		R17,$84		;con tro bat dau o dong 1 vi tri thu
	RCALL	CURS_POS		;xuat lenh ra LCD
	LD		R17,X			;lay data thu
	ANDI		R17,0X07
	LDI		R18,0X30		;chuyen sang ma ASCII 
	ADD		R17,R18				
	SBI		LCD,RS
	LDI		R16,1			;cho 100us
	RCALL	DELAY_US
	RCALL	OUT_LCD		;hien thu ra LCD
	LDI		R17,0X20		;ma dau trong
	SBI		LCD,RS
	LDI		R16,1			;cho 100us
	RCALL	DELAY_US
	RCALL	OUT_LCD 		;hien thu ra LCD
	LDI		COUNT,3
	LDI		R17,$86		;con tro bat dau o dong 1 vi tri gio
	RCALL	CURS_POS		;xuat lenh ra LCD
DISP_NXT1: 
	LD		R17,-X			;lay data
	CPI		COUNT,1		;data=sec
	BRNE		D_NXT		;khac,hien thi tiep
	CBR		R17,(1<<STO)	;xoa bit ST
D_NXT:	
	RCALL	NUM_DISP
	DEC		COUNT
	BREQ		QUIT1
	LDI		R17,':'
	SBI		LCD,RS
	LDI		R16,1			;cho 100us
	RCALL	DELAY_US
	RCALL	OUT_LCD 		;hien thu ra LCD
	RJMP		DISP_NXT1
;----------------------------------------------------
;Hien thu ngay/thang/nam
;----------------------------------------------------
QUIT1:		
	LDI		XH,HIGH(RTC_BUF+4);X tro buffer RTC ngay
	LDI		XL,LOW(RTC_BUF+4)
	LDI		COUNT,3
	LDI		R17,$C6	;con tro bat dau o dong 2 vi tri ngay
	RCALL	CURS_POS		;xuat lenh ra LCD
DISP_NXT2:
	LD		R17,X+
	RCALL	NUM_DISP
	DEC		COUNT
	BREQ		SW_CHK
	LDI		R17,'/'
	SBI		LCD,RS
	LDI		R16,1			;cho 100us
	RCALL	DELAY_US
	RCALL	OUT_LCD 		;hien thu ra LCD
	RJMP		DISP_NXT2
;------------------------------------------------------------------
;Dat lai RTC
;------------------------------------------------------------------
SW_CHK:	
	RCALL	GET_SW		;doc SW cho SW nhan
	SBRS		REG_FLAG,SW_FLG
	RJMP		START1
	CPI		R17,1
	BRNE		SW_CHK
	LDI		R17,$0E		;hien thi con tro 
	CBI		LCD,RS
	LDI		R16,1			;cho 100us
	RCALL	DELAY_US
	RCALL	OUT_LCD 		;xuat lenh ra LCD
RTC_SET:	
	CPI		COUNT,0		;cai dat thu?
	BRNE		HR_CHK		;khac,kiem tra gio
	LDI		XH,HIGH(RTC_BUF+3);X tro buffer RTC thu
	LDI		XL,LOW(RTC_BUF+3)
	LDI		NUM_MAX,7
	LDI		NUM_MIN,1
	LDI		POS_CRS,$84		;dat con tro vi tri thu
	RCALL	SET_NUM		;doc 
	LD		R17,X
	SBR		R17,(1<<VBATEN)	;cho phep nguon backup
	ST		X,R17
	RJMP		RTC_SET
HR_CHK:	
	CPI		COUNT,1		;cai dat gio?
	BRNE		MI_CHK		;khac,kiem tra phut
	LDI		XH,HIGH(RTC_BUF+2);X tro buffer RTC gio
	LDI		XL,LOW(RTC_BUF+2)
	LDI		NUM_MAX,0X23
	LDI		NUM_MIN,0
	LDI		POS_CRS,$86		;dat con tri vi tri gio
	RCALL	SET_NUM
	RJMP		RTC_SET
MI_CHK:	
	CPI		COUNT,2		;cai dat phut?
	BRNE		SEC_CHK		;khac,kiem tra giay
	LDI		XH,HIGH(RTC_BUF+1);X tro buffer RTC phut
	LDI		XL,LOW(RTC_BUF+1)
	LDI		NUM_MAX,0X59
	LDI		NUM_MIN,0
	LDI		POS_CRS,$89		;dat con tro vi tri phut
	RCALL	SET_NUM
	RJMP		RTC_SET
SEC_CHK:	
	CPI		COUNT,3		;cai dat giay?
	BRNE		DAT_CHK		;kiem tra ngay
	LDI		XH,HIGH(RTC_BUF);X tro buffer RTC giay
	LDI		XL,LOW(RTC_BUF)
	LDI		NUM_MAX,0X59
	LDI		NUM_MIN,0
	LDI		POS_CRS,$8C	;dat con tro vi tri giay
	RCALL	SET_NUM
	LD		R17,X
	SBR		R17,(1<<STO)	;dat bit STO=1 cho phep OSC
	ST		X,R17
	RJMP		RTC_SET
DAT_CHK:	
	CPI		COUNT,4		;cai dat ngay?
	BRNE		MO_CHK		;khac,kiem tra thang
	LDI		XH,HIGH(RTC_BUF+4);X tro buffer RTC ngay
	LDI		XL,LOW(RTC_BUF+4)
	LDI		NUM_MAX,0X31
	LDI		NUM_MIN,1
	LDI		POS_CRS,$C6	;con tro vi tri ngay
	RCALL	SET_NUM
	RJMP		RTC_SET
MO_CHK:	
	CPI		COUNT,5		;cai dat thang?
	BRNE		YEA_CHK		;khac,kiem tra nam
	LDI		XH,HIGH(RTC_BUF+5);X tro buffer RTC thang
	LDI		XL,LOW(RTC_BUF+5)
	LDI		NUM_MAX,0X12
	LDI		NUM_MIN,1
	LDI		POS_CRS,$C9	;con tro vi tri thang
	RCALL	SET_NUM
YEA_CHK:	
	CPI		COUNT,6		;cai dat nam?
	BRNE		EXIT_CHK		;khac,thoat
	LDI		XH,HIGH(RTC_BUF+6);X tro buffer RTC nam
	LDI		XL,LOW(RTC_BUF+6)
	LDI		NUM_MAX,0X99
	LDI		NUM_MIN,1
	LDI		POS_CRS,$CC	;con tro vi tri nam
	RCALL	SET_NUM
	RJMP		RTC_SET
;-----------------------------------------------------
;Luu cac gia tri cai dat vao RTCC
;-----------------------------------------------------
EXIT_CHK:  
	LDI		COUNT,7		;luu vao RTCC
	LDI		XH,HIGH(RTC_BUF);X tro buffer RTC
	LDI		XL,LOW(RTC_BUF)
	RCALL	TWI_START		;phat xung START
	LDI		R17,(CTL_BYTE|0X00);truy xuat ghi RTC
	RCALL	TWI_WRITE		;ghi RTC+W
	LDI		R17,0X00		;dia chi thanh ghi giay
	RCALL	TWI_WRITE		;ghi dia chi TCCR
WR_RTC:	
	LD		R17,X+
	RCALL	TWI_WRITE		;ghi TCCR
	DEC		COUNT
	BRNE		WR_RTC
	RCALL	TWI_STOP
	RJMP		START1
;------------------------------------------------------
;GET_SW doc trang thai SW1, SW2 co chong rung
;Tra ve ma SW1=1 hoac ma SW2=2 va co SW_FLG=1 neu co SW nhan
;Tra ve co SW_FLG=0 neu khong co SW nhan
;Su dung R16,R17,c? SW_FLG thuoc thanh ghi FLAG_REG
;--------------------------------------------------------------------------
GET_SW:
	CBR		REG_FLAG,(1<<SW_FLG);xoa co bso nhsn SW
BACK0:
	LDI		R16,255			;kiem tra SW nhan 50 lan lien tuc
WAIT0:
	IN		R17,CONT_IN
	ANDI		R17,(1<<SW1)|(1<<SW2);che bit SW1,SW2
	CPI		R17,(1<<SW1)|(1<<SW2);kiem tra SW nhan?		BREQ		EXIT_SW		;khong nhan, thoat
	DEC		R16			;co nhsn tirp tuc
	BRNE		WAIT0		;
	PUSH		R17			;cat ma SW
BACK1:
	LDI		R16,50			;kiem tra sw nha 50 lan lien tuc
WAIT1:	
	IN		R17,CONT_IN
	ANDI		R17,(1<<SW1)|(1<<SW2)
	CPI		R17,(1<<SW1)|(1<<SW2)
	BRNE		BACK1		;ch? nh? SW
	DEC		R16
	BRNE		WAIT1
	POP		R17			;ph?c h?i m? SW
	CPI		R17,(1<<SW2)	;SW1=0 nh?n,SW2=1 kh?ng nh?n
	BRNE		SW2_CODE		;kh?ng ph?i kiem tra m? SW2
	LDI		R17,1			;g?n gi? tr? m? SW1
	RJMP		SET_FLG		;b?o c? nh?n SW
SW2_CODE:	
	CPI		R17,(1<<SW1)	;SW2=0 nh?n,SW1=1 kh?ng nh?n
	BRNE		EXIT_SW		;kh?ng ph?i tho?t
	LDI		R17,2			;g?n gi? tr? m? SW2
SET_FLG:	
	SBR		REG_FLAG,(1<<SW_FLG);??t c? b?o nh?n SW
EXIT_SW:	  
	RET
;----------------------------------------------------------------
;SET_NUM c?i ??t c?c gi? tr? th?i gian ch?n qua bi?n COUNT
;Nh?n/nh? SW1 tho?t
;Nh?n/nh? SW2 c?i ??t gi? tr?
;S? d?ng R17,R18,ctc CURS_POS,GET_SW
;----------------------------------------------------------------
SET_NUM:		
	MOV		R17,POS_CRS	;??t v? tr? con tr? ??ng v? tr? c?i ??t
	RCALL	CURS_POS
SW_CHK1:		
	RCALL	GET_SW		;??c SW
	SBRS 		REG_FLAG,SW_FLG;c? SW nh?n
	RJMP		SW_CHK1		;ch? nh?n SW
	CPI		R17,1			;SW1 nh?n?
	BREQ		EXIT_NUM		;??ng,tho?t
	CPI		R17,2			;SW2 nh?n?
	BRNE		SW_CHK1		;kh?c,??c l?i SW
	LD		R17,X			;n?p gi? tr? c?i ??t
	CPI		COUNT,3		;c?i ??t gi?y?
	BRNE		DAY_CHK		;kh?c,kiem tra ng?y
	CBR		R17,(1<<STO)	;??ng,x?a bit ST
	RJMP		PRESET		;ti?n h?nh ??t
DAY_CHK:		
	CPI		COUNT,0		;c?i ??t ng?y?
	BRNE		PRESET		;kh?c,ti?n h?nh ??t
	ANDI		R17,0X07		;l?c l?y data ng?y
PRESET:		
	INC		R17			;t?ng gi? tr? th?m 1
	MOV		R18,R17		;c?t gi? tr? ??t
	ANDI		R17,$0F		;che l?y 4 bit th?p
	CPI		R17,$0A		;gi? tr?<10
	BRCS		NON_CR		;??ng,kh?ng tr?n
	LDI		R17,$06		;hi?u ??nh BCD
	ADD		R18,R17
NON_CR:		
	MOV		R17,R18		;tr? s? BCD ??t v? R17
	CP		R17,NUM_MAX	;so s?nh gi?i h?n MAX
	BRCS		DISP			;nh? h?n,hi?n th?
	BREQ		DISP			;b?ng,hi?n th?
	MOV		R17,NUM_MIN	;l?n h?n,tr? v? gi?i h?n MIN
DISP:	ST		X,R17			;c?t s? BCD ??t v?o buffer
	RCALL	NUM_DISP		;hi?n th? s? BCD ??t
	RJMP		SET_NUM		;ti?p t?c ??t
EXIT_NUM:	
	INC		COUNT		;t?ng bi?n ??m v? tr? c?i ??t
	RET
;---------------------------------------------------------------
NUM_DISP:	
	PUSH		R17			;c?t data
	SWAP		R17			;ho?n v? 4 bitth?p/cao
	ANDI		R17,0X0F		;che l?y s? BCD cao
	ORI		R17,0X30		;chuy?n sang m? ASCII
	SBI		LCD,RS
	LDI		R16,1			;ch? 100?s
	RCALL	DELAY_US
	RCALL	OUT_LCD		;hi?n th? gi? tr?	
	POP		R17			;ph?c h?i data
	ANDI	R17,0X0F		;che l?y s? BCD th?p
	ORI		R17,0X30		;chuy?n sang m? ASCII
	SBI		LCD,RS
	LDI		R16,1			;ch? 100?s
	RCALL	DELAY_US
	RCALL	OUT_LCD		;hi?n th? gi? tr?
	RET
;-----------------------------------------------------------------
;MSG_DISP	hi?n th? chu?i k? t? k?t th?c b?ng m? NULL ??t trong Flash ROM 
;Input: Z ch?a ??a ch? ??u chu?i k? t?
;Output: hi?n th? chu?i k? t? ra LCD t?i v? tr? con tr? hi?n h?nh
;S? d?ng R16,R17,ctc DELAY_US,OUT_LCD
;------------------------------------------------------------------
MSG_DISP:		
	LPM		R17,Z+		;l?y m? ASCII k? t? t? Flash ROM
	CPI		R17,NULL		;kiem tra k? t? k?t th?c
	BREQ		EXIT_MSG		;k? t? NULL tho?t
	LDI		R16,1			;ch? 100?s				
	RCALL	DELAY_US
	SBI		LCD,RS		;RS=1 ghi data hi?n th? LCD
	RCALL	OUT_LCD		;ghi m? ASCII k? t? ra LCD
	RJMP		MSG_DISP		;ti?p t?c hi?n th? k? t?
EXIT_MSG:		
	RET
;----------------------------------------------------------
;CURS_POS ??t con tr? t?i v? tr? c? ??a ch? trong R17
;Input: R17=$80 -$8F d?ng 1,$C0-$CF d?ng 2
;R17= ??a ch? v? tr? con tr?
;S? d?ng R16,ctc DELAY_US,OUT_LCD
;----------------------------------------------------------
CURS_POS:	 
	LDI		R16,1			;ch? 100?s
	RCALL	DELAY_US
	CBI		LCD,RS		;RS=0 ghi l?nh
	RCALL	OUT_LCD
	RET
;-----------------------------------------------------------------
;INIT_LCD4 kh?i ??ng LCD ghi 4 byte m? l?nh theo giao ti?p 4 bit
;Function set:R18=$28 2 d?ng font 5x8 giao ti?p 4 bit
;Clear display:R19=$01  x?a m?n h?nh
;Display on/off LCDrol:R20=$0C m?n h?nh on,con tr? off
;Entry mode set:R21=$06 d?ch ph?i con tr? ,?/c DDRAM t?ng 1 khi ghi data
;RS=bit0=0,RW=bit1=0
;----------------------------------------------------------------
INIT_LCD4: 	
	CBI		LCD,RS		;RS=0: ghi l?nh
	MOV		R17,R18		;R18=Function set 
	RCALL	OUT_LCD		;ghi 1 byte data ra LCD
	MOV		R17,R19		;R19=Clear display
	RCALL	OUT_LCD
	LDI		R16,20			;ch? 2ms sau l?nh Clear display
	RCALL	DELAY_US
	MOV		R17,R20		;R20=Display LCDrol on/off
	RCALL	OUT_LCD		
	MOV		R17,R21		;R21=Entry mode set
	RCALL	OUT_LCD				
	RET
;--------------------------------------------------
;OUT_LCD4 ghi m? l?nh/data ra LCD
;Input: R17 ch?a m? l?nh/data 4 bit cao
;--------------------------------------------------
OUT_LCD4: 	
	OUT		LCD,R17
	SBI		LCD,E
	CBI		LCD,E
	RET
;------------------------------------------------------
;OUT_LCD ghi 1 byte m? l?nh/data ra LCD 
;chia l?m 2 l?n ghi 4bit
;Input: R17 ch?a m? l?nh/data,R16
;bit RS=0/1:l?nh/data,bit RW=0:ghi 
;S? d?ng ctc OUT_LCD4
;------------------------------------------------------
OUT_LCD:		
	LDI		R16,1			;ch? 100us
	RCALL	DELAY_US
	IN		R16,LCD		;??c PORT LCD
	ANDI		R16,(1<<RS)		;l?c bit RS
	PUSH		R16			;c?t R16
	PUSH		R17			;c?t R17
	ANDI		R17,$F0		;l?y 4 bit cao
	OR		R17,R16		;gh?p bit RS 
	RCALL	OUT_LCD4		;ghi ra LCD
	LDI		R16,1			;ch? 100us
	RCALL	DELAY_US
	POP		R17			;ph?c h?i R17
	POP		R16			;ph?c h?i R16
	SWAP		R17			;??o 4 bit
	ANDI		R17,$F0		;l?y 4 bit th?p chuy?n th?nh cao
	OR		R17,R16		;gh?p bit RS
	RCALL	OUT_LCD4		;ghi ra LCD
	RET
;-------------------------------------------------------					
;DELAY_US t?o th?i gian tr? =R16x100?s(Fosc=8Mhz)
;Input:R16 h? s? nh?n th?i gian tr? 1 ??n 255
;-------------------------------------------------------
DELAY_US:
	MOV		R15,R16		;1MC n?p data cho R15
	LDI		R16,200		;1MC s? d?ng R16
L1:	MOV		R14,R16		;1MC n?p data cho R14
L2:	DEC		R14			;1MC
	NOP					;1MC
	BRNE	L2			;2/1MC
	DEC		R15			;1MC
	BRNE	L1			;2/1MC
	RET					;4MC
;---------------------------------------------------------
;TWI_INIT kh?i ??ng c?ng TWI
;??t t?c ?? tuy?n=100Khz
;---------------------------------------------------------
TWI_INIT:
	LDI		R17,8			;t?c ?? truy?n SCL=100Khz
	STS		TWBR,R17
	LDI		R17,1
	STS		TWSR,R17		;h? s? ??t tr??c=4
	LDI		R17,(1<<TWEN)	;cho ph?p TWI
	STS		TWCR,R17
	RET
;----------------------------------------------------------
TWI_START:
	LDI		R17,(1<<TWEN)|(1<<TWSTA)|(1<<TWINT);cho ph?p TWI,START,x?a TWINT
	STS		TWCR,R17
WAIT_STA:	
	LDS		R17,TWCR		;??c c? TWINT		SBRS	R17,TWINT		;ch? c? TWINT=1 b?o truy?n xong
	RJMP		WAIT_STA
	RET
;----------------------------------------------------------
TWI_WRITE:
	STS		TWDR,R17		;ghi data
	LDI		R17,(1<<TWEN)|(1<<TWINT);cho ph?p TWI,x?a TWINT
	STS		TWCR,R17
WAIT_WR:	
	LDS		R17,TWCR		;ch? c? TWINT=1 b?o truy?n xong
	SBRS		R17,TWINT
	RJMP		WAIT_WR
	RET
;----------------------------------------------------------
TWI_READ:
	LDI		R17,(1<<TWEN)|(1<<TWINT)|(1<<TWEA);cho ph?p TWI,x?a TWINT,tr? ACK
	STS		TWCR,R17
WAIT_RD:	
	LDS		R17,TWCR		;ch? c? TWINT=1 b?o truy?n xong
	SBRS		R17,TWINT
	RJMP		WAIT_RD
	LDS		R17,TWDR		;??c data thu ???c
	RET
;--------------------------------------------------
TWI_NAK:	
	LDI		R17,(1<<TWEN)|(1<<TWINT);choph?p TWI,x?a TWINT,tr? NAK
	STS		TWCR,R17
WAIT_NAK: 
	LDS		R17,TWCR		;ch? c? TWINT=1 b?o truy?n xong
	SBRS		R17,TWINT
	RJMP		WAIT_NAK
	RET
;----------------------------------------------------------
TWI_STOP:	
	LDI		R17,(1<<TWEN)|(1<<TWSTO)|(1<<TWINT);cho ph?p TWI,x?a TWINT,STOP
	STS		TWCR,R17
	RET
;---------------------------------------------------------
	.ORG	0X200
MSG1:	.DB		"THU  ",$00 
MSG2:	.DB		"NGAY ",$00
