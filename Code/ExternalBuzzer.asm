;Digital Piano
;This version is for on board buzzer
        	LIST   P=18F4520
        	#include <P18F4520.INC>
        	CONFIG OSC = XT
        	CONFIG WDT = OFF
        	CONFIG LVP = OFF

;----------------------------define own function
MOVLF   	MACRO    	Num, Dest
        	MOVLW     	Num
        	MOVWF     	Dest
        	ENDM

SETTBL  	MACRO     	Num
        	MOVLF     	low Num, TBLPTRL
        	MOVLF     	high Num, TBLPTRH
        	MOVLF     	upper Num, TBLPTRU
        	ENDM
;---------------------------------------------------
;CBLOCK will translate all variables into numbers before compiling
        	CBLOCK 	0x00
			Delay_High
			Delay_Low
			D1
			D2
			Delay
        	Note
			HalfPeriod
        	Counter
        	Record
        	ENDC
;---------------------------------------------------
;ORG will indicate where all the below operations are located
        	ORG      	0x00
        	GOTO     	Setup
;---------------------------------------------------
ButtomPin	EQU			PORTC
SoundPin	EQU			PORTB
LEDPin		EQU			PORTD

        	ORG        	0x30
Setup:  	CLRF     	TRISD
        	MOVLF     	0x0F, TRISC	;4*4 Matrix
			CLRF		TRISB		
        	CLRF     	LEDPin		;LED
        	CLRF     	SoundPin	;Sound
        	SETF     	ButtomPin	;Buttom
        	LFSR     	0, Record
			CLRF     	Counter
        	SETTBL   	PeriodTable    	;move the address of PeriodTable into table pointer
;---------------------------------------------------
Main:   	Call		GetNote
			MOVF		WREG
			BZ        	Main
			MOVWF		Note
			BTFSC		Note, 7		;Play Record
			BRA			PlayRecord	;If buttom 0 is bressed
			INCF    	Counter
        	MOVFF     	Note, POSTINC0
        	Call      	Lookup7Seg	
        	MOVWF     	LEDPin		;Show LED
        	Call      	GetFreq
        	Call      	PlaySound
        	CLRF    	LEDPin
        	BRA      	Main
;---------------------------------------------------
GetNote:	MOVLF		B'01110000', ButtomPin
			BTFSS		ButtomPin, 0
			RETLW		0xFF
			BTFSS		ButtomPin, 1
			RETLW		D'1'
			BTFSS		ButtomPin, 2
			RETLW		D'2'
			BTFSS		ButtomPin, 3
			RETLW		D'3'			
			MOVLF		B'10110000', ButtomPin
			BTFSS		ButtomPin, 0
			RETLW		D'4'
			BTFSS		ButtomPin, 1
			RETLW		D'5'
			BTFSS		ButtomPin, 2
			RETLW		D'6'
			BTFSS		ButtomPin, 3
			RETLW		D'7'			
			MOVLF		B'11010000', ButtomPin
			BTFSS		ButtomPin, 0
			RETLW		D'8'
			BTFSS		ButtomPin, 1
			RETLW		D'9'
			BTFSS		ButtomPin, 2
			RETLW		D'10'
			BTFSS		ButtomPin, 3
			RETLW		D'11'			
			MOVLF		B'11100000', ButtomPin
			BTFSS		ButtomPin, 0
			RETLW		D'12'
			BTFSS		ButtomPin, 1
			RETLW		D'13'
			BTFSS		ButtomPin, 2
			RETLW		D'14'
			BTFSS		ButtomPin, 3
			RETLW		D'15'
			RETLW		0x0
;---------------------------------------------------
Lookup7Seg:
			MOVF		Note, W
        	MULLW    	0x2
        	MOVF     	PRODL, W
        	ADDWF    	PCL, F
        	RETLW    	0x00
        	RETLW    	0x39    	;C
        	RETLW    	0x5E    	;D
        	RETLW    	0x79    	;E
        	RETLW    	0x71    	;F
        	RETLW    	0x7D    	;G
        	RETLW    	0x77    	;A
        	RETLW    	0x7C    	;B
        	RETLW    	0x39    	;C
        	RETLW    	0x5E    	;D
        	RETLW    	0x79    	;E
        	RETLW    	0x71    	;F
			RETLW    	0x7D    	;G
        	RETLW    	0x77    	;A
        	RETLW    	0x7C    	;B
        	RETLW    	0x39    	;C
        	
;---------------------------------------------------
GetFreq:
			MOVF      	Note, W
        	ADDWF     	TBLPTRL
        	TBLRD*
        	MOVFF     	TABLAT, HalfPeriod
        	MOVLF     	low PeriodTable, TBLPTRL ;move TABLAT back to lowPeriodTable
        	Return
;---------------------------------------------------
PlaySound:
			MOVLF		D'10',  D2
A2:			MOVLF 		D'60', D1  
A1:  		SETF	 	SoundPin
		  	MOVFF 		HalfPeriod, Delay   ;2*1
Lp1:  		DECF 		Delay   			;N
		   	BNZ  		Lp1   			;2(N-1) + 1

		  	CLRF	 	SoundPin
		  	MOVFF 		HalfPeriod, Delay   ;2*1
Lp2:  		DECF 		Delay   			;N
		   	BNZ  		Lp2   			;2(N-1) + 1
			
			DECF 		D1
   			BNZ  		A1
			
			DECF		D2
			BNZ			A2

   			CLRF     	SoundPin
   			Return
;---------------------------------------------------
PlayRecord:	LFSR     	0, Record
			MOVF		Counter
			BZ			Setup
			
NextNote:  	MOVFF     	POSTINC0, Note    	;lowPeriodTable
			Call      	Lookup7Seg	
        	MOVWF     	LEDPin		;Show LED
        	Call      	GetFreq
        	Call      	PlaySound
        	CLRF    	LEDPin
			Call		Pause
			DECF      	Counter
        	BNZ     	NextNote
        	  
        	LFSR     	0, Record
        	GOTO		Setup
;---------------------------------------------------
Pause:		
			MOVLF		0xFF, Delay_High
N1:			MOVLF		0x15, Delay_Low
N2:			Nop			
			DECF		Delay_Low
			BNZ			N2
			DECF		Delay_High
			BNZ			N1
			Return
;---------------------------------------------------
			ORG  		0x800
PeriodTable:
			DB  		D'0', D'159', D'141', D'126', D'119', D'106', D'94', D'84', D'79', D'70', D'63', D'59', D'53', D'47', D'42', D'39'
        	END
;--------------------------------------------------