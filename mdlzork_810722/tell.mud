<NEWTYPE PSTRING WORD>
<SETG RUBOUT? <>>
<SETG RUVEC <IUVECTOR 4>>
<SETG NO-TELL 0>
<SETG IN-TELL 0>
<SETG TELL-VEC <IUVECTOR 7>>

;"Print some strings to ,OUTCHAN"
<TITLE  TELL>
        <DECLARE ("VALUE" ATOM <PRIMTYPE STRING> "OPTIONAL" FIX
                  <OR STRING FALSE> <OR STRING FALSE>)>
        <MOVE   A* AB>
LOOP    <PUSH   TP* (AB)>
        <PUSH   TP* 1(AB)>
        <ADD    AB* [<(2) 2>]>
        <JUMPL  AB* LOOP>
        <HLRES  A>
        <ASH    A* -1>
        <ADDI   A* TABEND>
        <PUSHJ  P* @ (A) 1>
        <JRST   FINIS>
        <TELL4>
        <TELL3>
        <TELL2>
TABEND  <TELL1>

        <INTERNAL-ENTRY TELL1 1>                ; "push 1"
        <PUSH   TP* <TYPE-WORD FIX>>
        <PUSH   TP* [1]>
        <INTERNAL-ENTRY TELL2 2>
        <PUSH   TP* <TYPE-WORD FALSE>>
        <PUSH   TP* [0]>
        <INTERNAL-ENTRY TELL3 3>
        <PUSH   TP* <TYPE-WORD FALSE>>
        <PUSH   TP* [0]>
        <INTERNAL-ENTRY TELL4 4>
        <SUBM   M* (P)>
        <INTGO>
        <PUSHJ  P* SETUP>               ; "SETUP FOR INTERRUPTS"
         <JRST  [<PUSH  TP* <TYPE-WORD FALSE>>
                 <PUSH  TP* [0]>
                 <DPUSH TP* <PQUOTE <STRING <ASCII 13> <ASCII 10>>>>
                 <MOVE  C* <MQUOTE <RGLOC OUTCHAN T>>>
                 <ADD   C* GLOTOP 1>
                 <MOVE  C* 1(C)>
                 <PUSH  P* 1(C)>
                 <MOVEI C* 0>
                 <PUSHJ P* DOSIOT>      ; "PRINT CRLF"
                 <SUB   TP* [<(2) 2>]>
                 <JRST  INTLV>]>
INTLV    <JRST  [<SUB   P* [<(1) 1>]>
                 <JRST  RLDONE1>]>      ; "RETURN FROM NON-PRINT"
        <MOVE   C* <MQUOTE <RGLOC OUTCHAN T>>>
        <ADD    C* GLOTOP 1>
        <MOVE   C* 1(C)>
        <MOVE   C* 1(C)>                ; "CHANNEL NUMBER IN C"
        <PUSH   P* C>                   ; "SAVE ON STACK"
        <MOVE   E* <MQUOTE <RGLOC SCRIPT-CHANNEL T>>>
        <ADD    E* GLOTOP 1>
        <PUSH   TP* (E)>
        <PUSH   TP* 1(E)>
        <MOVE   O* -6(TP)>              ; "FIX SPECIFYING WHEN TO DO CR'S"
        <TRNN   O* 2>                   ; "SKIP IF PRINT CR BEFORE"
         <JRST  PTFST>
        <PUSH   TP* <PQUOTE <STRING <ASCII 13> <ASCII 10>>>>
        <PUSH   TP* <MQUOTE <STRING <ASCII 13> <ASCII 10>>>>
        <MOVEI  C* 0>
        <PUSHJ  P* DOSIOT>
PTFST   <LDB    C* [<(*220913*) -6>]>   ; "MAYBE THE GUY GAVE A LENGTH FOR THIS?"
        <PUSH   TP* -9(TP)>             ; "PUSH ARGS FOR DOSIOT"
        <PUSH   TP* -9(TP)>
        <PUSHJ  P* DOSIOT>
        <INTGO>
        <GETYP  O* -5(TP)>
        <CAIN   O* <TYPE-CODE FALSE>>   ; "IS IT FALSE?"
        <JRST   DONE>
        <PUSH   TP* -5(TP)>
        <PUSH   TP* -5(TP)>             ; "ARGS"
        <MOVEI  C* 0>
        <PUSHJ  P* DOSIOT>              ; "DO PRINT"
        <GETYP  O* -3(TP)>
        <CAIN   O* <TYPE-CODE FALSE>>
        <JRST   DONE>
        <PUSH   TP* -3(TP)>
        <PUSH   TP* -3(TP)>
        <MOVEI  C* 0>
        <PUSHJ  P* DOSIOT>
DONE    <MOVE   O* -6(TP)>
        <TRNN   O* 1>                   ; "CR AFTER?"
         <JRST  RLDONE>
        <PUSH   TP* <PQUOTE <STRING <ASCII 13> <ASCII 10>>>>
        <PUSH   TP* <MQUOTE <STRING <ASCII 13> <ASCII 10>>>>
        <MOVEI  C* 0>
        <PUSHJ  P* DOSIOT>              ; "PRINT CRLF"
RLDONE  <MOVE   A* <MQUOTE <RGLOC IN-TELL T>>>
        <ADD    A* GLOTOP 1>
        <SETZM  1(A)>                   ; "NO LONGER IN TELL"
        <SUB    P* [<(2) 2>]>           ; "CLEAN UP P"
        <SUB    TP* [<(2) 2>]>
RLDONE1 <SUB    TP* [<(8) 8>]>
        <MOVE   C* <MQUOTE <RGLOC TELL-FLAG T>>>        ;"SETG TELL-FLAG"
        <ADD    C* GLOTOP 1>
        <MOVE   A* <TYPE-WORD ATOM>>
        <MOVEM  A* (C)>
        <MOVE   B* <MQUOTE T>>
        <MOVEM  B* 1(C)>
        <JRST   MPOPJ>
; "SET UP FOR INTERRUPTS"
SETUP   <SUBM   M* (P)>
        <PUSH   P* (P)>
        <MOVE   A* <MQUOTE <RGLOC NO-TELL T>>>
        <ADD    A* GLOTOP 1>
        <SKIPGE 1(A)>           ; "IF ALREADY TURNED OFF, JUST LEAVE"
         <JRST  SPOPJ>
        <SKIPL  -4(TP)>         ; "DO THIS ONLY IF TOLD TO"
         <JRST  SETUPO>
        <MOVE   A* <MQUOTE <RGLOC TELL-VEC T>>>
        <ADD    A* GLOTOP 1>
        <MOVE   A* 1(A)>
        <HLRE   B* A>
        <ADDI   B* 1>
        <MOVNS  B>
        <ADDI   B* (A)>
        <HRLI   A* AB>
        <SUB    P* [<(1) 1>]>
        <BLT    A* (B)>
        <ADD    P* [<(1) 1>]>
        <MOVE   A* <MQUOTE <RGLOC IN-TELL T>>>
        <ADD    A* GLOTOP 1>
        <SETOM  1(A)>           ; "NOW IN TELL"
SETUPO  <SOS    (P)>
SPOPJ   <SOS    (P)>            ; "SKIP TWICE NORMALLY, ONCE IF NOT PRINTING"
        <JRST   MPOPJ>          ; "SKIP RETURN"
;"SYSTEM DEPENDENT"
;"PUSHJ DOSIOT WITH ARGS ON TOP OF TP STACK; CHANNEL/JFN IS -1(P); SCRIPT CHANNEL
IS NEXT FROB ON TP.  FORTUNATELY, NO AC'S ARE SACRED.  C HAS # CHARS TO PRINT
IF NON-ZERO."
DOSIOT  <SUBM   M* (P)>
        <SKIPG  C>                      ; "IF C>0, THEN ITS THE # OF CHARS TO PRINT"
         <HRRZ  C* -1(TP)>              ; "GET STRING LENGTH"
        <PUSH   P* C>
        <MOVE   B* (TP)>                ; "GET STRING"
        <SKIPL  -8(TP)>
         <JRST  DOSIOT1>                ; "ONLY ENABLE IF TOLD TO"
        <AOSN   INTFLG>
         <JSR   LCKINT>                 ; "ENABLE INTERRUPTS"
DOSIOT1 <IFOPSYS (TENEX
                  <MOVNS C>             ; "GET -LENGTH"
                 <JUMPE C* DODONE>      ; "0 LENGTH STRING"
                 <MOVE  A* -2(P)>               ; "GET JFN"
                 <SOUT>                 ; "DO IT")
                (ITS
                 <*CALL SIOT>
                  <JFCL>)>
        <SKIPGE -6(TP)>
         <SETZM INTFLG>                 ; "DISABLE INTERRUPTS"
        <SKIPL  -2(TP)>                 ; "SCRIPTING?"
         <JRST  DODONE>
        <MOVSI  A* <TYPE-CODE STRING>>
        <HRR    A* -1(TP)>
        <PUSH   TP* A>                  ; "PUSH STRING"
        <PUSH   TP* -1(TP)>
        <PUSH   TP* -5(TP)>             ; "PUSH CHANNEL"
        <PUSH   TP* -5(TP)>
        <PUSH   TP* <TYPE-WORD FIX>>
        <PUSH   TP* (P)>
        <MCALL  3 PRINTSTRING>          ; "DO PRINTSTRING"
DODONE  <SUB    TP* [<(2) 2>]>          ; "GET RID OF ARGS"
        <SUB    P* [<(1) 1>]>
        <JRST   MPOPJ>
<IFOPSYS (ITS
         SIOT   <SETZ>
                <SIXBIT "SIOT">
                <-2(P)>
                <MOVE   B>
                <SETZ   C>)>


<TITLE  CTRL-S>
        <DECLARE ("VALUE" <OR ATOM DISMISS> CHARACTER CHANNEL)>
        <DPUSH  TP* (AB)>
        <DPUSH  TP* 2(AB)>
        <PUSHJ  P* ICTRL>
        <JRST   FINIS>

<INTERNAL-ENTRY ICTRL 2>
        <SUBM   M* (P)>
        <MOVE   B* -2(TP)>
        <CAIN   B* 7>                   ; "CTRL-G?"
         <JRST  GACK>
        <IFOPSYS
         (TENEX
          <CAIE B* %<ASCII !\>>)
         (ITS
          <CAIE B* %<ASCII !\>>)>
         <JRST  [<MOVSI A* <TYPE-CODE ATOM>>
                 <JRST  ICTRL1>]>       ; "NOT CTRL-S, SO FLUSH"
        <SETZM  INTFLG>
        <MOVE   A* <MQUOTE <RGLOC INCHAN T>>>
        <ADD    A* GLOTOP 1>
        <DPUSH  TP* (A)>
        <MCALL  1 RESET>
        <PUSH   TP* <TYPE-WORD FALSE>>
        <PUSH   TP* [0]>
        <MCALL  1 TTY-INIT>
        <MOVE   A* <MQUOTE <RGLOC NO-TELL T>>>
        <ADD    A* GLOTOP 1>
        <SKIPGE 1(A)>           ; "ALREADY TRUE?"
         <JRST  ICTRLO>         ; "YES, SO FLUSH"
        <SETOM  1(A)>           ; "NO, SO MAKE IT TRUE"
        <MOVE   A* <MQUOTE <RGLOC IN-TELL T>>>
        <ADD    A* GLOTOP 1>
        <SKIPL  1(A)>           ; "IN TELL?"
         <JRST  ICTRLO>         ; "NO, FLUSH"
        <SETZM  1(A)>           ; "NOT ANY MORE"
        <PUSH   TP* <TYPE-WORD FIX>>
        <PUSH   TP* [0]>
        <MCALL  1 INT-LEVEL>    ; "FIX UP INTERRUPTS"
        <MOVE   A* <MQUOTE <RGLOC TELL-VEC T>>>
        <ADD    A* GLOTOP 1>    ; "GET POINTER TO SAVED AC'S (N OF THEM)"
        <MOVE   A* 1(A)>        ; "PICK UP POINTER"
        <HLRE   B* A>           ; "# OF AC'S IS IN B"
        <ADDI   B* P 1>         ; "FIRST ONE"
        <HRLS   A>
        <HRR    A* B>           ; "BLT POINTER IN A"
        <BLT    A* P>           ; "BLT THE AC'S BACK"
        <JRST   MPOPJ>          ; "AND LEAVE"
ICTRLO  <MOVSI  A* <TYPE-CODE DISMISS>>
ICTRL1  <MOVEI  B* <MQUOTE 'T>>
        <SUB    TP* [<(4) 4>]>
        <JRST   MPOPJ>
GACK    <MOVE   A* <MQUOTE <RGLOC INCHAN T>>>
        <ADD    A* GLOTOP 1>
        <DPUSH  TP* (A)>
        <MCALL  1 RESET>
        <PUSH   TP* <TYPE-WORD FALSE>>
        <PUSH   TP* [0]>
        <MCALL  1 TTY-INIT>
        <PUSH   TP* <TYPE-WORD FALSE>>
        <PUSH   TP* [0]>
        <PUSH   TP* <TYPE-WORD ATOM>>
        <PUSH   TP* <MQUOTE CONTROL-G?!-ERRORS>>
        <MCALL  2 HANDLE>
        <JRST   ICTRLO>

;"Get current time in disk format"
;"SYSTEM DEPENDENT (GROSSLY)"
<TITLE DSKDATE>
        <DECLARE ("VALUE" WORD)>
        <PUSHJ  P* IDSKDATE>
        <JRST   FINIS>

<INTERNAL-ENTRY IDSKDATE 0>
        <SUBM   M* (P)>
        <IFOPSYS (TENEX
                  <HRROI        B* -1>  ; "-1 TO SAY CURRENT TIME"
                 <MOVEI D* 0>           ; "NOTHING FANCY"
                 <ODCNV>                ; "GET IT: B HAS YEAR,,MONTH; C DAY,,; D ,,TIME"
                 <TLZ   D* -1>          ; "CLEAN OUT LH OF D"
                 <ASH   D* 1>           ; "TIME IN HALF-SECONDS"
                 <HLRZS C>              ; "GET DAY OF MONTH -1"
                 <ADDI  C* 1>           ; "DO THE RIGHT THING"
                 <DPB   C* [<(*220500*) D>]>    ; "STUFF DAY INTO D"
                 <IDIV  B* [(1)]>       ; "SPLIT B IN HALF"
                 <ADDI  C* 1>           ; "GET REAL MONTH"
                 <DPB   C* [<(*270400*) D>]>    ; "STUFF IN MONTH"
                 <IDIVI B* 100>         ; "GET YEAR OF CENTURY IN C"
                 <DPB   C* [<(*330700*) D>]>    ; "STUFF IN YEAR"
                 <MOVE  B* D>
                 <MOVE  A* <TYPE-WORD WORD>>
                 <JRST  MPOPJ>)
                (ITS
                 <*CALL RQDATE>
                  <SETO B*>
                 <MOVE  A* <TYPE-WORD WORD>>
                 <JRST  MPOPJ>
                 RQDATE <SETZ>
                 <SIXBIT "RQDATE">
                 <SETZM B>)>

;"GET STRING OF USER NAME (OR SOMETHING LIKE THAT)"
<TITLE  GXUNAME>
        <DECLARE ("VALUE" STRING)>
        <PUSHJ  P* IXUNAME>
        <JRST   FINIS>

<INTERNAL-ENTRY IXUNAME 0>
        <SUBM   M* (P)>
        <IFOPSYS (TENEX
                  <GJINF>               ; "GET DIRECTORY NUMBER IN B"
                 <MOVE  B* A>
                 <MOVE  C* <MQUOTE <RGLOC SCRATCH-STR T>>>
                 <ADD   C* GLOTOP 1>
                 <MOVE  A* 1(C)>
                 <DIRST>
                 <JFCL>
                 <MOVE  B* 1(C)>
                 <MOVE  A* (C)>
                 <JRST  MPOPJ>)
                (ITS
                 <*SUSET        [<(*74*) A>]>
                 <PUSH  TP* <TYPE-WORD WORD>>
                 <PUSH  TP* A>
                 <PUSHJ P* ISIXTO>
                 <JRST  MPOPJ>
                 ;"TAKES WORD ON TOP OF TP, RETURNS STRING"
        ISIXTO   <SUBM  M* (P)>
                 <LDB   O* [<(*000613*) 0>]>    ; "LAST BYTE IN WORD"
                 <MOVEI C* 1>
                 <JUMPE O* CONTIN>
                 <MOVEI C* 2>                   ; "NUMBER OF WORDS REQUIRED"
        CONTIN   <PUSH  P* C>                   ; "SAVE #WORDS"
                 <MOVE  A* C>
                 <MOVEI O* IBLOCK>
                 <PUSHJ P* RCALL>               ; "GET UVECTOR (IN A AND B)"
                 <MOVE  A* <TYPE-WORD STRING>>
                 <POP   P* C>
                 <MOVEI O* 4(C)>                ; "LENGTH IS FIVE OR SIX"
                 <HRR   A* O>                   ; "LENGTH OF STRING"
                 <ADD   C* B>
                 <MOVEI O* <TYPE-CODE CHARACTER>>
                 <DPB   O* [<(*221503*) 0>]>    ; "CLOBBER TYPE SLOT IN DOPE WORDS"
                 <HRLI  B* *440700*>            ; "GET STRING POINTER TO UV"
; "AT THIS POINT, IN A AND B WE HAVE THE TYPE-VALUE WORD, ALMOST READY TO
RETURN.  ON TOP OF TP, THE WORD TO BE HACKED."
        START    <PUSH  P* B>                   ; "SAVE BP TO RETURN"
                 <MOVE  C* (TP)>                ; "GET WORD TO HACK IN C"
                 <MOVE  D* [<(*440600*) C>]>    ; "AND SIXBIT POINTER IN D"
                 <HRRZ  E* A>                   ; "LENGTH OF STRING"
                 <JUMPE E* DONE>                ; "CAN'T HACK EMPTY STRING"
                 <CAILE E* 6>
                 <MOVEI E* 6>                   ; "MAX # CHARS"
        STRLOP   <ILDB  O* D>                   ; "GET CHAR IN O"
                 <ADDI  O* *40*>
                 <IDPB  O* B>                   ; "STUFF CHAR INTO STRING"
                 <SOJG  E* STRLOP>
        DONE     <POP   P* B>                   ; "GET OLD BP BACK"
                 <SUB   TP* [<(2) 2>]>
                 <JRST  MPOPJ>)>

;"Takes channel open to name file, returns string of name"
<IFOPSYS (TENEX
   <TITLE       GET-NAME>
        <DECLARE ("VALUE" <OR FALSE STRING>)>
        <PUSHJ  P* IGETNAME>
        <JRST   FINIS>
<INTERNAL-ENTRY IGETNAME 1>
        <SUBM   M* (P)>
;"FIRST, WE NEED A JFN TO THE CRETIN FILE WITH THE RIGHT CRETIN BITS."
        <MOVSI  A* *100001*>            ; "I HOPE THIS MEANS GET
                                        EXISTING FILE, SHORT FORM"
        <MOVE   B* <MQUOTE "DSK:<IMSSS>DATSYS.PMAP