# Mainframe Zork from 1979-12-11
This version is almost indentical to the 1981 version. See differences with the 1981 version below.
All unprintable charecters are removed.

## Changes in this version
~~~~
Change line 1381 in act3.mud to make "play violin" respond "An amazingly offensive noise issues from the violin.":
	<COND (<AND <NOT <EMPTY? <PRSI>>> <TRNN <PRSI> ,WEAPONBIT>>
	   
Change line 153 in parser.mud to prevent the parser from crashing with phrases like "HELLLO, SAILOR":
	<COND (<N=? <PRSO> <>> <SET ANDFLG T>)> ;"AND is only allowed between NOUN-phrases"

Change line 1384-86 in act3.mud to make "play me/troll/thief" work:
	   <JIGS-UP <STRING
"You are so engrossed in the role of the " <ODESC2 <PRSO>> " that
you kill yourself, just as he would have done!">>)>>

Change line 1207-08 in dung.mud to make save/restore during thief melee (for FLAGS to be properly saved/restored they have to be defined in MGVALS.)
	 THIEF-ENGROSSED!-FLAG
	 ]>
	 
BINF!-FLAG is used to hold the OBJECT that's burning in the receptacle. When restored it is unlikly that the pointer will point to the same OBJECT. 
To fix this add this line after line 414 in act2.mud to make save/restore work during balloon ride:
	<COND (.BINF <SET BINF <SETG BINF!-FLAG <1 <OCONTENTS .CONT>>>>)> ;"Rebind BINF to OBJ burning in receptacle."
	
Change line 396 in dung.mud to fix typo:
	Fovnder --> Founder

Changed more typos in dung.mud:
	Line 164, 572 & 2028: Removed double-space in sentence.
	Line 424: Added "." at end of sentence.
	Line 1969 & 2045: accomodate --> accommodate

Changed typo in act1.mud:
	Line 143: idead --> idea
	
Changed line 608 in rooms.mud to:
        <AND .FULL <NOT <0? <CHTYPE <ANDB .FULL 1> FIX>>>>>
	
Changed line 1177 in act3.mud to (issue #37):
	<VERB? "MOVE" "PULL">)>>
	
Changed typo in dung.mud:
	Line 503: of  unfriendly rocks --> of unfriendly rocks

Change line 705 in rooms.mud from (issue #40):
	(<AND <TRNN .Y ,OVISON> 
to:
	(<AND <TRNN .Y ,OVISON> <OR <TRNN .Y ,TOUCHBIT> <EMPTY? <ODESCO .Y>>>

Differences between the 1979 and 1981 version
=============================================

act1.253<->act1.254
-------------------

1921c1921,1925
<         <COND (<VERB? "TRNON" "BURN" "LIGHT">
---
>         <COND (<AND <VERB? "TAKE">
>                     <TRNN .C ,ONBIT>>
>                <CLOCK-ENABLE <2 .FOO>>
>                <>)
>               (<VERB? "TRNON" "BURN" "LIGHT">
The 1981 version have added a extra predicate when you pick up the burning candles.

act3.198<->act3.199
-------------------

1245,1247c1245,1249
<                      <COND (<OR <==? .HERE <SFIND-ROOM "CPANT">>
<                                 <==? .HERE .SROOM>>
<                                 <TELL "The rope dangles down the slide.">)>
---
>                      <COND (<==? .HERE .SROOM>
>                             <TELL "The rope dangles down the slide.">)
>                            (<==? .HERE <SFIND-ROOM "CPANT">>
>                             <TELL
>                              "The rope dangles down into the darkness.">)>
~~~
The 1981 version have different messages for the rope in the Dome and the Coal Mine.

dung.354<->dung.355
-------------------

5149c5149
< "There is an issue of US NEWS & DUNGEON REPORT dated 3/17/79 here."
---
> "There is an issue of US NEWS & DUNGEON REPORT dated 7/22/81 here."
5153,5154c5153
< 12/11/79                                     Late G.U.E. Edition
<            Send correspondence to ZORK@DM
---
> 7/22/81                                      Last G.U.E. Edition
5156,5157c5155,5164
< Many bugs have been fixed in this version.  There are probably no
< other changes.
---
> This version of ZORK is no longer being supported on this or any other
> machine.  In particular, bugs and feature requests will, most likely, be
> read and ignored.  There are updated versions of ZORK, including some
> altogether new problems, available for PDP-11s and various
> microcomputers (TRS-80, APPLE, maybe more later).  For information, send
> a SASE to:
>
>                 Infocom, Inc.
>                 P.O. Box 120, Kendall Station
>                 Cambridge, Ma. 02142
5496c5503
<       <+ ,OVISON ,TAKEBIT ,TIEBIT>
---
>       <+ ,OVISON ,TAKEBIT ,TIEBIT ,SACREDBIT>
~~~
New issue of the US NEWS & DUNGEON REPORT and the thief is prohibited to steal the rope.

rooms.393<->rooms.394
---------------------

405c405
< <DEFINE DO-SCRIPT ("AUX" CH (UNM ,XUNM) (MUDDLE ,MUDDLE))
---
> <DEFINE DO-SCRIPT ("AUX" (CH <>) (UNM ,XUNM) (MUDDLE ,MUDDLE))
413a414
>                  <=? <10 .CH> .UNM>
439,440c440,441
< <DEFINE DO-SAVE ("OPTIONAL" (UNM ,XUNM) "AUX" (MUDDLE ,MUDDLE) CH)
<   #DECL ((CH) <OR CHANNEL FALSE> (MUDDLE) FIX (UNM) STRING)
---
> <DEFINE DO-SAVE ("OPTIONAL" (UNM ,XUNM) "AUX" FNM (MUDDLE ,MUDDLE) (CH <>))
>   #DECL ((FNM) STRING (CH) <OR CHANNEL FALSE> (MUDDLE) FIX (UNM) STRING)
448a450
>         <AND <GASSIGNED? ZORK-HAND> <OFF ,ZORK-HAND>>
452c454
<        <COND (<SET CH <OPEN "PRINTB"
---
>        <COND (<AND <SET CH <OPEN "PRINTB"
454c456,458
<                                    <STRING <GET-DEV> !\: .UNM ";ZORK SAVE">)
---
>                                    <STRING <GET-DEV>
>                                            !\: .UNM
>                                            ";ZORK SAVE">)
456a461,462
>                    <OR <G? .MUDDLE 100>
>                        <=? <10 .CH> .UNM>>>
460,462c466,476
<              (<TELL "Save failed.">
<               <TELL <1 .CH> ,POST-CRLF " " <2 .CH>>)>
<        <HANDLER <EVENT "CHAR" 8 ,INCHAN> ,ZORK-HAND>
---
>              (T
>               <COND (.CH
>                      <CLOSE .CH>
>                      <RENAME <STRING <9 .CH> !\: <10 .CH> !\;
>                                      <7 .CH> !\  <8 .CH>>>)>
>               <TELL "Save failed.">
>               <COND (<NOT .CH> <TELL <1 .CH> ,POST-CRLF " " <2 .CH>>)
>                     (T
>                      <TELL " " ,POST-CRLF>)>)>
>        <COND (<NOT <MEMBER .UNM ,WINNERS>>
>               <AND <GASSIGNED? ZORK-HAND> <HANDLER <EVENT "CHAR" 8 ,INCHAN> ,ZORK-HAND>>)>
967c981,999
<                    <COND (<NOT .FEECH?>
---
>                    <PRINC "
> Text:
> " .CH>
>                    <COND (<L? .MUDDLE 100>
>                           <PUT .CH 13 <CHTYPE <MIN> FIX>>
>                           <PRINC !\\\ .CH>
>                           <SET STR <SUBSTRUC .STR 0
>                                              .CT
>                                              <BACK <REST .STR
>                                                          <LENGTH .STR>>
>                                                    .CT>>>
>                           <REPEAT ((SS .STR))
>                             #DECL ((SS) <OR FALSE STRING>)
>                             <COND (<SET SS <MEMQ !\" .SS>>
>                                    <PUT .SS 1 !\`>)
>                                   (<RETURN>)>>
>                           <PRINC .STR .CH>)
>                          (<PRINTSTRING .STR .CH .CT>)>
>                    <COND (.DEATH?
1004,1014d1035
<                    <PRINC "
< Text:
< " .CH>
<                    <COND (<L? .MUDDLE 100>
<                           <PUT .CH 13 <CHTYPE <MIN> FIX>>
<                           <PRINC !\\\ .CH>
<                           <PRIN1 <SUBSTRUC .STR 0 .CT
<                                            <BACK <REST .STR <LENGTH .STR>> .CT>>
<                                  .CH>
<                           <RENAME .CH "COMSYS;M >">)
<                          (<PRINTSTRING .STR .CH .CT>)>
1015a1037,1039
>                    <COND (<L? .MUDDLE 100>
>                           <PRINC !\" .CH>
>                           <RENAME .CH "COMSYS;M >">)>
1080,1081c1104,1106
<       <PRIN1 .SCORE .CH>
<       <COND (,END-GAME!-FLAG
---
>       <COND (<NOT ,END-GAME!-FLAG>
>              <PRIN1 .SCORE .CH>)
>             (<PRIN1 ,EG-SCORE .CH>
1173c1198,1199
<              <FINISH <>>)
---
>              <FINISH <>>
>              <REPEAT () <QUIT>>)
Extra DECL-check and error-handling in the 1981 version.

Timestamps of the original madadv.help, madadv.info and madadv.doc are 790317, 790317 and 790406.
