.EQU		OUTPUT_DDR	=	DDRA
.EQU		OUTPUT_PORT	=	PORTA
.EQU		OUTPUT_PIN	=	PINA
.EQU		DSI			=	0	
.EQU		LATCH		=	1
.EQU		CLK			=	2
.EQU		nCLR		=	3

LDI			R16,			0xFF
OUT			OUTPUT_DDR,		R16
SBI			OUTPUT_PORT,	nCLR
;__________________________________________________________
BD:
LDI			R21,			0X01
LOOP:
LDI			R24,			0X08
LOOP_1:
RCALL		OUT_PORT

SBI			OUTPUT_PORT,	LATCH
CBI			OUTPUT_PORT,	LATCH
RCALL		DELAY

LSL			R21
DEC			R24
BRNE		LOOP_1

LDI			R21,			0X40
LDI			R24,			0X06

LOOP_2:
RCALL		OUT_PORT

SBI			OUTPUT_PORT,	LATCH
CBI			OUTPUT_PORT,	LATCH
RCALL		DELAY

LSR			R21
DEC			R24
BRNE		LOOP_2

RJMP		BD


;___________________________________________________________
OUT_PORT:
MOV			R22,		R21
LDI			R16,		8
TT:
LSL			R22
BRCS		OUT_1
CBI			OUTPUT_PORT,	DSI
SBI			OUTPUT_PORT,	CLK
CBI			OUTPUT_PORT,	CLK
DEC			R16
BRNE		TT
RET

OUT_1:
SBI			OUTPUT_PORT,	DSI
SBI			OUTPUT_PORT,	CLK
CBI			OUTPUT_PORT,	CLK
DEC			R16
BRNE		TT
RET


;___________________________________________________________
DELAY:
LDI			R16,		41		;1MC

L1:
LDI			R17,		100		;1MC
;___________________________________
L2:
LDI			R18,		250		;1MC
;_____
L3:
NOP								;1MC
DEC			R18					;1MC
BRNE		L3					;2/1MC
;_____
DEC			R17					;1MC
BRNE		L2					;2/1MC
;____________________________________
DEC			R16					;1MC
BRNE		L1					;2/1MC

RET								;4MC
;___________________________________________________________
