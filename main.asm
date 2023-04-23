;
; LAB2_2_4.asm
;
; Created: 3/27/2023 6:44:42 PM
; Author : khoin
;


; Replace with your application code

.org 0x0000 ; interrupt vector table
rjmp reset_handler ; reset
.org 0x001A
rjmp timer1_COMP_ISR
reset_handler:
; initialize stack pointer
ldi r16, high(RAMEND)
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16
call shiftregister_initport
call shiftregister_cleardata
call initTimer1CTC
; enable global interrupts
sei
call ledmatrix_portinit
main:
jmp main
.equ clearSignalPort = PORTB ; Set clear signal port to PORTB
.equ clearSignalPin = 3 ; Set clear signal pin to pin 3 of PORTB	;3
.equ shiftClockPort = PORTB ; Set shift clock port to PORTB
.equ shiftClockPin = 2 ; Set shift clock pin to pin 2 of PORTB		;change to 0
.equ latchPort = PORTB ; Set latch port to PORTB
.equ latchPin = 1 ; Set latch pin to pin 1 of PORTB					;change to 2
.equ shiftDataPort = PORTB ; Set shift data port to PORTB
.equ shiftDataPin = 0 ; Set shift data pin to pin 0 of PORTB		;change to 1
; Initialize ports as outputs
shiftregister_initport:
push r24
ldi r24, (1<<clearSignalPin)|(1<<shiftClockPin)|(1<<latchPin)|(1<<shiftDataPin);
out DDRB, r24 ; Set DDRB to output
pop r24
ret
shiftregister_cleardata:
cbi clearSignalPort, clearSignalPin ; Set clear signal pin to low
; Wait for a short time
sbi clearSignalPort, clearSignalPin ; Set clear signal pin to high
ret
; Shift out data
;shift out R27 to bar led
shiftregister_shiftoutdata:
push r18
cbi shiftClockPort, shiftClockPin ;
ldi r18, 8 ; Shift 8 bits
shiftloop:
sbrc r27, 7 ; Check if the MSB of shiftData is 1
sbi shiftDataPort, shiftDataPin ; Set shift data pin to high
sbi shiftClockPort, shiftClockPin ; Set shift clock pin to high
lsl r27 ; Shift left
cbi shiftClockPort, shiftClockPin ; Set shift clock pin to low
cbi shiftDataPort, shiftDataPin ; Set shift data pin to low
dec r18
brne shiftloop
; Latch data
sbi latchPort, latchPin ; Set latch pin to high
cbi latchPort, latchPin ; Set latch pin to low
pop r18
ret
;Lookup table for collumn control
ledmatrix_col_control: .DB 0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01
; Lookup table for font
ledmatrix_Font_A: .DB 0b00000000, 0b11111100, 0b00010010, 0b00010001, 0b00010001, 0b00010010, 0b11111100, 0b00000000
;					  col7		,col6		,col5		,col4		,col3		,col2		,col1		,col0	
				   ;.DB 0b00000000, 0b00110000, 0b01001100, 0b00100010, 0b00100010, 0b01001100, 0b00110000, 0b00000000
; J38 connect to PORTD
; clear signal pin to pin 0 of PORTB
; shift clock pin to pin 1 of PORTB
; latch pin to pin 0 of PORTB
; shift data pin to pin 3 of PORTB
; Output: None
.equ LEDMATRIXPORT = PORTD
.equ LEDMATRIXDIR = DDRD
.dseg
.org SRAM_START ;starting address is 0x100
LedMatrixBuffer : .byte 8
LedMatrixColIndex : .byte 1
.cseg
.align 2
ledmatrix_portinit:
push r20
push r21
ldi r20, 0b11111111 ; SET port as output
out LEDMATRIXDIR, r20
ldi r20,0 ;col index start at 0
ldi r31,high(LedMatrixColIndex)
ldi r30,low(LedMatrixColIndex)
st z,r20
ldi r20,0
ldi r31,high(ledmatrix_Font_A << 1) ;Z register point to fontA value
ldi r30,low(ledmatrix_Font_A << 1)
ldi r29,high(LedMatrixBuffer) ; Y register point to fontA value
ldi r28,low(LedMatrixBuffer)
ldi r20,8
ledmatrix_portinit_loop: ;copy font to display buffer
lpm r21,z+
st y+,r21
dec r20
cpi r20,0
brne ledmatrix_portinit_loop
pop r21
pop r20
ret
; Display a Collumn of Led Matrix
; Input: R27 contains the value to display
; R26 contain the Col index (3..0)
; Output: None
ledmatrix_display_col:
push r16 ; Save the temporary register
push r27
clr r16
out LEDMATRIXPORT,r16
call shiftregister_shiftoutdata
ldi r31,high(ledmatrix_col_control << 1)
ldi r30,low(ledmatrix_col_control << 1)
clr r16
add r30,r26
adc r31,r16
lpm r27,z
out LEDMATRIXPORT,r27
pop r27
pop r16 ; Restore the temporary register
ret ; Return from the function
initTimer1CTC:
push r16
ldi r16, high(2500) ; Load the high yte into the temporary register
sts OCR1AH, r16 ; Set the high byte of the timer 1 compare value
ldi r16, low(2500) ; Load the low byte into the temporary register
sts OCR1AL, r16 ; Set the low byte of the timer 1 compare value
ldi r16, (1 << CS10)| (1<< WGM12) ; Load the value 0b00000101 into the temporary register
sts TCCR1B, r16 ;
ldi r16, (1 << OCIE1A); Load the value 0b00000010 into the temporary register
sts TIMSK1, r16 ; Enable the timer 1 compare A interrupt
pop r16
ret
timer1_COMP_ISR:
push r16
push r26
push r27
ldi r31,high(LedMatrixColIndex)
ldi r30,low(LedMatrixColIndex)
ld r16,z
mov r26,r16
ldi r31,high(LedMatrixBuffer)
ldi r30,low(LedMatrixBuffer)
add r30,r16
clr r16
adc r31,r16
ld r27,z
call ledmatrix_display_col
inc r26
cpi r26,8
brne timer1_COMP_ISR_CONT
ldi r26,0 ;if r26 = 8, reset to 0
timer1_COMP_ISR_CONT:
ldi r31,high(LedMatrixColIndex)
ldi r30,low(LedMatrixColIndex)
st z,r26
pop r27
pop r26
pop r16
reti