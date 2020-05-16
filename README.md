EE2004 Microcomputer System
===========================

Mini-Project Title
==================

+------------------+----------+
| Team Member Name | ID:      |
| ================ | ===      |
+------------------+----------+
| CHEN Tsung Yu    | 55077067 |
| =============    | ======== |
+------------------+----------+
| KUO Kuan Ting    | 55146655 |
| =============    | ======== |
+------------------+----------+

Instructor: Dr Angus WU
=======================

Tutorial Session: TB1
=====================

Tutorial Tutor: Angus WU
========================

Semester B, 2019
================

Date 23, 4, 2019
================

**Project Title**

Digital Piano

**Project Description**

There are mainly three features of our design.

First, we use 4x4 bottoms, instead of just using the more basic 8
buttons, as the keys of the piano. The 4x4 buttons are connected to 8
pin output, therefore, we use time multiplexing to check which pin is
being pressed. The keys cover two completed octaves, a play button and a
clear button, which is used in the third function.

The second function is the note display in the 7-segment LED. By keeping
track of which button is pressed, we can find out what note is played
and show the corresponding note on the LED. The LED display not only
occurs when the button is pressed, but it is also turned on when the
recorded music is being played so that the people can know what notes
are pressed.

The third function is music recording and playing. Every time when music
is played, the buttons that are pressed are recorded. When the play
button is pressed, the speaker will output the music. The same music can
be played out several times by pressing the play button. When we want to
clear the previous record of the music and start to record a new song,
we can press the 'clear button' to delete all the previous record and
start a new one.

**System Architecture**

![](media/image1.png){width="5.171720253718285in"
height="3.8010422134733157in"}

Figure 1: System Architecture

**I/O Description**

1.  Input:

    a.  4x4 Button: connected to PORTC

2.  Output:

    a.  Play Music: PORTB

    b.  7-segment LED: PORTD

**Program Description**

![](media/image2.png){width="5.807292213473316in"
height="7.126123140857393in"}

Figure 2: Flow Chart of Main and Setup

![](media/image3.png){width="5.954438976377952in"
height="7.926041119860018in"}

Figure 3: Flow Chart of GetNote

![](media/image4.png){width="6.640625546806649in"
height="7.479166666666667in"}

Figure 4: Flow Chart of GetFreq, Lookup7Seg and PlaySound

![](media/image5.png){width="5.5625in" height="8.85in"}

Figure 5: Flow Chart of PlayRecord and Pause

**Appendix**

;Digital Piano

> LIST P=18F4520
>
> \#include \<P18F4520.INC\>
>
> CONFIG OSC = XT
>
> CONFIG WDT = OFF
>
> CONFIG LVP = OFF

;\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--define own
function

MOVLF MACRO Num, Dest

MOVLW Num

MOVWF Dest

ENDM

SETTBL MACRO Num

> MOVLF low Num, TBLPTRL
>
> MOVLF high Num, TBLPTRH
>
> MOVLF upper Num, TBLPTRU
>
> ENDM

;\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--

;CBLOCK will translate all variables into numbers before compiling

CBLOCK 0x00

> Delay\_High
>
> Delay\_Low
>
> D1 ;tmp delay1
>
> D2 ;tmp delay2
>
> Delay
>
> Note
>
> HalfPeriod
>
> Counter
>
> tmp\_counter ;tmp counter
>
> Record

ENDC

;\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--

;ORG will indicate where all the below operations are located

ORG 0x00

GOTO Setup

;\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--

ButtomPin EQU PORTC

SoundPin EQU PORTB

LEDPin EQU PORTD

ORG 0x30

Setup: CLRF TRISD

> MOVLF 0x0F, TRISC ;4\*4 Matrix
>
> CLRF TRISB
>
> CLRF LEDPin ;LED
>
> CLRF SoundPin ;Sound
>
> SETF ButtomPin ;Buttom

LFSR 0, Record

CLRF Counter

SETTBL PeriodTable ;move the address of PeriodTable into table pointer

;\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--

Main: Call GetNote

MOVF WREG

BZ Main ;If the buttom is not pressed

MOVWF Note

BTFSC Note, 7 ;Play Record

BRA PlayRecord ;If buttom 0 is bressed

BTFSC Note, 6

BRA Setup ;Clear Counter

INCF Counter

MOVFF Note, POSTINC0

Call Lookup7Seg

> MOVWF LEDPin ;Show LED
>
> Call GetFreq
>
> Call PlaySound
>
> CLRF LEDPin
>
> BRA Main

;\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--

GetNote: MOVLF B\'01110000\', ButtomPin

BTFSS ButtomPin, 0

RETLW B\'10000000\'

BTFSS ButtomPin, 1

RETLW D\'1\'

BTFSS ButtomPin, 2

RETLW D\'2\'

BTFSS ButtomPin, 3

RETLW D\'3\'

MOVLF B\'10110000\', ButtomPin

BTFSS ButtomPin, 0

RETLW D\'4\'

BTFSS ButtomPin, 1

RETLW D\'5\'

BTFSS ButtomPin, 2

RETLW D\'6\'

BTFSS ButtomPin, 3

RETLW D\'7\'

MOVLF B\'11010000\', ButtomPin

BTFSS ButtomPin, 0

RETLW D\'8\'

BTFSS ButtomPin, 1

RETLW D\'9\'

BTFSS ButtomPin, 2

RETLW D\'10\'

BTFSS ButtomPin, 3

RETLW D\'11\'

MOVLF B\'11100000\', ButtomPin

BTFSS ButtomPin, 0

RETLW D\'12\'

BTFSS ButtomPin, 1

RETLW D\'13\'

BTFSS ButtomPin, 2

RETLW D\'14\'

BTFSS ButtomPin, 3

RETLW B\'01000000\'

RETLW 0x0

;\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--

Lookup7Seg:

> MOVF Note, W
>
> MULLW 0x2
>
> MOVF PRODL, W
>
> ADDWF PCL, F
>
> RETLW 0x00
>
> RETLW 0x39 ;C
>
> RETLW 0x5E ;D
>
> RETLW 0x79 ;E
>
> RETLW 0x71 ;F
>
> RETLW 0x7D ;G
>
> RETLW 0x77 ;A
>
> RETLW 0x7C ;B
>
> RETLW 0x39 ;C
>
> RETLW 0x5E ;D
>
> RETLW 0x79 ;E
>
> RETLW 0x71 ;F
>
> RETLW 0x7D ;G
>
> RETLW 0x77 ;A
>
> RETLW 0x7C ;B

;\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--

GetFreq:

MOVF Note, W

> ADDWF TBLPTRL
>
> TBLRD\*
>
> MOVFF TABLAT, HalfPeriod
>
> MOVLF low PeriodTable, TBLPTRL ;move TABLAT back to lowPeriodTable

Return

;\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--

PlaySound:

MOVLF D\'10\', D2

A2: MOVLF D\'60\', D1

A1: SETF SoundPin

MOVFF HalfPeriod, Delay ;2\*1

Lp1: DECF Delay ;N

BNZ Lp1 ;2(N-1) + 1

CLRF SoundPin

MOVFF HalfPeriod, Delay ;2\*1

Lp2: DECF Delay ;N

BNZ Lp2 ;2(N-1) + 1

DECF D1

BNZ A1

DECF D2

BNZ A2

CLRF SoundPin

Return

;\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--

PlayRecord: LFSR 0, Record

MOVFF Counter, tmp\_counter ;From counter to tmp counter

TSTFSZ tmp\_counter

BRA NextNote

GOTO Setup ;If no record

NextNote: MOVFF POSTINC0, Note ;lowPeriodTable

Call Lookup7Seg

> MOVWF LEDPin ;Show LED
>
> Call GetFreq
>
> Call PlaySound
>
> CLRF LEDPin

Call Pause

DECF tmp\_counter

BNZ NextNote

GOTO Main

;\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--

Pause:

MOVLF 0xFF, Delay\_High

N1: MOVLF 0x20, Delay\_Low

N2: Nop

DECF Delay\_Low

BNZ N2

DECF Delay\_High

BNZ N1

Return

;\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--

ORG 0x800

PeriodTable: DB D\'0\', D\'159\', D\'141\', D\'126\'

> DB D\'119\', D\'106\', D\'94\', D\'84\'
>
> DB D\'79\', D\'70\', D\'63\', D\'59\'
>
> DB D\'53\', D\'47\', D\'42\', D\'0\'

END

;\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--
