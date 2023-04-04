
	.data
; data for movement
moveState:		.byte	3
						;	0 - none
						; 	1 - 90 up
						;	2 - 45 up left
						;	3 - 30 up left
						;	4 - 45 up right
						;	5 - 30 up right
						;	6 - 90 down
						;	7 - 45 down left
						;	8 - 30 down left
						; 	9 - 45 down right
						; 	10 - 30 down right
moveData:		.byte	0, -10, -11, -12, -9, -8, 10, 9, 8, 11, 12

; this is what direction the player will go the next
; time the paddle will go.
nextState:		.byte	3

prompt90:			.string 27, "[20;2H", 27, "[40m", "90         ", 0
left45Prompt:		.string 27, "[20;2H", 27, "[40m", "45 Left    ", 0
left30Prompt:		.string 27, "[20;2H", 27, "[40m", "30 Left    ", 0
right45Prompt:		.string 27, "[20;2H", 27, "[40m", "45 Right   ", 0
right30Prompt:		.string 27, "[20;2H", 27, "[40m", "30 Right   ", 0


; black background
blackBg:			.string 		 27, "[40m",0



; colors: 	1 - red,
;			2 - green,
;			3 - yellow,
;			4 - blue,
;			5 - purple,
;			6 - white,
;			7 - space
;			A - player
;			B - horizontal border
;			C - vertical border
;			F - paddle


board_data:		.byte	0xB, 0xB, 0xB, 0xB, 0xB, 0xB, 0xB, 0xB, 0xB, 0xB
				.byte	0xC, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x2, 0x4, 0xC
				.byte	0xC, 0x3, 0x1, 0x4, 0x6, 0x5, 0x2, 0x1, 0x5, 0xC
				.byte	0xC, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0xC
				.byte	0xC, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0xC
				.byte	0xC, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0xC
				.byte	0xC, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0xC
				.byte	0xC, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0xC
				.byte	0xC, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0xC
				.byte	0xC, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0xC
				.byte	0xC, 0x7, 0x7, 0x7, 0xA, 0x7, 0x7, 0x7, 0x7, 0xC
paddleLine:		.byte	0xC, 0x7, 0x7, 0x7, 0x7, 0xF, 0x7, 0x7, 0x7, 0xC
				.byte 	0xB, 0xB, 0xB, 0xB, 0xB, 0xB, 0xB, 0xB, 0xB, 0xB
				.byte  	0xB, 0xB, 0xB, 0xB, 0xB, 0xB, 0xB, 0xB, 0xB, 0xB, 0 ; terminator


redBlock:			.string 		27, "[101m       ", 0
greenBlock:			.string 		27, "[102m       ", 0
yellowBlock:		.string 		27, "[103m       ", 0
blueBlock:			.string 		27, "[104m       ", 0
purpleBlock:		.string 		27, "[105m       ", 0
whiteBlock:			.string 		27, "[107m       ", 0
spaceBlock:			.string			27, "[100m       ", 0

; paddle
paddle:					.string			27, "[106m_______",0
paddle45:				.string			27, "[104m_", 0
paddle30:				.string			27, "[105m_", 0
paddle90:				.string			27, "[106m___", 0

redPlayer:			.string 		27, "[100m  ", 27, "[101m X ", 27, "[100m  ", 0
greenPlayer:		.string 		27, "[100m  ", 27, "[102m X ", 27, "[100m  ", 0
yellowPlayer:		.string 		27, "[100m  ", 27, "[103m X ", 27, "[100m  ", 0
bluePlayer:			.string 		27, "[100m  ", 27, "[104m X ", 27, "[100m  ", 0
purplePlayer:		.string 		27, "[100m  ", 27, "[105m X ", 27, "[100m  ", 0
whitePlayer:		.string 		27, "[100m  ", 27, "[107m X ", 27, "[100m  ", 0


hBorder:		.string			27, "[100m______", 0
vBorder:		.string			27, "[100m| ",0
; current player color
; colors: 	1 - red,
;			2 - green,
;			3 - yellow,
;			4 - blue,
;			5 - purple,
;			6 - white
playerColor:		.byte	0x1
;rgb constants
rgbRed:			.equ	0x2
rgbWhite:		.equ	0xE
rgbPurple:		.equ	0x6
rgbBlue:		.equ	0x4
rgbGreen:		.equ	0x8
rgbYellow:		.equ	0xA


playerFullPos:		.string 	27, "[11;25H", 0

								; hide cursor
newPos:				.string		27, "[?25l", 27, "[", "0", "1", ";", "0", "1","H", 0

	.text
	.global brakeout
	.global uart_init
	.global uart_interrupt_init
	.global	gpio_interrupt_init
	.global timer0_init
	.global output_string
	.global	output_character
	.global illuminate_RGB_LED
	.global drawBoard
	.global	storePlayerColor

; the current state of the movement
; note that the move data is +1 after this state.
p_moveState:		.word		moveState

; the next state for the player after hitting the paddle
p_nextState:		.word		nextState

; amount of empty spaces needed to fill the game area
emptyNeeded:		.equ		0xA

; black background
p_blackBg:			.word	blackBg

; spaces needed to fill game area
p_emptyNeeded:	.word	emptyNeeded

p_boardData:	.word	board_data


; block colors
p_redBlock:			.word	redBlock
p_greenBlock:		.word	greenBlock
p_yellowBlock:		.word	yellowBlock
p_blueBlock:		.word	blueBlock
p_purpleBlock:		.word	purpleBlock
p_whiteBlock:		.word	whiteBlock
p_spaceBlock:		.word	spaceBlock

; borders
p_hBorder:			.word	hBorder
p_vBorder:			.word	vBorder

; paddle
p_paddleLine:		.word	paddleLine
p_paddle:			.word	paddle
p_paddle45:			.word 	paddle45
p_paddle30:			.word 	paddle30
p_paddle90:			.word 	paddle90

;player colors
p_redPlayer:		.word	redPlayer
p_greenPlayer:		.word	greenPlayer
p_yellowPlayer:		.word	yellowPlayer
p_bluePlayer:		.word	bluePlayer
p_purplePlayer:		.word	purplePlayer
p_whitePlayer:		.word	whitePlayer

p_playerColor:		.word	playerColor

p_playerFullPos:	.word	playerFullPos
p_newPos:			.word 	newPos


; paddle angle prompts
p_90Prompt:				.word	prompt90
p_45LeftPrompt:			.word	left45Prompt
p_30LeftPrompt:			.word	left30Prompt
p_45RightPrompt:		.word	right45Prompt
p_30RightPrompt:		.word	right30Prompt



brakeout:
	; init timer

	bl		timer0_init
	; init uart
	bl		uart_init
	bl		uart_interrupt_init
	; init gpio
	bl		gpio_interrupt_init



	; load common pointers to saved register
	ldr		r4, p_boardData
	; r5 is loaded with the pointer of the end of the board
	ldr		r6, p_newPos
	ldr		r7, p_moveState
	ldr		r8, p_nextState
	ldr		r9, p_paddleLine

	bl		drawBoard


	mov		r0, #0x20
infinite:
	b	infinite




; colors: 1 - red, 2 - green, 3 - yellow, 4 - blue, 5 - purple, 6 - white
; r4 should be board data
drawBoard:
	push	{r4, lr}
	; set background color to black at first
	ldr		r0, p_blackBg
	bl		output_string

	; clear screen
	;mov		r0, #0xC
	;bl		output_character
	; go to the beginning of the screen
	ldr		r0, p_newPos
	bl		output_string


	; load in the number of spaces needed
	;ldr		r2, p_emptyNeeded
	;ldrb	r2, [r2]

	mov		r3, #0
checkData:
	ldrb	r0, [r4], #1
	add		r3, #1


	cmp		r3, #emptyNeeded
	bgt		addNewline

	cmp		r0, #0
	; save the end of the board into register r5
	itt		eq
	subeq	r4, #-1
	moveq	r5, r4
	beq		endDataToBoard

	cmp		r0, #7
	beq		drawSpace

	cmp		r0, #0xA
	beq		drawPlayer

	cmp		r0, #0xB
	beq		drawHorizontalBorder

	cmp		r0, #0xC
	beq		drawVerticalBorder

	; paddle
	cmp		r0, #0xF
	beq		drawPaddle

	cmp		r0, #1
	beq		drawRed

	cmp		r0, #2
	beq		drawGreen

	cmp		r0, #3
	beq		drawYellow

	cmp		r0, #4
	beq		drawBlue

	cmp		r0, #5
	beq		drawPurple

	cmp		r0, #6
	beq		drawWhite

	b		endDataToBoard ; if something else

drawRed:
	ldr		r0, p_redBlock
	bl		output_string
	b		checkData

drawGreen:
	ldr		r0, p_greenBlock
	bl		output_string
	b		checkData

drawYellow:
	ldr		r0, p_yellowBlock
	bl		output_string
	b		checkData

drawBlue:
	ldr		r0, p_blueBlock
	bl		output_string
	b		checkData

drawPurple:
	ldr		r0, p_purpleBlock
	bl		output_string
	b		checkData

drawWhite:
	ldr		r0, p_whiteBlock
	bl		output_string
	b		checkData

drawSpace:
	ldr		r0, p_spaceBlock
	bl		output_string
	b		checkData

drawPaddle:
	ldr		r0, p_paddle
	bl		output_string
	b		checkData


drawPlayer:
	bl		getPlayerColor	; returns address into r0
	bl		output_string
	b		checkData

addNewline:
	mov		r0, #0xA
	bl		output_character
	mov		r0, #0xD
	bl		output_character

	sub		r4, #1		; subtract address by one to not skip a color

	;update the number of spaces needed
	ldr		r3, p_emptyNeeded
	ldrb	r0, [r3]
	sub		r0, #1
	strb	r0, [r3]

	mov		r3, #0		; reset r3
	b		checkData

drawHorizontalBorder:
	ldr		r0, p_hBorder
	bl		output_string
	b		checkData

drawVerticalBorder:
	ldr		r0, p_vBorder
	bl		output_string
	b		checkData

endDataToBoard:
	; lastly print the paddle angle direction
	ldrb	r0, [r8]

	cmp		r0, #1
	beq		print90

	cmp		r0, #2
	beq		print45Left

	cmp		r0, #3
	beq		print30Left

	cmp		r0, #4
	beq		print45Right

	; print 30 right
	ldr		r0, p_30RightPrompt
	bl		output_string
	b		anglePrintDone

print90:
	ldr		r0, p_90Prompt
	bl		output_string
	b		anglePrintDone

print45Left:
	ldr		r0, p_45LeftPrompt
	bl		output_string
	b		anglePrintDone

print30Left:
	ldr		r0, p_30LeftPrompt
	bl		output_string
	b		anglePrintDone

print45Right:
	ldr		r0, p_45RightPrompt
	bl		output_string

anglePrintDone:
	pop		{r4, lr}
	mov		pc, lr



;drawPlayer
;	push	{lr}
;	bl		getPlayerColor	; returns address into r0
;	bl		output_string
;	pop		{lr}
;	mov		pc, lr

; returns r0 with the address of the correct color to display for the player
; colors: 1 - red, 2 - green, 3 - yellow, 4 - blue, 5 - purple, 6 - white
getPlayerColor:
	push	{lr}
	ldr		r1, p_playerColor
	ldrb	r0, [r1]

	cmp		r0, #1
	beq		playerIsRed

	cmp		r0, #2
	beq		playerIsGreen

	cmp		r0, #3
	beq		playerIsYellow

	cmp		r0, #4
	beq		playerIsBlue

	cmp		r0, #5
	beq		playerIsPurple

	; not anything else, just set to white then

	mov		r0, #rgbWhite
	bl		illuminate_RGB_LED
	ldr		r0, p_whitePlayer
	b		endGetPlayerColor

playerIsRed:
	mov		r0, #rgbRed
	bl		illuminate_RGB_LED
	ldr		r0, p_redPlayer
	b		endGetPlayerColor

playerIsGreen:
	mov		r0, #rgbGreen
	bl		illuminate_RGB_LED
	ldr		r0, p_greenPlayer
	b		endGetPlayerColor

playerIsYellow:
	mov		r0, #rgbYellow
	bl		illuminate_RGB_LED
	ldr		r0, p_yellowPlayer
	b		endGetPlayerColor

playerIsBlue:
	mov		r0, #rgbBlue
	bl		illuminate_RGB_LED
	ldr		r0, p_bluePlayer
	b		endGetPlayerColor

playerIsPurple:
	mov		r0, #rgbPurple
	bl		illuminate_RGB_LED
	ldr		r0, p_purplePlayer

endGetPlayerColor:
	pop		{lr}
	mov		pc, lr


; r0 should have the color to store.
storePlayerColor:
	ldr		r1, p_playerColor
	strb	r0, [r1]
	mov		pc, lr


	.end
