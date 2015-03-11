.EQU VGA_XPORT = 0x1E
.EQU VGA_YPORT = 0x1F
.EQU VGA_COLOR = 0x20

.EQU MAP_START  = 0x00
.EQU MAP_LENGTH = 0x64

.EQU MAP_WIDTH 	= 0x0A
.EQU MAP_HEIGHT = 0x0A

.EQU CELL_WIDTH  = 0x01
.EQU CELL_HEIGHT = 0x01

.DSEG
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

.EQU MINE_MASK	= 0x20
.EQU FLAG_MASK	= 0x10
.EQU VISIT_MASK	= 0x80
.EQU NUM_MASK	= 0x0F

.EQU UNVISITED = 0x8A
.EQU VISITED   = 0xFF
.EQU COLOR1 = 0x07
.EQU COLOR2 = 0x1F
.EQU COLOR3 = 0x1C
.EQU COLOR4 = 0x3C
.EQU COLOR5 = 0x34
.EQU COLOR6 = 0x24
.EQU COLOR7 = 0x44
.EQU COLOR8 = 0x20
.EQU C_MINE = 0xE0
.EQU C_FLAG = 0xD0		; randomly assigned, I don't really know what color this makes.

.CSEG
.ORG	0x0C9

; == Cell memory format ============================================================================================
; Binary format: V-MFNNNN		(e.g., 1-0011111, 1-100000, 0-001000)
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
;	r10 ------  An address in memory. Use coord_to_loc to go from coordinates to mem. address
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

main:
	MOV		r8, 0x02
	MOV		r9, 0x00
	CALL	mark_visited
	CALL	draw_screen
	IN		r0, 0x00
mloop:
	BRN 	main

; -------- mark_visited ---------------------------------------------------------
; (r8, r9) ---> The coordinates of the location in memory to visit
;				Will also visit all other visitable cells around the designated
;				cell.
; Tampers with: All registers r1 -> r10
; -------------------------------------------------------------------------------
mark_visited:
	CALL	coord_to_loc
	CALL	visit_test_for_num
	BREQ	visit_num
	CALL	visit_test
	BRNE	mv_exit
	LD		r31, (r10)
	PUSH	r31
	ADD		r31, VISIT_MASK
	ST		r31, (r10)
	CALL	draw_cell_color_unset
	CALL	visit_neighbors
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
	LD		r31, (r10)
	ADD		r31, VISIT_MASK
	ST		r31, (r10)
	CALL	draw_cell_color_unset
mv_exit:
	RET

; ------------- visit_neighbors --------------------------------------
; (r8, r9) ----> Coordinate to look if neighbors are numbers, and thus
;				 merit visiting.
; Tampers with: r31
; --------------------------------------------------------------------
visit_neighbors:
	PUSH	r31
	PUSH	r10
check_top:
	PUSH	r9
	SUB		r9, 0x01
	BRCS	check_left
	CALL	coord_to_loc
	CALL	visit_test_for_num
	BRNE	check_left
	LD		r31, (r10)
	ADD		r31, VISIT_MASK
	ST		r31, (r10)
	CALL	draw_cell_color_unset
check_left:
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
check_bottom:
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
check_right:
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
; --------------------------------------------------------------------
visit_test_for_num:
	LD		r31, (r10)
	AND		r31, NUM_MASK
	CMP		r31, 0x09
	BRCC	do_not_visit_num
	LD		r31, (r10)
	AND		r31, VISIT_MASK
	CMP		r31, VISIT_MASK
	BREQ	do_not_visit_num
	AND		r31, 0x00
	RET
do_not_visit_num:
	OR		r31, 0xFF
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
; ---------------------------------------------------------------------------------------------
loc_to_coord:
	PUSH	r10
	MOV		r8, 0x00
	MOV		r9, 0x00
div_y:
	SUB		r10, MAP_HEIGHT
	BRCS	add_x
	ADD		r9, 0x01
	BRN		div_y
add_x:
	ADD		r10, MAP_HEIGHT
	ADD		r8, r10
	POP		r10
	RET
	
; ------------------ coord_to_loc -----------------------------
; r10 <----- (r8, r9)
; Cnverts the coordinate registers to a map index, held in r10.
; -------------------------------------------------------------
coord_to_loc:
	MOV		r10, 0x00
	MOV		r31, r9
mult_y:
	SUB		r31, 0x01
	BRCS	dec_x
	ADD		r10, MAP_WIDTH
	BRN		mult_y
dec_x:
	ADD		r10, r8
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
	CMP 	r7, MAP_LENGTH
	BREQ	draw_exit
	MOV		r6, 0x00
	ADD		r6, MAP_START
	ADD		r6, r7
	LD		r5, (r6)
	CALL	coord_decode
	CALL	color_decode
	CALL	draw_cell_color_set
	ADD		r6, MAP_LENGTH
	ST		r4, (r6)
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
	OUT		r1, VGA_XPORT
	OUT		r2, VGA_YPORT
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
	PUSH	r10
	CALL	coord_to_loc
	LD		r5, (r10)
	CALL	color_decode
	CALL	draw_cell_color_set
	POP		r10
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
; Tampers with: r4
; ---------------------------------------------------------------------------
color_decode:
	PUSH	r5
	PUSH	r3
visit_check:
	MOV		r3, r5
	AND		r3, VISIT_MASK
	CMP		r3, VISIT_MASK
	BRNE	make_unvisited
	BRN		c_num_decode
make_unvisited:
	MOV		r4, UNVISITED
	BRN		exit
c_num_decode:
	MOV		r3, r5
	AND		r3, NUM_MASK
c_empty_check:
	CMP		r3, 0x00
	BRNE	c_1_check
	MOV		r4, VISITED
	BRN		flag_check
c_1_check:
	CMP		r3, 0x01
	BRNE	c_2_check
	MOV		r4, COLOR1
	BRN		exit
c_2_check:
	CMP		r3, 0x02
	BRNE	c_3_check
	MOV		r4, COLOR2
	BRN		exit
c_3_check:
	CMP		r3, 0x03
	BRNE	c_4_check
	MOV		r4, COLOR3
	BRN		exit
c_4_check:
	CMP		r3, 0x04
	BRNE	c_5_check
	MOV		r4, COLOR4
	BRN		exit
c_5_check:
	CMP		r3, 0x05
	BRNE	c_6_check
	MOV		r4, COLOR5
	BRN		exit
c_6_check:
	CMP		r3, 0x06
	BRNE	c_7_check
	MOV		r4, COLOR6
	BRN		exit
c_7_check:
	CMP		r3, 0x07
	BRNE	c_8_check
	MOV		r4, COLOR7
	BRN		exit
c_8_check:
	CMP		r3, 0x08
	BRNE	default_num_to_empty
	MOV		r4, COLOR8
	BRN		exit
default_num_to_empty:
	MOV		r4, VISITED
	BRN		exit
flag_check:
	MOV		r3, r5
	AND		r3, FLAG_MASK
	CMP		r3, FLAG_MASK
	BRNE	MINE_check
	MOV		r4, C_FLAG
	BRN		exit
MINE_check:
	MOV		r3, r5
	AND		r3, MINE_MASK
	CMP		r3, MINE_MASK
	BRNE	finally_unvisit
	MOV		r4, C_MINE
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
ctfl_exit:
	RET
