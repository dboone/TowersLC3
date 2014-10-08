	;  1. caller pushes arguments (last to first)
	;  2. caller invokes subroutine (use JSR)
	;  3. callee allocates return value, pushes R7 and R5
	;  4. callee allocates space for local variables (first to last)
	;  5. callee executes function code
	;  6. callee stores result into return value slot
	;  7. callee pops local variables, R5, and R7
	;  8. callee returns (use JMP R7)
	;  9. caller loads return value and pops arguments
	; 10. caller resumes computation

	.ORIG x3000
	LEA R0, HEAD
	TRAP x22
	
	LEA R0, PROMPT
	TRAP x22
	
	TRAP x20
	TRAP x21

	LD R4, NOFFSET
	ADD R4, R4, R0		; R4 contains the user's input

	LEA R0, ENDL
	TRAP x22

	; initialize the frame pointer and stack pointer
	LD R5, ISTACK
	LD R6, ISTACK

	; push main's local variable onto the stack
	AND R0, R0, #0
	ADD R0, R4, #0
	ADD R6, R6, #-1
	STR R0, R6, #0	
	
	; 1. caller pushes arguments (last to first)
	; we have four arguments: diskNumber, startPost, endPost, and midPost
	; R6 is pointing to theh bottom of the stack, so we can store a value there

	; push 2 (MIDPOST)
	AND R0, R0, #0
	ADD R0, R0, #2
	ADD R6, R6, #-1
	STR R0, R6, #0	

	; push 3 (ENDPOST)
	ADD R0, R0, #1
	ADD R6, R6, #-1
	STR R0, R6, #0

	; push 1 (STARTPOST)
	ADD R0, R0, #-2
	ADD R6, R6, #-1
	STR R0, R6, #0

	; push the number of disks
	ADD R0, R4, #0
	ADD R6, R6, #-1
	STR R0, R6, #0

	; display the instruction header
	LEA R0, INST1
	TRAP x22
	LD R0, OFFSET
	ADD R0, R0, R4
	TRAP x21
	LEA R0, INST2
	TRAP x22
	
	; 2. caller invokes subroutine (use JSR)
	JSR HANOI	
	TRAP x25	; do not remove this!
HANOI
	; 3. callee allocates return address, return value, pushes R7, and pushes R5
	; push return value
	ADD R6, R6, #-1
	
	; push return address
	ADD R6, R6, #-1
	STR R7, R6, #0
	
	; push dynamic link
	ADD R6, R6, #-1
	STR R5, R6, #0

	; set new frame pointer
	ADD R5, R6, #0	

	; 4. callee allocates space for local variables (first to last)
	; we are not using local variables, so there isn't anything to do here
	
	; 5. callee executes function code
	; check for the base case
	LDR R0, R5, #3
	ADD R0, R0, #-1
	BRz BASECASE

	; recursive call to move the disks to the temp post
	; caller pushes arguments (last to first)
	; we have four arguments: diskNumber, startPost, endPost, and midPost

	; push endPost
	ADD R6, R6, #-1
	LDR R0, R5, #5
	STR R0, R6, #0

	; push midPost
	ADD R6, R6, #-1
	LDR R0, R5, #6
	STR R0, R6, #0

	; push startPost
	ADD R6, R6, #-1
	LDR R0, R5, #4
	STR R0, R6, #0

	; get the number of disks from the stack and subtract one
	; push the number of disks
	ADD R6, R6, #-1
	LDR R0, R5, #3
	ADD R0, R0, #-1		; diskNumber -= 1
	STR R0, R6, #0

	JSR HANOI

	; 9. caller loads return value and pops arguments
	; pop the return value
	LDR R0, R6, #0
	ADD R6, R6, #1
	ADD R6, R6, #4

	; print the instruction
	LEA R0, MOVE
	TRAP x22
	
	LDR R0, R5, #3
	LD R1, OFFSET
	ADD R0, R1, R0
	TRAP x21
	
	LEA R0, FROM
	TRAP x22

	LDR R0, R5, #4
	LD R1, OFFSET
	ADD R0, R1, R0
	TRAP x21

	LEA R0, TO
	TRAP x22

	LDR R0, R5, #5
	LD R1, OFFSET
	ADD R0, R1, R0
	TRAP x21

	LEA R0, PERIOD
	TRAP x22

	; recursive call to move the disks to the end post
	; caller pushes arguments (last to first)
	; we have four arguments: diskNumber, startPost, endPost, and midPost

	; push startPost
	ADD R6, R6, #-1
	LDR R0, R5, #4
	STR R0, R6, #0

	; push endPost
	ADD R6, R6, #-1
	LDR R0, R5, #5
	STR R0, R6, #0

	; push midPost
	ADD R6, R6, #-1
	LDR R0, R5, #6
	STR R0, R6, #0

	; get the number of disks from the stack and subtract one
	; push the number of disks
	ADD R6, R6, #-1
	LDR R0, R5, #3
	ADD R0, R0, #-1		; diskNumber -= 1
	STR R0, R6, #0
	JSR HANOI
	
	; 9. caller loads return value and pops arguments
	; pop the return value
	LDR R0, R6, #0
	ADD R6, R6, #1
	ADD R6, R6, #4
	
	BRnzp HANOIEND

BASECASE
	; print "move disk 1 from post startPost to endPost"
	LEA R0, MOVE
	TRAP x22

	; get the diskNumber from the stack
	LDR R0, R5, #3
	LD R1, OFFSET
	ADD R0, R1, R0
	TRAP x21

	LEA R0, FROM
	TRAP x22

	; get the startPost number from the stack
	LDR R0, R5, #4
	LD R1, OFFSET
	ADD R0, R1, R0
	TRAP x21

	LEA R0, TO
	TRAP x22

	; get the endPost number from the stack
	LDR R0, R5, #5
	LD R1, OFFSET
	ADD R0, R1, R0
	TRAP x21

	LEA R0, PERIOD
	TRAP x22	
	
	; ending house keeping
HANOIEND
	LDR R5, R6, #0		; restore the frame pointer
	ADD R6, R6, #1
	LDR R7, R6, #0		; pop the return address
	ADD R6, R6, #1
	RET	

ISTACK	.FILL	x5000
OFFSET	.FILL	x30
NOFFSET	.FILL	x-30
HEAD	.STRINGZ "--Towers of Hanoi--\n"
PROMPT	.STRINGZ "How many disks? "
ENDL	.STRINGZ "\n"
INST1	.STRINGZ "Instructions to move "
INST2	.STRINGZ " disk(s) from post 1 to post 3:\n"
MOVE	.STRINGZ "Move disk "
FROM	.STRINGZ " from post "
TO	.STRINGZ " to post "
PERIOD	.STRINGZ ".\n"

	.END