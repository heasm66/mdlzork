;"*****************************************************************************
  ZORK 285
  ========
  An attempt to make a truthful as possible ZIL-version of the very first 
  MDL version of Zork from June 14th, 1977.
  
  Henrik Åsman, 2021
  
  (Original source: https://github.com/MITDDC) 
  *****************************************************************************"

;"Changelog Release 2
  * Changed logic in RDCOM to be more like MDL-original.
  * Add 'behind you' to to text when going through trap-door.
  * Added different message when thief dies if he is carrying something or not.
  * Moved around CR in description text for room CELLA in ROUTINE CELLAR.
  * Added extra CR Before listing painting in gallery if it's untouched and the only one on the floor.
"
;"Corrected 'bugs' from MDL original when running in patched mode:
    1. INFO & HELP print 'Nothing happens!' after text.
    2. SE from 'Round room' print '2' before message.
    3. Extra CRLF at various places.
        - Extra CR after listing objects on ground in LROOM.
        - Extra CR after listing objects on ground in CYCLO-R.
        - Extra CR after listing objects on ground in MIRR1, MIRR2.
        - Two CR when arriving to EHOUS from the east 2nd time onward.
        - Extra CR after listing objects on ground in LLD1.
        - CR before ODESC0 for PAINT.
        - CR before printing echo in ECHO.
        - Two CR before long desc in LROOM.
        - CR before naked 'open' trap-door in LROOM.
        - CR before naked 'open' window in EHOUS.
        - Two CR before long desc in KITCH.
        - CR before text when leaving CAROU.
        - CR before text when tying rope in DOME.
        - CR before text when untying rope in DOME.
        - CR before text when exorcise in LLD1.
        - CR before printing SCORE.
    4. There is an extra space between 'window' and 'which' in KITCHEN.
    5. OPEN GRATING in MAZ11 crash.
    6. LOOK in rooms with function room-desc print desc in dark places.
    7. THROW or GIVE WATER keeps water in room.
    8. Give snack to Cyclops at last possible moment: 'You have two choices: 1. Leave  2. Become dinner.'
       and then GIVE [OBJ] (not water), results in a crash.
    9. 'accompish' misspelled in WHEEEEE.
   10. YES/NO prints character and no CRLF.
   11. Just typing MOVE in LIVING ROOM should print half a message and leave trap-door exposed.
   12. Second EXORCISE crashes the original.
   13. TIE ROPE if it's already tied crashes the original.
   14. Dropping rope in dome without carrying it still drops it down to MTORC.
   15. You can get objects that's not visible (TRUNK in RESERVOIR-SOUTH).
   16. Don't print the last message before drowning in MAINT. You drown at the second to last message.
   17. CLOSE in DAM-R prints 'Open what?'
   18. Pressing buttons in MAINT give correct message if only adjective is used, but prints an extra 
       message when you type, for example, 'PRESS RED BUTTON'.
   19. Dropping rope in DOME when rope not present crashes game.
   
 Known differences in ZIL-version compared to MDL-version:
    1. Loud Room won't echo the uppercase characters as uppercase. All is lowercase.
"
;"Enable/disable debug messages"
<COMPILATION-FLAG-DEFAULT DEBUG <>>

;"Force the two spaces after a full stop to be printed."
<SETG PRESERVE-SPACES? T>

;"This is filled in by the compiler during compilation with the highest 
  object-number (= total number of objects) (ROOMs & OBJECTs)."
<CONSTANT LAST-OBJECT <>>

<GLOBAL PATCHED T>  ;"Tries to fix the listed bugs from above."

<VERSION XZIP>  ;"Z5 because we don't want a statusline" 
<CONSTANT RELEASEID 2>
<CONSTANT IFID-ARRAY <PTABLE (STRING) "UUID://EEC39B5A-41F9-4EED-B7D7-41222DB6DE0D//">>

;"Split source as in FROB.GLUE"
<INSERT-FILE "DEFS">
<INSERT-FILE "ROOMS">
<INSERT-FILE "TELL">
<INSERT-FILE "MAZER">
<INSERT-FILE "AACT">

<ROUTINE GO ()
    <FIXED-FONT-ON>  ;"Fixed font for a more 'terminal' feeling."
    <SAVE-IT>>

<ROUTINE SLEEP (SEC)
    <INPUT 1 <* .SEC 10> ABORT-WAIT>        ;"Wait for SEC seconds."
    <RTRUE>>

<ROUTINE ABORT-WAIT () <RTRUE>>

;"Returns container object if object is inside one.
  If the parent of OBJ have the synonym-property it
  means that the parent is another object."
<ROUTINE OCAN (OBJ) 
    <COND (<GETPT <LOC .OBJ> ,P?SYNONYM> <RETURN <LOC .OBJ>>)
          (T <RFALSE>)>>
    
;"Counts the number of children objects to an object."
<ROUTINE LENGTH (OBJ "AUX" (CNT 0) (CHILD <FIRST? .OBJ>))
    <REPEAT ()
        <COND (<NOT .CHILD> <RETURN>)>
        <SET CNT <+ .CNT 1>>
        <SET CHILD <NEXT? .CHILD>>>
    <RETURN .CNT>>

;"WORD of TYPE?"
<ROUTINE WT? (WORD PS)
    <COND (<0? .WORD> <RFALSE>)>
    <COND (<BTST <GETB .WORD 6> .PS> <RTRUE>)  ;"6 = Part of speach flags for EZIP-"
          (T <RFALSE>)>>

;"Word-2 is the same or synonym to word-2"
<ROUTINE W=? (W1 W2)
    <COND (<AND <OR <AND <WT? .W1 ,PS?VERB> <WT? .W2 ,PS?VERB>>
                    <AND <WT? .W1 ,PS?DIRECTION> <WT? .W2 ,PS?DIRECTION>>>
                <=? <GETB .W1 7> <GETB .W2 7>>>
                    <RTRUE>)
          (<AND <WT? .W1 ,PS?OBJECT> <WT? .W2 ,PS?OBJECT>
                <=? <FIND-OBJ .W1> <FIND-OBJ .W2>>>
                    <RTRUE>)
          (<AND <WT? .W1 ,PS?ADJECTIVE> <WT? .W2 ,PS?ADJECTIVE>
                <=? .W1 .W2>>
                    <RTRUE>)
          (T <RFALSE>)>>

;"Because the window, the grating, the mirror and the trap-door 
  only can be in one place at a time it have to move with the 
  player between the relevant rooms."
 <ROUTINE DOOR-FIX ("AUX" (PRSACT <1 ,PRSVEC>))
    <COND (<W=? .PRSACT ,W?WALK-IN>
            <COND (<=? ,HERE ,KITCH ,EHOUS> <MOVE ,WINDO ,HERE>)
                  (<=? ,HERE ,LROOM ,CELLA> <MOVE ,DOOR ,HERE>)
                  (<=? ,HERE ,MIRR1 ,MIRR2> <MOVE ,REFLE ,HERE>)
                  (<=? ,HERE ,CLEAR ,MAZ11> <MOVE ,GRATE ,HERE>)>)>>  

<DEFMAC ABS ('NUM)
    <FORM COND (<FORM L? .NUM 0> <FORM - 0 .NUM>)
               (T .NUM)>>

<ROUTINE MIN (N1 N2)
     <COND (<L? .N1 .N2> .N1)
           (T .N2)>>
           
<ROUTINE FIXED-FONT-ON () <PUT 0 8 <BOR <GET 0 8> 2>>>

<ROUTINE FIXED-FONT-OFF() <PUT 0 8 <BAND <GET 0 8> -3>>>

;"SIze of UEXIT, NEXIT and CEXIT."
<CONSTANT UEXIT 2>
<CONSTANT NEXIT 3>
<CONSTANT CEXIT 5>

;"Position of data in exits."
<CONSTANT EXIT-RM 0>
<CONSTANT NEXIT-MSG 0>
<CONSTANT CEXIT-VAR 4>
<CONSTANT CEXIT-MSG 1>

<GLOBAL RUG-MOVED-ERROR <>>

<ROUTINE PRINTSTRING (B "AUX" (L <+ <GETB .B 1> 1>))
    <DO (I 2 .L)
        <PRINTC <GETB .B .I>>>>

<SYNTAX SAVE = V-SAVE>
<SYNTAX RESTO = V-RESTORE>
<SYNTAX ABOUT = V-ABOUT>
<SYNTAX UNPAT = V-UNPATCHED>
<SYNTAX BUGFI = V-BUGFIXES>

<CONSTANT CAN-NOT-DO-THAT "I don't know how to do that.">

<ROUTINE V-RESTORE ()
    <COND (<NOT ,PATCHED> <TELL ,CAN-NOT-DO-THAT CR> <RTRUE>)>
    <COND (<RESTORE> <TELL "Ok." CR>)
          (T <TELL "Failed." CR>)>>

<ROUTINE V-SAVE ()
    <COND (<NOT ,PATCHED> <TELL ,CAN-NOT-DO-THAT CR> <RTRUE>)>
    <COND (<SAVE> <TELL "Ok." CR>)
          (T <TELL "Failed." CR>)>>

<ROUTINE V-ABOUT ()
    <COND (<NOT ,PATCHED> <TELL ,CAN-NOT-DO-THAT CR> <RTRUE>)>
    <REMARKABLY-DISGUSTING-CODE>
    <TELL " Release " N <BAND <LOWCORE RELEASEID> *3777*> "." CR> 
    
    <TELL 
"|
            THE ORIGINAL ZORK AS OF JUNE 14, 1977|
This is an attempt to make an exact replica in ZIL of the 285 point MDL-version|
of Zork as it was June 14, 1977.|
Zork is an interactive fiction game created at MIT by Tim Anderson, Marc Blank,|
Bruce Daniels, and Dave Lebling. Development of Zork started early May of 1977|
and the earliest preserved compiled versions are from June 12 and June 14 the|
same year. These versions also have some of their source code preserved,|
see more at https://github.com/MITDDC/zork.|
This version adds a couple of commands and fixes some minor bugs. There|
is also possible to play this version with the bugs restored and|
without the extra commands, see UNPATCHED.|
|
   ABOUT     Prints this message.|
   BUGFIXES  Lists all bugfixes that are made from original. These|
             can be turned of with UNPATCHED.|
             Warning, contains spoilers!|
   RESTORE   Restores a saved savepoint.|
   SAVE      Saves a savepoint.|
   UNPATCHED Removes access to these commands and removes the|
             bugfixes.|
|
Due to technical limitations in the Z-machine the echo in Echo Room always|
prints the echo in lowercase.|
Note that this version of Zork does not have a definite ending, the|
game is considered finished when you have reached the maxscore.|
Please report bugs or other differences against the original Zork (aside|
from the above mentioned) to: heasm66@gmail.com.|
Thanks to Jesse McGrew for the modern ZIL compiler Zilf and to the orginal|
implementors of Zork.|
Henrik Åsman, Stockholm 2021" CR>>

<ROUTINE V-BUGFIXES ()
    <COND (<NOT ,PATCHED> <TELL ,CAN-NOT-DO-THAT CR> <RTRUE>)>
    <TELL 
"            THESE BUGS ARE FIXED IN THE PATCHED VERSION|
      1. 'info' & 'help' print 'Nothing happens!' after text.|
      2. 'se' from Round room prints a '2' before message.|
      3. Extra carriage return (CR) at various places.|
          - Extra CR after listing objects on ground in Living Room.|
          - Extra CR after listing objects on ground in Cyclops Room.|
          - Extra CR after listing objects on ground in Mirror Room 1 & 2.|
          - Two CR when arriving in East of House from the east 2nd time onward.|
          - Extra CR after listing objects on ground in Land of Living Dead.|
          - CR before first description of painting.|
          - CR before printing the echo in Echo Room.|
          - Two CR before long description in Living Room.|
          - CR before naked 'open' trap-door in Living Room.|
          - CR before naked 'open' window in East of House.|
          - Two CR before long desc in Kitchen.|
          - CR before text when leaving Carousel Room.|
          - CR before text when tying rope in Dome Room.|
          - CR before text when untying rope in Dome Room.|
          - CR before text when exorcise in Land of Living Dead.|
          - CR before printing the score.|
      4. There is an extra space between 'window' and 'which' in Kitchen.|
      5. 'open grating' in Maze crashes game. 'open' works.|
      6. 'look' in rooms with function room-descriptions print description|
         when dark.|
      7. 'throw' or 'give water' drops water and it remains as an object in room.|
      8. 'give snack' to Cyclops at last possible moment when:|
         'You have two choices: 1. Leave  2. Become dinner.'|
         and then 'give [obj] (not water), results in a crash.|
      9. Typo in WHEEEEE, 'accompish'.|
     10. Answer to yes/no question prints character and no CRLF.|
     11. Just typing 'move' in Living Room should print half a message and leave|
         trap-door exposed.|
     12. A second 'exorcise' in Land of Living Dead crashes the game.|
     13. 'tie rope' if it's already tied results in a crash.|
     14. Dropping the rope in Dome Room when the rope is on the ground but not|
         carried still drops it down to Torch Room.|
     15. Dropping the rope in Dome Room when the rope is not in the room and|
         not carried results in a crash.|
     16. You can get objects that are not yet visible (the trunk in Reservoir South).|
     17. Don't print the last message before drowning in Maintenance Room. You|
         drown at the second to last message.|
     18. 'close' in Dam Room prints 'Open what?'|
     19. Pressing buttons in Maintenance Room give correct message if only adjective|
         is used, but prints an extra message when you type, for example,|
         'press red button'." CR>>

<ROUTINE V-UNPATCHED () 
    <COND (<NOT ,PATCHED> <TELL ,CAN-NOT-DO-THAT CR> <RTRUE>)>
    <TELL "Patches is now turned off." CR>
    <SETG PATCHED <>>>

<ROUTINE CAN-TAKE? (OBJ)
    <OR <BTST <GETP .OBJ ,P?OFLAGS> 1>              ;"Visible,"
             <NOT ,PATCHED>                         ;"or unpatched,"
             <AND <VICTIMS?> <=? VICTIMS? .OBJ>>>>  ;"or one of the victims."

;"Extract and prints compile date from header."
<ROUTINE REMARKABLY-DISGUSTING-CODE ()
    <TELL "This version created ">
    <TELL <NTH ,MONTHS <+ <* <- <GETB 0 20> 48> 10> <- <GETB 0 21> 48>>>>
    <TELL " " N <+ <* <- <GETB 0 22> 48> 10> <- <GETB 0 23> 48>>>
    <TELL ", 20" N <+ <* <- <GETB 0 18> 48> 10> <- <GETB 0 19> 48>> ".">>

