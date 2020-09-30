# Mainframe Zork from 1979-12-11
This version is almost indentical to the 1981 version. See differences with the 1981 version below.
All unprintable charecters are removed.

## Changes in this version
~~~~
Change line 1381 in act3.mud to make "play violin" respond "An amazingly offensive noise issues from the violin.":
	   <COND (<AND <NOT <EMPTY? <PRSI>>> <TRNN <PRSI> ,WEAPONBIT>>

Differences between the 1979 and 1981 version
=============================================

act1.mud
--------

1921c1921,1925
<         <COND (<VERB? "TRNON" "BURN" "LIGHT">
---
>         <COND (<AND <VERB? "TAKE">
>                     <TRNN .C ,ONBIT>>
>                <CLOCK-ENABLE <2 .FOO>>
>                <>)
>               (<VERB? "TRNON" "BURN" "LIGHT">
The 1981 version have added a extra predicate when you pick up the burning candles.

act3.mud
--------

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

dung.mud
--------

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

rooms.mud
---------

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
