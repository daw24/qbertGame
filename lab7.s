	AREA interrupts, CODE, READWRITE
	EXPORT lab7
	EXPORT FIQ_Handler
	
	EXTERN pin_connect_block_setup_for_uart0 
	EXTERN uart_init
	EXTERN read_character
	EXTERN output_character
	EXTERN read_string
	EXTERN output_string
	EXTERN div_and_mod
	EXTERN illuminateLEDs
	EXTERN illuminate_RGB_LED
	EXTERN display_digit_on_7_seg


GAME_BOARD = "                               SCORE 000",10,10,10,13,\
"           _____",10,13,"          ////Q/|",10,13,\
"         /____/ |____",10,13,"         |    | /////|",10,13,\
"         |____|/___/ |____",10,13,"         /////|   | //////|",\
10,13,"        /___/ |___|/____/ |_____",10,13,"        |   | /////",\
"|    | //////|",10,13,"        |___|/___/ |____|/____/ |____",10,13,\
"        /////|   | //////|    | /////|",10,13,"       /___/ |___|/",\
"____/ |____|/___/ |____",10,13,"       |   | /////|    | //////|",\
"   | /////|",10,13,"       |___|/___/ |____|/____/ |___|/___/ |",10,13,\
"      /////|   | //////|    | /////|    | /",10,13,"     /___/ |___|/",\
"____/ |____|/___/ |____|/",10,13,"    |    | /////|    |//////|    | /",\
10,13,"    |____|/___/ |____/____/ |____|/",10,13,"   //////|    | ///",\
"//|    | /",10,13,"  /____/ |____|/___/ |____|/",10,13,"  |    | /////",\
"|    | /",10,13,"  |____|/___/ |____|/",10,13," //////|    | /",10,13,\
"/____/ |____|/",10,13,"|    | /",10,13,"|____|/",10,13,0


INTRO = "          Welcome to ARM QBERT",10,10,10,13,"Instructions:",10,13,\
"Qbert is represented by a Q, balls are represented by a O, ",10,13,\
"the snake ball is a C, and the snake is an S.",10,10,13,\
"Use the w, a, s, d keys to move up, left, down, and right ",10,13,\
"respectively.",10,10,13,\
"Qbert starts the game with four lives. Getting hit by a ",10,13,\
"ball, or snake removes a life. Jumping off the side of the ",10,13,\
"pyramid also costs one one life.",10,10,13,\
"Unexplored squares are shaded with ////. Explore all squares",10,13,\
"to advance to the next level.",10,10,13,\
"The game is over after 2 minutes, or all four lives have ",10,13,\
"been lost.",10,10,13,\
"Press the space bar at anytime to exit the game.",10,10,13,\
"Press the ARM push button at anytime to pause the game.",10,13,\
"No inputs will be accepted until the game is unpaused by ",10,13,\
"pushing the ARM push button again.",10,10,13,\
"Press g at anytime to start a new game.",10,10,13,\
"Press g now to start...",10,13,0

GAME_OVER = "               Game Over      Score: 000",10,10,10,10,13,\
"               Press g to play again",10,13,\
"               Press space bar to exit",0

TEST_TIMER1 = "    timer 1   ",10,13,0


	ALIGN
Q_X_POSITION DCD 15	; Starting x=15
Q_Y_POSITION DCD 5	; Starting y=5
Q_DIRECTION DCD 0	;0=none, 1=up, 2=left, 3=down, 4=right
Q_SQUARE DCD 1
BALL1_X_POSITION DCD 0	
BALL1_Y_POSITION DCD 0
BALL1_DIRECTION DCD 0
BALL1_SQUARE DCD 0
BALL2_X_POSITION DCD 0	
BALL2_Y_POSITION DCD 0
BALL2_DIRECTION DCD 0
BALL2_SQUARE DCD 0
SNAKEBALL_X_POSITION DCD 0	
SNAKEBALL_Y_POSITION DCD 0
SNAKEBALL_DIRECTION DCD 0
SNAKEBALL_SQUARE DCD 0
SNAKE_X_POSITION DCD 0	
SNAKE_Y_POSITION DCD 0
SNAKE_DIRECTION DCD 0
SNAKE_SQUARE DCD 0
LEVEL DCD 1
LIVES DCD 4
SQUARE
	DCD 0			; 0
	DCD 0			; 1
	DCD 0			; 2
	DCD 0			; 3
	DCD 0			; 4
	DCD 0			; 5
	DCD 0			; 6
	DCD 0			; 7
	DCD 0			; 8
	DCD 0			; 9
	DCD 0			; 10
	DCD 0			; 11
	DCD 0			; 12
	DCD 0			; 13
	DCD 0			; 14
	DCD 0			; 15
	DCD 0			; 16
	DCD 0			; 17
	DCD 0			; 18
	DCD 0			; 29
	DCD 0			; 20
	DCD 0		    ; 21
SCORE DCD 0
BLINK DCD 0
Q_MOVES DCD 1
INC_TIMER_FLAG DCD 0 	; 0=up to date, 1=needs to be updated
NUM_BALLS DCD 0
NUM_HALF_SECS DCD 0
IS_PAUSED DCD 0	 		; 0=running, 1=paused	
BALL1_FELL_OFF DCD 0		; Set if falls off
BALL2_FELL_OFF DCD 0		; Set if falls off
SNAKEBALL_FELL_OFF DCD 0		; Set if falls off
IS_GAMEOVER_SCREEN DCD 0		; Set when at game over screen
DISPLAY_CURSE DCD 0
Q_RECENTLY_HIT = 0 		; Set when Q has been hit
	
    ALIGN
	 	
lab7
	STMFD sp!, {lr}
	;;;;;; TODO hide cursor????
	BL uart_init
	BL pin_connect_block_setup_for_uart0 
	BL interrupt_init

	MOV r2, #0x0C					; ASCII 0x0C is for new page
	BL output_character				; Clear the screen		
	; Seven-seg starts with a 0
	MOV r4, #0
	BL display_digit_on_7_seg 
	; RGB LED starts as white
	MOV r4, #5
	BL illuminate_RGB_LED			; Set RGB LCD to white
	; Display intro/instructions
	LDR r3, =INTRO
	BL output_string
	
	; Loop at intro screen until player starts a new game or quits
endlessLoop
	ADD r0, r0, #0					; NOP
 	B endlessLoop			

newGame
	STMFD SP!, {r0-r5, r9, lr}   	; Save registers
	MOV r2, #0x0C					; ASCII 0x0C is for new page
	BL output_character				; Clear the screen

	; is no longer at the game over screen
	LDR r0, =IS_GAMEOVER_SCREEN		 ; clear variable
	MOV r1, #0
	STRB r1, [r0]

	; set ball 1 and 2, snakeball and snake to no square
	LDR r0, =BALL1_SQUARE		
  	MOV r1, #0
	STR r1, [r0]
	; set ball2 to no square
	LDR r0, =BALL2_SQUARE		
	STR r1, [r0]
	; set snakeball to no square
	LDR r0, =SNAKEBALL_SQUARE		
	STR r1, [r0]
	; set snake to no square
	LDR r0, =SNAKE_SQUARE		
	STR r1, [r0]

	; Do not continue to blink after a new game is started
	LDR r0, =BLINK
	MOV r1, #0				
	STR r1, [r0]

	; Reset 2s spawn timer to 0
	LDR r4, =NUM_HALF_SECS					
	MOV r5, #0
	STR r5, [r4]

	; Reset SCORE to 0
	LDR r4, =SCORE					
	MOV r5, #0
	STR r5, [r4]

	; Reset NUM_BALLS to 0		  
	LDR r4, =NUM_BALLS					
	MOV r5, #0
	STR r5, [r4]

	; Reset all SQUAREs to 0
	BL resetAllSquares
					   
	; Reset LEVEL to 1
	LDR r4, =LEVEL					
	MOV r5, #1
	STR r5, [r4]
	
	; Reset LIVES to 4
	LDR r4, =LIVES					; Set the LIVES to 4
	MOV r5, #4
	STR r5, [r4]
	
	MOV r4, #1							   		
	BL display_digit_on_7_seg		; Display current level (1)
	MOV r4, #1
	BL illuminate_RGB_LED			; Set RGB LCD to green when game running
	
	; turn all four leds on
	MOV r4, #0x00					
	BL illuminateLEDs				; Set all 4 LCDs to on
						
	; Reset Q to starting position
	LDR r4, =Q_X_POSITION
	MOV r5, #15	
	STR r5, [r4]					; store new xPos	
	LDR r4, =Q_Y_POSITION
	MOV r5, #5
	STR r5, [r4]					; store new yPos
	
	; Reset Q_DIRECTION to 0 = none
	LDR r4, =Q_DIRECTION
	MOV r5, #0
	STR r5, [r4]					; store new direction
	
	; Display the game board
	LDR r3, =GAME_BOARD
	BL output_string				
	
	
	; Enable timer0
	LDR r2, =0xE000401C 			; Address of Match Register 0 (MR0)
	;LDR r0, =36864000	  			; timeout period of the timer (2s)
	;LDR r0, =18432000	  			; timeout period of the timer (1s) 
	LDR r0, =9216000	  			; timeout period of the timer (0.5s)
	;LDR r0, =8755200	  			; timeout period of the timer (0.45s)						   	
	STR r0, [r2]												
	LDR r0, =0xE0004004				; (T0TCR) Timer 0 timer control reg
	LDR r1, [r0]
	ORR r1, r1, #1					; set bit 0 to 1 to enable, or 0 to disable
	STR r1, [r0]
	
	; Enable timer1
	LDR r2, =0xE000801C 			; Address of Match Register 1 (MR1)
	;LDR r0, =36864000	  			; timeout period of the timer (2s)
	;LDR r0, =92160000	  			; timeout period of the timer (5s)
	LDR r0, =2211840000	  			; timeout period of the timer (120s)
	STR r0, [r2]
	LDR r0, =0xE0008004				; (T1TCR) Timer 1 timer control reg
	LDR r1, [r0]
	ORR r1, r1, #1					; set bit 0 to 1 to enable, or 0 to disable
	STR r1, [r0]
	BL interrupt_init
	LDMFD SP!, {r0-r5, r9, lr} 		; Restore registers
	BX lr


resetAllSquares
	STMFD SP!, {r0-r5, lr}   	; Save registers
	; Reset all SQUAREs to 0
	LDR r3, =SQUARE
	MOV r5, #0
resetNextSquare

	; Clear SQUARE to reset			
	MOV r2, #0
	STR r2, [r3, r5, LSL #2 ]
	ADD r5, r5, #1
	CMP r5, #22
	BLT resetNextSquare
	LDMFD SP!, {r0-r5, lr} 		; Restore registers
	BX lr

;;;;; TODO PURPLE AT GAME OVER
gameOver
	STMFD SP!, {r0-r3, lr}   		; Save registers
	MOV r2, #0x0C					; ASCII 0x0C is for new page
	BL output_character				; Clear the screen
	; Display Game Over screen
	LDR r3, =GAME_OVER
	BL output_string
	; Update score += lives left * 25
	LDR r0, =LIVES
	LDR r1, [r0]
	MOV r2, #25
	MUL r2, r1, r2
	LDR r0, =SCORE
	LDR r1, [r0]
	ADD r1, r2, r1
	STR r1, [r0]
	BL updateScore
	;BL interrupt_init
	; Disable timer0
	LDR r0, =0xE0004004				; (T0TCR) Timer 0 timer control reg
	LDR r1, [r0]
	AND r1, r1, #0					; set bit 0 to 1 to enable, or 0 to disable
	STRB r1, [r0]
	; Disable timer1
	LDR r0, =0xE0008004				; (T1TCR) Timer 1 timer control reg
	LDR r1, [r0]
	AND r1, r1, #0					; set bit 0 to 1 to enable, or 0 to disable
	STRB r1, [r0]					
	LDR r0, =IS_GAMEOVER_SCREEN		 ; set for game over screen
	MOV r1, #1
	STRB r1, [r0]				   
	LDMFD SP!, {r0-r3, lr} 			; Restore registers
	BX lr
	
increaseLevel
	STMFD SP!, {r0-r5, lr}   	; Save registers
	; THIS DOESNT WORK
	; pause the game while increaseing the level
	LDR r0, =IS_GAMEOVER_SCREEN				
	MOV r1, #1
	STRB r1, [r0]
	; Increase level by one and update 7-seg display
	LDR r0, =LEVEL				
	LDR r4, [r0]
	ADD r4, r4, #1
	STR r4, [r0]							   		
	BL display_digit_on_7_seg		; Display current level (takes arg in r4) 
	
	; Update score +100
	LDR r3, =SCORE
	LDR r2, [r3]
	ADD r2, r2, #100				; Player gets 100 points for completing a level
	STR r2, [r3]

  	; Reset Q to starting position
	LDR r4, =Q_X_POSITION
	MOV r5, #15	
	STR r5, [r4]				; store new xPos	
	LDR r4, =Q_Y_POSITION
	MOV r5, #5
	STR r5, [r4]				; store new yPos	
	; Reset Q_DIRECTION to 0 = none
	LDR r4, =Q_DIRECTION
	MOV r5, #0
	STR r5, [r4]				; store new direction
	; set ball1 to no square
	LDR r0, =BALL1_SQUARE		
  	MOV r1, #0
	STR r1, [r0]
	; set ball2 to no square
	LDR r0, =BALL2_SQUARE		
	STR r1, [r0]

	; Display the game board
	MOV r2, #0x0C					; ASCII 0x0C is for new page
	BL output_character				; Clear the screen	
	LDR r3, =GAME_BOARD
	BL output_string
	
	; Set flag to increase speed
	LDR r4, =INC_TIMER_FLAG
	MOV r5, #1	   
	STR r5, [r4]
	
	; TODO clear balls and snakes and rest spawns
	; Reset 2s spawn timer to 0
	LDR r4, =NUM_HALF_SECS					
	MOV r5, #0
	STR r5, [r4]
	; Number of balls -= 1
	LDR r4, =NUM_BALLS			
	LDR r5, [r4]
	SUB r5, r5, #1	
	STR r5, [r4]

	; Reset all SQUAREs to 0
	BL resetAllSquares

	; THIS DOESNT WORK
	; unpause the game after increasing level
	LDR r0, =IS_GAMEOVER_SCREEN				
	MOV r1, #0
	STRB r1, [r0]

	LDMFD SP!, {r0-r5, lr} 			; Restore registers
	BX lr

removeQ
	STMFD SP!, {r0-r5, lr}   	; Save registers
	LDR r4, =Q_X_POSITION		
	LDR r5, =Q_Y_POSITION
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r1, #10					; divisor
	LDR r0, [r5]				; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = xPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = xPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x3B				; ;
	BL output_character
	MOV r1, #10					; divisor
	LDR r0, [r4]				; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = yPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = yPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x66				; f
	BL output_character
	MOV r2, #0x20				; space
	BL output_character			
	BL interrupt_init				
	LDMFD SP!, {r0-r5, lr} 		; Restore registers
	BX lr             	   		; Return


redrawQ
	STMFD SP!, {r0-r8, lr}   	; Save registers
	LDR r3, =Q_DIRECTION
	LDR r8, [r3]
	LDR r4, =Q_X_POSITION
	LDR r6, [r4]		
	LDR r5, =Q_Y_POSITION
	LDR r7, [r5]
	CMP r8, #0					; direction = none
	BEQ savePosition
	CMP r8, #1					; direction = up
	ADDEQ r6, r6, #2			; new x = x+2
	SUBEQ r7, r7, #4			; new y = y-4
	BEQ savePosition
	CMP r8, #2					; direction = left
	SUBEQ r6, r6, #5			; new x = x-5
	SUBEQ r7, r7, #2			; new y = y-2
	BEQ savePosition
	CMP r8, #3					; direction = down
	SUBEQ r6, r6, #2			; new x = x-2
	ADDEQ r7, r7, #4			; new y = y+4
	BEQ savePosition
	CMP r8, #4					; direction = right
	ADDEQ r6, r6, #5			; new x = x+5
	ADDEQ r7, r7, #2			; new y = y+2
savePosition
	STR r6, [r4]				; store new xPos
	STR r7, [r5]				; store new yPos
	; draw a Q
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r1, #10					; divisor
	MOV r0, r7					; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = xPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = xPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x3B				; ;
	BL output_character
	MOV r1, #10					; divisor
	MOV r0, r6					; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = yPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = yPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x66				; f
	BL output_character
	MOV r2, #0x51				; Q
	BL output_character
	LDR r0, =Q_X_POSITION
	LDR r2, =Q_SQUARE
	BL updateSquare
	; Only clear the square if player has lives left 
	; this is to prevent spaces in game over screen
	LDR r3, =LIVES				
	LDR r4, [r3] 
	CMP r4, #0
	BLNE clearSquare
	; Check if all spaces cleared to see if player reached next level
	LDR r3, =SQUARE
	MOV r5, #1	  ;2
nextSquare
	LDR r4, [r3, r5, LSL #2]
	CMP r4, #0					; 0 if not cleared
	BEQ notClear
	ADD r5, r5, #1
	CMP r5, #22
	BLT nextSquare
	BL increaseLevel	
notClear
	BL interrupt_init
	LDMFD SP!, {r0-r8, lr} 		; Restore registers
	BX lr             	   		; Return

;r0=objects x position 
;r2=objects square
updateSquare
	STMFD SP!, {r5, lr}   	; Save registers
	LDR r5, [r0]
	CMP r5, #15			
	MOVEQ r1, #1
	BEQ doneSquare		
	CMP r5, #13		
	MOVEQ r1, #2
	BEQ doneSquare		
	CMP r5, #20 		
	MOVEQ r1, #3
	BEQ doneSquare		
	CMP r5, #11 	
	MOVEQ r1, #4
	BEQ doneSquare
	CMP r5, #18			
	MOVEQ r1, #5
	BEQ doneSquare		
	CMP r5, #25		
	MOVEQ r1, #6
	BEQ doneSquare		
	CMP r5, #9 		
	MOVEQ r1, #7
	BEQ doneSquare		
	CMP r5, #16 	
	MOVEQ r1, #8
	BEQ doneSquare
	CMP r5, #23			
	MOVEQ r1, #9
	BEQ doneSquare		
	CMP r5, #30		
	MOVEQ r1, #10
	BEQ doneSquare		
	CMP r5, #7 		
	MOVEQ r1, #11
	BEQ doneSquare		
	CMP r5, #14 	
	MOVEQ r1, #12
	BEQ doneSquare
	CMP r5, #21			
	MOVEQ r1, #13
	BEQ doneSquare		
	CMP r5, #28		
	MOVEQ r1, #14
	BEQ doneSquare		
	CMP r5, #35		
	MOVEQ r1, #15
	BEQ doneSquare		
	CMP r5, #5 	
	MOVEQ r1, #16
	BEQ doneSquare
	CMP r5, #12 	
	MOVEQ r1, #17
	BEQ doneSquare
	CMP r5, #19			
	MOVEQ r1, #18
	BEQ doneSquare		
	CMP r5, #26		
	MOVEQ r1, #19
	BEQ doneSquare		
	CMP r5, #33		
	MOVEQ r1, #20
	BEQ doneSquare		
	CMP r5, #40 	
	MOVEQ r1, #21
	BEQ doneSquare
	BL fallOff				 	; Q/enemy is off pyramid if not on a square
	B offSquare
doneSquare
	STR r1, [r2] 				; Store the new square
offSquare
	LDMFD SP!, {r5, lr} 		; Restore registers
	BX lr


;r0=objects x position 
;r2=objects square
fallOff
	STMFD SP!, {r4-r5, lr}   	; Save registers
	; Check if Q, or ball fell off pyramid
	LDR r1, =Q_X_POSITION
	CMP r0, r1
	BEQ qFell
	LDR r1, =SNAKEBALL_X_POSITION
	CMP r0, r1
	BEQ snakeBallFell
	LDR r1, =BALL2_X_POSITION
	CMP r0, r1
	BEQ ball2Fell
	LDR r4, =BALL1_FELL_OFF			; set O_FELL_OFF
	MOV r5, #1	
	STR r5, [r4]
	BL removeBall1
	B oFell
snakeBallFell
   	LDR r4, =SNAKEBALL_FELL_OFF			; set SANKEBALL_FELL_OFF
	MOV r5, #1	
	STR r5, [r4]
	BL removeSnakeBall
	B oFell
ball2Fell
   	LDR r4, =BALL2_FELL_OFF			; set O_FELL_OFF
	MOV r5, #1	
	STR r5, [r4]
	BL removeBall2	
	B oFell
qFell	
	BL removeQ					
	; Reset Q to starting position
	LDR r4, =Q_X_POSITION
	MOV r5, #15	
	STR r5, [r4]				; store new xPos	
	LDR r4, =Q_Y_POSITION
	MOV r5, #5
	STR r5, [r4]				; store new yPos
	; Reset Q_DIRECTION to 0 = none
	LDR r4, =Q_DIRECTION
	MOV r5, #0
	STR r5, [r4]				; store new direction
	BL removeLife
oFell
	LDMFD SP!, {r4-r5, lr} 		; Restore registers
	BX lr 


removeLife
	STMFD SP!, {r3-r5, lr}   	; Save registers
	; Blink RGB LED red 5 times
	; Set BLINK to 10 which will be decremented 10 times and 
	; blink each time
	LDR r3, =BLINK				
	MOV r5, #10	
	STR r5, [r3]				; store new BLINK
	BL blinkOnDeath	
	; Remove a life
	LDR r3, =LIVES				
	LDR r5, [r3] 
	SUB r5, #1
	STR r5, [r3]
	; Update lives LEDs
	CMP r5, #3
	LDREQ r4, =0x10000	   	;turn 3 leds on
	CMP r5, #2
	LDREQ r4, =0x30000	   	;turn 2 leds on
	CMP r5, #1
	LDREQ r4, =0x70000	   	;turn 1 leds on
	CMP r5, #0
	LDREQ r4, =0xF0000	   	;turn 0 leds on
	BL illuminateLEDs
	CMP r5, #0
	BLEQ gameOver
	CMP r5, #0 							   		
	BEQ qDead					; Do not need to update new Q position if game over
	BL redrawQ
qDead		
	LDMFD SP!, {r3-r5, lr} 		; Restore registers
	BX lr 

blinkOnDeath
	STMFD SP!, {r0-r5, lr}   	; Save registers
	LDR r3, =BLINK				; check if BLINK is 0
	LDR r5, [r3]
	CMP r5, #0
	MOVEQ r4, #1				; Set RGB back to green when zero
	BEQ noBlinks				; if BLINK is 0 do not blink
	; If BLINK is non-zero check if even or odd
	MOV r1, #2					; divisor
	MOV r0, r5					; dividend
	BL div_and_mod
	CMP r1, #0			   		; even if remainder = 0
	MOVEQ r4, #0				; SET RGB LED to red when even
	MOVGT r4, #6				; Set RGB LED to off when odd
	; Decrement BLINK
	SUB r5, r5, #1
	STR r5, [r3]					  	
noBlinks
	BL illuminate_RGB_LED 
	LDMFD SP!, {r0-r5, lr} 		; Restore registers
	BX lr 				
			
clearSquare	
	STMFD SP!, {r3-r5, lr}   	; Save registers
	LDR r3, =Q_SQUARE
	LDR r4, [r3]
	CMP r4, #1
	BLEQ clearLLL
	CMP r4, #2
	BLEQ clearLL
	CMP r4, #3
	BLEQ clearLL
	CMP r4, #5
	BLEQ clearLL
	CMP r4, #4
	BLEQ clearLR
	CMP r4, #7
	BLEQ clearLR
	CMP r4, #8
	BLEQ clearLR
	CMP r4, #12
	BLEQ clearLR
	CMP r4, #15
	BLEQ clearLR
	CMP r4, #17
	BLEQ clearLR
	CMP r4, #18
	BLEQ clearLR
	CMP r4, #20
	BLEQ clearLR
	CMP r4, #21
	BLEQ clearLR
	CMP r4, #9
	BLEQ clearLLR
	CMP r4, #10
	BLEQ clearLLR
	CMP r4, #11
	BLEQ clearLLR
	CMP r4, #13
	BLEQ clearLLR
	CMP r4, #16
	BLEQ clearLLR
	CMP r4, #19
	BLEQ clearLLR
	CMP r4, #6
	BLEQ clearLLL
	CMP r4, #14
	BLEQ clearLRR			
	LDMFD SP!, {r3-r5, lr} 		; Restore registers
	BX lr
	LTORG  						; Literal poop too distant

clearLL
	STMFD SP!, {r2-r6, lr}   	; Save registers
	; Check if space is already clear
	LDR r3, =SQUARE
	LDR r4, =Q_SQUARE
	LDR r5, [r4]
	MOV r5, r5, LSL #2
	LDR r6, [r3, r5]
	CMP r6, #0					; 0 if not cleared
	BNE alreadyClrLL
	; Move curosr left 3, and write 2 spaces
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r2, #0x33				; 3
	BL output_character
	MOV r2, #0x44				; D
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	; Set SQUARE to show its already been cleared
	MOV r2, #1
	STR r2, [r3, r5]
	; Update SCORE
	LDR r3, =SCORE
	LDR r2, [r3]
	ADD r2, r2, #10				; Player gets 10 point for unexplored square
	STR r2, [r3]
alreadyClrLL
	LDMFD SP!, {r2-r6, lr} 		; Restore registers
	BX lr

clearLR
 	STMFD SP!, {r2-r6, lr}   	; Save registers
	; Check if space is already clear
	LDR r3, =SQUARE
	LDR r4, =Q_SQUARE
	LDR r5, [r4]
	MOV r5, r5, LSL #2
	LDR r6, [r3, r5]
	CMP r6, #0					; 0 if not cleared
	BNE alreadyClrLR
	; Move curosr left 2, and write 1 space
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r2, #0x32				; 2
	BL output_character
	MOV r2, #0x44				; D
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	; Move cursor right 1, and write 1 space
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r2, #0x31				; 1
	BL output_character
	MOV r2, #0x43				; C
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	; Set SQUARE to show its already been cleared
	MOV r2, #1
	STR r2, [r3, r5]
	; Update SCORE
	LDR r3, =SCORE
	LDR r2, [r3]
	ADD r2, r2, #10				; Player gets 10 point for unexplored square
	STR r2, [r3]
alreadyClrLR
	LDMFD SP!, {r2-r6, lr} 		; Restore registers
	BX lr

clearLLR
	STMFD SP!, {r2-r6, lr}   	; Save registers
	LDR r3, =SQUARE
	LDR r4, =Q_SQUARE
	LDR r5, [r4]
	MOV r5, r5, LSL #2
	LDR r6, [r3, r5]
	CMP r6, #0					; 0 if not cleared
	BNE alreadyClrLLR
	; Move curosr left 3, and write 2 spaces
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r2, #0x33				; 3
	BL output_character
	MOV r2, #0x44				; D
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	; Move cursor right 1, and write 1 space
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r2, #0x31				; 1
	BL output_character
	MOV r2, #0x43				; C
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	; Set SQUARE to show its already been cleared
	MOV r2, #1
	STR r2, [r3, r5]
	; Update SCORE
	LDR r3, =SCORE
	LDR r2, [r3]
	ADD r2, r2, #10				; Player gets 10 point for unexplored square
	STR r2, [r3]
alreadyClrLLR
	LDMFD SP!, {r2-r6, lr} 		; Restore registers
	BX lr

clearLLL
 	STMFD SP!, {r2-r6, lr}   	; Save registers
	LDR r3, =SQUARE
	LDR r4, =Q_SQUARE
	LDR r5, [r4]
	MOV r5, r5, LSL #2
	LDR r6, [r3, r5]
	CMP r6, #0					; 0 if not cleared
	BNE alreadyClrLLL
	; Move curosr left 4, and write 3 spaces
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r2, #0x34				; 4
	BL output_character
	MOV r2, #0x44				; D
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	; Set SQUARE to show its already been cleared
	MOV r2, #1
	STR r2, [r3, r5]
	; Update SCORE
	LDR r3, =SCORE
	LDR r2, [r3]
	ADD r2, r2, #10				; Player gets 10 point for unexplored square
	STR r2, [r3]
alreadyClrLLL
	LDMFD SP!, {r2-r6, lr} 		; Restore registers
	BX lr

clearLRR
	STMFD SP!, {r2-r6, lr}   	; Save registers
	LDR r3, =SQUARE
	LDR r4, =Q_SQUARE
	LDR r5, [r4]
	MOV r5, r5, LSL #2
	LDR r6, [r3, r5]
	CMP r6, #0					; 0 if not cleared
	BNE alreadyClrLRR
	; Move curosr left 2, and write 1 spaces
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r2, #0x32				; 2
	BL output_character
	MOV r2, #0x44				; D
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	; Move cursor right 1, and write 2 space
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r2, #0x31				; 1
	BL output_character
	MOV r2, #0x43				; C
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	; Set SQUARE to show its already been cleared
	MOV r2, #1
	STR r2, [r3, r5]
	; Update SCORE
	LDR r3, =SCORE
	LDR r2, [r3]
	ADD r2, r2, #10				; Player gets 10 point for unexplored square
	STR r2, [r3]
alreadyClrLRR
	LDMFD SP!, {r2-r6, lr} 		; Restore registers
	BX lr

updateScore
	STMFD SP!, {r2-r4, lr}   	; Save registers
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r2, #1					; move to line 1				
	BL output_character
	MOV r2, #0x3B				; ;
	BL output_character
	MOV r2, #0x33				; move to column 39			
	BL output_character
	MOV r2, #0x39								
	BL output_character
	MOV r2, #0x66				; f
	BL output_character
	; Redraw SCORE
	LDR r3, =SCORE
	LDR r4, [r3]
	MOV r1, #1000				; divisor
	MOV r0, r4					; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = thousands digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r0, r1					; Move remainder to dividend
	MOV r1, #100				; divisor
	BL div_and_mod
	MOV r2, r0					; quotient = hundreds digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r0, r1					; Move remainder to dividend
	MOV r1, #10					; divisor
	BL div_and_mod
	MOV r2, r0					; quotient = tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	LDMFD SP!, {r2-r4, lr} 		; Restore registers
	BX lr


spawnEnemy
	STMFD SP!, {r2-r4, lr}   	; Save registers
	; dont spawn an enemy if one is currently at square 2 or 3
	LDR r2, =BALL1_SQUARE 
	LDR r1, [r2]
	CMP r1, #2					
	BEQ noSpawn	
	CMP r1, #3					
	BEQ noSpawn	
	LDR r2, =BALL2_SQUARE 
	LDR r1, [r2]
	CMP r1, #2					
	BEQ noSpawn	
	CMP r1, #3					
	BEQ noSpawn	
	LDR r2, =SNAKEBALL_SQUARE 
	LDR r1, [r2]
	CMP r1, #2					
	BEQ noSpawn	
	CMP r1, #3					
	BEQ noSpawn		
	; 1 in 4 chance to spawn enemy (called every 0.5s)
	MOV r3, #4	;8
	BL randomNum
	CMP r1, #0
	BNE noSpawn	   	
	; otherwise spawn enemy
	LDR r3, =NUM_BALLS
	LDR r2, [r3]
	ADD r2, r2, #1				; Increase number of balls by 1
	STR r2, [r3]			  
	; pick random number (r1=0 or r1=1)	
	MOV r3, #2
	BL randomNum
	CMP r1, #1
	BEQ square3
	; add ball to square 2 on pyramid
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r2, #0x39				; move to line 9				
	BL output_character
	MOV r2, #0x3B				; ;
	BL output_character
	MOV r2, #0x31				; move to column 13			
	BL output_character
	MOV r2, #0x33								
	BL output_character
	MOV r2, #0x66				; f
	BL output_character
	;MOV r2, #0x6F				; o
	;BL output_character
	; Check which ball to spawn
	LDR r2, =SNAKE_SQUARE 
	LDR r1, [r2]
	CMP r1, #0					; do not spawn snakeball if snake spawned
	BGT	checkBall1
	LDR r2, =SNAKEBALL_SQUARE 
	LDR r1, [r2]
	CMP r1, #0					; if snakeball square is 0, chance to spawn
	BNE checkBall1
	; 1-8 chance for snake ball
	MOV r3, #2 ;;;;;;;;;8;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	BL randomNum
	CMP r1, #0
	BNE checkBall1
	; Set ball x and y position
	MOV r2, #0x43				; C
	BL output_character
	LDR r3, =SNAKEBALL_X_POSITION
	MOV r2, #13
	STR r2, [r3]	
	LDR r3, =SNAKEBALL_Y_POSITION
	MOV r2, #9
	STR r2, [r3]
	LDR r2, =SNAKEBALL_SQUARE 		; ball's square = 
	MOV r1, #2
	STRB r1, [r2]
	BL square2
checkBall1
	LDR r2, =BALL1_SQUARE 
	LDR r1, [r2]
	CMP r1, #0					; if ball1 square is 0, spawn ball1
	BNE spawnBall2at2			; otherwise spawn ball2
	; Set ball x and y position
	MOV r2, #0x6F				; o
	BL output_character
	LDR r3, =BALL1_X_POSITION
	MOV r2, #13
	STR r2, [r3]	
	LDR r3, =BALL1_Y_POSITION
	MOV r2, #9
	STR r2, [r3]
	LDR r2, =BALL1_SQUARE 		; ball's square = 
	MOV r1, #2
	STRB r1, [r2]
	BL square2
spawnBall2at2
	MOV r2, #0x6F				; o
	BL output_character
	LDR r3, =BALL2_X_POSITION
	MOV r2, #13
	STR r2, [r3]	
	LDR r3, =BALL2_Y_POSITION
	MOV r2, #9
	STR r2, [r3]
	LDR r2, =BALL2_SQUARE 		; ball's square = 
	MOV r1, #2
	STRB r1, [r2]
	BL square2
square3
	; add ball to square 3 on pyramid
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r2, #0x37				; move to line 7				
	BL output_character
	MOV r2, #0x3B				; ;
	BL output_character
	MOV r2, #0x32				; move to column 20			
	BL output_character
	MOV r2, #0x30								
	BL output_character
	MOV r2, #0x66				; f
	BL output_character
	;MOV r2, #0x6F				; o
	;BL output_character
	; Check which ball to spawn
	LDR r2, =SNAKEBALL_SQUARE 
	LDR r1, [r2]
	CMP r1, #0					; if snakeball square is 0, chance to spawn
	BNE checkBall1Sqr3
	; 1-8 chance for snake ball
	MOV r3, #8
	BL randomNum
	CMP r1, #0
	BNE checkBall1Sqr3
	; Set ball x and y position
	MOV r2, #0x43				; C
	BL output_character
	LDR r3, =SNAKEBALL_X_POSITION
	MOV r2, #20
	STR r2, [r3]	
	LDR r3, =SNAKEBALL_Y_POSITION
	MOV r2, #7
	STR r2, [r3]
	LDR r2, =SNAKEBALL_SQUARE 		; ball's square = 
	MOV r1, #3
	STRB r1, [r2]
	BL square2
checkBall1Sqr3
	LDR r2, =BALL1_SQUARE 
	LDR r1, [r2]
	CMP r1, #0					; if ball1 square is 0, spawn ball1
	BNE spawnBall2at3			; otherwise spawn ball2
	; Set ball x and y position
	MOV r2, #0x6F				; o
	BL output_character
	LDR r3, =BALL1_X_POSITION
	MOV r2, #20
	STR r2, [r3]	
	LDR r3, =BALL1_Y_POSITION
	MOV r2, #7
	STR r2, [r3]
	LDR r2, =BALL1_SQUARE 		
	MOV r1, #3
	STRB r1, [r2]
	BL square2
spawnBall2at3
	MOV r2, #0x6F				; o
	BL output_character
	LDR r3, =BALL2_X_POSITION
	MOV r2, #20
	STR r2, [r3]	
	LDR r3, =BALL2_Y_POSITION
	MOV r2, #7
	STR r2, [r3]
	LDR r2, =BALL2_SQUARE 		; ball's square = 
	MOV r1, #3
	STRB r1, [r2]
noSpawn
square2
	LDMFD SP!, {r2-r4, lr} 		; Restore registers
	BX lr

spawnSnake
	STMFD SP!, {r0-r7, lr}   	; Save registers
	LDR r6, =SNAKE_X_POSITION	; r6 = snake x position	address
	LDR r3, [r6]				; r3 = snake x position
	LDR r7, =SNAKE_Y_POSITION	; r7 = snake y position address
	LDR r4, [r7]
	; draw a S
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r1, #10					; divisor
	MOV r0, r4					; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = xPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = xPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x3B				; ;
	BL output_character
	MOV r1, #10					; divisor
	MOV r0, r3					; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = yPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = yPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x66				; f
	BL output_character
	MOV r2, #0x53				; S
	BL output_character
	LDMFD SP!, {r0-r7, lr} 		; Restore registers
	BX lr


removeSnake
	STMFD SP!, {r0-r5, lr}   	; Save registers
	LDR r4, =SNAKE_X_POSITION		
	LDR r5, =SNAKE_Y_POSITION
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r1, #10					; divisor
	LDR r0, [r5]				; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = xPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = xPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x3B				; ;
	BL output_character
	MOV r1, #10					; divisor
	LDR r0, [r4]				; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = yPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = yPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x66				; f
	BL output_character
sOnPyramid
	LDR r0, =Q_SQUARE			
	LDR r1, [r0]				; r1 = q x pos
	LDR r4, =SNAKE_SQUARE
	LDR r2, [r4]				; r2 = snake x pos
	CMP r1, r2	 
	BEQ qOnSquareS
	; Check if square has been cleared
	LDR r3, =SQUARE
	LDR r4, =SNAKE_SQUARE
	LDR r5, [r4]
	MOV r5, r5, LSL #2
	LDR r6, [r3, r5]
	CMP r6, #0					; 0 if not cleared
	BNE alreadyClrS
	MOV r2, #0x2F				; forward slash
	BL output_character	
	B allDoneS
alreadyClrS
	MOV r2, #0x20				; space
	BL output_character
	b allDone
qOnSquareS
	MOV r2, #0x51				; Q
	BL output_character
	; set snake to no square
	LDR r0, =SNAKE_SQUARE		
  	MOV r1, #0
	STR r1, [r0]
	; Remove/Reset ball and keep Q displayed on the square.
	LDR r4, =NUM_BALLS			; number of balls -= 1
	LDR r5, [r4]
	SUB r5, r5, #1	
	STR r5, [r4]			
	; Reset 2s spawn timer to 0	so new ball doesnt spawn right away
	LDR r4, =NUM_HALF_SECS					
	MOV r5, #0
	STR r5, [r4]
allDoneS
	BL interrupt_init				
	LDMFD SP!, {r0-r5, lr} 		; Restore registers
	BX lr
	LTORG

moveSnake
	STMFD SP!, {r0-r7, lr}   	; Save registers
	BL removeSnake 				; remove old S position
	;Check player's Q positon 
	LDR r0, =Q_SQUARE
	LDR r1, [r0]				; r1 = Q Square
	LDR r0, =Q_X_POSITION
	LDR r8, [r0]				; r8 = Q x pos
	LDR r0, =Q_Y_POSITION
	LDR r9, [r0]				; r9 = Q y pos
	LDR r5, =SNAKE_SQUARE		; r5 = snake square address
	LDR r2, [r5]			 	; r2 = Snake Square
	LDR r6, =SNAKE_X_POSITION	; r6 = snake x position	address
	LDR r3, [r6]				; r3 = snake x position
	LDR r7, =SNAKE_Y_POSITION	; r7 = snake y position address
	LDR r4, [r7]				; r4 = snake y position
	CMP r2, #16					; Can only move up form sq 16
	ADDEQ r3, r3, #2			; new x = x+2
	SUBEQ r4, r4, #4			; new y = y-4
	BEQ saveSnakePosition		
	CMP r2, #21					; Can only move left form sq 21	
	SUBEQ r3, r3, #5			; new x = x-5
	SUBEQ r4, r4, #2			; new y = y-2
	BEQ saveSnakePosition					
	CMP r2, #17
	BNE square18
	CMP r1, #11
	SUBEQ r3, r3, #5			; new x = x-5 	left
	SUBEQ r4, r4, #2			; new y = y-2
	BEQ saveSnakePosition
	CMP r1, #16	
	SUBEQ r3, r3, #5			; new x = x-5	left
	SUBEQ r4, r4, #2			; new y = y-2
	BEQ saveSnakePosition
	ADD r3, r3, #2				; new x = x+2 	up
	SUB r4, r4, #4				; new y = y-4
	B saveSnakePosition
square18
	CMP r2, #18
	BNE square19
	CMP r1, #1
	ADDEQ r3, r3, #2				; new x = x+2 	up
	SUBEQ r4, r4, #4				; new y = y-4
	BEQ saveSnakePosition
	CMP r1, #2
	ADDEQ r3, r3, #2				; new x = x+2 	up
	SUBEQ r4, r4, #4				; new y = y-4
	BEQ saveSnakePosition
	CMP r1, #3
	ADDEQ r3, r3, #2				; new x = x+2 	up
	SUBEQ r4, r4, #4				; new y = y-4
	BEQ saveSnakePosition
	CMP r8, #17
	SUBLT r3, r3, #5			; new x = x-5	left
	SUBLT r4, r4, #2			; new y = y-2
	BLT saveSnakePosition
	ADD r3, r3, #2				; new x = x+2 	up
	SUB r4, r4, #4				; new y = y-4
	B saveSnakePosition
square19
	CMP r2, #19
	BNE square20
	CMP r8, #24
	SUBLT r3, r3, #5			; new x = x-5	left
	SUBLT r4, r4, #2			; new y = y-2
	BLT saveSnakePosition
	ADD r3, r3, #2				; new x = x+2 	up
	SUB r4, r4, #4				; new y = y-4
	B saveSnakePosition
square20
	CMP r2, #20
	BNE square11
	CMP r1, #15
	ADDEQ r3, r3, #2			; new x = x+2 	up
	SUBEQ r4, r4, #4			; new y = y-4
	BEQ saveSnakePosition
	CMP r1, #21	
	ADDEQ r3, r3, #2			; new x = x+2 	up
	SUBEQ r4, r4, #4			; new y = y-4
	BEQ saveSnakePosition
	SUB r3, r3, #5				; new x = x-5	left
	SUB r4, r4, #2				; new y = y-2
	B saveSnakePosition
square11
	CMP r2, #20
	BNE square12
	CMP r9, #16					; if q y > 16
	ADDLT r3, r3, #2			; new x = x+2 	up
	SUBLT r4, r4, #4			; new y = y-4
	BLT saveSnakePosition
	ADD r3, r3, #5				; new x = x+5	right
	ADD r4, r4, #2				; new y = y+2
	B saveSnakePosition
square12
	CMP r2, #12
	BNE square13
	CMP r1, #17
	SUBEQ r3, r3, #2			; new x = x-2 	down
	ADDEQ r4, r4, #4			; new y = y+4
	BEQ savePosition
	CMP r1, #8
	ADDEQ r3, r3, #2			; new x = x+2 	up
	SUBEQ r4, r4, #4			; new y = y-4
	BEQ saveSnakePosition
	CMP r3, r8
	SUBGT r3, r3, #5			; new x = x-5	left
	SUBGT r4, r4, #2			; new y = y-2
	BGT saveSnakePosition
	ADDLT r3, r3, #5			; new x = x+5	right
	ADDLT r4, r4, #2			; new y = y+2
	BLT saveSnakePosition
square13
   	CMP r2, #13
	BNE square14
	CMP r1, #18
	SUBEQ r3, r3, #2			; new x = x-2 	down
	ADDEQ r4, r4, #4			; new y = y+4
	BEQ savePosition
	CMP r1, #9
	ADDEQ r3, r3, #2			; new x = x+2 	up
	SUBEQ r4, r4, #4			; new y = y-4
	BEQ saveSnakePosition
	CMP r3, r8
	SUBGT r3, r3, #5			; new x = x-5	left
	SUBGT r4, r4, #2			; new y = y-2
	BGT saveSnakePosition
	ADDLT r3, r3, #5			; new x = x+5	right
	ADDLT r4, r4, #2			; new y = y+2
	BLT saveSnakePosition
square14
	CMP r2, #14
	BNE square15
	CMP r1, #19
	SUBEQ r3, r3, #2			; new x = x-2 	down
	ADDEQ r4, r4, #4			; new y = y+4
	BEQ savePosition
	CMP r1, #10
	ADDEQ r3, r3, #2			; new x = x+2 	up
	SUBEQ r4, r4, #4			; new y = y-4
	BEQ saveSnakePosition
	CMP r3, r8
	SUBGT r3, r3, #5			; new x = x-5	left
	SUBGT r4, r4, #2			; new y = y-2
	BGT saveSnakePosition
	ADDLT r3, r3, #5			; new x = x+5	right
	ADDLT r4, r4, #2			; new y = y+2
	BLT saveSnakePosition
square15
	CMP r2, #15
	BNE square7
	CMP r1, #20
	SUBEQ r3, r3, #2			; new x = x-2 	down
	ADDEQ r4, r4, #4			; new y = y+4
	BEQ savePosition
	CMP r1, #21
	ADDEQ r3, r3, #5			; new x = x+5	right
	ADDEQ r4, r4, #2			; new y = y+2
	BEQ saveSnakePosition
	SUB r3, r3, #5			; new x = x-5	left
	SUB r4, r4, #2			; new y = y-2
	B saveSnakePosition
square7
	CMP r2, #7
	BNE square8
	CMP r1, #11
	SUBEQ r3, r3, #2			; new x = x-2 	down
	ADDEQ r4, r4, #4			; new y = y+4
	BEQ savePosition
	CMP r1, #4
	ADDEQ r3, r3, #2			; new x = x+2 	up
	SUBEQ r4, r4, #4			; new y = y-4
	BEQ saveSnakePosition
	CMP r1, #12
	ADDEQ r3, r3, #5			; new x = x+5	right
	ADDEQ r4, r4, #2			; new y = y+2
	BEQ saveSnakePosition
	ADD r3, r3, #5				; new x = x+5 	right
	ADD r4, r4, #2				; new y = y+2
	B saveSnakePosition
square8
	CMP r2, #8
	BNE square9
	CMP r1, #12
	SUBEQ r3, r3, #2			; new x = x-2 	down
	ADDEQ r4, r4, #4			; new y = y+4
	BEQ savePosition
	CMP r1, #5
	ADDEQ r3, r3, #2			; new x = x+2 	up
	SUBEQ r4, r4, #4			; new y = y-4
	BEQ saveSnakePosition
	CMP r1, #13
	ADDEQ r3, r3, #5			; new x = x+5	right
	ADDEQ r4, r4, #2			; new y = y+2
	BEQ saveSnakePosition
	CMP r1, #4
	SUBEQ r3, r3, #5			; new x = x-5	left
	SUBEQ r4, r4, #2			; new y = y-2
	BEQ saveSnakePosition
	CMP r3, r8
	SUBGT r3, r3, #5			; new x = x-5	left
	SUBGT r4, r4, #2			; new y = y-2
	BGT saveSnakePosition
	ADDLT r3, r3, #5			; new x = x+5	right
	ADDLT r4, r4, #2			; new y = y+2
	BLT saveSnakePosition
square9
	CMP r2, #9
	BNE square10
	CMP r1, #13
	SUBEQ r3, r3, #2			; new x = x-2 	down
	ADDEQ r4, r4, #4			; new y = y+4
	BEQ savePosition
	CMP r1, #6
	ADDEQ r3, r3, #2			; new x = x+2 	up
	SUBEQ r4, r4, #4			; new y = y-4
	BEQ saveSnakePosition
	CMP r1, #14
	ADDEQ r3, r3, #5			; new x = x+5	right
	ADDEQ r4, r4, #2			; new y = y+2
	BEQ saveSnakePosition
	CMP r1, #5
	SUBEQ r3, r3, #5			; new x = x-5	left
	SUBEQ r4, r4, #2			; new y = y-2
	BEQ saveSnakePosition
	CMP r3, r8
	SUBGT r3, r3, #5			; new x = x-5	left
	SUBGT r4, r4, #2			; new y = y-2
	BGT saveSnakePosition
	ADDLT r3, r3, #5			; new x = x+5	right
	ADDLT r4, r4, #2			; new y = y+2
	BLT saveSnakePosition
square10
	CMP r2, #10
	BNE square4
	CMP r1, #14
	SUBEQ r3, r3, #2			; new x = x-2 	down
	ADDEQ r4, r4, #4			; new y = y+4
	BEQ savePosition
	CMP r1, #15
	ADDEQ r3, r3, #5			; new x = x+5	right
	ADDEQ r4, r4, #2			; new y = y+2
	BEQ saveSnakePosition
	CMP r1, #6
	SUBEQ r3, r3, #5			; new x = x-5	left
	SUBEQ r4, r4, #2			; new y = y-2
	BEQ saveSnakePosition
	CMP r3, r8
	SUBGT r3, r3, #5			; new x = x-5	left
	SUBGT r4, r4, #2			; new y = y-2
	BGT saveSnakePosition
	ADDLT r3, r3, #5			; new x = x+5	right
	ADDLT r4, r4, #2			; new y = y+2
	BLT saveSnakePosition
square4
	CMP r2, #4
	BNE square5
	CMP r1, #7
	SUBEQ r3, r3, #2			; new x = x-2 	down
	ADDEQ r4, r4, #4			; new y = y+4
	BEQ savePosition
	CMP r1, #2
	ADDEQ r3, r3, #2			; new x = x+2 	up
	SUBEQ r4, r4, #4			; new y = y-4
	BEQ saveSnakePosition
	CMP r1, #1
	ADDEQ r3, r3, #2			; new x = x+2 	up
	SUBEQ r4, r4, #4			; new y = y-4
	BEQ saveSnakePosition
	ADD r3, r3, #5				; new x = x+5	right
	ADD r4, r4, #2				; new y = y+2
	B saveSnakePosition
square5
	CMP r2, #5
	BNE square6
	CMP r1, #6
	SUBEQ r3, r3, #2			; new x = x-2 	down
	ADDEQ r4, r4, #4			; new y = y+4
	BEQ savePosition
	CMP r1, #3
	ADDEQ r3, r3, #2			; new x = x+2 	up
	SUBEQ r4, r4, #4			; new y = y-4
	BEQ saveSnakePosition
	CMP r1, #1
	ADDEQ r3, r3, #2			; new x = x+2 	up
	SUBEQ r4, r4, #4			; new y = y-4
	BEQ saveSnakePosition
	CMP r1, #9
	ADDEQ r3, r3, #5			; new x = x+5	right
	ADDEQ r4, r4, #2			; new y = y+2
	BEQ saveSnakePosition
	CMP r1, #6
	ADDEQ r3, r3, #5			; new x = x+5	right
	ADDEQ r4, r4, #2			; new y = y+2
	BEQ saveSnakePosition
	CMP r1, #2
	SUBEQ r3, r3, #5			; new x = x-5	left
	SUBEQ r4, r4, #2			; new y = y-2
	BEQ saveSnakePosition
	CMP r3, r8
	SUBGT r3, r3, #5			; new x = x-5	left
	SUBGT r4, r4, #2			; new y = y-2
	BGT saveSnakePosition
	ADDLT r3, r3, #5			; new x = x+5	right
	ADDLT r4, r4, #2			; new y = y+2
	BLT saveSnakePosition
square6
	CMP r2, #6
	BNE square2_
	CMP r1, #9
	SUBEQ r3, r3, #2			; new x = x-2 	down
	ADDEQ r4, r4, #4			; new y = y+4
	BEQ savePosition
	CMP r1, #10
	ADDEQ r3, r3, #5			; new x = x+5	right
	ADDEQ r4, r4, #2			; new y = y+2
	BEQ saveSnakePosition
	CMP r1, #3
	SUBEQ r3, r3, #5			; new x = x-5	left
	SUBEQ r4, r4, #2			; new y = y-2
	BEQ saveSnakePosition
	CMP r3, r8
	SUBGT r3, r3, #5			; new x = x-5	left
	SUBGT r4, r4, #2			; new y = y-2
	BGT saveSnakePosition
	ADDLT r3, r3, #5			; new x = x+5	right
	ADDLT r4, r4, #2			; new y = y+2
	BLT saveSnakePosition
square2_
	CMP r2, #2
	BNE square3_
	CMP r1, #4
	SUBEQ r3, r3, #2			; new x = x-2 	down
	ADDEQ r4, r4, #4			; new y = y+4
	BEQ savePosition
	CMP r1, #1
	ADDEQ r3, r3, #2			; new x = x+2 	up
	SUBEQ r4, r4, #4			; new y = y-4
	BEQ saveSnakePosition
	CMP r8, #15
	ADDGT r3, r3, #5				; new x = x+5	right
	ADDGT r4, r4, #2				; new y = y+2
	BGT saveSnakePosition
	SUB r3, r3, #2				; new x = x-2 	down
	ADD r4, r4, #4				; new y = y+4
	B savePosition
square3_
	CMP r2, #3
	BNE square1
	CMP r1, #6
	ADDEQ r3, r3, #5			; new x = x+5	right
	ADDEQ r4, r4, #2			; new y = y+2
	BEQ saveSnakePosition
	CMP r1, #1
	SUBEQ r3, r3, #5			; new x = x-5	left
	SUBEQ r4, r4, #2			; new y = y-2
	BEQ saveSnakePosition
	CMP r9, #13
	SUBGT r3, r3, #2				; new x = x-2 	down
	ADDGT r4, r4, #4				; new y = y+4
	BGT savePosition
	ADD r3, r3, #5			; new x = x+5	right
	ADD r4, r4, #2			; new y = y+2
	B saveSnakePosition
square1
	CMP r1, #3
	ADDEQ r3, r3, #5			; new x = x+5	right
	ADDEQ r4, r4, #2			; new y = y+2
	BEQ saveSnakePosition
	CMP r8, #31
	ADDGT r3, r3, #5			; new x = x+5	right
	ADDGT r4, r4, #2			; new y = y+2
	BGT saveSnakePosition
	SUB r3, r3, #2				; new x = x-2 	down
	ADD r4, r4, #4				; new y = y+4
	B savePosition
	

saveSnakePosition
	STR r3, [r6]				; store new xPos
	STR r4, [r7]				; store new yPos
	; draw a S
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r1, #10					; divisor
	MOV r0, r4					; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = xPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = xPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x3B				; ;
	BL output_character
	MOV r1, #10					; divisor
	MOV r0, r3					; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = yPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = yPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x66				; f
	BL output_character
	MOV r2, #0x53				; S
	BL output_character
	LDR r0, =SNAKE_X_POSITION	; store snakes new position
	LDR r2, =SNAKE_SQUARE
	BL updateSquare
	LDMFD SP!, {r0-r7, lr} 		; Restore registers
	BX lr

moveSnakeBall
	STMFD SP!, {r0-r7, lr}   	; Save registers
	BL removeSnakeBall 			; remove old C position
	; Check if snake ball is on bottom of pyramid
	LDR r4, =SNAKEBALL_SQUARE
	LDR r0, [r4]
	CMP r0, #16					 ; if snake ball is on square 2-15 move normal
	BLT normalMove
	; remove snake ball	and set snake starting position								
	LDR r0, =SNAKEBALL_X_POSITION 
	LDR r2, =SNAKE_X_POSITION
	LDR r3, [r0]
	STR r3, [r2]				; snake x pos = snakeball x pos 
	MOV r1, #0
	STR r1, [r0]				; clear snakeball x pos
	LDR r0, =SNAKEBALL_Y_POSITION
	LDR r2, =SNAKE_Y_POSITION
	LDR r3, [r0]
	STR r3, [r2]				; snake y pos = snakeball y pos 
	STR r1, [r0]				; clear snakeball y pos
	LDR r0, =SNAKEBALL_SQUARE
	LDR r2, =SNAKE_SQUARE
	LDR r3, [r0]
	STR r3, [r2]				; snake square = snakeball square 			
	STR r1, [r0]	; clear snakeball square
	; Remove/Reset ball and keep Q displayed on the square.
	LDR r4, =NUM_BALLS			; number of balls -= 1
	LDR r5, [r4]
	SUB r5, r5, #1	
	STR r5, [r4]			
	BL spawnSnake
	B snakeSpawned
normalMove
	; pick random number (r1=0 or r1=1)	
	MOV r3, #2
	BL randomNum
	LDR r4, =SNAKEBALL_X_POSITION
	LDR r6, [r4]		
	LDR r5, =SNAKEBALL_Y_POSITION
	LDR r7, [r5]
	CMP r1, #0					; direction = down
	SUBEQ r6, r6, #2			; new x = x-2
	ADDEQ r7, r7, #4			; new y = y+4
	BEQ saveSBallPosition
	CMP r1, #1					; direction = right
	ADDEQ r6, r6, #5			; new x = x+5
	ADDEQ r7, r7, #2			; new y = y+2
saveSBallPosition
	STR r6, [r4]				; store new xPos
	STR r7, [r5]				; store new yPos
	; draw a C
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r1, #10					; divisor
	MOV r0, r7					; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = xPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = xPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x3B				; ;
	BL output_character
	MOV r1, #10					; divisor
	MOV r0, r6					; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = yPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = yPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x66				; f
	BL output_character
	MOV r2, #0x43				; C
	BL output_character
	LDR r0, =SNAKEBALL_X_POSITION
	LDR r2, =SNAKEBALL_SQUARE
	BL updateSquare
snakeSpawned
	LDMFD SP!, {r0-r7, lr} 		; Restore registers
	BX lr


moveBall1
	STMFD SP!, {r0-r7, lr}   	; Save registers
	BL removeBall1 				; remove old o position
	;BL removeBall2
	; pick random number (r1=0 or r1=1)	
	MOV r3, #2
	BL randomNum
	LDR r4, =BALL1_X_POSITION
	LDR r6, [r4]		
	LDR r5, =BALL1_Y_POSITION
	LDR r7, [r5]
	CMP r1, #0					; direction = down
	SUBEQ r6, r6, #2			; new x = x-2
	ADDEQ r7, r7, #4			; new y = y+4
	BEQ saveBallPosition
	CMP r1, #1					; direction = right
	ADDEQ r6, r6, #5			; new x = x+5
	ADDEQ r7, r7, #2			; new y = y+2
saveBallPosition
	STR r6, [r4]				; store new xPos
	STR r7, [r5]				; store new yPos
	; draw a o
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r1, #10					; divisor
	MOV r0, r7					; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = xPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = xPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x3B				; ;
	BL output_character
	MOV r1, #10					; divisor
	MOV r0, r6					; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = yPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = yPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x66				; f
	BL output_character
	MOV r2, #0x6F				; o
	BL output_character
	LDR r0, =BALL1_X_POSITION
	LDR r2, =BALL1_SQUARE
	BL updateSquare
	LDMFD SP!, {r0-r7, lr} 		; Restore registers
	BX lr

moveBall2
	STMFD SP!, {r0-r7, lr}   	; Save registers
	BL removeBall2
	; pick random number (r1=0 or r1=1)	
	MOV r3, #2
	BL randomNum
	LDR r4, =BALL2_X_POSITION
	LDR r6, [r4]		
	LDR r5, =BALL2_Y_POSITION
	LDR r7, [r5]
	CMP r1, #0					; direction = down
	SUBEQ r6, r6, #2			; new x = x-2
	ADDEQ r7, r7, #4			; new y = y+4
	BEQ saveBall2Position
	CMP r1, #1					; direction = right
	ADDEQ r6, r6, #5			; new x = x+5
	ADDEQ r7, r7, #2			; new y = y+2
saveBall2Position
	STR r6, [r4]				; store new xPos
	STR r7, [r5]				; store new yPos
	; draw a o
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r1, #10					; divisor
	MOV r0, r7					; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = xPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = xPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x3B				; ;
	BL output_character
	MOV r1, #10					; divisor
	MOV r0, r6					; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = yPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = yPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x66				; f
	BL output_character
	MOV r2, #0x6F				; o
	BL output_character
	LDR r0, =BALL2_X_POSITION
	LDR r2, =BALL2_SQUARE
	BL updateSquare
	LDMFD SP!, {r0-r7, lr} 		; Restore registers
	BX lr


removeSnakeBall
	STMFD SP!, {r0-r5, lr}   	; Save registers
	LDR r4, =SNAKEBALL_X_POSITION		
	LDR r5, =SNAKEBALL_Y_POSITION
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r1, #10					; divisor
	LDR r0, [r5]				; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = xPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = xPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x3B				; ;
	BL output_character
	MOV r1, #10					; divisor
	LDR r0, [r4]				; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = yPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = yPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x66				; f
	BL output_character
	; Check if C is off the pyramid
	LDR r4, =SNAKEBALL_FELL_OFF			
	LDRB r5, [r4]
	CMP r5, #1	
	BNE cOnPyramid
	MOV r2, #0x20				; space
	BL output_character
	B resetSBall
cOnPyramid
	LDR r0, =Q_SQUARE			
	LDR r1, [r0]				; r1 = q x pos
	LDR r4, =SNAKEBALL_SQUARE
	LDR r2, [r4]				; r2 = ball x pos
	CMP r1, r2	 
	BEQ qOnSquareC
	; Check if square has been cleared
	LDR r3, =SQUARE
	LDR r4, =SNAKEBALL_SQUARE
	LDR r5, [r4]
	MOV r5, r5, LSL #2
	LDR r6, [r3, r5]
	CMP r6, #0					; 0 if not cleared
	BNE alreadyClrC
	MOV r2, #0x2F				; forward slash
	BL output_character	
	B allDoneC
alreadyClrC
	MOV r2, #0x20				; space
	BL output_character
	b allDone
qOnSquareC
	MOV r2, #0x51				; Q
	BL output_character
resetSBall
	; set ball to no square
	LDR r0, =SNAKEBALL_SQUARE		
  	MOV r1, #0
	STR r1, [r0]			
	LDR r4, =SNAKEBALL_FELL_OFF			; clear O_FELL_OFF
	MOV r5, #0	
	STR r5, [r4]
	; Remove/Reset ball and keep Q displayed on the square.
	LDR r4, =NUM_BALLS			; number of balls -= 1
	LDR r5, [r4]
	SUB r5, r5, #1	
	STR r5, [r4]
	; Reset 2s spawn timer to 0	so new ball doesnt spawn right away
	LDR r4, =NUM_HALF_SECS					
	MOV r5, #0
	STR r5, [r4]
allDoneC
	BL interrupt_init				
	LDMFD SP!, {r0-r5, lr} 		; Restore registers
	BX lr


removeBall1
	STMFD SP!, {r0-r5, lr}   	; Save registers
	LDR r4, =BALL1_X_POSITION		
	LDR r5, =BALL1_Y_POSITION
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r1, #10					; divisor
	LDR r0, [r5]				; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = xPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = xPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x3B				; ;
	BL output_character
	MOV r1, #10					; divisor
	LDR r0, [r4]				; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = yPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = yPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x66				; f
	BL output_character

	; Check if o is off the pyramid
	LDR r4, =BALL1_FELL_OFF			
	LDRB r5, [r4]
	CMP r5, #1	
	BNE oOnPyramid
	MOV r2, #0x20				; space
	BL output_character
	B resetBall

oOnPyramid
	LDR r0, =Q_SQUARE			
	LDR r1, [r0]				; r1 = q x pos
	LDR r4, =BALL1_SQUARE
	LDR r2, [r4]				; r2 = ball x pos
	CMP r1, r2	 
	BEQ qOnSquare

	; Check if square has been cleared
	LDR r3, =SQUARE
	LDR r4, =BALL1_SQUARE
	LDR r5, [r4]
	MOV r5, r5, LSL #2
	LDR r6, [r3, r5]
	CMP r6, #0					; 0 if not cleared
	BNE alreadyClr
	MOV r2, #0x2F				; forward slash
	BL output_character	
	B allDone

alreadyClr
	MOV r2, #0x20				; space
	BL output_character
	b allDone

qOnSquare
	MOV r2, #0x51				; Q
	BL output_character

resetBall
	; set ball to no square
	LDR r0, =BALL1_SQUARE		
  	MOV r1, #0
	STR r1, [r0]			
	LDR r4, =BALL1_FELL_OFF			; clear O_FELL_OFF
	MOV r5, #0	
	STR r5, [r4]
	; Remove/Reset ball and keep Q displayed on the square.
	LDR r4, =NUM_BALLS			; number of balls -= 1
	LDR r5, [r4]
	SUB r5, r5, #1	
	STR r5, [r4]
	; Reset 2s spawn timer to 0	so new ball doesnt spawn right away
	LDR r4, =NUM_HALF_SECS					
	MOV r5, #0
	STR r5, [r4]

allDone
	BL interrupt_init				
	LDMFD SP!, {r0-r5, lr} 		; Restore registers
	BX lr
		
removeBall2
	STMFD SP!, {r0-r5, lr}   	; Save registers
	LDR r4, =BALL2_X_POSITION		
	LDR r5, =BALL2_Y_POSITION
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r1, #10					; divisor
	LDR r0, [r5]				; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = xPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = xPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x3B				; ;
	BL output_character
	MOV r1, #10					; divisor
	LDR r0, [r4]				; dividend
	BL div_and_mod
	MOV r2, r0					; quotient = yPos tens digit
	ADD r2, r2, #0x30			; convert to ascii				
	BL output_character
	MOV r2, r1					; remiander = yPos ones digit
	ADD r2, r2, #0x30			; convert to ascii
	BL output_character
	MOV r2, #0x66				; f
	BL output_character

	; Check if o is off the pyramid
	LDR r4, =BALL2_FELL_OFF			
	LDRB r5, [r4]
	CMP r5, #1	
	BNE o2OnPyramid
	MOV r2, #0x20				; space
	BL output_character
	B resetBall2

o2OnPyramid
	LDR r0, =Q_SQUARE			
	LDR r1, [r0]				; r1 = q x pos
	LDR r4, =BALL2_SQUARE
	LDR r2, [r4]				; r2 = ball x pos
	CMP r1, r2	 
	BEQ qOnSquare2

	; Check if square has been cleared
	LDR r3, =SQUARE
	LDR r4, =BALL2_SQUARE
	LDR r5, [r4]
	MOV r5, r5, LSL #2
	LDR r6, [r3, r5]
	CMP r6, #0					; 0 if not cleared
	BNE alreadyClr2
	MOV r2, #0x2F				; forward slash
	BL output_character	
	B allDone

alreadyClr2
	MOV r2, #0x20				; space
	BL output_character
	b allDone

qOnSquare2
	MOV r2, #0x51				; Q
	BL output_character

resetBall2
	; set ball to no square
	LDR r0, =BALL2_SQUARE		
  	MOV r1, #0
	STR r1, [r0]			
	LDR r4, =BALL2_FELL_OFF			; clear O_FELL_OFF
	MOV r5, #0	
	STR r5, [r4]
	; Remove/Reset ball and keep Q displayed on the square.
	LDR r4, =NUM_BALLS			; number of balls -= 1
	LDR r5, [r4]
	SUB r5, r5, #1	
	STR r5, [r4]
	; Reset 2s spawn timer to 0	so new ball doesnt spawn right away
	LDR r4, =NUM_HALF_SECS					
	MOV r5, #0
	STR r5, [r4]

allDone2
	BL interrupt_init				
	LDMFD SP!, {r0-r5, lr} 		; Restore registers
	BX lr    


; return a random 0 or 1 in r1 (remainder)
; r3 = 1-r3 random number returned in r0
randomNum
	STMFD SP!, {r3, lr}   			; Save registers
	LDR r2, =0xE0008008			; Load Timer1 (T1TC) address
	; Load least sig byte from current time into r0
	LDRB r0, [r2]				; dividend
	; Randomize the dividend more
	LDR r2, =Q_SQUARE
	LDRB r1, [r2]
	ADD r0, r0, r1
	LDR r2, =Q_X_POSITION
	LDRB r1, [r2]
	ADD r0, r0, r1
	LDR r2, =Q_Y_POSITION
	LDRB r1, [r2]
	ADD r0, r0, r1
	LDR r2, =LIVES
	LDRB r1, [r2]
	ADD r0, r0, r1
	MOV r1, r3	
	;MOV r1, #2					; divisor
	BL div_and_mod 
   	LDMFD SP!, {r3, lr} 			; Restore registers
	BX lr

setAllSqrsTo0
	STMFD SP!, {r0, r1, lr}   			; Save registers
	; set ball 1 and 2, snakeball and snake to no square
	LDR r0, =BALL1_SQUARE		
  	MOV r1, #0
	STR r1, [r0]
	; set ball2 to no square
	LDR r0, =BALL2_SQUARE		
	STR r1, [r0]
	; set snakeball to no square
	LDR r0, =SNAKEBALL_SQUARE		
	STR r1, [r0]
	; set snake to no square
	LDR r0, =SNAKE_SQUARE		
	STR r1, [r0]
	LDR r0, =NUM_BALLS		
  	MOV r1, #0
	STR r1, [r0]
	LDMFD SP!, {r0, r1, lr} 			; Restore registers
	BX lr

; check if Q x position = 0 x position
didoHitQ
	STMFD SP!, {lr}   			; Save registers
	LDR r0, =Q_DIRECTION
	MOV r1, #0
	STR r1, [r0]
	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =SNAKE_SQUARE
  	LDR r2, [r0]				; r2 = snake x pos
	CMP r1, r2
	BLEQ removeLife
	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =SNAKE_SQUARE
  	LDR r2, [r0]				; r2 = snake x pos
	CMP r1, r2
	BLEQ qCurse
	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =SNAKE_SQUARE
  	LDR r2, [r0]				; r2 = snake x pos
	CMP r1, r2
	BLEQ removeSnakeBall
	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =SNAKE_SQUARE
  	LDR r2, [r0]				; r2 = snake x pos
	CMP r1, r2
	BLEQ removeBall1
	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =SNAKE_SQUARE
  	LDR r2, [r0]				; r2 = snake x pos
	CMP r1, r2
	BLEQ removeBall2
	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =SNAKE_SQUARE
  	LDR r2, [r0]				; r2 = snake x pos
	CMP r1, r2
	BLEQ removeSnake
;	BEQ setAllSqrsTo0
	BEQ doneHit

	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =SNAKEBALL_SQUARE
  	LDR r2, [r0]				; r2 = snakeball x pos
	CMP r1, r2
	BLEQ removeLife
	;BLEQ removeSnakeBall
	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =SNAKEBALL_SQUARE
  	LDR r2, [r0]				; r2 = snakeball x pos
	CMP r1, r2
	BLEQ qCurse
	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =SNAKEBALL_SQUARE
  	LDR r2, [r0]				; r2 = snakeball x pos
	CMP r1, r2
	BLEQ removeSnake
	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =SNAKEBALL_SQUARE
  	LDR r2, [r0]				; r2 = snakeball x pos
	CMP r1, r2
	BLEQ removeBall1
	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =SNAKEBALL_SQUARE
  	LDR r2, [r0]				; r2 = snakeball x pos
	CMP r1, r2
	BLEQ removeBall2
	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =SNAKEBALL_SQUARE
  	LDR r2, [r0]				; r2 = snakeball x pos
	CMP r1, r2
	BLEQ removeSnakeBall
	;BEQ setAllSqrsTo0
	BEQ doneHit

	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =BALL1_SQUARE
  	LDR r2, [r0]				; r2 = ball1 x pos
	CMP r1, r2
	BLEQ removeLife
	;BLEQ removeBall1
	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =BALL1_SQUARE
  	LDR r2, [r0]				; r2 = ball1 x pos
	CMP r1, r2
	BLEQ qCurse
	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =BALL1_SQUARE
  	LDR r2, [r0]				; r2 = ball1 x pos
	CMP r1, r2
	BLEQ removeSnake
	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =BALL1_SQUARE
  	LDR r2, [r0]				; r2 = ball1 x pos
	CMP r1, r2
	BLEQ removeSnakeBall
	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =BALL1_SQUARE
  	LDR r2, [r0]				; r2 = ball1 x pos
	CMP r1, r2
	BLEQ removeBall2
	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =BALL1_SQUARE
  	LDR r2, [r0]				; r2 = ball1 x pos
	CMP r1, r2
	BLEQ removeBall1
	;BEQ setAllSqrsTo0
	BEQ doneHit

	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =BALL2_SQUARE
  	LDR r2, [r0]				; r2 = ball2 x pos
	CMP r1, r2
	BLEQ removeLife
	;BLEQ removeBall2
	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =BALL2_SQUARE
  	LDR r2, [r0]				; r2 = ball2 x pos
	CMP r1, r2
	BLEQ qCurse
	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =BALL2_SQUARE
  	LDR r2, [r0]				; r2 = ball2 x pos
	CMP r1, r2
	BLEQ removeSnake
	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =BALL2_SQUARE
  	LDR r2, [r0]				; r2 = ball2 x pos
	CMP r1, r2
	BLEQ removeSnakeBall
	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =BALL2_SQUARE
  	LDR r2, [r0]				; r2 = ball2 x pos
	CMP r1, r2
	BLEQ removeBall1
	LDR r0, =Q_SQUARE			; r1 = q x pos
	LDR r1, [r0]
	LDR r0, =BALL2_SQUARE
  	LDR r2, [r0]				; r2 = ball2 x pos
	CMP r1, r2
	BLEQ removeBall2
	;BEQ setAllSqrsTo0
doneHit
	LDMFD SP!, {lr} 			; Restore registers
	BX lr

;Q'bert curses when hit by ball
qCurse
	STMFD SP!, {r3-r5, lr}   	; Save registers
	LDR r3, =Q_SQUARE
	LDR r4, [r3]
	CMP r4, #1
	BLEQ curseLLL
	CMP r4, #2
	BLEQ curseLL
	CMP r4, #3
	BLEQ curseLL
	CMP r4, #5
	BLEQ curseLL
	CMP r4, #4
	BLEQ curseLR
	CMP r4, #7
	BLEQ curseLR
	CMP r4, #8
	BLEQ curseLR
	CMP r4, #12
	BLEQ curseLR
	CMP r4, #15
	BLEQ curseLR
	CMP r4, #17
	BLEQ curseLR
	CMP r4, #18
	BLEQ curseLR
	CMP r4, #20
	BLEQ curseLR
	CMP r4, #21
	BLEQ curseLR
	CMP r4, #9
	BLEQ curseLLR
	CMP r4, #10
	BLEQ curseLLR
	CMP r4, #11
	BLEQ curseLLR
	CMP r4, #13
	BLEQ curseLLR
	CMP r4, #16
	BLEQ curseLLR
	CMP r4, #19
	BLEQ curseLLR
	CMP r4, #6
	BLEQ curseLLL
	CMP r4, #14
	BLEQ curseLRR			
	LDMFD SP!, {r3-r5, lr} 		; Restore registers
	BX lr
	LTORG  						; Literal poop too distant

curseLL
	STMFD SP!, {r2-r6, lr}   	; Save registers
	; Move curosr left 3
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r2, #0x33				; 3
	BL output_character
	MOV r2, #0x44				; D
	BL output_character
	; Check if write curse or clear curse
	LDR r0, =DISPLAY_CURSE		 
	LDR r1, [r0]
	CMP r1, #0
	BEQ writeCurseLL
	; Write 3 spaces
	MOV r2, #0x20				; space
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	LDR r0, =DISPLAY_CURSE
	MOV r1, #0
	STR r1, [r0]
	B doneLL
writeCurseLL
	MOV r2, #0x21				; !
	BL output_character
	MOV r2, #0x40				; @
	BL output_character
	MOV r2, #0x23				; #
	BL output_character
	; pause game for 4 cycles to display curse
	LDR r0, =Q_RECENTLY_HIT		 
	MOV r1, #1
	STRB r1, [r0]
	LDR r0, =DISPLAY_CURSE		 
	MOV r1, #1
	STRB r1, [r0]
doneLL
	LDMFD SP!, {r2-r6, lr} 		; Restore registers
	BX lr

curseLR
 	STMFD SP!, {r2-r6, lr}   	; Save registers
	; Check if write curse or clear curse
	LDR r0, =DISPLAY_CURSE		 
	LDR r1, [r0]
	CMP r1, #0
	BEQ writeCurseLR
	; Move curosr left 3
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r2, #0x32				; 2
	BL output_character
	MOV r2, #0x44				; D
	BL output_character
	; Write 3 spaces
	MOV r2, #0x20				; space
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	LDR r0, =DISPLAY_CURSE
	MOV r1, #0
	STR r1, [r0]
	B doneLR
writeCurseLR
	; Move curosr left 2
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r2, #0x32				; 2
	BL output_character
	MOV r2, #0x44				; D
	BL output_character
	MOV r2, #0x21				; !
	BL output_character
	MOV r2, #0x40				; @
	BL output_character
	MOV r2, #0x23				; #
	BL output_character
	; pause game for 4 cycles to display curse
	LDR r0, =Q_RECENTLY_HIT		 
	MOV r1, #1
	STRB r1, [r0]
	LDR r0, =DISPLAY_CURSE		 
	MOV r1, #1
	STRB r1, [r0]
doneLR
	LDMFD SP!, {r2-r6, lr} 		; Restore registers
	BX lr

curseLLR
	STMFD SP!, {r2-r6, lr}   	; Save registers
	; Check if write curse or clear curse
	LDR r0, =DISPLAY_CURSE		 
	LDR r1, [r0]
	CMP r1, #0
	BEQ writeCurseLLR
	; Move curosr left 3
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r2, #0x33				; 3
	BL output_character
	MOV r2, #0x44				; D
	BL output_character
	; Write 4 spaces
	MOV r2, #0x20				; space
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	LDR r0, =DISPLAY_CURSE
	MOV r1, #0
	STR r1, [r0]
	B doneLLR
writeCurseLLR
	; Move curosr left 3
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r2, #0x33				; 3
	BL output_character
	MOV r2, #0x44				; D
	BL output_character
	MOV r2, #0x21				; !
	BL output_character
	MOV r2, #0x40				; @
	BL output_character
	MOV r2, #0x23				; #
	BL output_character
	MOV r2, #0x24				; $
	BL output_character
	; pause game for 4 cycles to display curse
	LDR r0, =Q_RECENTLY_HIT		 
	MOV r1, #1
	STRB r1, [r0]
	LDR r0, =DISPLAY_CURSE		 
	MOV r1, #1
	STRB r1, [r0]
doneLLR
	LDMFD SP!, {r2-r6, lr} 		; Restore registers
	BX lr

curseLLL
 	STMFD SP!, {r2-r6, lr}   	; Save registers
	; Move curosr left 4
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r2, #0x34				; 4
	BL output_character
	MOV r2, #0x44				; D
	BL output_character
	; Check if write curse or clear curse
	LDR r0, =DISPLAY_CURSE		 
	LDR r1, [r0]
	CMP r1, #0
	BEQ writeCurseLLL
	; Write 4 spaces
	MOV r2, #0x20				; space
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	LDR r0, =DISPLAY_CURSE
	MOV r1, #0
	STR r1, [r0]
	B doneLLL
writeCurseLLL
	MOV r2, #0x21				; !
	BL output_character
	MOV r2, #0x40				; @
	BL output_character
	MOV r2, #0x23				; #
	BL output_character
	MOV r2, #0x24				; $
	BL output_character
	; pause game for 4 cycles to display curse
	LDR r0, =Q_RECENTLY_HIT		 
	MOV r1, #1
	STRB r1, [r0]
	LDR r0, =DISPLAY_CURSE		 
	MOV r1, #1
	STRB r1, [r0]
doneLLL
	LDMFD SP!, {r2-r6, lr} 		; Restore registers
	BX lr

curseLRR
	STMFD SP!, {r2-r6, lr}   	; Save registers
	
	; Check if write curse or clear curse
	LDR r0, =DISPLAY_CURSE		 
	LDR r1, [r0]
	CMP r1, #0
	BEQ writeCurseLRR
	; Move curosr left 3
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r2, #0x32				; 2
	BL output_character
	MOV r2, #0x44				; D
	BL output_character
	; Write 4 spaces
	MOV r2, #0x20				; space
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	MOV r2, #0x20				; space
	BL output_character
	LDR r0, =DISPLAY_CURSE
	MOV r1, #0
	STR r1, [r0]
	B doneLRR
writeCurseLRR
	; Move curosr left 2
	MOV r2, #0x1B				; ESC
	BL output_character			
	MOV r2, #0x5B				; [
	BL output_character
	MOV r2, #0x32				; 2
	BL output_character
	MOV r2, #0x44				; D
	BL output_character
	MOV r2, #0x21				; !
	BL output_character
	MOV r2, #0x40				; @
	BL output_character
	MOV r2, #0x23				; #
	BL output_character
	MOV r2, #0x24				; $
	BL output_character
	; pause game for 4 cycles to display curse
	LDR r0, =Q_RECENTLY_HIT	 
	MOV r1, #1
	STRB r1, [r0]
	LDR r0, =DISPLAY_CURSE		 
	MOV r1, #1
	STRB r1, [r0]
doneLRR
	LDMFD SP!, {r2-r6, lr} 		; Restore registers
	BX lr


			
interrupt_init       
		STMFD SP!, {r0-r1, lr}   	; Save registers 
		
		; Push button setup		 
		LDR r0, =0xE002C000
		LDR r1, [r0]
		ORR r1, r1, #0x20000000
		BIC r1, r1, #0x10000000
		STR r1, [r0]  ; PINSEL0 bits 29:28 = 10

		; Classify sources as IRQ or FIQ		  
		LDR r0, =0xFFFFF000
		LDR r1, [r0, #0xC]
		ORR r1, r1, #0x8000 		; External Interrupt 1
		ORR r1, r1, #0x40 			; uart0 interrupt
		ORR r1, r1, #0x30			; Timer0 and Timer1 interrupt bits 4-5
		STR r1, [r0, #0xC]

		; Enable Interrupts
		LDR r0, =0xFFFFF000
		LDR r1, [r0, #0x10] 
		ORR r1, r1, #0x8000 		; External Interrupt 1
		ORR r1, r1, #0x40 			; uart0 interrupt
		ORR r1, r1, #0x30			; Timer0 and Timer1 interrupt bits 4-5
		STR r1, [r0, #0x10]

		; External Interrupt 1 setup for edge sensitive
		LDR r0, =0xE01FC148
		LDR r1, [r0]
		ORR r1, r1, #2  			; EINT1 = Edge Sensitive
		STR r1, [r0]
		
		; UART0 Interrupt setup
		LDR r0, =0xe000C004
		LDR r1, [r0]
		ORR r1, r1, #1
		STR r1, [r0]

		; Timer0 Interrupt setup
		LDR r0, =0xE0004014					; T0MCR
		LDR r1, [r0]
		; bit 3 set to 1 generates an interrupt when MR1 = TC
		; bit 4 set to 1 resets the TC when MR1 = TC
		; bit 5 set to 1 stops the timer when MR1 = TC
		ORR r1, r1, #0x38  ;18
		STR r1, [r0]
	
		; TODO Timer1 interrupt setup
		LDR r0, =0xE0008014		  			; T1MCR
		LDR r1, [r0]
		; bit 3 set to 1 generates an interrupt when MR1 = TC
		; bit 4 set to 1 resets the TC when MR1 = TC
		; bit 5 set to 1 stops the timer when MR1 = TC
		ORR r1, r1, #0x38	 ;18
		STR r1, [r0]

		; Enable FIQ's, Disable IRQ's
		MRS r0, CPSR
		BIC r0, r0, #0x40
		ORR r0, r0, #0x80
		MSR CPSR_c, r0

		LDMFD SP!, {r0-r1, lr} 		; Restore registers
		BX lr             	   		; Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;			FIQ HANDLER 										;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FIQ_Handler
		STMFD SP!, {r0-r10, lr}   		; Save registers
		; check if at game over screen
		;LDR r0, =IS_GAMEOVER_SCREEN
		;LDR r1, [r0]
		;CMP r1, #1						; set = at game over screen
		;BEQ checkKBinterrupt		; only check for new game and quit keys

EINT1	; Check for EINT1 interrupt
		LDR r0, =0xE01FC140				; push button
		LDR r1, [r0]
		TST r1, #2						; check if 3 bit is 1			
		BEQ timer0Interrupt

		ORR r1, r1, #2					; Clear Interrupt
		STR r1, [r0]

		; check if at game over screen
		LDR r0, =IS_GAMEOVER_SCREEN
		LDR r1, [r0]
		CMP r1, #1						; set = at game over screen
		BEQ timer0Interrupt		; only check for new game and quit keys
		; check if Q recently hit
		LDR r0, =Q_RECENTLY_HIT
		LDR r1, [r0]
		CMP r1, #1						; set = at game over screen
		BEQ timer0Interrupt		; only check for new game and quit keys
		
		; Push button EINT1 Handling Code
		; Check if game is currently paused
		LDR r3, =IS_PAUSED				
		LDRB r4, [r3]
		CMP r4, #1
		BEQ unpause
		; Pause timer0
		LDR r0, =0xE0004004				; (T0TCR) Timer 0 timer control reg
		LDR r1, [r0]
		AND r1, r1, #0					; set bit 0 to 1 to enable, or 0 to disable
		STR r1, [r0]
		; Pause timer1
		LDR r0, =0xE0008004				; (T1TCR) Timer 1 timer control reg
		LDR r1, [r0]
		AND r1, r1, #0					; set bit 0 to 1 to enable, or 0 to disable
		STR r1, [r0]
		; Set pause flag
		MOV r0, #1
		STRB r0, [r3]
		; Set RGB to blue while paused
		MOV r4, #2							   		
		BL illuminate_RGB_LED			
		; Write "PAUSED" to the game
		MOV r2, #0x1B				; ESC
		BL output_character			
		MOV r2, #0x5B				; [
		BL output_character
		MOV r2, #0x31				; move to line 1				
		BL output_character
		MOV r2, #0x3B				; ;
		BL output_character
		MOV r2, #0x31				; move to column 12			
		BL output_character
		MOV r2, #0x32								
		BL output_character
		MOV r2, #0x66				; f
		BL output_character
		MOV r2, #0x50				; P
		BL output_character
		MOV r2, #0x41				; A
		BL output_character
		MOV r2, #0x55				; U
		BL output_character
		MOV r2, #0x53				; S
		BL output_character
		MOV r2, #0x45				; E
		BL output_character
		B pausedFIQExit
unpause
		; Clear pause flag
		LDR r3, =IS_PAUSED
		MOV r0, #0
		STRB r0, [r3]
		; Unpause timer0
		LDR r0, =0xE0004004				; (T0TCR) Timer 0 timer control reg
		LDR r1, [r0]
		ORR r1, r1, #1					; set bit 0 to 1 to enable, or 0 to disable
		STR r1, [r0]
		; Unpause timer1
		LDR r0, =0xE0008004				; (T1TCR) Timer 1 timer control reg
		LDR r1, [r0]
		ORR r1, r1, #1					; set bit 0 to 1 to enable, or 0 to disable
		STR r1, [r0]
		; Set RGB to green when unpasued
		MOV r4, #1							   		
		BL illuminate_RGB_LED
		; Write "     " to the game
		MOV r2, #0x1B				; ESC
		BL output_character			
		MOV r2, #0x5B				; [
		BL output_character
		MOV r2, #0x31				; move to line 1				
		BL output_character
		MOV r2, #0x3B				; ;
		BL output_character
		MOV r2, #0x31				; move to column 12			
		BL output_character
		MOV r2, #0x32								
		BL output_character
		MOV r2, #0x66				; f
		BL output_character
		MOV r2, #0x20				; space
		BL output_character
		MOV r2, #0x20				; space
		BL output_character
		MOV r2, #0x20				; space
		BL output_character
		MOV r2, #0x20				; space
		BL output_character
		MOV r2, #0x20				; space
		BL output_character
		B FIQ_Exit


timer0Interrupt ; Check if timer0 interrupt

		LDR r0, =0xE0004000			; Timer	0 (T0IR)
		LDR r1, [r0]
  		; bit 3 is set if timer interrupt
		TST r1, #2
		BEQ timer1Interrupt
		; Clear Interrupt by writing 1 to bit 1
		ORR r1, r1, #2
		STR r1, [r0]
		; Timer 0 Handling Code
		; check if at game over screen
		LDR r0, =IS_GAMEOVER_SCREEN
		LDR r1, [r0]
		CMP r1, #1						; set = at game over screen
		BEQ allowDurGamOvr		; only check for new game and quit keys
		; check if Q recently hit
		LDR r0, =Q_RECENTLY_HIT
		LDR r1, [r0]
		CMP r1, #1						; set = at game over screen
		BEQ allowDurGamOvr		; only check for new game and quit keys
		; Check if game is currently paused
		LDR r3, =IS_PAUSED				
		LDRB r4, [r3]
		CMP r4, #1
		BEQ pausedFIQExit
		; Spawn an enemy if time is > 2s and NUMENEMIES < 2
		LDR r3, =NUM_HALF_SECS				
		LDR r4, [r3]
		ADD r4, r4, #1 
		STR r4, [r3]
		CMP r4, #4
		BLT not2Secs
		LDR r3, =NUM_BALLS				
		LDR r4, [r3]
		CMP r4, #2					; Check if there are 2 balls already
		BLLT spawnEnemy
		; Move enemy 1 every 2 cycles	
		LDR r3, =NUM_HALF_SECS				
		LDR r0, [r3]
		CMP r0, #4
		BEQ not2Secs			; dont move o on first itteration (4 0.5s)
	
checkOthers
		MOV r1, #2				; divisor
		BL div_and_mod
		MOV r6, r1 
		CMP r6, #0 				; check if remainder is 0 (otherwise 1)
		BNE notSpawning
		;Check if enemy is spawned and move it if true 1move/sec
		LDR r0, =SNAKE_SQUARE
		LDR r1, [r0]
		CMP r1, #0
		BLNE moveSnake
		LDR r0, =BALL1_SQUARE
		LDR r1, [r0]
		CMP r1, #0 
		BLNE moveBall1					; Move enemy once every 2s if spawned
		LDR r0, =BALL2_SQUARE
		LDR r1, [r0]
		CMP r1, #0
		BLNE moveBall2
		LDR r0, =SNAKEBALL_SQUARE
		LDR r1, [r0]
		CMP r1, #0
		BLNE moveSnakeBall
		
notSpawning		
		BL didoHitQ

not2Secs ; no enemies spawned in first 2 seconds		
		; Reset Q_MOVES  so q can move twice again during next turn
		LDR r3, =Q_MOVES				
		MOV r4, #1
		STR r4, [r3]

allowDurGamOvr
		; Blink if recently died
		BL blinkOnDeath

		; Check if displaying curse
		LDR r0, =DISPLAY_CURSE
		LDR r1, [r0]
		CMP r1, #0
		BEQ notCurse	  	; 0 = no curse currently displayed
		CMP r1, #4
		BEQ removeCurse 	; check if curse has been displayed for 2 secs
		ADD r1, r1, #1 
		STR r1, [r0]		; increment count by 1 if not and exit
		B FIQ_Exit
removeCurse
		LDR r0, =Q_RECENTLY_HIT
		STR r1, [r0]		; clear game over status
		BL qCurse		; remove the curse
		LDR r0, =Q_DIRECTION
		MOV r1, #0
		STR r1, [r0]
		; TODO check which ball
		LDR r0, =BALL1_SQUARE		; set ball to no square
  		MOV r1, #0
		STR r1, [r0]
		BL redrawQ


notCurse		
		MOV r2, #0				; increment by 1 when 0 LIVES or 0 BLINK
		; Check if Game Over, and set RGB to purple if yes
		LDR r0, =IS_GAMEOVER_SCREEN
		LDR r1, [r0]
		CMP r1, #1
		ADDEQ r2, #1
		; Check if BLINK is zero
		LDR r3, =BLINK				
		LDR r4, [r3] 
		CMP r4, #0
		ADDEQ r2, #1
		; If both zero, set RGB to purple for game over
		CMP r2, #2
		MOVEQ r4, #3
		BLEQ illuminate_RGB_LED

		B FIQ_Exit



timer1Interrupt ; Check if timer1 interrupt
		LDR r0, =IS_GAMEOVER_SCREEN
		LDR r1, [r0]
		CMP r1, #1						; set = at game over screen
		BEQ checkKBinterrupt		; only check for new game and quit keys
		; check if Q recently hit
		LDR r0, =Q_RECENTLY_HIT
		LDR r1, [r0]
		CMP r1, #1						; set = at game over screen
		BEQ checkKBinterrupt		; only check for new game and quit keys

		LDR r0, =0xE0008000			; Timer	1 (T1IR)
		LDR r1, [r0]
  		; bit 2 is set if timer interrupt
		TST r1, #2
		BEQ checkKBinterrupt
		; Clear Interrupt by writing 1 to bit 1
		ORR r1, r1, #2
		STR r1, [r0]
		; Check if game is currently paused
		LDR r3, =IS_PAUSED				
		LDRB r4, [r3]
		CMP r4, #1
		BEQ pausedFIQExit
		; Timer 1 Handling Code
		BL gameOver				; Game over when timer reaches 2 mins
		B pausedFIQExit			; dont restart timers on FIQ exit


;EINT1	; Check for EINT1 interrupt
	

;;;;;;;;;;;;; TODO PRESSING OTHER KEYS IS GIVING RANDOM !!!!!!!
checkKBinterrupt ; Check if keyboard interrupt
		LDR r0, =0xe000C008		; uart0
		LDR r1, [r0]
		TST r1, #0				; check if 0 bit is not 1
		BNE FIQ_Exit			; If not, exit handler
		;UART0 is cleared automatically when data is read
		
		

		; Check if game is currently paused
		LDR r3, =IS_PAUSED				
		LDRB r4, [r3]
		CMP r4, #1
		BEQ pausedFIQExit
		; keyboard Handling Code
		BL read_character
		; If spacebar
        CMP r2, #0x20			; Spacebar
        BLEQ quit				; quit program
		; If g
		CMP r2, #0x67			; New Game
        BLEQ newGame			; Start new Game
		BLEQ FIQ_Exit

		; check if at game over screen
		LDR r0, =IS_GAMEOVER_SCREEN
		LDR r1, [r0]
		CMP r1, #1				; set = at game over screen
		BEQ pausedFIQExit	    ; only check for new game and quit keys
		; check if Q recently hit
		LDR r0, =Q_RECENTLY_HIT
		LDR r1, [r0]
		CMP r1, #1						; set = at game over screen
		BEQ pausedFIQExit		; only check for new game and quit keys

		
		LDR r3, =Q_DIRECTION
		CMP r2, #0x77			; w
		MOVEQ r1, #1			; set direction up
		BEQ storeDir
		CMP r2, #0x61			; a
		MOVEQ r1, #2			; set direction left
		BEQ storeDir
		CMP r2, #0x73 			; s
		MOVEQ r1, #3			; set direction down
		BEQ storeDir
		CMP r2, #0x64 			; d
		MOVEQ r1, #4			; set direction right
		BEQ storeDir
		MOV r1, #0				; If not w,a,s,d then set direction to none
storeDir				
		STR r1, [r3]			; Store the new direction
		
		; Check if Q has any moves left this turn
		LDR r3, =Q_MOVES				
		LDR r4, [r3]
		CMP r4, #0
		BLE outOfMoves				; do not move Q if out of moves
		BL removeQ
		BL redrawQ
		BL updateScore
		BL didoHitQ
		SUB r4, r4, #1				; decrement Q_MOVES by 1
		STR r4, [r3]
outOfMoves

FIQ_Exit
	; Re-enable timer0
	LDR r2, =0xE000401C 			; Address of Match Register 0 (MR0)
	;LDR r0, =36864000	  			; timeout period of the timer (2s)
	;LDR r0, =18432000	  			; timeout period of the timer (1s) 
	LDR r0, =9216000	  			; timeout period of the timer (0.5s)
	;LDR r0, =8755200	  			; timeout period of the timer (0.45s)

	LDR r4, =INC_TIMER_FLAG			; Check if timer needs to be speed up
	LDR r5, [r4]					; 0=no 1=yes
	CMP r5, #0
	BEQ noIncrease
	MOV r5, #0					   	; timer is no up to date
	STR r5, [r4]					; clear flag
	; Increase speed	
	LDR r3, =LEVEL				
	LDR r1, [r3]
	MOV r4, #0  		
	;LDR r5, =2448000
	LDR r5, =460800
mulAgain1 							; 5% of 0.5s timeout
    SUB r1, r1, #1  				; multiply that percent by the LEVEL-1
	CMP r1, #0
	ADDGT r4, r4, r5
	BGT mulAgain1
	SUB r0, r0, r4					; Subtract that number from .5s timout						   	
	STR r0, [r2]
	LDR r2, =0xE000401C 			; Address of Match Register 0 (MR0)
	LDR r3, [r2]
noIncrease
	LDR r0, =0xE0004004				; (T0TCR) Timer 0 timer control reg
	LDR r1, [r0]
	ORR r1, r1, #1					; set bit 0 to 1 to enable, or 0 to disable
	STR r1, [r0]
	
	; Re-enable timer1
	LDR r0, =0xE0008004				; (T1TCR) Timer 1 timer control reg
	LDR r1, [r0]
	ORR r1, r1, #1					; set bit 0 to 1 to enable, or 0 to disable
	STR r1, [r0]

pausedFIQExit
	;BL interrupt_init	
	LDMFD SP!, {r0-r10, lr}
	SUBS pc, lr, #4


quit	
	MOV r2, #0x0C			; ASCII 0x0C is for new page
	BL output_character		; Clear the screen
	MOV r4, #16				; Clear the 7-seg display
	BL display_digit_on_7_seg 
	MOV r4, #6			   	; Turn off RGB LCD
	BL illuminate_RGB_LED		
	MOV r4, #0xF0000		; Turn off all 4 LCDs			
	BL illuminateLEDs					
	LDMFD SP!, {lr}			; Restore register lr from stack	
	BX LR
	END