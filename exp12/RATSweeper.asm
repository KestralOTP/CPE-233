;- Programmers: Spencer Chang
;-				Nick Avila
;-
;-
;- Project Title: RAT Sweeper
;- Date: Winter 2015
;- Class: CPE 233-03/04
;- Instructor: Bryan Mealy
;-
;------------------------------------------------------------
;------------------------------------------------------------
; Various key parameter constants
;------------------------------------------------------------
.EQU UP       = 0x1D     ; 'w' 
.EQU LEFT     = 0x1C     ; 'a'
.EQU RIGHT    = 0x23     ; 'd'
.EQU DOWN     = 0x1B     ; 's'
.EQU SPACE	  = 0x29	 ; 'Reveal Spot'
.EQU ENTER	  = 0x5A	 ; 'Place Flag
;------------------------------------------------------------

;------------------------------------------------------------
; Various screen parameter constants for 40x30 screen
;------------------------------------------------------------
.EQU LO_X    = 0x05
.EQU HI_X    = 0x0E
.EQU LO_Y    = 0x05
.EQU HI_Y    = 0x0E

.EQU KEY_X	 = 0x17					; Starting X-coord for key
.EQU KEY_Y	 = 0x03					; Starting Y-coord for key
;------------------------------------------------------------

;------------------------------------------------------------
; Various screen I/O constants
;------------------------------------------------------------
.EQU LEDS                = 0x40     ; LED array
.EQU SSEG                = 0x82     ; 7-segment decoder 
.EQU SWITCHES            = 0x20     ; switches 

.EQU PS2_CONTROL         = 0x46     ; ps2 control register 
.EQU PS2_KEY_CODE        = 0x44     ; ps2 data register
.EQU PS2_STATUS          = 0x45     ; ps2 status register

.EQU VGA_HADD            = 0x90     ; high address register (also VGA_HADD)
.EQU VGA_LADD            = 0x91     ; low address register  (also VGA_LADD)
.EQU VGA_COLOR           = 0x92     ; color value register
;------------------------------------------------------------

;------------------------------------------------------------------
; Various drawing constants
;------------------------------------------------------------------
.EQU BG_COLOR	  = 0xB6			; Background: Light Gray

.EQU BLUE         = 0x03            ; color data: blue 		(for 1 mine)
.EQU DGREEN		  = 0x10			; color data: dark green(for 2 mines)
.EQU CRED         = 0xE0            ; color data: red 		(for 3 mines)
.EQU DBLUE		  = 0x01			; color data: dark blue (for 4 mines)
.EQU VIOLET		  = 0x21			; color data: violet	(for 5 mines)
.EQU DGRAY		  = 0x49			; color data: dark gray	(for the mine)

.EQU COLOR1 = 0x07			; color data: BLUE (diff shade than default, 0x03)
.EQU COLOR2 = 0x1F			; color data: TEAL
.EQU COLOR3 = 0x1C          ; color data: GREEN
.EQU COLOR4 = 0x3C			; EXOR value is more PURPLE than EXOR of 0x1C
.EQU COLOR5 = 0x34			; This is a DARKER GREEN than 0x1C
.EQU COLOR6 = 0x24			; NEARLY a BLACK color
.EQU COLOR7 = 0x44			; DARK BROWN color
.EQU COLOR8 = 0x20			; Very much like color6 (NEARLY BLACK)
.EQU C_MINE = 0xE0			; Bright RED (CRED above)
.EQU C_FLAG = 0xD0		    ; GOLD color

.EQU BROWN		  = 0x88			; color data: BROWN
.EQU BLACK		  = 0x00			; color data: BLACK
.EQU YELLOW		  = 0xFC			; color data: YELLOW
;------------------------------------------------------------------

;------------------------------------------------------------------
; Various Constant Definitions
;------------------------------------------------------------------
.EQU KEY_UP     = 0xF0        ; key release data
.EQU int_flag   = 0x01        ; interrupt hello from keyboard
;------------------------------------------------------------------
.EQU time_INSIDE_FOR_COUNT    = 0xC5
.EQU time_MIDDLE_FOR_COUNT    = 0xC5
.EQU time_OUTSIDE_FOR_COUNT   = 0xC4
;------------------------------------------------------------------

;------------------------------------------------------------------
; Various MAP and CELL Constant Definitions
;------------------------------------------------------------------
.EQU MAP_START  = 0x00					; These two numbers are for the Scrath Memory
.EQU MAP_LENGTH = 0x64					; 0x64 = 100 (10x10)

.EQU MAP_WIDTH 	= 0x0A					; This is a 10x10 map
.EQU MAP_HEIGHT = 0x0A

.EQU CELL_WIDTH  = 0x01					; Adjustable if change of resolution is desired.
.EQU CELL_HEIGHT = 0x01

.EQU MINE_MASK	= 0x20					; Is there a mine in this cell?
.EQU FLAG_MASK	= 0x10					; This is the number for flags
.EQU VISIT_MASK	= 0x80					; This is the number indicating visits
.EQU NUM_MASK	= 0x0F					; Checks how many mines are around cell

.EQU UNVISITED = 0x8A					; Color of unvisited squares. (change)
.EQU VISITED   = 0xFF					; Color of visited squares. (change)
;-------------------------------------------------------------------

;--------- Data Segments for the Minesweeper Map -------------------
.DSEG
.ORG 0x00
map:
 .DB 0x20, 0x02, 0x0A, 0x0A, 0x0A, 0x0A, 0x01, 0x20, 0x02, 0x01
 .DB 0x20, 0x02, 0x0A, 0x0A, 0x0A, 0x0A, 0x01, 0x02, 0x20, 0x02
 .DB 0x01, 0x01, 0x01, 0x02, 0x03, 0x02, 0x01, 0x02, 0x20, 0x02
 .DB 0x0B, 0x0B, 0x02, 0x20, 0x20, 0x20, 0x02, 0x01, 0x02, 0x20
 .DB 0x0B, 0x0B, 0x03, 0x20, 0x08, 0x20, 0x03, 0x0D, 0x0D, 0x0D
 .DB 0x0B, 0x0B, 0x02, 0x20, 0x20, 0x20, 0x02, 0x0D, 0x0D, 0x0D
 .DB 0x0B, 0x0B, 0x01, 0x02, 0x03, 0x02, 0x01, 0x01, 0x01, 0x01
 .DB 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x01, 0x20, 0x01
 .DB 0x01, 0x02, 0x03, 0x02, 0x01, 0x0B, 0x01, 0x02, 0x02, 0x01
 .DB 0x01, 0x20, 0x20, 0x20, 0x01, 0x0B, 0x01, 0x20, 0x01, 0x0C

;- We resolved to a LUT for the board since a RNG would be difficult to work with in the time that we had.
;- We are sure it is possible to use a RNG, but that requires more lines of code.
;---------------------------------------------------------------------------------------------------------

.CSEG
.ORG	0x0F0 ; (Changed from 0x0C9, which is right up against the value of DSEG)

; == Cell memory format ============================================================================================
; Binary format: V-MFNNNN		(e.g., 1-0011111, 1-100000, 0-001000)
; This format corresponds to each cell in the RAT Sweeper board. The above format can be deciphered as follows:
;
;    V: The bit that shows if this cell has already been visited.
;    M: The bit that shows if this cell is a mine or not.
;    F: The bit that shows if this cell has been flagged or not. (Probably will be unused).
; NNNN: For the numbers representing the number of mines in the vicinity of the cell.
;       For numbers greater than 8, 0x09 -> 0x0F, indicate groups of empty space that are revealed
;		when one of their member cells are visited. In terms of color decoding, 0x09 -> 0x0F map 
;		to the "visited" color if that cell has already been visited.
;
; == REGISTER MAPPING ==============================================================================================
;	r1 	------	X coordinate to draw to the VGA driver. Adjusted for cell dimensions. 
; 	r2 	------ 	Y Coordinate to draw to the VGA driver. "                           "
;	r3 	------	Free to use.
;	r4 	------	VGA color of the current cell to draw.
;	r5	------  Current memory *value* to be processed.
;	r6	------	Current memory location to be used.
;  	r7  ------  Current index drawing from. Note: r6 = MAP_START + r7.
;		------		Can be considering:	map[r7]	--> value at r7
;	r8	------	X coord to visit
; 	r9 	------	Y coord to visit
;	r10 ------  An address in memory. Use coord_to_loc to go from coordinates to mem. address. This involves the
;				aforementioned Binary Format for each Cell.
;	...
;	r30 ------  Junk register. *
;	r31	------	Junk register. *
;
;	* r30 and r31 are for when you want a quick and dirty register to use, and don't want to use a register safely.
;	This is for the interests of performance. Having a register designated as a "junk register" means you can do
;	whatever you want to it. But DON'T try to depend on the value that register across subroutine calls. It's up to 
;	you to back up these registers if you need to. 
;
; == MEMORY MAPPING ================================================================================================
; 0x00 --> 0x64 Level 1
;
; == F.A.Q. ========================================================================================================
; Q: How the hell do I visit a cell? What does that even mean?
; A: You know when you play minesweeper, all the cells are in a "hidden" state? "Visiting" a cell
; 	 will "unhide" that cell, revealing what's underneath it.
;	 To visit a cell, obtaine the coordinate of the cell you want to visit. If you have the memory location
;	 of that cell, use loc_to_coord first. Then call mark_visited to visit that cell and all cells that
;	 neighbor it.
;
; Q: OK, but how are those cells drawn to the screen?
; A: mark_visited will color those cells for you.
;
; Q: What if I wanted to draw an individual cell?
; A: Use coord_to_loc to obtain the memory location in r10 if you haven't, and use draw_cell_color_unset. 
;    There is draw_cell_color_set if you have already decoded the color value of the cell, but draw_cell_color_unset
;    will handle that for you.
;
; Q; What's the difference between r1, r2 and r8, r9?
; A: If the map existed out on its own, r8 and r9 would point to a coordinate on the map. IE, for the cell in the
;	 3rd column, 4th row of the map, use: (r8, r9) ---> (2, 3)
;	 (r1, r2) Are meant to be the coordinates of each __super pixel__ sent to the VGA driver. You can easily convert
; 	 between cell coordinate to screen coordinate, which is what coord_to_fpga_loc does for you.
;
; ===================================================================================================================
init:	 MOV    r15, 0x0A         ;- starting y value (middle row)
         MOV    r16, 0x0A         ;- starting x value (middle column)
         MOV    r23, 0x00         ;- clear interrupt flag register
		 MOV 	r26, 0x00

         MOV    r14, BG_COLOR     ;- bluish color
         CALL   draw_background  ;- draw using default color

         MOV    r14, BG_COLOR     ;- dark Gray color
		 MOV	r18, r14			 ;- saves background color
		 EXOR	r14, 0xFF
		 MOV	r18,r14
         CALL   draw_dot         ;- plop down intial shape
         IN     r20,SWITCHES     ;- store current switch settings
         SEI                     ;- allow interrupts

main:
	MOV		r8, 0x02			; Starting X coord
	MOV		r9, 0x00			; Starting Y coord
	CALL	mark_visited		; Main subroutine for marking visited memory cells
	CALL	draw_screen			; Redraw the screen to catch updates of the game (See if we can just draw one bit at a time until we reveal squares?)
	IN		r0, 0x00			; Used for debugging purposes and is for the Sweeper Game state
mloop:
	CALL 	blink				; Blink where our cursor is (need to make sure it links with Nick's coord_to_loc stuff)
	BRN 	main				; Continue looping back through the entire thing.
;--------------------------------------------------------------------------------
;- Main Game Logic: Flag and Mine placement
;- Main Contributor: Nick Avila
;--------------------------------------------------------------------------------

; -------- mark_visited ---------------------------------------------------------
; (r8, r9) ---> The coordinates of the location in memory to visit
;				Will also visit all other visitable cells around the designated
;				cell.
;
;- Parameters:
;-	r10 - Memory Address in SCRAM
;-
; Tampers with: All registers r1 -> r10
; -------------------------------------------------------------------------------
mark_visited:
	CALL	coord_to_loc					; Converts r8,r9 to a memory address in SCRAM
	CALL	visit_test_for_num				; Regs Used: r10, r31
	BREQ	visit_num						; If not visited, branch.....
	CALL	visit_test						; Another visit test
	BRNE	mv_exit							; If visited, branch...
	LD		r31, (r10)						; Else, put memory address into r31
	PUSH	r31								; Save r31
	ADD		r31, VISIT_MASK					; Make r31 visited
	ST		r31, (r10)						; Put r31 back into the memory address
	CALL	draw_cell_color_unset			; Color the Cell correctly.
	CALL	visit_neighbors					; 
scroll_table:
	POP		r31
	MOV		r10, 0x00
scroll_loop:
	CMP		r10, MAP_LENGTH
	BREQ	mv_exit
	LD		r30, (r10)
	PUSH	r30
	AND		r31, NUM_MASK
	CMP		r30, r31
	BRNE	sl_end
	CALL	visit_test
	BRNE	sl_end
	POP		r30
	ADD		r30, VISIT_MASK
	ST		r30, (r10)
	CALL	loc_to_coord
	CALL	visit_neighbors
	ADD		r10, 0x01
	BRN		scroll_loop
sl_end:
	ADD		r10, 0x01
	POP		r30
	BRN		scroll_loop
visit_num:
	LD		r31, (r10)						; Grab value at r10 and put into temp reg
	ADD		r31, VISIT_MASK					; Assert the VISIT bit
	ST		r31, (r10)						; Overwrite the value at r10 with r31
	CALL	draw_cell_color_unset			; Sets the correct color of the cell.
mv_exit:
	RET										; Exit this horrendous loop

; ------------- visit_neighbors --------------------------------------
; (r8, r9) ----> Coordinate to look if neighbors are numbers, and thus
;				 merit visiting.
;
; Parameters:
;	r8 - X Coordinate
;	r9 - Y Coordinate
;
; Tampers with: r31
; --------------------------------------------------------------------
visit_neighbors:
	PUSH	r31								; Save r31
	PUSH	r10								; Save r10
check_top:				; Checks above
	PUSH	r9								; Save r9 (Y)
	SUB		r9, 0x01						; Move up one row
	BRCS	check_left						; If at top of board, check other spaces.
	CALL	coord_to_loc					; Else, convert to the memory address.
	CALL	visit_test_for_num				; Check if we can visit
	BRNE	check_left						; If not, check other spaces.
	LD		r31, (r10)						; Put value AT r10 into r31
	ADD		r31, VISIT_MASK					; Assert the VISIT bit.
	ST		r31, (r10)						; Overwrite the value AT r10 with new value in r31.
	CALL	draw_cell_color_unset			; Now, color the appropriate color in the cell.
check_left:				; Checks to left
	POP		r9
	PUSH	r8
	SUB		r8, 0x01
	BRCS	check_left
	CALL	coord_to_loc
	CALL	visit_test_for_num
	BRNE	check_bottom
	LD		r31, (r10)
	ADD		r31, VISIT_MASK
	ST		r31, (r10)
	CALL	draw_cell_color_unset
check_bottom:			; Checks below
	POP		r8
	PUSH	r9
	ADD		r9, 0x01
	CMP		r9, MAP_HEIGHT
	BRCC	check_right
	CALL	coord_to_loc
	CALL	visit_test_for_num
	BRNE	check_right
	LD		r31, (r10)
	ADD		r31, VISIT_MASK
	ST		r31, (r10)
	CALL	draw_cell_color_unset
check_right:			; Checks to the right
	POP		r9
	PUSH	r8
	ADD		r8, 0x01
	CMP		r8, MAP_WIDTH
	BRCC	vn_exit
	CALL	coord_to_loc
	CALL	visit_test_for_num
	BRNE	vn_exit
	LD		r31, (r10)
	ADD		r31, VISIT_MASK
	ST		r31, (r10)
	CALL	draw_cell_color_unset
vn_exit:
	POP		r8
	POP		r10
	POP		r31
	RET

; ---------- visit_test_for_num -------------------------------------
; Look at the cell given by index r10, and test to see if
; it should be visited. Sets the Z flag if the cell is neither
; a number or already visited, clearing it if it shouldn't be visited.
;
; This subroutine will out a value that is 0, making Z=1, if the cell has
; not been visited and should be visited.
;
; --------------------------------------------------------------------
visit_test_for_num:
	LD		r31, (r10)					; Put memory address into r31
	AND		r31, NUM_MASK				; Check the Number on this space.
	CMP		r31, 0x09					; If it's greater than or equal to 9...
	BRCC	do_not_visit_num			; .....don't visit the number (indicates mine or flag)
	LD		r31, (r10)					; Load value AT r10 into r31
	AND		r31, VISIT_MASK				; Has the cell been visited?
	CMP		r31, VISIT_MASK				; If cell visited, then branch...
	BREQ	do_not_visit_num
	AND		r31, 0x00					; Else, make Z = 1.
	RET
do_not_visit_num:
	OR		r31, 0xFF					; Clear Z Flag.
	RET

; ----------------- visit_test ----------------------------
; r10 ---> Location in memory to decode
; Sets the Z flag if the location in memory is NOT visited,
;	not a mine, and not the numbers 0 through 8. 
; ---------------------------------------------------------
visit_test:
	PUSH	r31
	LD		r31, (r10)
	PUSH	r31
	AND		r31, VISIT_MASK
	POP		r31
	BRNE	do_not_visit
	PUSH	r31
	AND		r31, MINE_MASK
	POP		r31
	BRNE	do_not_visit
	AND		r31, NUM_MASK
	CMP		r31, 0x09
	BRCS	do_not_visit
	CMP		r31, 0x10
	BRCC	do_not_visit
	TEST	r31, 0x00
	POP		r31
	RET
do_not_visit:
	OR		r31, 0xFF
	POP		r31
	RET
	
; -------------------- loc_to_coord -----------------------------------------------------------
; r10 -----> (r8, r9) 
;	Takes index value in r10 and makes r8, r9 the corresponding x, y coordinates for that cell.
;	This reverses the process of coord_to_loc by continually subtracting ten from the memory address.
; This makes it usable for the VGA driver, which requires (X,Y) coordinates to work. 
;
; Parameters:
;	r10 - Memory Address in SCRAM
; Output:
;	r8 - X coordinate of the memory address
;	r9 - Y coordinate of the memory address
; ---------------------------------------------------------------------------------------------
loc_to_coord:
	PUSH	r10
	MOV		r8, 0x00
	MOV		r9, 0x00
div_y:
	SUB		r10, MAP_HEIGHT
	BRCS	add_x1
	ADD		r9, 0x01
	BRN		div_y
add_x1: ;******************************************************
	ADD		r10, MAP_HEIGHT
	ADD		r8, r10
	POP		r10
	RET
	
; ------------------ coord_to_loc -----------------------------
; r10 <----- (r8, r9)
;
; Converts the coordinate registers to a map index, held in r10.
; This is done by adding 10 to r10 until r31 (temp Y-coord) is 
; exhausted, putting us in the correct row.
; Then, r8 (X-coord) will add to r10, putting us in the correct column.
;
; Parameters:
;  r8 - X coord to visit in SCRAM (for use with VGA?)
;  r9 - Y coord to visit in SCRAM (for use with VGA?)
; Output:
;	r10 - Memory Address in SCRAM (for use in RAT MCU)
; -------------------------------------------------------------
coord_to_loc:
	MOV		r10, 0x00				; Clear the memory address.
	MOV		r31, r9					; Move in the value of the Y-coord
mult_y:
	SUB		r31, 0x01				; For each increment of Y, add 10 to address in SCRAM. (like rows)
	BRCS	dec_x					; Once Y-coord is exhausted, add the X value.
	ADD		r10, MAP_WIDTH
	BRN		mult_y
dec_x:								; This corresponds to the column of the 10x10 map
	ADD		r10, r8					; Add the X-coord/column to memory address.
	ADD		r10, MAP_START
	RET

; --------------- draw_screen ----------------------------------------------
; Draws the entire screen by iterating over the map length,
; decoding the current values in each cell to a color, and outing
; the appropriate VGA coordinate and color with the draw_cell subroutine.
;
; Use the draw_cell subroutine if you don't want to color the entire screen.
; ---------------------------------------------------------------------------
draw_screen:
	PUSH 	r5					; current memory value
	PUSH	r6
	PUSH	r7
	MOV		r6, 0x00			; current memory location
	MOV		r7, 0x00			; map index
draw_loop:
	CMP 	r7, MAP_LENGTH		; Scans for the 100th cell
	BREQ	draw_exit
	MOV		r6, 0x00
	ADD		r6, MAP_START
	ADD		r6, r7
	LD		r5, (r6)
	CALL	coord_decode
	CALL	color_decode
	CALL	draw_cell_color_set
	ADD		r6, MAP_LENGTH
	ST		r4, (r6)			; Stores the color of corresponding cell into SCRAM
	ADD		r7, 0x01
	BRN		draw_loop
draw_exit:
	POP		r7
	POP		r6
	POP		r5
	RET

; -------------------- draw_cell_color_set -----------------------------
; Draw the cell currently located at (r8, r9) in the map.
; Converts r8, and r9, to their FPGA coordinates and outs 
; them to the VGA driver.
;
; Use this in the case where r4 has already been filled with a color.
; ----------------------------------------------------------------------
draw_cell_color_set:
	CALL	coord_to_fpga_loc
	OUT		r1, VGA_HADD ; (Previously VGA_XPORT)
	OUT		r2, VGA_LADD ; (Previously VGA_YPORT)
	OUT		r4, VGA_COLOR
	RET
; -------------------- draw_cell_color_unset ---------------------------
; See draw_cell_color_set, but sets the appropriate color from (r8, r9)
; in r4 before it colors.
;
; Use this subroutine if you have not decoded the color of the target cell.
; This subroutine will coord_to_loc on your coordinate registers, store your
; index register r10 into r5 as input for color_decode. color_decude sets 
; the color register appropriately and this subroutine then calls draw_cell_color_set.
;
; Tampers with: r4, r5 only
; ----------------------------------------------------------------------
draw_cell_color_unset:
	PUSH	r10								; Save r10
	CALL	coord_to_loc					; Convert the coordinates to SCRAM address.
	LD		r5, (r10)						; Get the value from the cell at r10
	CALL	color_decode					; Will decode the binary format of our memory address
	CALL	draw_cell_color_set				; Now set the color of the cell.
	POP		r10								; Restore r10
	RET

; ---------------------- coord_decode ---------------------------------
; deprecated, use coord_to_loc.
; Used by some older subroutines.
; @TODO remove this.
; ---------------------------------------------------------------------
coord_decode:
	PUSH 	r6
	MOV		r8, 0x00   ; X
	MOV		r9, 0x00   ; Y
find_y_coord:
	CMP		r6, MAP_WIDTH
	BRCC	sub_r6
	BRCS	find_x_coord
sub_r6:
	SUB		r6, MAP_WIDTH
	ADD		r9, 0x01
	BRN		find_y_coord
find_x_coord:
	MOV		r8, r6
	POP		r6
	RET

; ----------------------- color_decode --------------------------------------
; Given an index (r5, a location in memory), take the value of the cell and
; decode its appropriate color. See the .EQU directives for the color values.
;
; Parameters:
;	r5 - Binary number format containing cell information.
;
; Tampers with: r4
; ---------------------------------------------------------------------------
color_decode:
	PUSH	r5
	PUSH	r3

visit_check:
	MOV		r3, r5							; Move cell info into r3
	AND		r3, VISIT_MASK					; Has it been visited?
	CMP		r3, VISIT_MASK					; If not, move the unvisited color in and exit
	BRNE	make_unvisited
	BRN		c_num_decode
make_unvisited:
	MOV		r4, UNVISITED					; Color for unvisited squares.
	BRN		exit
c_num_decode:
	MOV		r3, r5
	AND		r3, NUM_MASK
c_empty_check:
	CMP		r3, 0x00
	BRNE	c_1_check
	MOV		r4, VISITED						; 
	BRN		flag_check

c_1_check:
	CMP		r3, 0x01						; If there is 1 mine nearby....
	BRNE	c_2_check
	MOV		r4, COLOR1						; color data: BLUE (diff shade than default, 0x03)
	BRN		exit
c_2_check:
	CMP		r3, 0x02						; If there are 2 mines nearby....
	BRNE	c_3_check
	MOV		r4, COLOR2						; color data: TEAL
	BRN		exit
c_3_check:
	CMP		r3, 0x03						; If there are 3 mines nearby....
	BRNE	c_4_check
	MOV		r4, COLOR3						; color data: GREEN
	BRN		exit
c_4_check:
	CMP		r3, 0x04						; If there are 4 mines nearby....
	BRNE	c_5_check
	MOV		r4, COLOR4						; EXOR value is more PURPLE than EXOR of 0x1C
	BRN		exit							; Color is pretty much GREEN
c_5_check:
	CMP		r3, 0x05						; If there are 5 mines nearby....
	BRNE	c_6_check
	MOV		r4, COLOR5						; This is a DARKER GREEN than 0x1C
	BRN		exit
c_6_check:
	CMP		r3, 0x06						; If there are 6 mines nearby....
	BRNE	c_7_check
	MOV		r4, COLOR6						; NEARLY a BLACK color
	BRN		exit
c_7_check:
	CMP		r3, 0x07						; If there are 7 mines nearby....
	BRNE	c_8_check
	MOV		r4, COLOR7						; DARK BROWN color
	BRN		exit
c_8_check:
	CMP		r3, 0x08						; If there are 8 mines nearby....
	BRNE	default_num_to_empty
	MOV		r4, COLOR8						; Very much like color6 (NEARLY BLACK)
	BRN		exit

default_num_to_empty:
	MOV		r4, VISITED
	BRN		exit
flag_check:
	MOV		r3, r5
	AND		r3, FLAG_MASK
	CMP		r3, FLAG_MASK
	BRNE	MINE_check
	MOV		r4, C_FLAG						; GOLD color
	BRN		exit
MINE_check:
	MOV		r3, r5
	AND		r3, MINE_MASK
	CMP		r3, MINE_MASK
	BRNE	finally_unvisit
	MOV		r4, C_MINE						; Bright RED (CRED above)
	; BRN GAME_OVER
	BRN		exit
finally_unvisit:
	MOV		r4, UNVISITED
exit:
	POP 	r3
	POP	 	r5
	RET

; ------------------------- coord_to_fpga_loc -------------------
; Take a coordinate on the map and make it a coordinate for the
; VGA driver.
; r8, r9   (x , y )
; r1, r2   (x', y')
;
; These coordinates are adjusted for cell width and height, and if needed,
; should also adjust for the location of the map on screen.
; So, if you had 2x2 super pixels, you can use this to compensate.
; ---------------------------------------------------------------
coord_to_fpga_loc:
	MOV		r30, r9		;y
	MOV		r31, r8		;x
	MOV		r1,	0x00	;x
	MOV		r2, 0x00	;y
fpga_comp_x:
	CMP		r31, 0x00
	BREQ	fpga_comp_y
	ADD		r1, CELL_WIDTH
	SUB		r31, 0x01
	BRN		fpga_comp_x
fpga_comp_y:
	CMP		r30, 0x00
	BREQ	ctfl_exit
	ADD		r2, CELL_HEIGHT
	SUB		r30, 0x01
	BRN		fpga_comp_y
ctfl_exit:  RET
;----------------------------------------------------------------

;----------------------------------------------------------------
;- Drawing and Color Subroutines
;- Main Contributor: Spencer Chang
;----------------------------------------------------------------
;------------------------------------------------------------------
;- Register Usage Key
;------------------------------------------------------------------
;- r12 -- holds keyboard input
;- r13 -- Copied Y-Coordinate going out to VGA*
;- r14 -- holds drawing color
;- r15 -- main Y location value
;- r16 -- main X location value
;- r17 -- Ending X or Y coordinates (temp register)
;- r18 -- secondary color value
;- r19 -- secondary Y location value
;- r20 -- secondary X location value
;- r21 -- Loop Count (temp register)
;- r22 -- Loop Count (temp register)
;- r23 -- for interrupt flag 
;- r24 -- Copied X-Coordinate going out to VGA*
;- r25 -- saves current switch settings
;- r30 -- Junk Register
;- r31 -- Junk Register
;------------------------------------------------------------------

;---------------------- Subroutine - Blink --------------------------
;- This subroutine blinks the dot on the screen periodically. It will
;- also blink the LSB LED on the Nexys2 Board to match the rate the
;- screen dot will blink.
;-
;- Tweaked Registers: r14, r26, r28
;--------------------------------------------------------------------
blink:		PUSH r14
			MOV r14, r18
			EXOR r18, 0xFF
			EXOR r14, 0xFF
			EXOR r26, 0x01
			CALL draw_dot		; The blinking dot DOES WORK.
			OUT r26, LEDS		; The LED blinking DOES WORK.
			CALL delay
			POP r14
			RET
;--------------------------------------------------------------------

;------------------- Subroutine - Delay (blinking) ------------------
;- This subroutine delays the blinking of the dot on the screen so
;- human eyes can actually see the dot blink on the screen.
;-
;- Tweaked Registers: r27, r28, r29
;------------------------------------------------------------------
delay:	     	MOV     R29, time_OUTSIDE_FOR_COUNT  	;set outside for loop count
outside_for: 	SUB     R29, 0x01

				MOV     R28, time_MIDDLE_FOR_COUNT   	;set middle for loop count
middle_for: 	SUB     R28, 0x01
			 
				MOV     R27, time_INSIDE_FOR_COUNT  	;set inside for loop count
inside_for: 	SUB     R27, 0x01
				BRNE    inside_for
			 
				OR      R28, 0x00              		 	;load flags for middle for counter
				BRNE    middle_for
			 
				OR      R29, 0x00               		;load flags for outsde for counter value
				BRNE    outside_for

exit_delay:		RET
;-----------------------------------------------------------

;---------------- Subroutine - Restore Old -----------------
;- This restores the color of the place where the dot used
;- to be. It will call draw_dot and use registers r18, r19, r20
;- both of which have been modified outside the subroutine
;- for use.
;-
;- Tweaked Registers: r18, r19, r20
;------------------------------------------------------------
restore_old:		PUSH r14			; Push bg_color
					PUSH r15			; Push Y-coord
					PUSH r16			; Push X-coord
					MOV r15, r19		; Mov old Y-coord
					MOV r16, r20		; Mov old X-coord
					MOV r14, r18		; Mov old BG_color
					CALL draw_dot		; Restore color to old dot.
					POP r16
					POP r15
					POP r14
					RET

;---------------- Subroutine - Mines Key ---------------------
;- This displays a key for the mines using colors and a number
;- of dark gray dots to represent the number of mines around
;- that color. This is based off the original Minesweeper colors.
;-	Blue - 1, Dark Green - 2, Red - 3, Dark Blue - 4, Violet - 5
;-
;- Tweaked Registers: r18, r19, r20, r21, r22
;------------------------------------------------------------
mines_key:		PUSH r15					; Y-coord
				PUSH r16					; X-coord
				PUSH r20				; Color of dots
				PUSH r21				; Number of dots
				PUSH r22

				MOV r20, VIOLET			; Push colors for ease of retrieval
				PUSH r20
				MOV r20, DBLUE
				PUSH r20
				MOV r20, CRED
				PUSH r20
				MOV r20, DGREEN
				PUSH r20
				MOV r20, BLUE
				PUSH r20

				MOV r21, 0x00
				MOV r15,KEY_Y				; starting Y-coord
				MOV r22, 0x00

out_loop:		MOV r16,KEY_X				; starting X-coord
				ADD r15,0x02					; This part of the loop increments the key row
				POP r20						; Chooses next color
				MOV r14, r20					; Mov color into color reg
				MOV r21,0x00				; Clear the dot count
				ADD r22,0x01				; Add to the row count
				CALL draw_dot				; Draw dot color

in_loop:		MOV r14,DGRAY				; Mov mine color into color reg
				ADD r16,0x02					; Add space between dots
				CALL draw_dot				; Draw Mine dot color
				ADD r21,0x01				; Inc dot count

				CMP r21,r22
				BRNE in_loop

				CMP r22,0x05
				BRNE out_loop

				POP r22						; Restore Registers
				POP r21
				POP r20
				POP r16
				POP r15
				RET
;------------------------------------------------------------
;- These subroutines add and/or subtract '1' from the given 
;- X or Y value, depending on the direction the blit was 
;- told to go. The trick here is to not go off the screen
;- so the blit is moved only if there is room to move the 
;- blit without going off the screen.  
;- 
;- Tweaked Registers: possibly r15; possibly r16
;------------------------------------------------------------
sub_x:   CMP   r16,LO_X    ; see if you can move
         BREQ  done1
		 MOV   r19, r15		; Save Y, then X
		 MOV   r20, r16	  ; Save old place
         SUB   r16,0x01    ; move if you can
done1:   RET

sub_y:   CMP   r15,LO_Y    ; see if you can move
         BREQ  done2
		 MOV   r19, r15		; Save Y, then X
		 MOV   r20, r16	  ; Save old place
         SUB   r15,0x01    ; move if you can
done2:   RET
 
add_x:   CMP   r16,HI_X    ; see if you can move
         BREQ  done3  
		 MOV   r19, r15		; Save Y, then X
		 MOV   r20, r16	  ; Save old place
         ADD   r16,0x01    ; move if you can
done3:   RET

add_y:   CMP   r15,HI_Y    ; see if you can move
         BREQ  done4   
		 MOV   r19, r15		; Save Y, then X
		 MOV   r20, r16	  ; Save old place
         ADD   r15,0x01    ; move if you can
done4:   RET
;---------------------------------------------------------
 
;--------------------------------------------------------------------
;-  Subroutine: draw_horizontal_line
;-
;-  Draws a horizontal line from (r16,r15) to (r17,r15) using color in r14
;-
;-  Parameters:
;-   r16  = starting x-coordinate
;-   r15  = y-coordinate
;-   r17  = ending x-coordinate
;-   r14  = color used for line
;- 
;- Tweaked registers: r16,r17
;--------------------------------------------------------------------
draw_horizontal_line:
        ADD    r17,0x01          ; go from r16 to r17 inclusive

draw_horiz1:
        CALL   draw_dot         ; draw tile
        ADD    r16,0x01          ; increment column (X) count
        CMP    r16,r17            ; see if there are more columns
        BRNE   draw_horiz1      ; branch if more columns
        RET
;--------------------------------------------------------------------

;---------------------------------------------------------------------
;-  Subroutine: draw_vertical_line
;-
;-  Draws a horizontal line from (r16,r15) to (r16,r17) using color in r14
;-
;-  Parameters:
;-   r16  = x-coordinate
;-   r15  = starting y-coordinate
;-   r17  = ending y-coordinate
;-   r14  = color used for line
;- 
;- Tweaked registers: r15,r17
;--------------------------------------------------------------------
draw_vertical_line:
         ADD    r17,0x01         ; go from r15 to r17 inclusive

draw_vert1:          
         CALL   draw_dot        ; draw tile
         ADD    r15,0x01         ; increment row (y) count
         CMP    r15,r17           ; see if there are more rows
         BRNE   draw_vert1      ; branch if more rows
         RET
;--------------------------------------------------------------------

;---------------------------------------------------------------------
;-  Subroutine: draw_background
;-
;-  Fills the 30x40 grid with one color using successive calls to 
;-  draw_horizontal_line subroutine. 
;- 
;-  Tweaked registers: r21,r15,r16,r17
;----------------------------------------------------------------------
draw_background: 
         PUSH  r15                       ; save registers
         PUSH  r16
         MOV   r21,0x05                 ; r21 keeps track of rows
start:   MOV   r15,r21                   ; load current row count 
         MOV   r16,0x05                  ; restart x coordinates
		 MOV   r17, 0x0E					; This is 19 for columns 0-19 = 20 columns
 
         CALL  draw_horizontal_line     ; draw a complete line
         ADD   r21,0x01                 ; increment row count
         CMP   r21,0x0E					; Should be 20 rows, giving a 20x20 map
		 BRNE  start                    ; branch to draw more rows
		 CALL mines_key					; Newly Added*******
         POP   r16                       ; restore registers
         POP   r15
         RET
;---------------------------------------------------------------------
    
;---------------------------------------------------------------------
;- Subrountine: draw_dot
;- 
;- This subroutine draws a dot on the display the given coordinates: 
;- 
;- (X,Y) = (r16,r15)  with a color stored in r14  
;- 
;- Tweaked registers: r13,r24
;---------------------------------------------------------------------
draw_dot: 
           MOV   r13,r15         ; copy Y coordinate
           MOV   r24,r16         ; copy X coordinate

           AND   r24,0x3F       ; make sure top 2 bits cleared
           AND   r13,0x1F       ; make sure top 3 bits cleared
           LSR   r13            ; need to get the bot 2 bits of r13 into sA
           BRCS  dd_add40
t1:        LSR   r13
           BRCS  dd_add80

dd_out:    OUT   r24,VGA_LADD   ; write bot 8 address bits to register
           OUT   r13,VGA_HADD   ; write top 3 address bits to register
           OUT   r14,VGA_COLOR  ; write data to frame buffer
           RET

dd_add40:  OR    r24,0x40       ; set bit if needed
           CLC                 ; freshen bit
           BRN   t1             

dd_add80:  OR    r24,0x80       ; set bit if needed
           BRN   dd_out
; --------------------------------------------------------------------

;--------------------------------------------------------------
; Interrup Service Routine - Handles Interrupts from keyboard
;--------------------------------------------------------------
; Sample ISR that looks for various key presses. When a useful
; key press is found, the program does something useful. The 
; code also handles the key-up code and subsequent re-sending
; of the associated scan-code. 
;
; Tweaked Registers; r12,r3,r23
;--------------------------------------------------------------
ISR:      PUSH	r3
		  CMP   r23, int_flag        ; check key-up flag 
          BRNE  continue
          MOV   r23, 0x00            ; clean key-up flag
          BRN   reset_ps2_register       

continue: IN    r12, PS2_KEY_CODE     ; get keycode data
       
move_up:  CMP   r12, UP               ; decode keypress value
          BRNE  move_down
          CALL  sub_y                ; verify move is possible
          CALL  draw_dot             ; draw object
		  CALL restore_old			 ; Restore the bg_color of dot's old coord's
		  MOV r18, BG_COLOR
          BRN   reset_ps2_register

move_down:
          CMP   r12, DOWN
          BRNE  move_left
          CALL  add_y                ; verify move
          CALL  draw_dot             ; draw object
		  CALL restore_old			 ; Restore the bg_color of dot's old coord's
		  MOV r18, BG_COLOR
          BRN   reset_ps2_register

move_left:
          CMP   r12, LEFT
          BRNE  move_right
          CALL  sub_x                ; verify move
          CALL  draw_dot             ; draw object
		  CALL restore_old			 ; Restore the bg_color of dot's old coord's
		  MOV r18, BG_COLOR
          BRN   reset_ps2_register

move_right:
          CMP   r12, RIGHT
;          BRNE  key_up_check
		  BRNE  reveal_spot
          CALL  add_x                ; verify move
          CALL  draw_dot             ; draw object
		  CALL restore_old			 ; Restore the bg_color of dot's old coord's
		  MOV r18, BG_COLOR
          BRN   reset_ps2_register

reveal_spot:
         CMP   r12, SPACE				  ;POTENTIAL PROBLEM: When calling "restore_old" in other ISR case statements,
         BRNE  place_flag				  ;    the color revealed on this space will be overwritten.
										  ;SOLUTION: r18 holds the secondary color of the tile. Write a few instructions
										  ;    that will store and save the color of the tile when it's changed.
		  ;MOV r18, BROWN	 		; Sets the color of flags
		  ;CALL mark_visited
          CALL  draw_dot            ; draw object
          BRN   reset_ps2_register

place_flag:
          CMP   r12, ENTER
          BRNE  key_up_check
		   MOV r18, YELLOW
		   CALL  draw_dot             ; draw object
          BRN   reset_ps2_register


key_up_check:  
          CMP   r12,KEY_UP            ; look for key-up code 
          BRNE  reset_ps2_register   ; branch if not found

set_skip_flag:
          ADD   r23, 0x01            ; indicate key-up found

reset_ps2_register:                  ; reset PS2 register 
		  ;MOV	 r18, BG_COLOR       ; Remember to get the color of the tile next
		  MOV    r3, 0x01
          OUT    r3, PS2_CONTROL 
          MOV    r3, 0x00
          OUT    r3, PS2_CONTROL
		  POP	 r3
          RETIE
;-------------------------------------------------------------------

;---------------------------------------------------------------------
; interrupt vector 
;---------------------------------------------------------------------
.CSEG
.ORG 0x3FF
           BRN   ISR
;---------------------------------------------------------------------

