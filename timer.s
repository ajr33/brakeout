	.data

;the gameclock
game_time:		.word	0
print_time:		.word	0, 0

;rgb data after winning
rgb_data:	.byte	2 	; 2 - red
					  	; 4 - blue
					  	; 6 - purple
					  	; 8 - green
					  	; A - yellow
					  	; C - cyan
					  	; E - white



state:		.byte	1
; the state of the game
					; 1 - normal gameplay

vMovement:	.byte   0 	; 	0 = up, 	1 = down
hMovement:	.byte 	1	; 	0 = left 	1 = right

angle:	.byte	1
					; 	0 = 90 (straight up/down)
					;	1 = 60
					;	2 = 45


	.text

    .global GameClock_Handler	;yes diff
    .global Timer0_Handler
    .global Timer1_Handler		;yes diff
    .global timer0_init	;yes same
	.global timer1_init				;yes same as above
	.global output_string	;yes same
    .global int2string
    .global	reset_game_clock
    .global illuminate_RGB_LED
    .global show_player_time
    .global drawBoard

;p_moveState:		.word	moveState
;p_moveData:			.word	moveData

;rgb constants
rgbRed:			.equ	0x2
rgbWhite:		.equ	0xE
rgbPurple:		.equ	0x6
rgbBlue:		.equ	0x4
rgbGreen:		.equ	0x8
rgbYellow:		.equ	0xA


pVMove:		.word	vMovement
pHMove:		.word	hMovement
pAngle:		.word 	angle
;TIMER OFFSETS
RCGCTIMER: 	    .equ 0x604 	            ;Timer Run Mode Clock Gating Control
GPTMCTL:	    .equ 0x00C 	            ;Timer Control Register
GPTMTAMR: 	    .equ 0x004	            ;Timer A Mode Register
GPTMTAILR:	    .equ 0x028	            ;Timer Interval Load Register
GPTMIMR:	    .equ 0x018	            ;Timer Interrupt Mask Register
GPTMICR:	    .equ 0x024      	    ;Timer Interrupt Clear Register
EN0: 		    .equ 0x100	            ;NVIC Interrupt Enable Register

;***************************************************************************************************
; Function name: timer0_interrupt_init
; Function behavior: Initializes timer 0 for 32-bit mode, half second intervals. Sets address of
; shared variable from lab7.s
;
; Function inputs:
; r0 : Address of local variable from main
;
; Function returns: none
;
; Registers used:
; r0: value manipulation
; r1: holds base address of timer 0
;
; Subroutines called: none
;
;
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;***************************************************************************************************
timer0_init:
	PUSH    {lr}


	;set r1 to clock settings base address
	MOV     r1, #0xE000
	MOVT    r1, #0x400F

	;load in current value of the timer clock settings
	LDRB    r0, [r1, #RCGCTIMER]
	ORR     r0, r0, #0x1
	STRB    r0, [r1, #RCGCTIMER]        ;enable clock for timer 0 (A)

	;TIMER SETUP

	;set r1 to timer 0 base address
	MOV     r1, #0x0000
	MOVT    r1, #0x4003

	;Disable the timer
	;load current status
	LDRB    r0, [r1, #GPTMCTL]
	AND     r0, r0, #0x0		        ;set bit 0 to 1
	STRB    r0, [r1, #GPTMCTL]          ;disable timer 0 (A) for setup

	;set 32-bit mode
	;GPTMCFG: 	.equ 0x000 ;General Purpose Timer Configuration Register
	;load current status
	LDRB    r0, [r1]
	AND     r0, r0, #0x0	            ;set bit 0 to 1
	STRB    r0, [r1] 		            ;set configuration 32-bit for 16/32 bit timer

	;set periodic mode
	;load current status
	LDRB    r0, [r1, #GPTMTAMR]
	ORR     r0, r0, #0x2			    ;set 2 to r0
	STRB    r0, [r1, #GPTMTAMR]         ;set periodic mode for timer A

	;set interval period
	;load current status
	LDR     r0, [r1, #GPTMTAILR]
	MOV     r0, #0x1200				    ;set r2 to 8 million
	MOVT    r0, #0x007A			        ;for 2 timer interrupts a second
	STR     r0, [r1, #GPTMTAILR] 	    ;set interval period for timer A

	;set up to interrupt processor
	;load current status
	LDR     r0, [r1, #GPTMIMR]
	ORR     r0, r0, #0x1		        ;set bit 0 to 1
	STR     r0, [r1, #GPTMIMR] 	        ;enable interrupts for timer A

	;Allow Timer to Interrupt Processor
	;set r1 to EN0 base address
	MOV     r1, #0xE000
	MOVT    r1, #0xE000

	;load current status
	LDR     r0, [r1, #EN0]
	ORR     r0, r0, #0x80000		    ;set timer 0 to be able to interrupt processor
	STR     r0, [r1, #EN0]

	;set r1 to timer 0 base address
	MOV     r1, #0x0000
	MOVT    r1, #0x4003

	;enable timer
	LDRB    r0, [r1, #0xC]
	ORR     r0, r0, #0x3		        ; set bit 0 to 1, set bit 1 to 1 to allow debugger to stop timer
	STRB    r0, [r1, #0xC]            	; enable timer 0 (A) for use

	POP     {lr}
	MOV     pc, lr

;***************************************************************************************************
; Function name: timer1_init
; Function behavior: Initializes the timer to be continuous. Timer is used as a seed for random
; number generator.
;
; Function inputs: none
;
; Function returns: none
;
; Registers used:
; r0: value manipulation
; r1: holds base address of timer 0
;
; Subroutines called:
;
;
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;***************************************************************************************************
timer1_init:
	PUSH    {lr}

	;set r1 to clock settings base address
	MOV     r1, #0xE000
	MOVT    r1, #0x400F

	;load in current value of the timer clock settings
	LDRB    r0, [r1, #RCGCTIMER]
	ORR     r0, r0, #0x2
	STRB    r0, [r1, #RCGCTIMER]        ;enable clock for timer 1 (A)

	;TIMER SETUP

	;set r1 to timer 1 base address
	MOV     r1, #0x1000
	MOVT    r1, #0x4003

	;Disable the timer
	;load current status
	LDRB    r0, [r1, #GPTMCTL]
	AND     r0, r0, #0x0
	STRB    r0, [r1, #GPTMCTL]          ;disable timer 1 (A) for setup

	;set 32-bit mode
	;GPTMCFG: 	.equ 0x000 ;General Purpose Timer Configuration Register
	;load current status
	LDRB    r0, [r1]
	AND     r0, r0, #0x0
	STRB    r0, [r1] 		            ;set configuration 32-bit for 16/32 bit timer

	;set periodic mode
	;load current status
	LDRB    r0, [r1, #GPTMTAMR]
	ORR     r0, r0, #0x2			    ;set 2 to r0
	STRB    r0, [r1, #GPTMTAMR]         ;set periodic mode for timer A

	;set interval period
	;load current status
	LDR     r0, [r1, #GPTMTAILR]
	MOV     r0, #0x2400				    ;set r2 to 16 million
	MOVT    r0, #0x00F4			        ;for 1 timer interrupt a second
	STR     r0, [r1, #GPTMTAILR] 	    ;set interval period for timer A



	;set up to interrupt processor
	;load current status
	LDR     r0, [r1, #GPTMIMR]
	ORR     r0, r0, #0x1		        ;set bit 0 to 1
	STR     r0, [r1, #GPTMIMR] 	        ;enable interrupts for timer A

	;Allow Timer to Interrupt Processor
	;set r1 to EN0 base address
	MOV     r1, #0xE000
	MOVT    r1, #0xE000

	;load current status
	LDR     r0, [r1, #EN0]
	ORR     r0, r0, #0x200000		    ;set timer 1 to be able to interrupt processor
	STR     r0, [r1, #EN0]



	POP     {lr}
	MOV     pc, lr


Timer0_Handler:
    push    {r4-r11, lr}

    ;CLEAR INTERRUPT
	;load timer 1 base address
	MOV     r1, #0x0000
	MOVT    r1, #0x4003

	;set 1 to clear the interrupt
	LDR     r0, [r1, #GPTMICR]
	ORR     r0, r0, #0x01
	STR     r0, [r1, #GPTMICR]

	; movement state
	;ldr		r1, p_moveState
	;r7 hold moves state from brakeout.s
	ldrb	r0, [r7]

	;save current pointer
	push	{r4}
	;mov		r9, #0
checkBoard:
	;add		r9, #1
	;cmp		r9, #3
	;itt		eq
	;moveq	r0, #1
	;moveq	r9, #0

	; loads offest for board.
	;ldr		r3, p_moveData
	add		r3, r7, #1	;start address for move data
	ldrb	r2, [r3, r0]

	; correctly keeps sign for negatives
	; r2 is where the player will end up
	rev		r2, r2
	asr		r2, r2, #24

	bl		findPlayer ; modifies r4

	ldrb	r0, [r4, r2]

newSpaceCheck:
	cmp		r0, #0x7
	beq		validSpace

	cmp		r0, #0xB
	beq		hBorderHit

	cmp		r0, #0xC
	beq		vBorderHit

	cmp		r0, #0xF
	beq		paddleHit
	;cmp		r0, #0xF0
	;bgt		paddleHit

	b		blockHit

paddleHit:

	; change to next paddle hit state
	; next state is in r8 from brakeout.s
	ldrb	r0, [r8]
	strb	r0, [r7]

	b		checkBoard


hBorderHit:
	;store new state
	ldrb	r0, [r7]
	cmp		r0, #5
	bgt		subState

	add		r0, #5
	strb	r0, [r7]

	b		checkBoard

subState:
	sub		r0, #5
	strb	r0, [r7]

	b		checkBoard


vBorderHit:
	; check if hit wall already
;	cmp		r9, #1
;	bgt		alreadyHitV

	ldrb	r0, [r7]
	cmp		r0, #3
	bgt		moreThan3State

	cmp		r0, #3
	beq		sc3


	add 	r0, #2
	strb	r0, [r7]
	b		checkBoard

sc3:	; special case 3
	mov		r0, #4
	strb	r0, [r7]
	b		checkBoard



moreThan3State:
	cmp		r0, #5
	bgt		moreThan5State

	cmp		r0, #5
	beq		sc5

	sub		r0, #2
	strb	r0, [r7]
	b		checkBoard


sc5:	; special case 5
	mov		r0, #2
	strb	r0, [r7]
	b		checkBoard


moreThan5State:
	cmp		r0, #8
	bgt		moreThan8State

	cmp		r0, #8
	beq		sc8


	add		r0, #2
	strb	r0, [r7]
	b		checkBoard

sc8:	; special case 8
	mov		r0, #9
	strb	r0, [r7]
	b		checkBoard

moreThan8State:

	cmp		r0, #10
	beq		sc10


	sub		r0, #2
	strb	r0, [r7]
	b		checkBoard

sc10:	; special case 10
	mov		r0, #7
	strb	r0, [r7]
	b		checkBoard


blockHit:
	; same as validSpace but update player's movement
	; update movement the same as hBlockHit
	;store new state
;	ldr		r1, p_moveState
	ldrb	r0, [r7]	; r7 holds moveState
	cmp		r0, #5
	bgt		subBlockState

	add		r0, #5
	strb	r0, [r7]
	b		validSpace

subBlockState:
	sub		r0, #5
	strb	r0, [r7]

validSpace:

	mov		r0, #0x7
	strb	r0, [r4]

	; update players position
	mov		r0, #0xA
	strb	r0, [r4, r2] ; r2 still holds offset

timer0_done:
	pop		{r4}
	bl		drawBoard
	pop    {r4-r11, lr}
	bx		lr







; finds where the player is on the board
findPlayer:
	ldrb	r0, [r4], #1
	cmp		r0, #0xA
	bne		findPlayer
	; player is in one spot back
	sub		r4, #1
	mov		pc, lr




loadOffest:
	ldrb	r3, [r2]
	ldrb	r0, [r4, r3] ; load the offest into r0
	mov		pc, lr


; finds the point where r7 is equal to point of the paddle that was hit
findPaddle:
	ldrb	r3, [r7], #1
	cmp		r3, r0
	bne		findPaddle
	sub		r7, #1
	mov		pc, lr


;***************************************************************************************************
; Function name: Timer1_Handler
; Function behavior: Main gameplay loop. Updates the board state based on the direction variable.
; Uses remaining board spaces and score to determine if game is ended and whether game was won/lost.
;
; Function inputs: none
;
; Function returns: none
;
; Registers used:
;
;
; Subroutines called:
;
;
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;***************************************************************************************************
Timer1_Handler:
    push    {r4-r11, lr}

    ;CLEAR INTERRUPT
	;load timer 1 base address
	MOV     r1, #0x1000
	MOVT    r1, #0x4003

	;set 1 to clear the interrupt
	LDR     r0, [r1, #GPTMICR]
	ORR     r0, r0, #0x01
	STR     r0, [r1, #GPTMICR]


Timer_Handler_return:
    ; Regardless, need to update score and time on board
    ;bl      print_time_score

    pop     {r4-r11, lr}
    bx      lr

    .end
