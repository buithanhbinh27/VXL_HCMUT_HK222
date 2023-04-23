;
; LAB_1_2_2.asm
;
; Created: 20/03/2023 11:28:03 SA
; Author : Admin
;


; Replace with your application code

.EQU	OUTPUT_DDR	=	DDRA
.EQU	OUTPUT_PORT	=	PORTA
.EQU	OUTPUT_PIN	=	PINA

LDI		R16,	0xFF
OUT		OUTPUT_DDR,	R16

LOOP:
CBI		OUTPUT_PORT,	0
RCALL	DELAY_1S

SBI		OUTPUT_PORT,	0
RCALL	DELAY_1S

RJMP	LOOP
 
DELAY_1S:
LDI		R16,	41		;1MC

L1:
LDI		R17,	100		;1MC
;___________________________________
L2:
LDI		R18,	250		;1MC
;_____
L3:
NOP						;1MC
DEC		R18				;1MC
BRNE	L3				;2/1MC

DEC		R17				;1MC
BRNE	L2				;2/1MC
;____________________________________
DEC		R16				;1MC
BRNE	L1				;2/1MC

RET					       ;4MC


 