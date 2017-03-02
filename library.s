	AREA   LIBRARY, CODE, READWRITE


	EXPORT uart_init
	EXPORT pin_connect_block_setup_for_uart0
	EXPORT read_character
	EXPORT output_character
	EXPORT read_string
	EXPORT output_string
	EXPORT display_digit_on_7_seg
	EXPORT read_from_push_btns
	EXPORT illuminateLEDs
	EXPORT illuminate_RGB_LED
	EXPORT div_and_mod


; Constants
U0LSR   EQU 0x14       		; UART0 Line Status Register 
PINSEL0 EQU 0xE002C000		;pin select 0
UART0   EQU 0xE000C000		;Base address of UART0
IOBASE  EQU 0xE0028000
IO0CLR  EQU 0xC
IO1CLR  EQU 0x1C
IO0SET  EQU 0x4
IO1SET  EQU 0x14
IO1PIN  EQU 0x10  
IO0DIR  EQU 0x8  ; GPIO Direction Register Port 0 Address
IO1DIR  EQU 0x18  ; GPIO Direction Register Port 1 Address

	ALIGN
digits_SET		
		DCD 0x00001F80  ; 0
 		DCD 0x00000300  ; 1 
		DCD 0x00002D80  ; 2
		DCD 0x00002780  ; 3
		DCD 0x00003300  ; 4
		DCD 0x00003680  ; 5
		DCD 0x00003E80  ; 6
		DCD 0x00000380  ; 7
		DCD 0x00003F80  ; 8
		DCD 0x00003780  ; 9
		DCD 0x00003B80  ; 10 (A)
		DCD 0x00003E00  ; 11 (b)
		DCD 0x00001C80  ; 12 (C)
		DCD 0x00002F00  ; 13 (d)
		DCD 0x00003C80  ; 14 (E)
		DCD 0x00003880  ; 15 (F)
		DCD 0x00000000  ; 16 (clear)
		DCD 0x00002000	; 17 (-)
	ALIGN

uart_init
	;rewrite C code serial_init 3 lines loading addresses and numbers
   STMFD sp!, {r0, r1, lr}
   ; 8-bit word length, 1 stop bit, no parity
   ; Disable break control       
   ; Enable divisor latch access           
   LDR r0, =0xE000C000
   MOV r1, #131
   STR r1, [r0, #0xC]

   ; Set lower divisor latch for 14,400 baud
   MOV r1, #80
   STR r1, [r0]

   ; Set upper divisor latch for 9,600 baud
   MOV r1, #0
   STR r1, [r0, #4]

   ; 8-bit word length, 1 stop bit, no parity,  
   ; Disable break control                     
   ; Disable divisor latch access
   MOV r1, #3
   STR r1, [r0, #0xC]

   LDMFD sp!, {r0, r1, lr} 
   BX lr 

pin_connect_block_setup_for_uart0 
   STMFD sp!, {r0, r1, lr} 
   LDR r0, =0xE002C000  ; PINSEL0 
   LDR r1, [r0] 
   ORR r1, r1, #5 
   BIC r1, r1, #0xA 
   STR r1, [r0] 
   LDMFD sp!, {r0, r1, lr} 
   BX lr 


; Takes NONE
; Returns NONE
read_character
	STMFD SP!,{lr} 			; Store register lr on stack
	LDR r0, =0xE000C000		; Load base address
read_char_loop
	LDRB r1, [r0, #U0LSR]	; Add offset
	AND r1, #0x01			; Set all bytes to zero except RDR
	CMP r1, #0x01			; Compare RDR to 1
	BNE read_char_loop		; Go back to start if 0
	LDR r2, [r0]			; Read byte from recieve reg
	LDMFD sp!, {lr}
	BX lr


; Takes NONE
; Returns NONE
output_character 
	STMFD SP!,{lr, r0, r1} 	; Store registers r0, r1, r2 on stack
	LDR r0, =0xE000C000		; Load base address
output_char_loop
	LDRB r1, [r0, #U0LSR]	; Add offset
	AND r1, #0x20			; Set all bytes to zero except THRE
	CMP r1, #0x20			; Compare THRE to 1
	BNE output_char_loop	; Go back to start if 0
	STRB r2, [r0]			; Store byte in transmit register
	LDMFD sp!, {lr, r0, r1}
	BX lr


; Takes NONE
; Returns r4=input number from -9999 to 9999
read_string
    ;reads a string and stores it as a null-terminated string in memory.
    ;User terminates the string by hitting Enter.
    ;Base address of the string should be passed into the routine in r4.
	STMFD SP!, {lr, r2}
	MOV r6, #0				; Initialize sign flag
	MOV r5, #0xA			; r5 will multiply by 10
	MOV r4, #0
read_string_loop
    BL read_character		; Read the first input
	CMP r2, #0x0D			; Check if enter was pushed
	BEQ check_sign          ; If enter was pushed stop read_string
	CMP r2, #0x2D
	BNE not_negative		; Check if "-"
	MOV r6, #1
	BL output_character
	B   read_string_loop
not_negative
	BL output_character		; Output the input to the terminal
	SUB r2, r2, #0x30		; Convert from ASCII to dec
    MUL r4, r5, r4			; Move the previous input to the next tens spot
	ADD r4, r4, r2			; Add the new input to the ones spot
	B read_string_loop		; Check for next input
check_sign	
	CMP r6, #0				; If flag is not set, end the loop
	BEQ end_read_str
	 
	MVN r4, r4				; If flag is set, Two's complement
	ADD r4, r4, #1	       
end_read_str
	LDMFD SP!, {lr, r2}
	BX lr
	;range -9999 ~ +9999
    ;repeat read_character until ENTER(0x0D) key is entered.

	;if past range, disp error (change string and send to output string) 
	;Push it to a memory location
	;return base address of the string into the routine in r4
	
; Takes NONE
; Returns NONE
output_string
	STMFD SP!,{lr, r2, r3} ; Store registers lr, r2, r3 on stack
output_str_loop
	LDRB r2, [r3], #1		; Load first byte of prompt and post increment one byte	
	CMP r2, #0				; Check if null character
	BLNE output_character 	; Output character
	CMP r2, #0				; Check if null character
	BNE output_str_loop		; check next character
	LDMFD sp!, {lr, r2, r3} 
	BX lr		



display_digit_on_7_seg
	LDR r0, =IOBASE		    ; Load base address
    LDR r1, [r0, #IO0DIR]	; Load Port 0 GPIO Direction Register
    ORR r1, r1,  #0x3F80	; Set Port 0 Pin 7~13 as output
    STR r1, [r0, #IO0DIR]	;
	STMFD SP!, {r1, r3, lr }
	LDR r1, =0xE0028000
	LDR r3, =digits_SET
	MOV r4, r4, LSL #2
	LDR r2, [r3, r4]
	STR r2, [r1]
	LDMFD SP!, {r1, r3, lr }
	BX lr

read_from_push_btns
	STMFD SP!, {r1, r2, lr}

    LDR r1, =0XE0028010   	; load I01PIN address
    LDR r0, [r1]          	; load IO1PIN address on r0
    AND r0, r0, #0xF00000 	; Look only pins 20-23

    MOV r0, r0, LSR #20   	; Shift to most-right for byte
	EOR r0, r0, #0xF	  	; Invert the last byte data
	
    BL illuminateLEDs     	; Light up LEDs
	LDMFD SP!, {r1, r2, lr}
	BX lr

; takes in r4,
;r4=0x0	turn 4 leds on
;r4=0x10000	turn 3 leds on
;r4=0x30000	turn 2 leds on
;r4=0x70000	turn 1 leds on
;r4=0xF0000	turn 0 leds on 
illuminateLEDs
	STMFD SP!, {r1, r2, lr}
    LDR r6, =IOBASE		    ; Load base address
    LDR r1, [r6, #IO1DIR]	; Load Port 1 GPIO Direction Register
    ORR r1, r1, #0xF0000	; Set Port 1. Pin 16~19 as output
    STR r1, [r6, #IO1DIR]

    LDR r1, =IOBASE	    	; load base address

	MOV r2, #0xF0000   		; SET LED - pins 20-23 in IO1CLR this turns them
    STR r2, [r1, #IO1CLR]	; all off by storing 0xF0000 on IO1CLR address

	; Clear the LEDs wanted on by putting a zero in IO1SET 
	STR r4, [r1, #IO1SET]	 ; IO1SET  EQU 0x14

	LDMFD SP!, {r1, r2, lr}	
	BX lr

; red is port 17, blue is 18, and green is 21
illuminate_RGB_LED
	STMFD SP!, {lr, r0, r2 }
	LDR r0, =0xE002C004  	; PINSEL1 address
	LDR r1, [r0]
	LDR r2, = 0xC30C
	BIC r1, r1, r2			; Clear bits 5:2, 11:10 This sets 
							; P0.17, P0.18 and P0.21 as pin 
							; connect blocks to use.
	STR r1, [r0]
	
	LDR r0, =0xE0028008		; PORT0 IODIR address
	LDR r1, [r0]
	ORR r1, r1, #0x260000 	; set bits 17, 18, 21 to 1 for output
	STR r1, [r0]

	CMP r4, #0
	BEQ set_red
	CMP r4, #1
	BEQ set_green
	CMP r4, #2
	BEQ set_blue
	CMP r4, #3
	BEQ set_purple
	CMP r4, #4
	BEQ set_yellow
	CMP r4, #5
	BEQ set_white
	CMP r4, #6
	BEQ set_off
set_red
	LDR r0, =0xE0028004		; PORT0 IOSET address
	LDR r1, [r0]
	ORR r1, r1, #0x240000	; set pin 18 and 21, green=off, blue=off
	STR r1, [r0]
	
	LDR r0, =0xE002800C	   	; PORT0 IOCLR address
	LDR r1, [r0]
	ORR r1, r1, #0x20000	 ; set pin 17, red=on
	STR r1, [r0]
	LDMFD SP!, {lr, r0, r2 }
	BX lr
set_green
	LDR r0, =0xE0028004		; PORT0 IOSET address
	LDR r1, [r0]
	ORR r1, r1, #0x60000	; set pin 17 and 18, red=off, blue=off
	STR r1, [r0]
	
	LDR r0, =0xE002800C	   	; PORT0 IOCLR address
	LDR r1, [r0]
	ORR r1, r1, #0x200000	; set pin 21, green=on
	STR r1, [r0]
	LDMFD SP!, {lr, r0, r2 }
	BX lr
set_blue
	LDR r0, =0xE0028004		; PORT0 IOSET address
	LDR r1, [r0]
	ORR r1, r1, #0x220000	; set pin 17 and 21, red=off, green=off
	STR r1, [r0]
	
	LDR r0, =0xE002800C	   	; PORT0 IOCLR address
	LDR r1, [r0]
	ORR r1, r1, #0x40000	; set pin 18, blue=on
	STR r1, [r0]
	LDMFD SP!, {lr, r0, r2 }
	BX lr
set_purple
	LDR r0, =0xE0028004		; PORT0 IOSET address
	LDR r1, [r0]
	ORR r1, r1, #0x200000	; set pin 18, green=off
	STR r1, [r0]
	
	LDR r0, =0xE002800C	   	; PORT0 IOCLR address
	LDR r1, [r0]
	ORR r1, r1, #0x60000	; set pin 17 and 18, red=on blue=on
	STR r1, [r0]
	LDMFD SP!, {lr, r0, r2 }
	BX lr
set_yellow
	LDR r0, =0xE0028004		; PORT0 IOSET address
	LDR r1, [r0]
	ORR r1, r1, #0x40000	; set pin 18, blue=off
	STR r1, [r0]
	
	LDR r0, =0xE002800C	   	; PORT0 IOCLR address
	LDR r1, [r0]
	ORR r1, r1, #0x220000	; set pin 17 and 21, red=on green=on
	STR r1, [r0]
	LDMFD SP!, {lr, r0, r2 }
	BX lr
set_white
	LDR r0, =0xE002800C	   	; PORT0 IOCLR address
	LDR r1, [r0]
	ORR r1, r1, #0x260000	; set pin 17, 18, and 21 red=on green=on blue=on
	STR r1, [r0]
	LDMFD SP!, {lr, r0, r2 }
	BX lr
set_off
	LDR r0, =0xE0028004		; PORT0 IOSET address
	LDR r1, [r0]
	ORR r1, r1, #0x260000	; set pin 17, 18, 21 red=off, blue=off and green=off
	STR r1, [r0]
	LDMFD SP!, {lr, r0, r2 }
	BX lr
	
	
; Takes r0=dividend, r1=divisor
; Returns r0=quotient, r1=remainder	
div_and_mod
	STMFD r13!, {r2-r12, r14}
			
	; Your code for the signed division/mod routine goes here.  
	; The dividend is passed in r0 and the divisor in r1.
	; The quotient is returned in r0 and the remainder in r1. 
	 MOV r2, #17   ; Initialize 16 bit counter
	 MOV r3, #0    ; Initialize Quotient
	 MOV r4, #0    ; Initialize the sign for the dividend and divisor. 0,2=positive, 1=negative
	 CMP r0, #0    ; check if dividend is negative
	 BGT POSI
	 MVN r0, r0    ; One's compliment for dividend
	 ADD r0, r0, #1; Two's compliment for r0
	 MOV r4, #1    ; Reminder that dividend is negative
POSI CMP r1, #0    ; Check if divisor is negative
	 BGT POS2      
	 MVN r1, r1    ; One's compliment for divisor
	 ADD r1, r1, #1; Two's compliment for divisor
	 ADD r4, r4, #1; Sign for the dividend and divisor. 0,2=positive, 1=negative

POS2 LSL r1, #16   ; Shift divisor by number of bits

LOOP SUB r2, r2, #1; decrement the counter
     SUB r0, r0, r1; Calculate the remainder
     CMP r0, #0    ; Is remainder less than zero
	 BLT YES       ;	
	 
     MOV r3, r3, LSL #1    ; Left Shift Quotient LSB = 1
     ADD r3 ,#1    ;   
 	 BL  WOW       ;
	 
YES  ADD r0, r0, r1; Calculate the remainder
     MOV r3, r3, LSL #1;
	 
WOW	 MOV r1, r1, ROR #1; rotate the divisor right
	 
	 CMP r2, #0    ; See if counter is positive
	 BGT LOOP      ; If positive, loop
	 
	 CMP r4, #1; Check if dividend was negative
	 BNE DONE  ;
	 MVN r3, r3; Convert the quotient to negative
	 ADD r3, r3, #1; by using Two's compliment
DONE MOV r1, r0; Move the remainder to the r1 register
	 MOV r0, r3; Move the quotient into r0 register 
	 
	LDMFD r13!, {r2-r12, r14}
	BX lr      ; Return to the C program	   

	
	END



