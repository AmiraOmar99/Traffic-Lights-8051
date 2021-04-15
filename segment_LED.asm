$NOMOD51	 ;to suppress the pre-defined addresses by keil
$include (C8051F020.H)		; to declare the device peripherals	with it's addresses
ORG 00H					   ; to start writing the code from the base 0


;disable the watch dog
MOV WDTCN,#11011110B ;0DEH
MOV WDTCN,#10101101B ;0ADH

; config of clock
MOV OSCICN , #14H ; 2MH clock

; config cross bar
MOV XBR0 , #00H
MOV XBR1 , #00H
MOV XBR2 , #040H  ; Cross bar enabled , weak Pull-up enabled 

TABLE_SEG EQU 100H			; start address of look-up Table
		RED_LED BIT P1.6
		GREEN_LED BIT P1.5
		LEFT_7_SEGMENT EQU P3
		RIGHT_7_SEGMENT EQU P2
		
		ORG 0					;tells the compiler all subsequent code starting at address 0
		CALL ON
		MOV DPTR, #TABLE_SEG


PRESET_MAX30:	MOV A, #2				;max left segment
			MOV R1, A
			MOVC A, @A+DPTR
			MOV LEFT_7_SEGMENT, A
			MOV A, #3				;MSB Tracker, Max Left Segment + 1
			MOV R2, A
			JMP MAIN


MAIN:	MOV A, #9
		MOV R0, A
		
LOOP3:	MOVC A, @A+DPTR			; location in the look-up Table
		MOV RIGHT_7_SEGMENT, A	; write to the 7-segment
		DEC R0
		MOV A, R0
		ACALL DELAY
		
		CJNE R0, #0H, LOOP3		; check the number
		DEC R2

		MOVC A, @A+DPTR
		MOV RIGHT_7_SEGMENT, A
		ACALL DELAY
		
		CJNE R2, #0, LCONT
		CALL REST
		JMP MAIN

LCONT:	DEC R1
		MOV A, R1
		MOVC A, @A+DPTR
		MOV LEFT_7_SEGMENT, A

		JMP MAIN

REST:	CALL TOG
      ACALL PRESET_MAX30
		RET

ON:		SETB GREEN_LED
		CLR RED_LED
		RET
		
OFF:	CLR GREEN_LED
		SETB RED_LED
		RET

TOG:	CPL GREEN_LED
		CPL RED_LED
		RET
			
		;look up table for right seven segment common cathode
        ORG TABLE_SEG
        DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH


DELAY:                  
			MOV R4,#8
			MOV R5 ,#50
			MOV R6, #50
			        
			LOOP2:	  DJNZ R6, LOOP2
			          DJNZ R5, LOOP2
			          DJNZ R4, LOOP2
      RET
		
				

			END