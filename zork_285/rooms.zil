;"ROOMS - ROOMS.154 Jun 14, 1977
  Contrary to what you might believe, this is not where the rooms are defined. Instead this is
  where all basic functions for verb handling, parsing and moving around are defined."

;"GUTS OF FROB:  BASIC VERBS, COMMAND READER, PARSER, VOCABULARY HACKERS."

;"In MDL this flag is set everytime the TELL-function is called. In ZIL this flag
  is set when the TELL call contains a CR to print a CRLF instead."
<GLOBAL TELL-FLAG <>>

;"In MDL this function saved the workspace and the started the game. Due to how MDL 
  handle SAVE/RESTORE this had the effect that when the workspace was restored the
  execution started with the code following the call to the SAVE function. In practice
  this meant that a RESTORE loaded and started the game."
<ROUTINE SAVE-IT () 
    <START-F ,WHOUS>>

;"START is a reserved word in ZIL and not valid as a name on a routine."
<ROUTINE START-F (RM)      ;"Was START"
    <SETG DEATHS 0>
    <SETG MOVES 0>
    <PUTP ,WINNER ,P?AROOM <SETG HERE .RM>>
    <CRLF>
    <TELL "Welcome to adventure." CR>
    <RDCOM>>

;"Probability. <PROB 60> have a 60% chance to return T."
<ROUTINE PROB (NUM) <L=? <RANDOM 100> .NUM>>

;"LIT? --
    IS THERE ANY LIGHT SOURCE IN THIS ROOM"

<ROUTINE LIT? (RM)
    <OR <GETP .RM ,P?RLIGHT?>
        <LFCN .RM>
        <LFCN ,WINNER>>>
    
<ROUTINE LFCN (L)
    <MAP-CONTENTS (X .L)
        <COND (<G? <GETP .X ,P?OLIGHT?> 0>
            <RTRUE>)>>
    <RFALSE>>

;"WALK --
    GIVEN A DIRECTION, WILL ATTEMPT TO WALK THERE"    

<ROUTINE WALK ("AUX" (RM ,HERE) WHERE PTS NRM STR LEAVINGS)
    <IFFLAG (DEBUG <TELL "WALK" CR>)>
    <AND <GETP .RM ,P?RACTION> <APPLY <GETP .RM ,P?RACTION>>>  ;"Extra call to RACTION with W?WALK (CAROUSEL-ROOM)" 
    <SET WHERE <GETB <2 ,PRSVEC> 7>>  ;"P1? for direction word"
    <COND (<AND <NOT <LIT? .RM>> <PROB 75>>
            <COND (<SET NRM <GETPT .RM .WHERE>>
                <SET PTS <PTSIZE .NRM>>
                <SET LEAVINGS <0 .NRM>>  ;"Where to?"
                <COND (<AND <=? .PTS ,UEXIT>  ;"There's an UEXIT there and the room is lit. 75% chance for success." 
                            <LIT? .LEAVINGS>>
                        <GOTO .LEAVINGS> 
                        <ROOM-INFO <>>) 
                      (<AND <=? .PTS ,CEXIT>  ;"There's an CEXIT there with true FLAG and the room is lit. 75% chance for success."
                            <VALUE <GETB .NRM ,CEXIT-VAR>>
                            <LIT? .LEAVINGS>>
                        <GOTO .LEAVINGS> 
                        <ROOM-INFO <>>)
                      (T 
                        <TELL "Dear, dear.  You seem to have fallen into a bottomless pit." CR>
                        <SLEEP 4>
                        <JIGS-UP <PICK-ONE ,NO-LIGHTS>>)>)
                  (T
                    <TELL "Dear, dear.  You seem to have fallen into a bottomless pit." CR>
                    <SLEEP 4>
                    <JIGS-UP <PICK-ONE ,NO-LIGHTS>>)>)
          (<SET NRM <GETPT .RM .WHERE>>
                <SET PTS <PTSIZE .NRM>>
                <SET LEAVINGS <GET .NRM ,EXIT-RM>>                  ;"Where to?"
                <COND (<=? .PTS ,UEXIT> 
                        <GOTO .LEAVINGS> 
                        <ROOM-INFO <>>)
                      (<=? .PTS ,CEXIT>
                        <COND (<VALUE <GETB .NRM ,CEXIT-VAR>>       ;"FLAG is true"
                                <GOTO .LEAVINGS> 
                                <ROOM-INFO <>>)
                              (<SET STR <GET .NRM ,CEXIT-MSG>>      ;"FLAG is false"
                                <TELL .STR CR>)
                              (T 
                                <TELL "There is no way to go in this direction." CR>)>)
                      (<=? .PTS ,NEXIT> 
                        <TELL .LEAVINGS CR>)>)
          (<TELL "There is no way to go in this direction." CR>)>>

<GLOBAL NO-LIGHTS
    <LTABLE
"Oops!  It wasn't quite bottomless.  You hit the [solid rock] bottom at|
more than 85 mph, shattering many of your bones."
"What's your life insurance company?"
"I hope you left the name of your next-of-kin at the main office when|
you came in.  Not that there's much left to show them..."
"My map must be in error.  I could have sworn that was a bottomless pit,|
but you seem to have found a bottom.  Thanks for your assistance.">>

;"ROOM-INFO --
    PRINT SOMETHING ABOUT THIS PLACE
    1. CHECK FOR LIGHT --> ELSE WARN LOSER
    2. GIVE A DESCRIPTION OF THE ROOM
    3. TELL WHAT'S ON THE FLOOR IN THE WAY OF OBJECTS
    4. SIGNAL ENTRY INTO THE ROOM"

<ROUTINE ROOM-DESC () <ROOM-INFO T>>
    
<ROUTINE ROOM-INFO (FULL "AUX" (RM ,HERE))
    <IFFLAG (DEBUG <TELL "ROOM-INFO" CR>)>
    <SETG TELL-FLAG T>
    <COND (<NOT <LIT? .RM>>
            <TELL "It is now completely dark.  You will probably fall into a pit." CR>
            <RTRUE>)
          (<AND <GETP .RM ,P?RSEEN?> <PROB 80> <NOT .FULL>> <TELL <GETP .RM ,P?RDESC2> CR>)
          (<AND <NOT <GETP .RM ,P?RDESC1>> <GETP .RM ,P?RACTION>>
            <PUT ,PRSVEC 1 ,W?LOOK>
            <APPLY <GETP .RM ,P?RACTION>>)
          (T <TELL <GETP .RM ,P?RDESC1> CR>)>
    <PUTP .RM ,P?RSEEN? T>

    ;"Extra CR Before listing painting in gallery if it's untouched and the only one on the floor."
    <AND <NOT ,PATCHED> <=? .RM ,GALLE> <NOT <GETP ,PAINT ,P?OTOUCH?>> <=? <FIRST? ,GALLE> ,PAINT> <CRLF>>
    
    <MAP-CONTENTS (X .RM)           ;"List all objects in room."
        <COND (<OVIS? .X>
            <LONG-DESC-OBJ .X>
            <TELL CR>
            <COND (<N=? .X ,THIEF>  ;"Don't list object carried by thief"
                <MAP-CONTENTS (Y .X)
                    <LONG-DESC-OBJ .Y>
                    <TELL " [in the " <GETP .X ,P?ODESC2> "]" CR>>)>)>>
    
    <AND <NOT ,PATCHED> <=? .RM ,LROOM ,MIRR1 ,MIRR2 ,CYCLO-R ,LLD1> <CRLF>>

     ;"Trigger call to RACTION with WALK-IN when entering a room."
    <AND <GETP .RM ,P?RACTION> 
         <NOT .FULL>                ;"If FULL is <> then call is from WALK"
         <PUT ,PRSVEC 1 ,W?WALK-IN>
         <APPLY <GETP .RM ,P?RACTION>>>>

;"GIVE LONG DESCRIPTION OF OBJECT"

<ROUTINE LONG-DESC-OBJ (OBJ)
    <IFFLAG (DEBUG <TELL "LONG-DESC-OBJ" CR>)>
    <COND (<OR <GETP .OBJ ,P?OTOUCH?> <NOT <GETP .OBJ ,P?ODESC0>>>
            <TELL <GETP .OBJ ,P?ODESC1>>)
          (<TELL <GETP .OBJ ,P?ODESC0>>)>>

;"RDCOM --
    READ A COMMAND LINE AND WIN IMMEDIATELY"

;"This is the main loop."
<ROUTINE RDCOM ("AUX" RM)
    <PUTB ,INBUF 0 ,INBUF-SIZE>    ;"Max length of INBUF"
    <PUTB ,LEXV 0 10>              ;"Max # words that will be parsed"
    <ROOM-INFO T>
    <REPEAT ()
        <SET RM ,HERE>
       <TELL ">">
        <SETG TELL-FLAG <>>
        <LEX>
        <SETG MOVES <+ ,MOVES 1>>
        ;"EPARSE, extract PRSVEC (PRSA, PRSO & PRSI)"
        <COND (<AND <EPARSE ,LEXV <>> <WT? <1 ,PRSVEC> ,PS?VERB>>
            ;"PARSE OK - DO VERB-ACTION"
            <COND (<APPLY <VFCN <1 ,PRSVEC>>>
                ;"VERB-ACTION OK - DO ROOM-ACTION"
                <AND <GETP .RM ,P?RACTION> <APPLY <GETP .RM ,P?RACTION>>>)>)>
        <OR ,TELL-FLAG <TELL "Nothing happens." CR>>
        ;"Run DEMONS"
        <REPEAT ((I 0))
            <COND (<G? <SET I <+ .I 1>> <0 ,DEMONS>> <RETURN>)>
            <APPLY <GET ,DEMONS .I>>>

    <IFFLAG
        (DEBUG
            <TELL "---------- PARSE ----------" CR>
            <PROG (WORDS WLEN WSTART WEND DICT PRT-CR)
                ;"Print result"
                <SET WORDS <GETB ,LEXV 1>> ;"# of parsed words"
                <DO (I 1 .WORDS)
                    <SET PRT-CR T>
                    <SET WLEN <GETB ,LEXV <* .I 4>>>
                    <SET WSTART <GETB ,LEXV <+ <* .I 4> 1>>>
                    <SET WEND <+ .WSTART <- .WLEN 1>>>
                    <SET DICT <GET ,LEXV <+ <* <- .I 1> 2> 1>>>
                    <TELL "#" N .I ", " N .WLEN " chars. ">
                    <TELL "Word = '">
                    <DO (J .WSTART .WEND)
                        <PRINTC <GETB ,INBUF .J>>>
                    <TELL "' (" N .DICT ")">
                    <COND (<WT? .DICT ,PS?VERB> 
                            <TELL ", #VERB " N <GETB .DICT 7>> 
                            <TELL " " N <VARGS .DICT> " " N <VMAX .DICT> " ">
                            <SET PRT-CR <NOT <VSTR .DICT>>>)
                          (<WT? .DICT ,PS?BUZZ-WORD> <TELL ", BUZZ">)
                          (<WT? .DICT ,PS?DIRECTION> <TELL ", DIRECTION">)
                          (<WT? .DICT ,PS?ADJECTIVE> <TELL ", ADJECTIVE">)
                          (<WT? .DICT ,PS?OBJECT> <TELL ", OBJECT">)>
                    <COND (.PRT-CR <CRLF>)>>
                <TELL "EPARSE return value = ">
                <COND (.RET <TELL "False">) (T <TELL "True">)>
                <CRLF>
                <TELL "PRSVEC = " N <1 ,PRSVEC> " " N <2 ,PRSVEC> " " N <3 ,PRSVEC> CR>>
            <TELL "---------------------------" CR>)>>>

<ROUTINE TAKE ("AUX" (WIN ,WINNER) (VEC ,PRSVEC) (RM <GETP .WIN ,P?AROOM>) (OBJ <2 .VEC>)) 
    <IFFLAG (DEBUG <TELL "TAKE" CR>)>
    <COND (<AND .OBJ <NOT <WT? .OBJ ,PS?OBJECT>>>
            <TELL "There's none for the taking." CR>
            <RTRUE>)>
    <COND (<AND <NOT .OBJ> <NOT <NEXT? <FIRST? .RM>>>>  ;"If noun is missing and only one item in room, use that item."
            <SET OBJ <FIRST? .RM>>)
          (T <SET OBJ <FIND-OBJ .OBJ>>)>    ;"Set OBJ to the actual OBJECT."
    <COND (<NOT .OBJ>
            <TELL "Take what?" CR>
            <RTRUE>)>
    <COND (<OCAN .OBJ> <SET OBJ <OCAN .OBJ>>)>  ;"If OBJ is in container in ROOM, use container instead."
    <COND (<AND <IN? .OBJ .RM> <CAN-TAKE? .OBJ>>
            ;"Strangely because OBJ isn't counted itself, only items contained by it. You usually 
              can carry 9 objects (LOAD-MAX is 8) but if the 9th you try to pick up is a 
              container (bottle) you are denied."
            <COND (<G? <+ <LENGTH .WIN> <LENGTH .OBJ>> ,LOAD-MAX>   
                    <TELL "Your load is too heavy.  You will have to leave something behind." CR>)
                  (<NOT <APPLY-OBJECT .OBJ>>    ;"Give OBJECT-routine oppertunity to handle action."
                    <MOVE .OBJ .WIN>
                    <PUTP .OBJ ,P?OTOUCH? T>
                    <PUTP .WIN ,P?ASCORE 
                        <+ <GETP .WIN ,P?ASCORE> <GETP .OBJ ,P?OFVAL>>>
                    <PUTP .OBJ ,P?OFVAL 0>
                    <TELL "Taken." CR>)>)
          (<IN? .OBJ .WIN> <TELL "You already have it." CR>)
          (T <TELL "I can't see one here." CR>)>>

<ROUTINE DROP ("AUX" (WINNER ,WINNER) (VEC ,PRSVEC) (RM <GETP .WINNER ,P?AROOM>) (OBJ <2 .VEC>) NOBJ) 
    <COND (<AND .OBJ <NOT <WT? .OBJ ,PS?OBJECT>>>
            <TELL "You don't have one to drop." CR>
            <RTRUE>)>
    <COND (<AND <NOT .OBJ> <NOT <NEXT? <FIRST? .WINNER>>>>  ;"If noun is missing and only one item is carried, use that item."
            <SET OBJ <FIRST? .WINNER>>)
          (T <SET OBJ <FIND-OBJ .OBJ>>)>    ;"Set OBJ to the actual OBJECT."
    <COND (<AND <3 .VEC>  ;"If indirect object is given and OBJ is not carried, switch objects."
                <NOT <OR <IN? .OBJ .WINNER> 
                     <IN? <OCAN .OBJ> .WINNER>>>>
            <SET NOBJ <3 .VEC>>
            <PUT .VEC 3 <2 .VEC>>
            <PUT .VEC 2 .NOBJ>
            <SET OBJ <FIND-OBJ .NOBJ>>)>
    <COND (<NOT .OBJ>
            <TELL "Drop what?" CR>
            <RTRUE>)>
    <COND (<OR <IN? .OBJ .WINNER> <IN? <OCAN .OBJ> .WINNER>>
            <MOVE .OBJ .RM>
            <COND (<AND <NOT <3 .VEC>>  ;"If no indirect object given but enemy present, use it as indirect."
                        <OR <W=? <1 .VEC> ,W?GIVE>
                            <W=? <1 .VEC> ,W?THROW>>>
                    <PUT .VEC 3 <VICTIMS?>>)>
            <COND (<OBJECT-ACTION>)  ;"Give OBJECT-routine oppertunity to handle action."
                  (<W=? <1 .VEC> ,W?DROP> <TELL "Dropped." CR>)
                  (<W=? <1 .VEC> ,W?THROW> <TELL "Thrown." CR>)>)
          (T <TELL "You are not carrying that." CR>)>>

;"OBJECT-ACTION --
    CALL OBJECT FUNCTIONS FOR DIRECT AND INDIRECT OBJECTS"

<ROUTINE OBJECT-ACTION ("AUX" (VEC ,PRSVEC) (PRSO <FIND-OBJ <2 .VEC>>)
                                            (PRSI <FIND-OBJ <3 .VEC>>))
    <COND (<AND .PRSI <WT? <3 .VEC> ,PS?OBJECT>>
            <COND (<OBJ-HERE? .PRSI>
                    <AND <APPLY-OBJECT .PRSI> <RETURN T>>)          ;"Return if PRSI handle action."
                  (T <TELL "There is none of those here." CR>
                    <RETURN T>)>)>
    <COND (<AND .PRSO <WT? <2 .VEC> ,PS?OBJECT>>
            <COND (<OBJ-HERE? .PRSO>
                    <AND <APPLY-OBJECT .PRSO> <RETURN T>>)
                  (T <TELL "There is none of those here." CR>
                    <RETURN T>)>)>>

<ROUTINE OBJ-HERE? (OBJ "AUX" (RM ,HERE) (WIN ,WINNER))
    <AND <OCAN .OBJ> <SET OBJ <OCAN .OBJ>>>
    <OR <IN? .OBJ .RM> <IN? .OBJ .WIN>>>
    
<ROUTINE INVENT ("AUX" (ANY <>) MULT) 
    <COND (<G? <LENGTH ,WINNER> 0>
            <MAP-CONTENTS (X ,WINNER)           ;"List all objects in player."
                <COND (<OVIS? .X>
                        <OR .ANY <TELL "You are carrying:" CR>>
                        <SET ANY T>
                        <TELL "A " <GETP .X ,P?ODESC2>>
                        <OR <NOT <LENGTH .X>> <TELL " with ">>
                        <SET MULT <>>
                        <MAP-CONTENTS (Y .X)
                            <TELL <GETP .Y ,P?ODESC2>>
                            <COND (.MULT <TELL " and ">)>
                            <SET MULT T>>
                        <COND (<G? <LENGTH .X> 1> <TELL ".">)>
                        <TELL CR>)>>)
          (T <TELL "You are empty handed." CR>)>>

<ROUTINE POUR () T>  
 
<ROUTINE THROW () T> 
 
<ROUTINE MOVE ("AUX" (VEC ,PRSVEC) (RM <GETP ,WINNER ,P?AROOM>) (OBJ <2 .VEC>))
    <COND (<AND .OBJ <NOT <WT? .OBJ ,PS?OBJECT>>>
           <TELL "How can you move THAT?" CR>)
          (<IN? <FIND-OBJ .OBJ> .RM> <OBJECT-ACTION>)
          (<TELL "I can't see one here." CR>
           <COND (<AND <NOT ,PATCHED> <NOT ,RUG-MOVED-ERROR>>
                    <TELL "With the rug removed, the dusty cover of a closed trap-door appears." CR>
                    <SETG RUG-MOVED-ERROR T>)>
          )>>

;"Returns T if adversary is in room."
<ROUTINE VICTIMS? ("AUX"(RM ,HERE))
    <COND (<IN? ,THIEF .RM> <RETURN ,W?THIEF>)
          (<IN? ,CYCLO .RM> <RETURN ,W?CYCLO>)
          (<IN? ,GHOST .RM> <RETURN ,W?GHOST>)
          (<IN? ,ICE .RM> <RETURN ,W?ICE>)
          (<IN? ,TROLL .RM> <RETURN ,W?TROLL>)
          (T <RFALSE>)>>
      
<ROUTINE LAMP-ON ("AUX" (ME ,WINNER) OBJ (LIT-RM? <LIT? ,HERE>))
    <COND (<NOT <2 ,PRSVEC>> <PUT ,PRSVEC 2 <LIGHT-SOURCE .ME>>)>
    <SET OBJ <FIND-OBJ <2 ,PRSVEC>>>
    <>
    <COND (<OBJECT-ACTION>)
          (.OBJ
            <COND (<NOT <AND <WT? <2 ,PRSVEC> ,PS?OBJECT>
                             <N=? <GETP .OBJ ,P?OLIGHT?> 0>
                             <IN? .OBJ .ME>>>
                    <TELL "You can't turn that on." CR>
                    <RTRUE>)>
            <COND (<G? <GETP .OBJ ,P?OLIGHT?> 0>
                    <TELL "It is already on." CR>)
                  (T 
                    <PUTP .OBJ ,P?OLIGHT? 1>
                    <TELL "The " <GETP .OBJ ,P?ODESC2> " is now on." CR>
                    <COND (<NOT .LIT-RM?> <ROOM-INFO <>>)>)>)
          (T 
            <TELL "There is nothing here to turn on." CR>
            <RTRUE>)>>

<ROUTINE LAMP-OFF ("AUX" (ME ,WINNER) OBJ)
    <COND (<NOT <2 ,PRSVEC>> <PUT ,PRSVEC 2 <LIGHT-SOURCE .ME>>)>
    <SET OBJ <FIND-OBJ <2 ,PRSVEC>>>
    <COND (<OBJECT-ACTION>)
          (.OBJ
            <COND (<NOT <AND <WT? <2 ,PRSVEC> ,PS?OBJECT>
                             <N=? <GETP .OBJ ,P?OLIGHT?> 0>
                             <IN? .OBJ .ME>>>
                    <TELL "You can't turn that off." CR>
                    <RTRUE>)>
            <COND (<L? <GETP .OBJ ,P?OLIGHT?> 0>
                    <TELL "It is already off." CR>) 
                  (T 
                    <PUTP .OBJ ,P?OLIGHT? -1>
                    <TELL "The " <GETP .OBJ ,P?ODESC2> " is now off." CR>)>)
          (T 
            <TELL "There is nothing here to turn off." CR>
            <RTRUE>)>>
          
<ROUTINE SCORE ("OPT" (ASK? T) "AUX" SCOR) 
    <OR ,PATCHED <CRLF>>
    <COND (.ASK? <TELL "Were you to quit, your score would be ">)
          (T <TELL "Your score is ">)>
    <SET SCOR <GETP ,WINNER P?ASCORE>>
    <MAP-CONTENTS (X ,TROPH)
        <SET SCOR <+ .SCOR <GETP .X ,P?OTVAL>>>>
    <TELL N .SCOR " [total of " N ,SCORE-MAX " points], in " N ,MOVES " moves." CR>
    <TELL "This score gives you the rank of ">
    <COND (<G=? .SCOR ,SCORE-MAX> <TELL "Cheater">)                         ;"100%"
          (<G? <* .SCOR 100> <* 95 ,SCORE-MAX>> <TELL "Master">)            ;"95%"
          (<G? <* .SCOR 100> <* 90 ,SCORE-MAX>> <TELL "Winner">)            ;"90%"
          (<G? <* .SCOR 100> <* 80 ,SCORE-MAX>> <TELL "Hacker">)            ;"80%"
          (<G? <* .SCOR 100> <* 60 ,SCORE-MAX>> <TELL "Adventurer">)        ;"60%"
          (<G? <* .SCOR 100> <* 40 ,SCORE-MAX>> <TELL "Junior Adventurer">) ;"40%"
          (<G? <* .SCOR 100> <* 20 ,SCORE-MAX>> <TELL "Novice Adventurer">) ;"20%"
          (<G? <* .SCOR 100> <* 10 ,SCORE-MAX>> <TELL "Rank Amateur">)      ;"10%"
          (T <TELL "Loser">)>
    <TELL "." CR>>

<ROUTINE FINISH ("OPT" (ASK? T))
    <IFFLAG (DEBUG <TELL " FINISH" CR>)>
    <SCORE .ASK?>
    <COND (<OR
               <AND .ASK?
                    <TELL "Do you wish to leave the game? (Y is affirmative): " CR>
                    <YES/NO>>
               <NOT .ASK?>>
            <QUIT>)>>

<CONSTANT MONTHS
    <LTABLE
       "January"
       "February"
       "March"
       "April"
       "May"
       "June"
       "July"
       "August"
       "September"
       "October"
       "November"
       "December">>

<ROUTINE JIGS-UP (DESC "AUX" (WINNER ,WINNER) (DEATHS ,DEATHS) (I 2))
    <IFFLAG (DEBUG <TELL "JIGS-UP" CR>)>
    <COND (<G? ,DEATHS 2>
            <TELL
"You clearly are a suicidal maniac.  We don't allow psychotics in the|
cave, since they may harm other adventurers.  Your remains will|
installed in the Land of the Living Dead, where your fellow adventurers|
may gloat over them." CR>
            <FINISH <>>)
          (<SETG DEATHS <+ ,DEATHS 1>>
            <TELL .DESC CR>
            <TELL "Do you want me to try to patch you?" CR>
            <COND (<NOT <YES/NO>>
                    <TELL
"What?  You don't trust me?  Why, only last week I patched a running ITS|
and it survived for over 30 seconds.  Oh, well." CR>
                    <FINISH <>>)
                  (T
                    <TELL
"Now, let me see...|
Well, we weren't quite able to restore your state.  You can't have|
everything." CR>
                    <MOVE ,LAMP <GET ,RANDOM-LIST 1>>  ;"LROOM"
                    <GOTO ,FORE1>
                    <REPEAT ((X <FIRST? .WINNER>) N)
                        <COND (<NOT .X> <RETURN>)>
                        <SET N <NEXT? .X>>
                        <MOVE .X <GET ,RANDOM-LIST .I>>
                        <SET .X .N>
                        <SET I <+ .I 1>>
                        <COND (<G? .I <GET ,RANDOM-LIST 0>> <SET I 1>)>>)>)>>

<ROUTINE YES/NO ("AUX" IN)
    <SET IN <INPUT 1>>
    <OR ,PATCHED <TELL C .IN>>
    <COND (<=? .IN !\Y !\y> <RTRUE>) (T <RFALSE>)>> 

<ROUTINE INFO () 
    <TELL 
"You are near a large dungeon, which is reputed to contain vast|
quantities of treasure.  Naturally, you wish to acquire some of it.  In|
order to do so, you must of course remove it from the dungeon; to|
receive full credit for it, you must deliver it safely to the \"living|
room\".  In addition to valuables, the dungeon contains various objects|
which may or may not be useful in your attempt to get rich; you may need|
sources of light, since dungeons are often dark, and weapons, since|
dungeons often have unfriendly things wandering about.|
To determine how successful you have been, there is a score kept.  When|
you find a valuable object (i.e., pick it up), you receive a certain|
number of points, which depends on the difficulty of finding it.  You|
receive extra points for transporting the treasure safely to the living|
room.  In addition, some particularly interesting rooms have a value|
associated with your entering them.|
Of special note is a thief (always carrying a large bag) who likes to|
wander around in the dungeon (he has never been seen by the light of|
day).  He likes to take things; since he steals for pleasure rather than|
profit, and is sadistic, he only takes things which you have seen. |
Although he prefers valuables, sometimes in his haste he may take|
something which is worthless; from time to time, he examines his take|
and discards objects which he doesn't like.  He may occasionally stop in|
a room you are visiting, but more often he just wanders through and rips|
you off (he is a skilled pickpocket).">
    <CRLF>
    <AND ,PATCHED <SETG TELL-FLAG T>>>

<ROUTINE HELP () 
    <TELL 
"All commands should be terminated with altmode, due to an|
implementation restriction.|
You are talking to an extremely stupid parser.  It understands sentences|
of the following types:|
one word:  must be a direction (\"North\" or \"N\", \"Down\" or \"D\", etc.;),|
     an action which requires no object (\"Light\", \"Enter\",...) or a|
     magic word, if you know one.  Some words, such as articles and|
     prepositions, are ignored:  \"The north\" is just like \"North\".  In|
     addition, \"Inventory\" lists your possessions, and \"Look\" gives the|
     long description of the room you're currently in, with its|
     contents.|
two word:  \"Take frobozz\", \"Kick chomper\", and so on.|
three word:  Typically a sentence which has an object and a target: |
     \"Throw the spear at the snake,\" for example.  \"Throw spear snake\"|
     will work, as, strangely, will \"Throw snake spear.\"  \"Throw spear\"|
     will work if there is something reasonable to throw it at;|
     otherwise it is usually like \"Drop spear.\"  Some objects may do|
     something else when thrown.|
All words are five letters long; anything extra is discarded.  Objects|
frequently have several names, and there may be several ways of|
performing the same action.  \"Walk north\" is like \"North\", for example. |
Some verbs are meaningful only in certain contexts:  you usually can't|
\"Give\" something unless there is something there to take it; to \"Eat\"|
you have to have some food.  Some verbs aren't known at all;|
usually you'll find out about them the hard way.  Etc.">
    <CRLF>
    <AND ,PATCHED <SETG TELL-FLAG T>>>

;"PARSER & AUXILIARIES"

<CONSTANT INBUF-SIZE 100>
<GLOBAL INBUF <ITABLE BYTE ,INBUF-SIZE>>

;"SET UP INPUT ERROR HANDLER TO CAUSE EPARSE TO FALSE OUT"

;"Try to parse the LEX-buffer and fill PRSVEC with verb, direct object and
  indirect object. If successfull TRUE is returned; otherwise FALSE.
    SV      The lexbuffer to parse (not really a vector but name remains
            for historcal purpose.
    SILENT? If TRUE no messages will be printed (for echo)."
<ROUTINE EPARSE (SV SILENT?
                "AUX" (VEC ,PRSVEC) (PRS T) (CNT <GETB .SV 1>) (VERB? <>)
                       W ARG-MIN ARG-MAX (ARG-NUM 0))
    ;"Clear PRSVEC"
    <PUT .VEC 1 <>>
    <PUT .VEC 2 <>>
    <PUT .VEC 3 <>>
    <COND (<0? .CNT>)                               ;"Empty input; return PRS (T)"
          (<DO (I 1 .CNT)                           ;"Traverse over all words in input."
            <SET W <GET .SV <+ <* <- .I 1> 2> 1>>>  ;"Current word"
            <COND (<NOT .VERB?>                     ;"VERB? not set; Search for VERB or DIRECTION, ignore BUZZ."
                <COND (<WT? .W PS?VERB>
                        <SET VERB? .W>
                        <SET ARG-MAX <VMAX .VERB?>>
                        <SET ARG-MIN <VARGS .VERB?>>
                        <PUT .VEC 1 .VERB?>)
                      (<OR <WT? .W PS?DIRECTION> <=? .W ,W?LEAVE>>
                        <COND (<=? .W ,W?LEAVE> <SET .W ,W?OUT>)>
                        <SET VERB? ,W?WALK>
                        <SET ARG-MAX 1>
                        <SET ARG-MIN 1>
                        <SET ARG-NUM 1>
                        <PUT .VEC 1 .VERB?>
                        <PUT .VEC 2 .W>
                        <SET PRS T> <SET .I .CNT>)
                      (<WT? .W PS?BUZZ-WORD>)
                      (<OR <WT? .W PS?OBJECT> <WT? .W PS?ADJECTIVE> <0? .W>>
                        <COND (<OR <WT? .W PS?OBJECT> <WT? .W PS?ADJECTIVE>>
                                <OR .SILENT?
                                <TELL "What should I do with it?" CR>>)     ;"VERB? is not set but found an OBJECT."
                             (<OR .SILENT?
                                <TELL "I don't know how to do that." CR>>)> ;"VERB? is not set and found an unknown word."
                        <SET PRS <>> <SET .I .CNT>)                   
                      (<OR .SILENT? <TELL "I can't parse that." CR>>        ;"Illegal PoS. Shouldn't happen."
                        <SET PRS <>> <SET .I .CNT>)>)
                  (<NOT <0? .W>>                                            ;"VERB is found and legal word"
                <COND (<WT? .W PS?BUZZ-WORD>)                   ;"Ignore BUZZ"
                      (<OR <WT? .W PS?OBJECT> <WT? .W PS?ADJECTIVE>>
                        <SET ARG-NUM <+ .ARG-NUM 1>>
                        <COND (<2 .VEC> <PUT .VEC 3 .W>)
                              (T <PUT .VEC 2 .W>)>)
                      (<WT? .W PS?DIRECTION>
                        <COND (<2 .VEC>
                                <OR .SILENT? <TELL "I can't parse that." CR>>   ;"GO KNIFE SOUTH"
                                <SET PRS <>> <SET .I .CNT>)
                              (<PUT .VEC 2 .W>
                                <SET ARG-NUM <+ .ARG-NUM 1>>
                                <SET PRS T> <SET .I .CNT>)>)>)
                  (T <OR .SILENT? <TELL "I don't know that word." CR>>              ;"Unknown word"
                <SET PRS <>> <SET .I .CNT>)>>)>
    <COND (<AND .PRS <NOT <0? .CNT>>>
            <COND (<NOT .VERB?> <OR .SILENT? <TELL "Huh?" CR>> <SET PRS <>>);"No VERB?"
                  (<AND <L=? .ARG-NUM .ARG-MAX> <G=? .ARG-NUM .ARG-MIN>>    ;"Verb present and arguments in allowed range."
                <COND (<VACTION? .VERB?>
                    <COND (<WT? <2 .VEC> PS?DIRECTION>
                        <OR .SILENT? <TELL "You can't do that!" CR>>        ;"If VACTION? = T (Verb is not WALK) and PRSO is DIRECTION. GET SOUTH."
                        <SET PRS <>>)>)
                      (T
                    <COND (<NOT <WT? <2 .VEC> PS?DIRECTION>>
                        <OR .SILENT? <TELL "Go where?" CR>>                 ;"If VACTION? = FALSE (Verb is WALK) and PRSO is not DIRECTION. GO TROLL."
                        <SET PRS <>>)>)>)
                  (T 
                <COND (<NOT <OR .SILENT? <VSTR .VERB?>>>                        ;"Verb present and illegal argument range print VSTR. TIE."
                    <OR .SILENT? <TELL "I don't understand." CR>>)>         ;"Verb present and illegal argument range and empty VSTR. GO."
                <SET PRS <>>)>)>
    .PRS>

;"Create table to store result from EPARSE.
  Contains 4 word slots to support 1-base."
<GLOBAL PRSVEC <ITABLE 8 (BYTE)>>

<CONSTANT LEXV-SIZE 59>
<GLOBAL LEXV <ITABLE BYTE ,LEXV-SIZE>>
<GLOBAL RAWBUF <ITABLE BYTE ,INBUF-SIZE>>

;"Inputs text and puts the result in INBUF and LEXV"
<ROUTINE LEX ("AUX" LEN WS WE WC)
    <DO (I 1 ,INBUF-SIZE) <PUTB ,INBUF .I 0>>  ;"Clear INBUF"
    <DO (I 1 ,LEXV-SIZE) <PUTB ,LEXV .I 0>>    ;"Clear LEXV"
    <READ ,INBUF ,LEXV>
    ;"Some (Lectrote 1.3.5/Parchment) terps that uses ZVM don't preserve this 
      when resuming from an autosave. This makes sure it's reset between sessions"
    <FIXED-FONT-ON>  
    <DO (I 1 ,INBUF-SIZE) <PUTB ,RAWBUF .I <GETB ,INBUF .I>>>  ;"Copy INBUF to RAWBUF beefore manipulating it."
    ;"Replace all .,:;?! in input with SPACE, See BRKS in ROOMS.154..LEX"
    <SET LEN <+ <GETB ,INBUF 1> 1>>
    <DO (I 0 .LEN) 
        <COND (<OR <=? <GETB ,INBUF .I> !\.>
                   <=? <GETB ,INBUF .I> !\,>
                   <=? <GETB ,INBUF .I> !\:>
                   <=? <GETB ,INBUF .I> !\;>
                   <=? <GETB ,INBUF .I> !\!>
                   <=? <GETB ,INBUF .I> !\?>> <PUTB ,INBUF .I 32>)>>
    ;"Limit words in input to max 5 characters"
    <SET WC <GETB ,LEXV 1>> ;"# of parsed words"
    <DO (I 1 .WC)
        <SET LEN <GETB ,LEXV <* .I 4>>>
        <SET WS <GETB ,LEXV <+ <* .I 4> 1>>>
        <SET WE <+ .WS <- .LEN 1>>>
        <COND (<G? .LEN 5>
            <SET WS <+ .WS 5>>
            <DO (J .WS .WE) <PUTB ,INBUF .J 32>>)>>     
    ;"Redo parsing"
    <LEX ,INBUF ,LEXV>>

;"STUFF FOR ADDING TO VOCABULARY, ADDING TO LISTS (OF DEMONS, FOR EXAMPLE)."
;"Much of this isn't needed, it's built into ZIL."

;"<CRLF> returns T in original so we have to explicitly return it here."
<ROUTINE ACT-HACK () <OBJECT-ACTION> <RTRUE>>

