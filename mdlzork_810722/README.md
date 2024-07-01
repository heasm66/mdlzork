# Mainframe Zork from 1981-07-22
Patched by Matthew T Russotto to run under Confusion plus all unprintable charecters are removed.

Changes in this version:
~~~~
Change line 1381 in act3.mud to make "play violin" respond "An amazingly offensive noise issues from the violin.":
    <COND (<AND <NOT <EMPTY? <PRSI>>> <TRNN <PRSI> ,WEAPONBIT>>

Change line 153 in parser.mud to prevent the parser from crashing with phrases like "HELLLO, SAILOR":
    <COND (<N=? <PRSO> <>> <SET ANDFLG T>)> ;"AND is only allowed between NOUN-phrases"

Change line 1386-88 in act3.mud to make "play me/thief/troll" work:
       <JIGS-UP <STRING
"You are so engrossed in the role of the " <ODESC2 <PRSO>> " that
you kill yourself, just as he would have done!">>)>>

Change line 1207-08 in dung.mud to make save/restore during thief melee (for FLAGS to be properly saved/restored they have to be defined in MGVALS.)
     THIEF-ENGROSSED!-FLAG
     ]>

BINF!-FLAG is used to hold the OBJECT that's burning in the receptacle. When restored it is unlikly that the pointer will point to the same OBJECT. 
To fix this add this line after line 414 in act2.mud to make save/restore work during balloon ride:
    <COND (.BINF <SET BINF <SETG BINF!-FLAG <1 <OCONTENTS .CONT>>>>)> ;"Rebind BINF to OBJ burning in receptacle."

Changed more typos in dung.mud:
    Line 164, 572 & 2028: Removed double-space in sentence.
    Line 424: Added "." at end of sentence.
    Line 1969 & 2045: accomodate --> accommodate

Changed typo in act1.mud:
    Line 143: idead --> idea
    
Changed line 622 in rooms.mud to:
        <AND .FULL <NOT <0? <CHTYPE <ANDB .FULL 1> FIX>>>>>
    
Changed line 1177 in act3.mud to (issue #37):
    <VERB? "MOVE" "PULL">)>>

Changed typo in dung.mud:
    Line 503: of  unfriendly rocks --> of unfriendly rocks

Change line 719 in rooms.mud from (issue #40):
    (<AND <TRNN .Y ,OVISON> 
to:
    (<AND <TRNN .Y ,OVISON> <OR <TRNN .Y ,TOUCHBIT> <EMPTY? <ODESCO .Y>>>

Added missing space on line 25 in act2.mud (issue #51) 

Added new function for dummy window in NHOUS and SHOUS on line 1664-1167 in act1.mud (issue #58)
    <DEFINE DWIND-FUNCTION ()
        <COND (<VERB? "OPEN">
               <TELL
    "The window cannot be opened.">)>>

Changed line 1516 in dung.mud, to use new function, from (issue #58):
    <>>
to:
    DWIND-FUNCTION>

Change definition of DEFMAC VERB? in defs.mud from (issue #48):
    <DEFMAC VERB? ("ARGS" AL)
            <COND (<1? <LENGTH .AL>>
                   <FORM ==? <FORM VNAME '<PRSA>> <PSTRING <1 .AL>>>)
                  (ELSE
                   <FORM PROG ((VA <FORM VNAME '<PRSA>>))
                         #DECL ((VA) PSTRING)
                         <FORM OR
                               !<MAPF ,LIST
                                      <FUNCTION (A)
                                          <FORM ==? <FORM LVAL VA> <PSTRING .A>>>
                                      .AL>>>)>>
to:
    <DEFMAC VERB? ("ARGS" AL)
            <COND (<1? <LENGTH .AL>>
                   <FORM PROG (PV)
                      #DECL ((PV) <OR ACTION VERB FALSE>)
                      <FORM AND <FORM SET PV '<PRSA>> <FORM ==? <FORM VNAME <FORM LVAL PV>> <PSTRING <1 .AL>>>>
                   >)
                  (ELSE
                   <FORM PROG ((PV '<PRSA>) (VA <FORM AND <FORM LVAL PV> <FORM VNAME <FORM LVAL PV>>>))
                       #DECL ((PV) <OR ACTION VERB FALSE> (VA) <OR PSTRING FALSE>)
                       <FORM AND PV
                         <FORM OR
                               !<MAPF ,LIST
                                      <FUNCTION (A)
                                          <FORM ==? <FORM LVAL VA> <PSTRING .A>>>
                                      .AL>>>>)>>

Change line 1433 in act3.mud from (issue #41):
    <TELL "Affixed loosely to the brochure is a small stamp.">>) 
to:
    <TELL "Affixed loosely to the brochure is a small stamp.">> T)

Add new function to act3.mud (issue #45):
    <DEFINE ROPE-BACK ("AUX" (ROPE <SFIND-OBJ "ROPE">) (TTIE ,TIMBER-TIE!-FLAG)
                 (COFFIN <SFIND-OBJ "COFFI">)
                 (TIMBER <SFIND-OBJ "TIMBE">))
        #DECL ((ROPE COFFIN TIMBER) OBJECT (TTIE) <OR OBJECT FALSE>)
        <SETG DOME-FLAG!-FLAG <>>
        <SETG TIMBER-TIE!-FLAG <>>
        <TRZ .ROPE <+ ,CLIMBBIT ,NDESCBIT>>
        <AND .TTIE <TRZ .TTIE ,NDESCBIT>>
        <COND (<==? .TTIE .COFFIN>
           <ODESC1 .COFFIN ,COFFIN-UNTIED>)
          (<ODESC1 .TIMBER ,TIMBER-UNTIED>)>>

Changes to act1.mud (issue #45):
    @@ -1169,7 +1169,7 @@ 
                           <PUT .HACK ,HOBJS <SET HH <ROB-ROOM .RM .HH 100>>>
                           <PUT .HACK ,HOBJS <SET HH <ROB-ADV .WIN .HH>>>
                           <COND (<MEMQ <SFIND-OBJ "ROPE"> .HH>
-                                 <SETG DOME-FLAG!-FLAG <>>)>
+                                 <ROPE-BACK>)>
                           <COND (<==? .OBJT .HH>
                                  <TELL
    "The other occupant (he of the large bag), finding nothing of value,
    @@ -1229,7 +1229,7 @@
                                  <MAPLEAVE>)>>
                   <ROBJS .RM>>
             <COND (<MEMQ <SFIND-OBJ "ROPE"> .HH>
-                   <SETG DOME-FLAG!-FLAG <>>)>)>)>
+                   <ROPE-BACK>)>)>)>
         <COND (<SET ONCE <NOT .ONCE>>               ;"Move to next room, and hack."
                <PROG ((ROOMS <HROOMS .HACK>))
                  #DECL ((ROOMS) <LIST [REST ROOM]>)

Changes to act3.mud (issue #45):
    @@ -1203,8 +1203,5 @@
                        <N==? .HERE .SROOM>>>
-            <SETG DOME-FLAG!-FLAG <>>
-            <SETG TIMBER-TIE!-FLAG <>>
-            <TRZ .TIMBER ,NDESCBIT>
-            <TRZ .COFFIN ,NDESCBIT>
+            <ROPE-BACK>
             <COND (<VERB? "TIE">
                    <TELL "There is nothing it can be tied to.">)>)
            (<AND <VERB? "CLDN"> <==? .HERE <SFIND-ROOM "CPANT">>>
    @@ -1258,9 +1255,7 @@
                           <COND (<==? .TTIE .COFFIN>
                                  <ODESC1 .COFFIN ,COFFIN-UNTIED>)
                                 (<ODESC1 .TIMBER ,TIMBER-UNTIED>)>)>
-                   <SETG DOME-FLAG!-FLAG <>>
-                   <SETG TIMBER-TIE!-FLAG <>>
-                   <TRZ .ROPE <+ ,CLIMBBIT ,NDESCBIT>>
+                   <ROPE-BACK>
                    <TELL 
    "The rope is now untied.">)
                   (<TELL "It is not tied to anything.">)>)
    @@ -1324,5 +1331,5 @@
               <GO&LOOK <SFIND-ROOM "CELLA">>)
              (<VERB? "PUT">
               <COND (<==? <PRSO> ,TIMBER-TIE!-FLAG>
-                     <SETG TIMBER-TIE!-FLAG <>>)>
+                     <ROPE-BACK>)>
               <SLIDER <PRSO>>)>>

Add initial value to THIEF-ENGROSSED!-FLAG in melee.mud on line 38 (issue #62)
    <SETG THIEF-ENGROSSED!-FLAG <>>

Change line 93-94 in tell-repl.mud from (issue #42 & #61):
    <DEFINE GXUNAME () "MTRZORK">
    <SETG XUNM "MTRZORK">
to:
    <DEFINE GXUNAME () ,XUNM>
    <COND (<NOT <GASSIGNED? XUNM>> <SETG XUNM "MTRZORK">)>

Change run.mud from (issue #42 & #61):
    <FLOAD "loadall.mud">
    <SAVE-IT>
to:
    "User name is used as seed in RANDOM and as name on the directory where SAVE- and SCRIPT-files are saved.
     Full name is used inside the game once for flavour.
     Change them for your own amusement."
    <SETG XUNM "MTRZORK">                    ;"Username, traditionally 3-6 characters."
    <PUT ,OUTCHAN 10 "Intrepid Adventurer">  ;"Full name"

    <FLOAD "loadall.mud">

    <CRLF>
    <TELL "This copy is built with username '" 0 ,XUNM "' and with full name '"> 
    <TELL <GET-NAME> 1 "'.">
    <TELL "(See 'run.mud' what they do and on how to change them.)">
    <CRLF>

    <SAVE-IT>

Added RSACREDBIT to "TREE" in dung.mud line 1715:
    <+ ,RLANDBIT ,RLIGHTBIT ,RNWALLBIT ,RSACREDBIT>


Timestamps of the original madadv.help, madadv.info and madadv.doc are 790317, 790317 and 790406.


