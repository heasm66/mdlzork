
"GUTS OF FROB:  BASIC VERBS, COMMAND READER, PARSER, VOCABULARY HACKERS."

<SETG ALT-FLAG T>

<GDECL (MUDDLE) FIX (TENEX?) <OR ATOM FALSE> (VERS DEV SNM SCRATCH-STR) STRING>

<DEFINE SAVE-IT ("OPTIONAL" (FN <COND (<L? ,MUDDLE 100>"MADMAN;MADADV SAVE")
                                      (T "<MDL>MADADV.SAVE")>)
                 (START? T)
                 "AUX" (MUDDLE ,MUDDLE) STV (ST <REMARKABLY-DISGUSTING-CODE>))
        #DECL ((START?) <OR ATOM FALSE> (FN) STRING (MUDDLE) FIX (STV) <OR STRING FIX>) 
        <PUT <FIND-OBJ "PAPER"> ,ODESC1 <UNSPEAKABLE-CODE>>
        <SETG VERS .ST>
        <SETG SCRIPT-CHANNEL <>>
        <SETG DBG <>>
        <SETG RAW-SCORE 0>
        <SETG PTEMP <CHTYPE [<CHTYPE WITH!-WORDS PREP> <FIND-OBJ "!!!!!">] PHRASE>>
        <SET IH <ON "IPC" ,ILO 1>>
        <HANDLER ,DIVERT-INT ,DIVERT-HAND>
        <COND (<G? .MUDDLE 100>
               <SETG SCRATCH-STR <ISTRING 32>>
               <SETG DEV "DSK">
               <SETG SNM "MDL">)
              (<SNAME "">
               <SETG DEV "DSK">
               <SETG SNM "MADMAN">)>
        <INT-LEVEL 100000>
        <SETG DEATHS 0>
        <SETG MOVES 0>
        <SETG WINNER ,PLAYER>
        <COND (<AND <=? <SAVE .FN> "SAVED">
                    <NOT .START?>>
                <INT-LEVEL 0>
               T)
              (T
               ; "STARTER on 10x sets up tty correctly, setg's DEV to \"MDL\"
                  if that device exists; if not, (sort of) returns directory save file
                  came from.  On its it returns # zorkers currently in existence."
               <RANDOM <CHTYPE <DSKDATE> FIX>>
               <INT-LEVEL 0>
               <COND (<AND <TYPE? <SET STV <STARTER>> FIX>
                           <G? .STV 3>>
                      <OR <MEMBER <SETG XUNM <XUNAME>> ,WINNERS>
                          <=? ,XUNM "SEC">
                          <=? ,XUNM "ELBOW">
                          <AND <OFF "CHAR" ,INCHAN>
                               <TELL 
"There appears before you a threatening figure clad all over
in heavy black armor.  His legs seem like the massive trunk
of the oak tree.  His broad shoulders and helmeted head loom
high over your own puny frame and you realize that his powerful
arms could easily crush the very life from your body.  There
hangs from his belt a veritable arsenal of deadly weapons:
sword, mace, ball and chain, dagger, lance, and trident.
He speaks with a commanding voice:

                \"YOU SHALL NOT PASS \"

As he grabs you by the neck all grows dim about you.">
                               <QUIT>>>)
                     (<TYPE? .STV STRING>
                      <SETG SNM <SUBSTRUC ,SCRATCH-STR
                                          0
                                          <- <LENGTH ,SCRATCH-STR>
                                             <LENGTH <MEMQ <ASCII 0> .STV>>>>>)>
               <COND (<G? ,MUDDLE 100> <SETG TENEX? <GETSYS>>)
                     (<APPLY ,IPC-OFF>
                      <APPLY ,IPC-ON <UNAME> "ZORK">)>
               <SET BH <ON "BLOCKED" ,BLO 100>>
               <START "WHOUS" .ST>)>>



"Stuff for diverting gc's"

<SETG DIVERT-CNT 0>

<SETG DIVERT-MAX 99>

<SETG DIVERT-INC 4000>

<SETG DIVERT-AMT 0>

<SETG DIVERT-LMT 100000>

<GDECL (DIVERT-CNT DIVERT-MAX DIVERT-INC DIVERT-AMT DIVERT-LMT) FIX>

<DEFINE DIVERT-FCN  (AMT REASON)
        <SETG DIVERT-CNT <+ ,DIVERT-CNT 1>>
        <SETG DIVERT-AMT <+ ,DIVERT-AMT ,DIVERT-INC .AMT>>
        <COND (<OR <G? ,DIVERT-CNT ,DIVERT-MAX>
                   <G? ,DIVERT-AMT ,DIVERT-LMT>>        ;"Too much diversion ?"
                <SETG DIVERT-AMT <SETG DIVERT-CNT 0>>
                <GC-FCN>
                <GC>)
              (ELSE     ;"Divert this request for storage"
                <COND (<1? ,DIVERT-CNT>         ;"First diversion ?"
                       <HANDLER ,GC-INT ,GC-HAND>)>
                <BLOAT <+ .AMT ,DIVERT-INC>>
                                ;"Get storage desired plus extra increment")>>

<SETG DIVERT-HAND <HANDLER <SETG DIVERT-INT <EVENT "DIVERT-AGC" 1000>>
                        ,DIVERT-FCN>>

<OFF ,DIVERT-HAND>

<DEFINE GC-FCN  ("TUPLE" T)
        <OFF ,GC-HAND>
        <SETG DIVERT-AMT <SETG DIVERT-CNT 0>>>

<SETG GC-HAND <HANDLER <SETG GC-INT <EVENT "GC" 11>>
                        ,GC-FCN>>

<OFF ,GC-HAND>



<DEFINE XUNAME ()
  #DECL ((VALUE) STRING)
  <MAPF ,STRING
        <FUNCTION (X)
           #DECL ((X) CHARACTER)
           <COND (<OR <0? <ASCII .X>>
                      <==? <ASCII .X> 32>>
                  <MAPSTOP>)
                 (T .X)>>
        <GXUNAME>>>

<DEFINE ITS-GET-NAME (UNAME "AUX" (NM <FIELD .UNAME ,$NAME>) CMA JR LFST LLST
                      TLEN TSTR STR)
        #DECL ((STR TSTR UNAME) STRING (NM CMA JR) <OR STRING FALSE>
               (TLEN LLST LFST) FIX)
        <COND (.NM
               <COND (<SET CMA <MEMQ !\, .NM>>
                      <SET LLST <- <LENGTH .NM> <LENGTH .CMA>>>
                      <SET CMA <REST .CMA>>
                      <SET LFST <LENGTH .CMA>>
                      <COND (<SET JR <MEMQ !\, .CMA>>
                             <SET LFST <- .LFST <LENGTH .JR>>>)>
                      <REPEAT ()
                              <COND (<EMPTY? .CMA> <RETURN>)
                                    (<MEMQ <1 .CMA> %<STRING <ASCII 32> <ASCII 9>>>
                                     <SET CMA <REST .CMA>>
                                     <SET LFST <- .LFST 1>>)
                                    (ELSE <RETURN>)>>
                      <SET TLEN <+ .LFST 1 .LLST <LENGTH .JR>>>
                      <SET STR <ISTRING .TLEN !\ >>
                      <SET TSTR .STR>
                      <SUBSTRUC .CMA 0 .LFST .TSTR>
                      <SET TSTR <REST .TSTR <+ .LFST 1>>>
                      <SUBSTRUC .NM 0 .LLST .TSTR>
                      <AND .JR <SUBSTRUC .JR 0 <LENGTH .JR> <REST .TSTR .LLST>>>
                      <SETG USER-NAME .STR>)
                     (ELSE <SETG USER-NAME .NM>)>)>>

<DEFINE UNSPEAKABLE-CODE ("AUX" STR NSTR (LEN-I 0) (O <FIND-OBJ "PAPER">))
    #DECL ((O) OBJECT (NSTR STR) STRING (LEN-I) FIX)
    <SET STR <MEMQ !\/ <OREAD .O>>>
    <COND (<==? <1 <BACK .STR 2>> !\1>
           <SET STR <BACK .STR 2>>
           <SET LEN-I 1>)
          (<SET STR <BACK .STR 1>>)>
    <SET NSTR <REST <MEMQ !\/ <REST <MEMQ !\/ .STR>>> 3>>
    <STRING "There is an issue of US NEWS & DUNGEON REPORT dated "
            <SUBSTRUC .STR 0 <- <LENGTH .STR> <LENGTH .NSTR>>>
            " here.">>

<DEFINE REMARKABLY-DISGUSTING-CODE ("AUX" (N <DSKDATE>))
        #DECL ((N) <PRIMTYPE WORD>)
        <STRING
         "This version created "
         <NTH ,MONTHS <CHTYPE <GETBITS .N <BITS 4 23>> FIX>>
         !\ 
         <UNPARSE <CHTYPE <GETBITS .N <BITS 5 18>> FIX>>
         !\.>>

<DEFINE VERSION ()
  <TELL ,VERS>>

<SETG PLAYED-TIME 0>

<GDECL (PLAYED-TIME) FIX>

<DEFINE GET-TIME ("AUX" (NOW <DSKDATE>) (THEN ,INTIME))
        #DECL ((NOW THEN) <PRIMTYPE WORD>)
        <+ <COND (<N==? <CHTYPE <GETBITS .NOW <BITS 18 18>> FIX>
                        <CHTYPE <GETBITS .THEN <BITS 18 18>> FIX>>
                  </ <- <+ <CHTYPE <GETBITS .NOW <BITS 18 0>> FIX>
                           <* 24 7200>>
                        <CHTYPE <GETBITS .THEN <BITS 18 0>> FIX>>
                     2>)
                 (</ <- <CHTYPE <GETBITS .NOW <BITS 18 0>> FIX>
                        <CHTYPE <GETBITS .THEN <BITS 18 0>> FIX>>
                     2>)>
           ,PLAYED-TIME>>

<DEFINE PLAY-TIME ("OPTIONAL" (LOSER? T)
                   "AUX" (OUTCHAN .OUTCHAN) TIME MINS)
        #DECL ((MINS TIME) FIX (LOSER?) <OR ATOM FALSE> (OUTCHAN) CHANNEL)
        <SET TIME <GET-TIME>>
        <SETG TELL-FLAG T>
        <COND (.LOSER? <PRINC "You have been playing DUNGEON for ">)
              (T
               <PRINC "Played for ">)>
        <AND <G? <SET MINS </ .TIME 3600>> 0>
             <PRIN1 .MINS>
             <PRINC " hour">
             <OR <1? .MINS> <PRINC "s">>
             <PRINC ", ">>
        <COND (<G? <SET MINS <MOD </ .TIME 60> 60>> 0>
               <PRIN1 .MINS>
               <PRINC " minute">
               <COND (<NOT <1? .MINS>> <PRINC "s">)>
               <PRINC ", and ">)>
        <PRIN1 <SET MINS <MOD .TIME 60>>>
        <PRINC " second">
        <OR <1? .MINS> <PRINC "s">>
        <COND (.LOSER? <PRINC ".
">)
              (<PRINC ".">)>
        .TIME> 

<DEFINE HANDLE (FRM "TUPLE" ZORK "AUX" ZF CH) 
        #DECL ((ZF) ANY (FRM) FRAME (ZORK) <SPECIAL TUPLE> (CH) <OR CHANNEL FALSE>)
        <PUT ,OUTCHAN 13 80>
        <COND (<AND <OR <NOT <GASSIGNED? XUNM>>
                        <MEMBER ,XUNM ,WINNERS>>
                    T>
               <PUT <1 <BACK ,INCHAN>> 6 #LOSE 27>
               <AND <GASSIGNED? SAVEREP> <SETG REP ,SAVEREP>>
               <AND <ASSIGNED? BH> <OFF .BH>>
               <INT-LEVEL 0>
               <SETG DBG T>
               <SETG ALT-FLAG T>)
              (,ERRFLG
               <QUIT>)
              (T
               <COND (<AND <NOT <EMPTY? .ZORK>>
                           <==? <1 .ZORK> CONTROL-G?!-ERRORS>>
                      <INT-LEVEL 0>
                      <FINISH>
                      <PUT <1 <BACK ,INCHAN>> 6 <COND (<G? ,MUDDLE 100>
                                                       <COND (,TENEX? #LOSE *37*)
                                                             (T #LOSE *000000000012*)>)
                                                      (T #LOSE *000000000015*)>>
                      <ERRET T .FRM>)
                     (<AND <==? <LENGTH .ZORK> 3>
                           <==? <1 .ZORK> FILE-SYSTEM-ERROR!-ERRORS>
                           <NOT <SET ZF <3 .ZORK>>>
                           <==? <LENGTH .ZF> 3>
                           <=? <1 .ZF>
                               "ILLEGAL CHR AFTER CNTRL P ON TTY DISPLAY">>
                      ; "HACK FOR ILLEGAL CHR AFTER CTRL-P"
                      <PUT <1 <BACK ,INCHAN>> 6 #LOSE *000000000015*>
                      <INT-LEVEL 0>
                      <ERRET T .FRM>)
                     (<SETG ERRFLG T>
                      <UNWIND
                       <PROG ()
                         <INT-LEVEL 0>
                         <TELL
"I'm sorry, you seem to have encountered an error in the program.">
                         <COND (<SET CH <RECOPEN "BUG">>
                                <TELL "Please describe what happened:">
                                <BUGGER .CH>)
                               (<TELL 
"Send mail to DUNGEON@MIT-DMS describing what it was you tried to do.">
                                <TELL ,VERS>
                                <MAPF <> <FUNCTION (X) <PRINT .X>> .ZORK>)>
                         <FINISH #FALSE (". Error.")>>
                       <FINISH #FALSE (". Error.")>>)>)>>

<PSETG WINNERS '["BKD" "TAA" "MARC" "PDL" "MDL"]>

<SETG ERRFLG <>>
<GDECL (WINNERS) <VECTOR [REST STRING]> (ERRFLG) <OR ATOM FALSE>>

<OR <LOOKUP "COMPILE" <ROOT>>
        <AND <GET PACKAGE OBLIST> <LOOKUP "GLUE" <GET PACKAGE OBLIST>>> <LOOKUP "GROUP-GLUE" <GET INITIAL OBLIST>>
    <SETG ERRH
          <HANDLER <OR <GET ERROR!-INTERRUPTS INTERRUPT> <EVENT "ERROR" 8>>
                   ,HANDLE>>>

<GDECL (MOVES) FIX (SCRIPT-CHANNEL) <OR CHANNEL FALSE>>

<DEFINE START (RM "OPTIONAL" (ST "") "AUX" FN (MUDDLE ,MUDDLE) (XUNM <XUNAME>)) 
        #DECL ((ST RM) STRING (MUDDLE) FIX (XUNM) STRING (FN) <OR FALSE STRING>)
        <SETG XUNM .XUNM>
        <SETG INTIME <DSKDATE>>
        <COND (<L? .MUDDLE 100>
               <AND <G? <LENGTH .XUNM> 2> <=? <SUBSTRUC .XUNM 0 3> "___"> <QUIT>>
               <SET FN <ITS-GET-NAME .XUNM>>)
              (<SET FN <GET-NAME>>)>
        <COND (.FN
               <SETG USER-NAME .FN>)
              (<SETG USER-NAME .XUNM>)>
                <PUT ,WINNER ,AROOM <SETG HERE <FIND-ROOM .RM>>>
        <TELL "Welcome to Dungeon.
" 1 .ST>
        <CONTIN>>

<DEFINE CONTIN () 
        <SETG ALT-FLAG <>>
        <PUT <1 <BACK ,INCHAN>> 6 <COND (<G? ,MUDDLE 100>
                                         <COND (,TENEX? #LOSE *37*)
                                               (T #LOSE *000000000012*)>)
                                        (T #LOSE *000000000015*)>>
        <SETG SAVEREP ,REP>
        <SETG REP ,RDCOM>
        <RESET ,INCHAN>
        <SETG WINNER ,PLAYER>
        <PUT ,PRSVEC 2 <>>
        ,NULL>

<SETG MY-SCRIPT <>>

<GDECL (MY-SCRIPT) <OR ATOM FALSE>>

<DEFINE MAKE-SCRIPT ("AUX" CH)
  #DECL ((CH) <OR CHANNEL FALSE>)
  <COND (,SCRIPT-CHANNEL
         <>)
        (<SET CH <OPEN "PRINT" <STRING "MARC;%Z" ,XUNM " >">>>
         <PUT <TOP ,INCHAN> 1 (.CH)>
         <PUT <TOP ,OUTCHAN> 1 (.CH)>
         <SETG SCRIPT-CHANNEL .CH>
         <SETG MY-SCRIPT T>)>>

<DEFINE FLUSH-ME ()
  <UNWIND
   <PROG ()
         <TELL
"Suddenly, a sinister, wraithlike figure appears before you, seeming
to float in the air.  He glows with an eldritch light.  In a barely
audible voice he says, \"Begone, defiler!  Your presence upsets the
very balance of the System itself!\"  With a sinister chuckle, he
raises his oaken staff, taps you on the head, and fades into the
gloom.  In his place appears a tastefully lettered sign reading:

                        DUNGEON CLOSED

At that instant, you disappear, and all your belongings clatter to
the ground.
">
         <FINISH <>>>
   <FINISH <>>>>

<DEFINE DO-SCRIPT ("AUX" CH (UNM ,XUNM) (MUDDLE ,MUDDLE))
  #DECL ((CH) <OR CHANNEL FALSE> (UNM) STRING (MUDDLE) FIX)
  <COND (,MY-SCRIPT
         <DO-UNSCRIPT <>>)>
  <COND (,SCRIPT-CHANNEL
         <TELL "You are already scripting.">)
        (<AND
          <OR <G? .MUDDLE 100>
              <AND <NOT <MEMBER "GUEST" .UNM>>
                   <SET CH <OPEN "READ" ".FILE." "(DIR)" "DSK" .UNM>>
                   <CLOSE .CH>
                   <SET CH <OPEN "READ" "_MSGS_" .UNM "DSK" .UNM>>
                   <CLOSE .CH>>>
          <SET CH <OPEN "PRINT" "ZORK" "SCRIPT" "DSK" .UNM>>>
         <PUT <TOP ,INCHAN> 1 (.CH)>
         <PUT <TOP ,OUTCHAN> 1 (.CH)>
         <SETG SCRIPT-CHANNEL .CH>
         <COND (<L? ,MUDDLE 100>
                <TELL "Scripting to " 1 ,XUNM ";ZORK SCRIPT">)
               (T
                <TELL "Scripting to <" 1 ,XUNM ">ZORK.SCRIPT">)>)
        (T
         <TELL "I can't open the script channel.">)>>

<DEFINE DO-UNSCRIPT ("OPTIONAL" (VERBOSE T))
  #DECL ((VERBOSE) <OR ATOM FALSE>)
  <COND (,SCRIPT-CHANNEL
         <PUT <TOP ,INCHAN> 1 ()>
         <PUT <TOP ,OUTCHAN> 1 ()>
         <CLOSE ,SCRIPT-CHANNEL>
         <SETG SCRIPT-CHANNEL <>>
         <AND .VERBOSE <TELL "Scripting off.">>)
        (<AND .VERBOSE <TELL "Scripting wasn't on.">>)>>

<GDECL (THEN) FIX>

<DEFINE DO-SAVE ("AUX" (MUDDLE ,MUDDLE) CH (UNM ,XUNM))
  #DECL ((CH) <OR CHANNEL FALSE> (MUDDLE) FIX (UNM) STRING)
  <COND (<OR <G? .MUDDLE 100>
             <AND <NOT <MEMBER "GUEST" .UNM>>
                  <SET CH <OPEN "READ" ".FILE." "(DIR)" "DSK" .UNM>>
                  <CLOSE .CH>>>
         <COND (<OR <G? .MUDDLE 100>
                    <AND <SET CH <OPEN "READ" "_MSGS_" .UNM "DSK" .UNM>>
                         <CLOSE .CH>>>
                <AND ,SCRIPT-CHANNEL <DO-UNSCRIPT>>
                <TELL "Saving.">
                <INT-LEVEL 100000>
                <OFF "CHAR" ,INCHAN>
                <SETG THEN <CHTYPE <DSKDATE> FIX>>
                <SETG PLAYED-TIME <GET-TIME>>
                <COND (<SET CH <OPEN "PRINTB"
                                     <COND (<L? .MUDDLE 100>
                                            <STRING "DSK:" .UNM ";ZORK SAVE">)
                                           (T
                                            <STRING "DSK:<" .UNM ">ZORK.SAVE">)>>>
                       <SAVE-GAME .CH>
                       <FINISH <CHTYPE '(". Saved.") FALSE>>)
                      (<TELL "Save failed.">
                       <TELL <1 .CH> 1 " " <2 .CH>>)>)
               (<TELL "Can't open channel for save.">)>)
        (T <TELL "Can't open channel for save.">)>>

<DEFINE DO-RESTORE ("AUX" CH STR (MUDDLE ,MUDDLE) NOWD NOW THEND)
  #DECL ((CH) <OR CHANNEL FALSE> (STR) STRING (NOWD NOW THEND MUDDLE) FIX)
   <COND (<L? .MUDDLE 100>
          <SET STR <STRING "DSK:" ,XUNM ";ZORK SAVE">>)
         (T
          <SET STR <STRING "DSK:<" ,XUNM ">ZORK.SAVE">>)>
   <PROG ((FOO T) (SNM <SNAME>))
         #DECL ((FOO) <OR ATOM FALSE> (SNM) <SPECIAL STRING>)
         <COND (<SET CH <OPEN "READB" .STR>>
                <COND (<RESTORE-GAME .CH>
                       <COND (<MEMBER ,XUNM ,WINNERS>
                              <SET NOW <CHTYPE <DSKDATE> FIX>>)
                             (<==? <SET NOWD
                                        <CHTYPE <GETBITS <SET NOW
                                                              <CHTYPE <DSKDATE> FIX>>
                                                         <BITS 18 18>>
                                                FIX>>
                                   <SET THEND
                                        <CHTYPE <GETBITS ,THEN <BITS 18 18>> FIX>>>
                              <COND (<G=? <- .NOW ,THEN> 2400>)
                                    (<TELL "It's too soon.">
                                     <COND (<G? ,MUDDLE 100>
                                            <OFF "CHAR" ,INCHAN>
                                            <INT-LEVEL 10000>
                                            <QUIT>)>
                                     <QUIT>)>)
                             (<1? <- .NOWD .THEND>>
                              <COND (<G=? <- <+ <CHTYPE <GETBITS .NOW <BITS 18 0>> FIX>
                                                <* 24 7200>>
                                             <CHTYPE <GETBITS .NOW <BITS 18 0>> FIX>>
                                          2400>)
                                    (<TELL "It's too soon.">
                                     <QUIT>)>)>
                       <SETG INTIME .NOW>
                       <TELL "Restored.">)
                      (<TELL "Restore failed.">)>
                <ROOM-DESC>)
               (<AND .FOO <G? .MUDDLE 100>>
                <SET STR <STRING "DSK:<" <SNAME> ">ZORK.SAVE">>
                <SET FOO <>>
                <AGAIN>)
               (<TELL <2 .CH> 1 " " <1 .CH>>)>>>

<DEFINE PROB (NUM) #DECL ((NUM) FIX) <L=? <MOD <RANDOM> 100> .NUM>>

"GET-ATOM TAKES A VALUE AND SEARCHES INITIAL FOR FIRST ATOM
SETG'ED TO THAT."

<DEFINE GET-ATOM ACT (VAL "AUX" (O <GET INITIAL OBLIST>))
  #DECL ((O) OBLIST)
  <MAPF <>
    <FUNCTION (X) #DECL ((X) <LIST [REST ATOM]>)
      <MAPF <>
        <FUNCTION (X) #DECL ((X) ATOM)
          <COND (<AND <GASSIGNED? .X>
                      <==? ,.X .VAL>>
                 <RETURN .X .ACT>)>>
        .X>>
    .O>>

;
"ROOM-INFO --
        PRINT SOMETHING ABOUT THIS PLACE
        1. CHECK FOR LIGHT --> ELSE WARN LOSER
        2. GIVE A DESCRIPTION OF THE ROOM
        3. TELL WHAT'S ON THE FLOOR IN THE WAY OF OBJECTS
        4. SIGNAL ENTRY INTO THE ROOM
"
<SETG BRIEF!-FLAG <>>
<SETG SUPER-BRIEF!-FLAG <>>

<GDECL (SUPER-BRIEF!-FLAG BRIEF!-FLAG) <OR ATOM FALSE>>

<DEFINE BRIEF ()
        <SETG BRIEF!-FLAG T>
        <TELL "Brief descriptions.">>

<DEFINE SUPER-BRIEF ()
        <SETG SUPER-BRIEF!-FLAG T>
        <TELL "No long descriptions.">>

<DEFINE UN-BRIEF ()
        <SETG BRIEF!-FLAG <>>
        <SETG SUPER-BRIEF!-FLAG <>>
        <TELL "Long descriptions.">>

<DEFINE UN-SUPER-BRIEF ()
        <SETG SUPER-BRIEF!-FLAG <>>
        <TELL "Some long descriptions.">>

<DEFINE ROOM-DESC () <ROOM-INFO T>>

<DEFINE ROOM-INFO ("OPTIONAL" (FULL <>)
                   "AUX" (AV <AVEHICLE ,WINNER>) (RM ,HERE) (PRSO <2 ,PRSVEC>)
                         (WINOBJ <FIND-OBJ "#####">) (OUTCHAN ,OUTCHAN) RA)
   #DECL ((RM) ROOM (WINOBJ) OBJECT (AV) <OR FALSE OBJECT> (OUTCHAN) CHANNEL
          (PRSO) <OR DIRECTION FALSE OBJECT> (FULL) <OR ATOM FALSE>)
   <SETG TELL-FLAG T>
   <COND (<TYPE? .PRSO DIRECTION>
          <SET PRSO <>>
          <PUT ,PRSVEC 2 <>>)>
   <PROG ()
     <COND (<N==? ,HERE <AROOM ,PLAYER>>
            <PUT ,PRSVEC 1 ,WALK-IN!-WORDS>
            <TELL "Done.">
            <RETURN>)
           (.PRSO
            <COND (<OBJECT-ACTION>)
                  (<OREAD .PRSO>
                   <TELL <OREAD .PRSO>>)
                  (<TELL "I see nothing special about the "
                         1
                         <ODESC2 .PRSO>
                         ".">)>
            <RETURN>)
           (<NOT <LIT? .RM>>
            <TELL 
"It is pitch black.  You are likely to be eaten by a grue.">
            <RETURN <>>)
           (<OR <AND <NOT .FULL> ,SUPER-BRIEF!-FLAG>
                <AND <RSEEN? .RM>
                 <OR ,BRIEF!-FLAG <PROB 80>>
                 <NOT .FULL>>>
            <TELL <RDESC2 .RM>>)
           (<AND <EMPTY? <RDESC1 .RM>> <SET RA <RACTION .RM>>>
            <PUT ,PRSVEC 1 ,LOOK!-WORDS>
            <APPLY-RANDOM .RA>
            <PUT ,PRSVEC 1 ,FOO!-WORDS>)
           (<TELL <RDESC1 .RM>>)>
     <RTRO .RM ,RSEENBIT>
     <AND .AV <TELL "You are in the " 1 <ODESC2 .AV> ".">>
     <MAPF <>
      <FUNCTION (X) 
         #DECL ((X) OBJECT)
         <COND
          (<AND <OVIS? .X> <DESCRIBABLE? .X>>
           <COND (<==? .X .AV>)
                 (T
                  <COND (<LONG-DESC-OBJ .X>
                         <AND .AV <TELL " [in the room]" 0>>
                         <CRLF>)>)>
           <COND (<TRNN .X ,ACTORBIT>
                  <INVENT <ORAND .X>>)
                 (<SEE-INSIDE? .X>
                  <PRINT-CONT
                   .X .AV .WINOBJ ,INDENTSTR <COND (.FULL)
                                                   (,SUPER-BRIEF!-FLAG <>)
                                                   (,BRIEF!-FLAG <>)
                                                   (T)>>)>)>>
      <ROBJS .RM>>
     <COND (<AND <SET RA <RACTION .RM>>
                 <NOT .FULL>>
            <PUT ,PRSVEC 1 ,WALK-IN!-WORDS>
            <APPLY-RANDOM .RA>
            <PUT ,PRSVEC 1 ,FOO!-WORDS>)>
     T>>

<PSETG INDENTSTR <REST <ISTRING 8> 8>>

<DEFINE PRINT-CONT PRINT-C (OBJ AV WINOBJ INDENT "OPTIONAL" (CASE? T)
                            "AUX" (CONT <OCONTENTS .OBJ>))
    #DECL ((AV) <OR FALSE OBJECT> (OBJ WINOBJ) OBJECT (INDENT) STRING
           (CONT) <LIST [REST OBJECT]> (CASE?) <OR ATOM FALSE>)
    <COND (<NOT <EMPTY? .CONT>>
           <COND (<==? .OBJ <FIND-OBJ "TCASE">>
                  <COND (<NOT .CASE?> <RETURN T .PRINT-C>)>
                  <TELL "Your collection of treasures consists of:">)
                 (<NOT <AND <==? <LENGTH .CONT> 1>
                            <==? <1 .CONT> <FIND-OBJ "#####">>>>
                  <TELL .INDENT 0>
                  <TELL "The " 1 <ODESC2 .OBJ> " contains:">)
                 (<RETURN T .PRINT-C>)>
           <MAPF <>
             <FUNCTION (Y) 
               #DECL ((Y) OBJECT)
               <COND (<AND .AV <==? .Y .WINOBJ>>)
                     (<AND <OVIS? .Y> <DESCRIBABLE? .Y> <NOT <EMPTY? <ODESC2 .Y>>>>
                      <TELL .INDENT 1 " A " <ODESC2 .Y>>)>
               <COND (<SEE-INSIDE? .Y>
                      <PRINT-CONT .Y .AV .WINOBJ <BACK .INDENT>>)>>
             <OCONTENTS .OBJ>>)>>

"GIVE LONG DESCRIPTION OF OBJECT"

<DEFINE LONG-DESC-OBJ (OBJ "AUX" STR) 
        #DECL ((OBJ) OBJECT)
        <COND (<OR <OTOUCH? .OBJ> <NOT <ODESCO .OBJ>>>
               <SET STR <ODESC1 .OBJ>>)
              (<SET STR <ODESCO .OBJ>>)>
        <COND (<EMPTY? .STR> <>)
              (<TELL .STR 0>)>>

"TRUE IF PARSER WON:  OTHERWISE INHIBITS OBJECT ACTIONS, CLOCKS (BUT NOT THIEF)."

<GDECL (PARSE-WON) <OR ATOM FALSE> (PARSE-CONT) <OR FALSE <VECTOR [REST STRING]>>>

<SETG PARSE-CONT <>>

<PSETG READER-STRING <STRING <ASCII 27> <ASCII 13> <ASCII 10>>>

<DEFINE RDCOM ("OPTIONAL" (IVEC <>)
               "AUX" (STR ,READER-STRING) VC RVEC RM (INPLEN 1) (INBUF ,INBUF)
                     (WINNER ,WINNER) AV (OUTCHAN ,OUTCHAN) RANDOM-ACTION PC)
   #DECL ((RVEC PC) <OR FALSE VECTOR> (RM) ROOM (INPLEN) FIX (INBUF) STRING
          (WINNER) ADV (AV) <OR FALSE OBJECT> (OUTCHAN) CHANNEL
          (IVEC) <OR FALSE VECTOR> (VC) VECTOR)
   <OR .IVEC <PROG ()
                   <PUT .OUTCHAN 13 1000>
                   <ROOM-INFO T>>>
   <REPEAT (VVAL CV)
           #DECL ((CV) <OR FALSE VERB>)
           <SET VVAL T>
           <SET PC <>>
           <COND (<SET PC ,PARSE-CONT>)
                 (<NOT .IVEC>
                  <SET RM ,HERE>
                  <PRINC ">">
                  <SETG TELL-FLAG <>>
                  <SET INPLEN <READSTRING .INBUF ,INCHAN .STR>>
                  ;"<READCHR ,INCHAN>
                  <OR ,ALT-FLAG <READCHR ,INCHAN>>"
                  <SET VC <LEX .INBUF <REST .INBUF .INPLEN> T>>)>
           <COND (<G? .INPLEN 0>
                  <SETG MOVES <+ ,MOVES 1>>
                  <COND (<SETG PARSE-WON
                               <AND <EPARSE <OR .IVEC .PC .VC> <>>
                                    <TYPE? <SET CV <1 <SET RVEC ,PRSVEC>>> VERB>>>
                         <COND (<NOT <SET RANDOM-ACTION <AACTION .WINNER>>>)
                               (<APPLY-RANDOM .RANDOM-ACTION>
                                <RETURN>)>
                         <AND <SET AV <AVEHICLE .WINNER>>
                              <SET RANDOM-ACTION <OACTION .AV>>
                              <SET VVAL <NOT <APPLY-RANDOM .RANDOM-ACTION READ-IN>>>>
                         <COND (<AND .VVAL <SET RANDOM-ACTION <VFCN .CV>>
                                     <APPLY-RANDOM .RANDOM-ACTION>>
                                <COND (<AND <SET RANDOM-ACTION <RACTION <SET RM ,HERE>>>
                                            <APPLY-RANDOM .RANDOM-ACTION>>)>)>)
                        (.IVEC
                         <COND (,TELL-FLAG
                                <TELL "Please input entire command again.">)
                               (<TELL "Nothing happens.">)>
                         <RETURN>)>
                  <OR ,TELL-FLAG <TELL "Nothing happens.">>)
                 (T <SETG PARSE-WON <>> <TELL "Beg pardon?">)>
           <MAPF <>
                 <FUNCTION (X) 
                         #DECL ((X) HACK)
                         <COND (<SET RANDOM-ACTION <HACTION .X>>
                                <APPLY-RANDOM .RANDOM-ACTION .X>)>>
                 ,DEMONS>
           <AND ,PARSE-WON
                <SET AV <AVEHICLE .WINNER>>
                <SET RANDOM-ACTION <OACTION .AV>>
                <APPLY-RANDOM .RANDOM-ACTION READ-OUT>>
           <AND .IVEC <RETURN>>>>

<DEFINE SCORE-OBJ (OBJ "AUX" TEMP) #DECL ((OBJ) OBJECT)
        <COND (<G? <SET TEMP <OFVAL .OBJ>> 0>
               <SCORE-UPD .TEMP>
               <PUT .OBJ ,OFVAL 0>)>>

<DEFINE SCORE-ROOM (RM "AUX" TEMP) #DECL ((RM) ROOM)
        <COND (<G? <SET TEMP <RVAL .RM>> 0>
               <SCORE-UPD .TEMP>
               <PUT .RM ,RVAL 0>)>>

<DEFINE SCORE-UPD (NUM "AUX" (WINNER ,WINNER) (MS ,SCORE-MAX))
        #DECL ((NUM) FIX)
        <PUT .WINNER ,ASCORE <+ <ASCORE .WINNER> .NUM>>
        <COND (<OR <G=? <SET NUM <SETG RAW-SCORE <+ ,RAW-SCORE .NUM>>> .MS>
                   <AND <1? ,DEATHS> <G=? .NUM <- .MS 10>>>>
               <CLOCK-ENABLE <CLOCK-INT ,EGHER 15>>)>>

<DEFINE END-GAME-HERALD ()
        <SETG END-GAME!-FLAG T>
        <TELL
"Suddenly a sinister wraithlike figure, cloaked and hooded, appears
seeming to float in the air before you.  In a low, almost inaudible
voice he says, \"I welcome you to the ranks of the chosen of Zork. You
have persisted through many trials and tests, and have overcome them
all.  One such as yourself is fit to join the even the Implementers!\"
He then raises his oaken staff, and chuckling, drifts away like a
wisp of smoke, his laughter fading in the distance.">
        <OR <AND <GASSIGNED? END-GAME-EXISTS?> ,END-GAME-EXISTS?>
            <TELL "
Unfortunately, as the wraith fades, in his place appears a tastefully
lettered sign reading:

              \"Soon to be Constructed on this Site
                A Complete Modern Dungeon Endgame
                    Designed and Built by the
                  Frobozz Magic Dungeon Company\"

">>>

<DEFINE SCORE ("OPTIONAL" (ASK? T) "AUX" SCOR (OUTCHAN .OUTCHAN) PCT) 
        #DECL ((ASK?) <OR ATOM FALSE> (SCOR) FIX (OUTCHAN) CHANNEL (PCT) FLOAT)
        <SETG TELL-FLAG T>
        <CRLF>
        <COND (.ASK? <PRINC 
"Your score would be ">)
              (<PRINC "Your score is ">)>
        <PRIN1 <SET SCOR
                    <ASCORE ,WINNER>>>
        <PRINC " [total of ">
        <PRIN1 ,SCORE-MAX>
        <PRINC " points], in ">
        <PRIN1 ,MOVES>
        <COND (<1? ,MOVES> <PRINC " move.">)
              (<PRINC " moves.">)>
        <CRLF>
        <PRINC "This score gives you the rank of ">
        <SET PCT </ <FLOAT .SCOR> <FLOAT ,SCORE-MAX>>>
        <PRINC <COND (<1? .PCT> "Cheater")
                     (<G? .PCT 0.95000000> "Wizard")
                     (<G? .PCT 0.89999999> "Master")
                     (<G? .PCT 0.79999999> "Winner")
                     (<G? .PCT 0.60000000> "Hacker")
                     (<G? .PCT 0.39999999> "Adventurer")
                     (<G? .PCT 0.19999999> "Junior Adventurer")
                     (<G? .PCT 0.09999999> "Novice Adventurer")
                     (<G? .PCT 0.04999999> "Amateur Adventurer")
                     ("Beginner")>>
        <PRINC ".">
        <CRLF>
        .SCOR>

<DEFINE FINISH ("OPTIONAL" (ASK? T) "AUX" SCOR) 
        #DECL ((ASK?) <OR ATOM FALSE> (SCOR) FIX)
        <UNWIND
         <PROG ()
          <SET SCOR <SCORE .ASK?>>
          <COND (<OR <AND .ASK?
                          <TELL 
"Do you wish to leave the game? (Y is affirmative): ">
                          <YES/NO <>>>
                     <NOT .ASK?>>
                 <RECORD .SCOR ,MOVES ,DEATHS .ASK? ,HERE>
                 <QUIT>)>>
         <QUIT>>>

"PRINT OUT DESCRIPTION OF LOSSAGE:  WHEN PLAYED, SCORE, # MOVES, ETC.
IF CALLED WITH CHANNEL, MUST BE FROM ERROR HANDLER--ERROR OCCURRED, GAME
WILL GO AWAY WHEN FINISHES."

<SETG RECORD-STRING <ISTRING 5>>

<GDECL (RECORD-STRING) STRING>

<PSETG RECORDER-STRING <STRING <ASCII 26> <ASCII 3> <ASCII 0>>>

<DEFINE FEECH ()
        <BUGGER T>>

<DEFINE BUGGER ("OPTIONAL" (FEECH? <>) "AUX" (DEATH? <TYPE? .FEECH? CHANNEL>)
                CT STR (CH <>) (INCHAN ,INCHAN))
    #DECL ((STR) STRING (CH) <OR FALSE <CHANNEL FIX>> (FEECH?) <OR CHANNEL ATOM FALSE>
           (INCHAN) CHANNEL (CT) FIX (DEATH?) <OR ATOM FALSE>)
    <COND (<GASSIGNED? BUGSTR>
           <SET STR ,BUGSTR>)
          (<SET STR <ISTRING 3000>>)>
    <RESET .INCHAN>
    <UNWIND
        <PROG BUGGER ()
              <COND (.DEATH?
                     <SET CH .FEECH?>
                     <SET FEECH? <>>)
                    (T <TELL "Hold on...">)>
              <COND (<AND <NOT .CH> <NOT <SET CH <RECOPEN "BUG">>>>
                     <TELL "Bug report not possible?">)
                    (<CLOSE .CH>
                     <PUT <1 <BACK .INCHAN>> 6 #LOSE 27>
                     <TELL <COND (.FEECH? "Feature") ("Bug")>
                                 1
                                 " (terminate with altmode): ">
                     <SET CT <READSTRING .STR .INCHAN %<STRING <ASCII 27>>>>
                     <READCHR .INCHAN>
                     <PUT <1 <BACK .INCHAN>> 6 <COND (<G? ,MUDDLE 100>
                                                       <COND (,TENEX? #LOSE *37*)
                                                             (T #LOSE *000000000012*)>)
                                                      (T #LOSE *000000000015*)>>
                     <COND (<==? .CT <LENGTH .STR>>
                            <TELL "Bug too long?">)>
                     <COND (<NOT <SET CH <RECOPEN "BUG">>>
                            <TELL "Bug channel can't be opened??">
                            <RETURN T .BUGGER>)>
                     <CRLF .CH>
                     <PRINC "
********                " .CH>
                     <COND (.FEECH? <PRINC "FEATURE    REQUEST" .CH>)
                           (<PRINC "BUG     REPORT" .CH>)>
                     <PRINC "            **********" .CH>
                     <CRLF .CH>
                     <PRINC ,VERS .CH>
                     <RECOUT .CH <ASCORE ,WINNER> ,MOVES ,DEATHS #FALSE (". Griping.")
                             ,HERE>
                     <COND (<NOT .FEECH?>
                            <CRLF .CH>
                            <PRINC "Winner:" .CH>
                            <PRINT ,WINNER .CH>
                            <CRLF .CH>
                            <PRINC "Trophy case:" .CH>
                            <PRINT <FIND-OBJ "TCASE"> .CH>
                            <CRLF .CH>
                            <PRINC "Robber:" .CH>
                            <PRINT ,ROBBER-DEMON .CH>
                            <CRLF .CH>
                            <PRINC "Clocker:" .CH>
                            <PRINT ,CLOCKER .CH>
                            <COND (<AND .DEATH?
                                        <ASSIGNED? ZORK>>
                                   <CRLF .CH>
                                   <PRINC "Error:" .CH>
                                   <MAPF <> <FUNCTION (X) <PRINT .X .CH>> .ZORK>)>)>
                     <PRINC "
Text:
" .CH>
                     <PRINTSTRING .STR .CH .CT>
                     <CRLF .CH>
                     <CLOSE .CH>
                     <COND (.FEECH? <TELL "Feature recorded.  Feel free.">)
                           (<TELL "Bug recorded.  Thank you.">)>)>>
        <PROG ()
              <AND .CH <NOT <0? <1 .CH>>> <CLOSE .CH>>
              <PUT <1 <BACK .INCHAN>> 6 <COND (<G? ,MUDDLE 100>
                                               <COND (,TENEX? #LOSE *37*)
                                                     (T #LOSE *000000000012*)>)
                                              (T #LOSE *000000000015*)>>>>>
        
<DEFINE RECOPEN (NAM "AUX" CH (CT 0) FL (STR ,RECORD-STRING)
                (DEV <VALUE DEV>) (SNM <VALUE SNM>) (MUDDLE ,MUDDLE))
    #DECL ((CH) <OR FALSE <CHANNEL FIX>> (MUDDLE FL CT) FIX (NAM STR DEV SNM) STRING)
    <PROG ()
          <COND (<SET CH <OPEN "READB" "ZORK" .NAM .DEV .SNM>>
                 <COND (<G=? <SET FL <FILE-LENGTH .CH>> 1>
                        <ACCESS .CH <- .FL 1>>
                        <SET CT <READSTRING .STR .CH ,RECORDER-STRING>>)>
                 <CLOSE .CH>
                 <COND (<SET CH <OPEN "PRINTO" "ZORK" .NAM .DEV .SNM>>)
                       (<AND <G? .MUDDLE 100> <==? <3 .CH> *600123*>>
                        ; "Can't win--no write access"
                          <RETURN .CH>)
                       (T <SLEEP 1> <AGAIN>)>
                 <ACCESS .CH <MAX 0 <- .FL 1>>>
                 <PRINTSTRING .STR .CH .CT>
                 .CH)
                (<OR <AND <L? .MUDDLE 100> <N==? <3 .CH> *4000000*>>
                     <AND <G? .MUDDLE 100> <==? <3 .CH> *600130*>>>
                 ;"on 10x, must get FILE BUSY to try again"
                 <SLEEP 1>
                 <AGAIN>)
                (<SET CH <OPEN "PRINT" "ZORK" .NAM .DEV .SNM>>)
                (<AND <G? .MUDDLE 100> <==? <3 .CH> *600117*>>
                 ; "No write access"
                   .CH)
                (.CH)>>>

<DEFINE RECORD (SCORE MOVES DEATHS QUIT? LOC "AUX" (CH <>))
        #DECL ((SCORE MOVES DEATHS) FIX (QUIT?) <OR ATOM FALSE> (LOC) ROOM
               (CH) <OR <CHANNEL FIX> FALSE>)
        <UNWIND
         <PROG RECORD ()
          <AND <NOT <SET CH <RECOPEN "LOG">>> <RETURN T .RECORD>> 
          <RECOUT .CH .SCORE .MOVES .DEATHS .QUIT? .LOC>
          <CRLF .CH>
          <CLOSE .CH>>
         <AND <TYPE? .CH CHANNEL> <NOT <0? <1 .CH>>> <CLOSE .CH>>>>

<DEFINE RECOUT (CH SCORE MOVES DEATHS QUIT? LOC "AUX" (OUTCHAN .CH))
        #DECL ((CH) CHANNEL (SCORE MOVES DEATHS) FIX (QUIT?) <OR ATOM FALSE>
               (LOC) ROOM (OUTCHAN) <SPECIAL CHANNEL>)
        <CRLF .CH>
        <PRINC "        " .CH>
        <PRINC ,USER-NAME .CH>
        <COND (<N=? ,USER-NAME ,XUNM>
               <PRINC "  (" .CH>
               <PRINC ,XUNM .CH>
               <PRINC !\) .CH>)>
        <PRINC "        " .CH>
        <PDSKDATE <DSKDATE> .CH>
        <CRLF .CH>
        <PLAY-TIME <>>
        <CRLF .CH>
        <PRIN1 .SCORE .CH>
        <PRINC " points, " .CH>
        <PRIN1 .MOVES .CH>
        <PRINC " move" .CH>
        <COND (<1? .MOVES> <PRINC ", " .CH>)
              (T <PRINC "s, " .CH>)>
        <PRIN1 .DEATHS .CH>
        <PRINC " death" .CH>
        <COND (<1? .DEATHS> <PRINC ". " .CH>)
              (T <PRINC "s. " .CH>)>
        <PRINC " In " .CH>
        <PRINC <RDESC2 .LOC> .CH>
        <COND (.QUIT? <PRINC ". Quit." .CH>)
              (<EMPTY? .QUIT?> <PRINC ". Died." .CH>)
              (<PRINC <1 .QUIT?> .CH>)>
        <CRLF .CH>
        <MAPF <>
              <FUNCTION (X Y)
                        #DECL ((X) ATOM (Y) STRING)
                        <COND (,.X <PRINC "/" .CH> <PRINC .Y .CH>)>>
              ,FLAG-NAMES
              ,SHORT-NAMES>
        <MAPF <>
              <FUNCTION (X Y)
                        #DECL ((X) ATOM (Y) STRING)
                        <COND (<0? ,.X> <PRINC "/" .CH> <PRINC .Y .CH>)>>
              ,VAL-NAMES
              ,SHORT-VAL-NAMES>>

FLAG-NAMES 

<GDECL (FLAG-NAMES VAL-NAMES)
       <UVECTOR [REST ATOM]>
       (SHORT-NAMES SHORT-VAL-NAMES)
       <VECTOR [REST STRING]>>

<BLOCK (<OR <GET FLAG OBLIST> <MOBLIST FLAG>> <GET INITIAL OBLIST> <ROOT>)>

<PSETG FLAG-NAMES
      <UVECTOR TROLL-FLAG
               LOW-TIDE
               DOME-FLAG
               GLACIER-FLAG
               ECHO-FLAG
               RIDDLE-FLAG
               LLD-FLAG
               CYCLOPS-FLAG
               MAGIC-FLAG
               RAINBOW
               GNOME-DOOR
               CAROUSEL-FLIP
               CAGE-SOLVE>>

<ENDBLOCK>

<PSETG SHORT-NAMES
      <VECTOR "TR" "LO" "DO" "GL" "EC"
              "RI" "LL" "CY" "MA" "RA" "GN" "CA" "CG">>

<PSETG VAL-NAMES <UVECTOR LIGHT-SHAFT>>

<PSETG SHORT-VAL-NAMES <VECTOR "LI">>

<DEFINE PDSKDATE (WD CH
                  "AUX" (TIM <CHTYPE <GETBITS .WD <BITS 18 0>> FIX>) (A/P " AM")
                        HR)
        #DECL ((WD) <PRIMTYPE WORD> (TIM HR) FIX (A/P) STRING (CH) CHANNEL)
        <PRINC " " .CH>
        <COND (<0? <CHTYPE .WD FIX>> <PRINC "unknown " .CH>)
              (T
               <PRINC <NTH ,MONTHS <CHTYPE <GETBITS .WD <BITS 4 23>> FIX>> .CH>
               <PRINC " " .CH>
               <PRIN1 <CHTYPE <GETBITS .WD <BITS 5 18>> FIX> .CH>
               <PRINC " at " .CH>
               <SET HR </ .TIM 7200>>
               <COND (<G=? .HR 12> <SET HR <- .HR 12>> <SET A/P " PM">)>
               <COND (<0? .HR> <SET HR 12>)>
               <PRIN1 .HR .CH>
               <PRINC ":" .CH>
               <SET HR </ <MOD .TIM 7200> 120>>
               <COND (<L? .HR 10> <PRINC "0" .CH>)>
               <PRIN1 .HR .CH>
               <PRINC .A/P .CH>)>>

<PSETG MONTHS
      ["January"
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
       "December"]>

<GDECL (MONTHS) <VECTOR [12 STRING]>>

<DEFINE JIGS-UP (DESC
                 "AUX" (WINNER ,WINNER) (DEATHS ,DEATHS) (AOBJS <AOBJS .WINNER>)
                       (RANDOM-LIST ,RANDOM-LIST) (LAMP <FIND-OBJ "LAMP">)
                       LAMP-LOCATION (VAL-LIST ()) LC C)
        #DECL ((DESC) STRING (DEATHS) FIX (AOBJS) <LIST [REST OBJECT]>
               (VAL-LIST) <LIST [REST OBJECT]> (LAMP-LOCATION) <OR FALSE ROOM>
               (WINNER) ADV (RANDOM-LIST) <LIST [REST ROOM]> (C LAMP) OBJECT)
  <COND
   (,DBG
    <TELL .DESC>)
   (<UNWIND
     <PROG ()
        <COND (<N==? .WINNER ,PLAYER>
               <TELL .DESC>
               <TELL "The " 1 <ODESC2 <AOBJ .WINNER>> " has died.">
               <REMOVE-OBJECT <AOBJ .WINNER>>
               <PUT .WINNER ,AROOM <FIND-ROOM "FCHMP">>
               <RETURN>)>
        <RESET ,INCHAN>
        <SCORE-UPD -10>
        <PUT .WINNER ,AVEHICLE <>>
        <COND (<G=? .DEATHS 2>
               <TELL .DESC>
               <TELL 
"You clearly are a suicidal maniac.  We don't allow psychotics in the
cave, since they may harm other adventurers.  Your remains will
installed in the Land of the Living Dead, where your fellow adventurers 
may gloat over them.">
               <FINISH <>>)
              (<SETG DEATHS <+ .DEATHS 1>>
               <TELL .DESC>
               <TELL "Do you want me to try to patch you?" 0>
               <COND (<NOT <YES/NO T>>
                      <TELL 
"What?  You don't trust me?  Why, only last week I patched a running ITS
and it survived for over 30 seconds.  Oh, well." 2>
                      <FINISH <>>)
                     (T
                      <TELL 
"Now, let me see...
Well, we weren't quite able to restore your state.  You can't have
everything.">
                      <COND (<SET LAMP-LOCATION <OROOM .LAMP>>
                             <PUT .WINNER ,AOBJS (.LAMP !.AOBJS)>
                             <COND (<MEMQ .LAMP <ROBJS .LAMP-LOCATION>>
                                    <REMOVE-OBJECT .LAMP>)
                                   (<SET LC <OCAN .LAMP>>
                                    <PUT .LC
                                         ,OCONTENTS
                                         <SPLICE-OUT .LAMP <OCONTENTS .LC>>>
                                    <PUT .LAMP ,OROOM <>>
                                    <PUT .LAMP ,OCAN <>>)>)
                            (<MEMQ .LAMP .AOBJS>
                             <PUT .WINNER ,AOBJS (.LAMP !<SPLICE-OUT .LAMP .AOBJS>)>)>
                      <TRZ <FIND-OBJ "DOOR"> ,TOUCHBIT>
                      <GOTO <FIND-ROOM "FORE1">>
                      <SETG EGYPT-FLAG!-FLAG T>
                      <SET VAL-LIST <ROB-ADV .WINNER .VAL-LIST>>
                      <COND (<MEMQ <SET C <FIND-OBJ "COFFI">> <AOBJS .WINNER>>
                             <PUT .WINNER ,AOBJS <SPLICE-OUT .C <AOBJS .WINNER>>>
                             <INSERT-OBJECT .C <FIND-ROOM "EGYPT">>)>
                      <MAPF <>
                            <FUNCTION (X Y) 
                                    #DECL ((X) OBJECT (Y) ROOM)
                                    <INSERT-OBJECT .X .Y>>
                            <SET AOBJS <AOBJS .WINNER>>
                            .RANDOM-LIST>
                      <COND (<G=? <LENGTH .RANDOM-LIST> <LENGTH .AOBJS>>
                             <SET AOBJS .VAL-LIST>)
                            (<EMPTY? .VAL-LIST>
                             <SET AOBJS <REST .AOBJS <LENGTH .RANDOM-LIST>>>)
                            (T
                             <PUTREST <REST .VAL-LIST <- <LENGTH .VAL-LIST> 1>>
                                      <REST .AOBJS <LENGTH .RANDOM-LIST>>>
                             <SET AOBJS .VAL-LIST>)>
                      <MAPF <>
                            <FUNCTION (X Y) 
                                      #DECL ((X) OBJECT (Y) ROOM)
                                      <INSERT-OBJECT .X .Y>>
                            .AOBJS
                            ,ROOMS>
                      <PUT .WINNER ,AOBJS ()>
                      T)>)>>
     <PROG ()
       <RECORD <SCORE <>> ,MOVES ,DEATHS <> ,HERE>
       <QUIT>>>)>>

<DEFINE INFO () <FILE-TO-TTY "MADADV" "INFO">>

<DEFINE HELP () <FILE-TO-TTY "MADADV" "HELP">>

<PSETG BREAKS <STRING <ASCII 3> <ASCII 0>>>

<DEFINE FILE-TO-TTY (FILE1 FILE2 "OPTIONAL" (DEV <VALUE DEV>) (SNM <VALUE SNM>)
                     "AUX" (CH <OPEN "READ" .FILE1 .FILE2 .DEV .SNM>)
                           LEN
                           (BUF ,INBUF) (BUFLEN <LENGTH .BUF>)
                           ITER)
        #DECL ((BUF FILE1 FILE2 DEV SNM) STRING (CH) <OR CHANNEL FALSE> 
               (ITER LEN BUFLEN) FIX)
        <COND (.CH
               <UNWIND
                <PROG ()
                      <SET LEN <FILE-LENGTH .CH>>
                      <SET ITER </ .LEN .BUFLEN>>
                      <OR <0? <MOD .LEN .BUFLEN>> <SET ITER <+ .ITER 1>>>
                      <CRLF ,OUTCHAN>
                      <SETG TELL-FLAG T>
                      <REPEAT (SLEN)
                              #DECL ((SLEN) FIX)
                              <COND (<1? .ITER>
                                     <SET SLEN <READSTRING .BUF .CH ,BREAKS>>)
                                    (<SET SLEN <READSTRING .BUF .CH .BUFLEN>>)>
                              <PRINTSTRING .BUF ,OUTCHAN .SLEN>
                              <COND (<0? <SET ITER <- .ITER 1>>>
                                     <CRLF ,OUTCHAN>
                                     <RETURN <CLOSE .CH>>)>>>
                <CLOSE .CH>>)
              (<TELL "File not found.">)>>

<DEFINE INVENT ("OPTIONAL" (WIN ,WINNER) "AUX" (ANY <>) (OUTCHAN ,OUTCHAN)) 
   #DECL ((ANY) <OR ATOM FALSE> (OUTCHAN) CHANNEL (WIN) ADV)
   <MAPF <>
    <FUNCTION (X) 
            #DECL ((X) OBJECT)
            <COND (<OVIS? .X>
                   <OR .ANY <PROG ()
                                  <COND (<==? .WIN ,PLAYER>
                                         <TELL "You are carrying:">)
                                        (<TELL "The "
                                               1
                                               <ODESC2 <AOBJ .WIN>>
                                               " is carrying:">)>
                                  <SET ANY T>>>
                   <TELL "A " 0 <ODESC2 .X>>
                   <COND (<OR <EMPTY? <OCONTENTS .X>> <NOT <SEE-INSIDE? .X>>>)
                         (<TELL " with " 0>
                          <PRINT-CONTENTS <OCONTENTS .X>>)>
                   <CRLF>)>>
    <AOBJS .WIN>>
   <OR .ANY <N==? .WIN ,PLAYER> <TELL "You are empty handed.">>>

<DEFINE PRINT-CONTENTS (OLST "AUX" (OUTCHAN ,OUTCHAN))
    #DECL ((OLST) <LIST [REST OBJECT]> (OUTCHAN) CHANNEL)
    <MAPR <>
        <FUNCTION (Y) 
                #DECL ((Y) <LIST [REST OBJECT]>)
                <PRINC "a ">
                <PRINC <ODESC2 <1 .Y>>>
                <COND (<G? <LENGTH .Y> 2>
                       <PRINC ", ">)
                      (<==? <LENGTH .Y> 2>
                       <PRINC ", and ">)>>
        .OLST>>


;"LIT? --
        IS THERE ANY LIGHT SOURCE IN THIS ROOM"

<DEFINE LIT? (RM "AUX" (WIN ,WINNER))
        #DECL ((RM) ROOM (WIN) ADV)
        <OR <RLIGHT? .RM>
            <LFCN <ROBJS .RM>>
            <LFCN <AOBJS .WIN>>
            <AND <N==? .WIN ,PLAYER>
                 <==? ,HERE <AROOM ,PLAYER>>
                 <LFCN <AOBJS ,PLAYER>>>>>

<DEFINE LFCN LFCN (L "AUX" Y) 
        #DECL ((L) <LIST [REST OBJECT]> (Y) ADV)
        <MAPF <>
              <FUNCTION (X) 
                      #DECL ((X) OBJECT)
                      <AND <TRNN .X ,ONBIT> <MAPLEAVE T>>
                      <COND (<AND <OVIS? .X>
                                  <OR <OOPEN? .X>
                                      <TRANSPARENT? .X>>>
                             <MAPF <>
                               <FUNCTION (X) #DECL ((X) OBJECT)
                                 <COND (<TRNN .X ,ONBIT>
                                        <RETURN T .LFCN>)>>
                               <OCONTENTS .X>>)>
                      <COND (<AND <TRNN .X ,ACTORBIT>
                                  <LFCN <AOBJS <SET Y <ORAND .X>>>>>
                             <MAPLEAVE T>)>>
              .L>>

;"WALK --
        GIVEN A DIRECTION, WILL ATTEMPT TO WALK THERE"

<DEFINE WALK ("AUX" LEAVINGS NRM (WHERE <CHTYPE <2 ,PRSVEC> ATOM>) (ME ,WINNER)
                    (RM <1 .ME>) NL RANDOM-ACTION CXS)
        #DECL ((WHERE) ATOM (ME) ADV (RM) ROOM
               (LEAVINGS) <OR ATOM ROOM CEXIT DOOR NEXIT>
               (NRM) <OR FALSE
                         <<PRIMTYPE VECTOR> [REST ATOM <OR ROOM NEXIT CEXIT DOOR>]>>
               (NL) <OR ATOM ROOM FALSE>)
        <COND (<AND <==? .ME ,PLAYER> <NOT <LIT? .RM>> <PROB 75>>
               <COND (<SET NRM <MEMQ .WHERE <REXITS .RM>>>
                      <SET LEAVINGS <2 .NRM>>
                      <COND (<AND <TYPE? .LEAVINGS ROOM> <LIT? .LEAVINGS>>
                             <AND <GOTO .LEAVINGS> <ROOM-INFO <>>>)
                            (<AND <TYPE? .LEAVINGS CEXIT>
                                  <SET LEAVINGS
                                       <COND (<AND <SET RANDOM-ACTION
                                                        <CXACTION .LEAVINGS>>
                                                   <APPLY-RANDOM .RANDOM-ACTION>>)
                                             (,<CXFLAG .LEAVINGS>
                                              <CXROOM .LEAVINGS>)>>
                                  <AND <TYPE? .LEAVINGS ROOM> <LIT? .LEAVINGS>>>
                             <AND <GOTO .LEAVINGS> <ROOM-INFO <>>>)
                            (<AND <TYPE? .LEAVINGS DOOR>
                                  <SET LEAVINGS
                                       <COND (<AND <SET RANDOM-ACTION
                                                        <DACTION .LEAVINGS>>
                                                   <APPLY-RANDOM .RANDOM-ACTION>>)
                                             (<OOPEN? <DOBJ .LEAVINGS>>
                                              <GET-DOOR-ROOM .RM .LEAVINGS>)>>
                                  <LIT? .LEAVINGS>>
                             <AND <GOTO .LEAVINGS> <ROOM-INFO <>>>)
                            (<JIGS-UP 
"Oh, no!  A fearsome grue slithered into the room and devoured you.">)>)
                     (<JIGS-UP 
"Oh, no!  You walked into the slavering fangs of a lurking grue.">)>)
              (<SET NRM <MEMQ .WHERE <REXITS .RM>>>
               <SET LEAVINGS <2 .NRM>>
               <COND (<TYPE? .LEAVINGS ROOM> <AND <GOTO .LEAVINGS> <ROOM-INFO <>>>)
                     (<TYPE? .LEAVINGS CEXIT>
                      <COND (<OR <AND <SET RANDOM-ACTION <CXACTION .LEAVINGS>>
                                      <SET NL <APPLY-RANDOM .RANDOM-ACTION>>>
                                 <AND ,<CXFLAG .LEAVINGS>
                                      <SET NL <CXROOM .LEAVINGS>>>>
                             <OR <TYPE? .NL ATOM> <AND <GOTO .NL> <ROOM-INFO <>>>>)
                            (<SET CXS <CXSTR .LEAVINGS>>
                             <OR <EMPTY? .CXS>
                                 <TELL .CXS>>)
                            (<TELL "You can't go that way.">)>)
                     (<TYPE? .LEAVINGS DOOR>
                      <COND (<OR <AND <SET RANDOM-ACTION <DACTION .LEAVINGS>>
                                      <COND (<SET NL <APPLY-RANDOM .RANDOM-ACTION>>
                                             <COND (<TYPE? .NL ATOM>
                                                    <SET NL
                                                         <GET-DOOR-ROOM .RM
                                                                        .LEAVINGS>>)>)>>
                                 <AND <OOPEN? <DOBJ .LEAVINGS>>
                                      <SET NL <GET-DOOR-ROOM .RM .LEAVINGS>>>>
                             <AND <GOTO .NL> <ROOM-INFO <>>>)
                            (<SET CXS <DSTR .LEAVINGS>>
                             <TELL .CXS>)
                            (<TELL "The " 1 <ODESC2 <DOBJ .LEAVINGS>> " is closed.">)>)
                     (T <TELL .LEAVINGS>)>)
              (<TELL "You can't go that way.">)>>

<DEFINE TAKE ("OPTIONAL" (TAKE? T)
              "AUX" (WIN ,WINNER) (VEC ,PRSVEC) (RM <AROOM .WIN>) NOBJ
                    (OBJ <2 .VEC>) (GETTER? <>) (ROBJS <ROBJS .RM>)
                    (AOBJS <AOBJS .WIN>) (LOAD-MAX ,LOAD-MAX))
   #DECL ((WIN) ADV (VEC) VECTOR (OBJ NOBJ) OBJECT (RM) ROOM
          (GETTER? TAKE?) <OR ATOM FALSE> (LOAD-MAX) FIX 
          (ROBJS AOBJS) <LIST [REST OBJECT]>)
   <PROG ()
         <COND (<TRNN .OBJ ,NO-CHECK-BIT>
                <RETURN <OBJECT-ACTION>>)>
         <COND (<STAR? .OBJ>
                <RETURN <OBJECT-ACTION>>)>
         <COND (<OCAN .OBJ>
                <SET NOBJ <OCAN .OBJ>>
                <COND (<SEE-INSIDE? .NOBJ>
                       <COND (<OOPEN? .NOBJ> <SET GETTER? T>)
                             (<TELL "I can't reach that."> <RETURN <>>)>)
                      (<TELL "I can't see one here."> <RETURN <>>)>)>
         <COND
          (<==? .OBJ <AVEHICLE .WIN>>
           <TELL "You are in it, loser!">
           <RETURN <>>)
          (<NOT <CAN-TAKE? .OBJ>>
           <OR <APPLY-OBJECT .OBJ> <TELL <PICK-ONE ,YUKS>>>
           <RETURN <>>)
          (<OR .GETTER? <MEMQ .OBJ .ROBJS>>
           <SET LOAD-MAX <+ .LOAD-MAX <FIX <* </ 1.0 .LOAD-MAX> <ASTRENGTH .WIN>>>>>
           <COND (<AND .GETTER? <MEMQ .NOBJ .AOBJS>>)
                 (<G? <+ <WEIGHT .AOBJS> <WEIGHT <OCONTENTS .OBJ>> <OSIZE .OBJ>>
                      .LOAD-MAX>
                  <TELL 
"Your load is too heavy.  You will have to leave something behind.">
                  <RETURN <>>)>
           <COND (<NOT <APPLY-OBJECT .OBJ>>
                  <COND (.GETTER?
                         <PUT .NOBJ
                              ,OCONTENTS
                              <SPLICE-OUT .OBJ <OCONTENTS .NOBJ>>>
                         <PUT .OBJ ,OROOM <>>
                         <PUT .OBJ ,OCAN <>>)
                        (<REMOVE-OBJECT .OBJ>)>
                  <PUT .WIN ,AOBJS (.OBJ !.AOBJS)>
                  <TRO .OBJ ,TOUCHBIT>
                  <SCORE-OBJ .OBJ>
                  <COND (.TAKE? <TELL "Taken.">) (T)>)
                 (T)>)
          (<MEMQ .OBJ .AOBJS> <TELL "You already have it.">)>>>

<DEFINE PUTTER ("OPTIONAL" (OBJACT T) 
                "AUX" (PV ,PRSVEC) (OBJO <2 .PV>) (OBJI <3 .PV>) (WIN ,WINNER)
                (AOBJS <AOBJS .WIN>) CROCK CAN (ROBJS <ROBJS ,HERE>)
                (OCAN <>))
        #DECL ((PV) <VECTOR [3 ANY]> (OBJO OBJI) OBJECT (WIN) ADV
               (AOBJS ROBJS) <LIST [REST OBJECT]> (CROCK CAN) OBJECT
               (OCAN) <OR FALSE OBJECT> (OBJACT) <OR ATOM FALSE>)
        <PROG ()
              <COND (<TRNN .OBJO ,NO-CHECK-BIT>
                     <RETURN <OBJECT-ACTION>>)>
              <COND (<OR <STAR? .OBJO>
                         <STAR? .OBJI>>
                     <RETURN <OR <OBJECT-ACTION>
                                 <TELL "Nice try.">>>)>
              <COND (<OR <OOPEN? .OBJI>
                         <OPENABLE? .OBJI>
                         <TRNN .OBJI ,VEHBIT>>
                     <SET CAN .OBJI>
                     <SET CROCK .OBJO>)
                    (<TELL "I can't do that."> <RETURN <>>)>
              <COND (<NOT <OOPEN? .CAN>>
                     <TELL "I can't reach inside.">
                     <RETURN <>>)
                    (<==? .CAN .CROCK>
                     <TELL "How can you do that?">
                     <RETURN <>>)
                    (<==? <OCAN .CROCK> .CAN>
                     <TELL "The " 0 <ODESC2 .CROCK> " is already in the ">
                     <TELL <ODESC2 .CAN>>
                     <RETURN T>)
                    (<G? <+ <WEIGHT <OCONTENTS .CAN>>
                            <WEIGHT <OCONTENTS .CROCK>>
                            <OSIZE .CROCK>>
                         <OCAPAC .CAN>>
                     <TELL "It won't fit.">
                     <RETURN <>>)>
              <COND (<OR <MEMQ .CROCK .ROBJS>
                         <AND <SET OCAN <OCAN .CROCK>>
                              <MEMQ .OCAN .ROBJS>>
                         <AND .OCAN
                              <SET OCAN <OCAN .OCAN>>
                              <MEMQ .OCAN .ROBJS>>>
                     <PUT .PV 1 ,TAKE!-WORDS>
                     <PUT .PV 2 .CROCK>
                     <PUT .PV 3 <>>
                     <COND (<NOT <TAKE <>>> <RETURN <>>)
                           (<SET AOBJS <AOBJS .WIN>>)>)
                    (<SET OCAN <OCAN .CROCK>>
                     <COND (<OOPEN? .OCAN>
                            <SCORE-OBJ .CROCK>
                            <PUT .WIN ,AOBJS <SET AOBJS (.CROCK !.AOBJS)>>
                            <PUT .OCAN
                                 ,OCONTENTS
                                 <SPLICE-OUT .CROCK <OCONTENTS .OCAN>>>
                            <PUT .CROCK ,OCAN <>>)
                           (<TELL "I can't reach the " 1 <ODESC2 .CROCK>>
                            <RETURN <>>)>)>
              <PUT .PV 1 ,PUT!-WORDS>
              <PUT .PV 2 .CROCK>
              <PUT .PV 3 .CAN>
              <COND (<AND .OBJACT <OBJECT-ACTION>> <RETURN>)
                    (<PUT .WIN ,AOBJS <SPLICE-OUT .CROCK .AOBJS>>
                     <PUT .CAN ,OCONTENTS (.CROCK !<OCONTENTS .CAN>)>
                     <PUT .CROCK ,OCAN .CAN>
                     <PUT .CROCK ,OROOM ,HERE>
                     <TELL "Done.">)>>>
 
<DEFINE DROPPER ("AUX" (WINNER ,WINNER) (AV <AVEHICLE .WINNER>)
                    (AOBJS <AOBJS .WINNER>) (GETTER? <>) (VEC ,PRSVEC)
                    (RM <AROOM .WINNER>) (OBJ <2 .VEC>) (PI <3 .VEC>)  NOBJ)
        #DECL ((VEC) <VECTOR VERB OBJECT <OR FALSE OBJECT>>
               (OBJ NOBJ) OBJECT (PI AV) <OR FALSE OBJECT>
               (RM) ROOM (GETTER?) <OR ATOM FALSE>)
        <PROG ()
              <COND (<TRNN .OBJ ,NO-CHECK-BIT>
                     <RETURN <OBJECT-ACTION>>)>
              <COND (<AND <OCAN .OBJ> <SET NOBJ <OCAN .OBJ>> <MEMQ .NOBJ .AOBJS>>
                     <COND (<OOPEN? .NOBJ> <SET GETTER? T>)
                           (<TELL "I can't reach that.">
                            <RETURN>)>)>
              <COND (<OR .GETTER? <MEMQ .OBJ .AOBJS>>
                     <COND (.AV)
                           (.GETTER?
                            <PUT .NOBJ
                                 ,OCONTENTS
                                 <SPLICE-OUT .OBJ <OCONTENTS .NOBJ>>>
                            <PUT .OBJ ,OCAN <>>)
                           (<PUT .WINNER ,AOBJS <SPLICE-OUT .OBJ .AOBJS>>)>
                     <COND (.AV <PUT .VEC 2 .OBJ> <PUT .VEC 3 .AV> <PUTTER <>>)
                           (<INSERT-OBJECT .OBJ .RM>)>
                     <COND (<OBJECT-ACTION>)
                           (<==? <VNAME <1 .VEC>> DROP!-WORDS>
                            <TELL "Dropped.">)
                           (<==? <VNAME <1 .VEC>> THROW!-WORDS>
                            <TELL "Thrown.">)>)
                    (<TELL "You are not carrying that.">)>>>


"STUFF FOR 'EVERYTHING' AND 'VALUABLES'"
<SETG OBJ-UV <CHUTYPE <REST <IUVECTOR 20> 20> OBJECT>>
<GDECL (OBJ-UV) <UVECTOR [REST OBJECT]>>

<DEFINE FROB-LOTS FL (UV "AUX" (PRSVEC ,PRSVEC) (PA <1 .PRSVEC>) (RA <VFCN .PA>) PI
                   (WINNER ,WINNER) (HERE ,HERE))
  #DECL ((UV) <UVECTOR [REST OBJECT]> (PRSVEC) <VECTOR VERB [2 ANY]>
         (PA) VERB (RA) RAPPLIC (PI) <OR OBJECT FALSE> (WINNER) ADV (HERE) ROOM)
  <COND (<==? .PA ,TAKE!-WORDS>
         <COND (<NOT <LIT? .HERE>>
                <TELL "It is too dark in here to see.">
                <RETURN T .FL>)>
         <MAPF <>
           <FUNCTION (X) #DECL ((X) OBJECT)
             <COND (<OR <CAN-TAKE? .X>
                        <TRNN .X ,TRYTAKEBIT>>
                    <PUT .PRSVEC 2 .X>
                    <TELL <ODESC2 .X> 0 ":
  ">
                    <APPLY-RANDOM .RA>
                    <COND (<N==? .HERE <AROOM .WINNER>>
                           <MAPLEAVE>)>)>>
           .UV>)
        (<OR <==? .PA ,DROP!-WORDS>
             <==? .PA ,PUT!-WORDS>>
         <COND (<AND <==? .PA ,PUT!-WORDS>
                     <3 .PRSVEC>
                     <NOT <LIT? .HERE>>>
                <TELL "It is too dark in here to see.">
                <RETURN T .FL>)>
         <MAPF <>
           <FUNCTION (X) #DECL ((X) OBJECT)
             <PUT .PRSVEC 2 .X>
             <TELL <ODESC2 .X> 0 ":
  ">
             <APPLY-RANDOM .RA>
             <COND (<N==? .HERE <AROOM .WINNER>>
                    <MAPLEAVE>)>>
           .UV>)>
  T>

<PSETG LOSSTR "I can't do everything, because I ran out of room.">

<DEFINE VALUABLES&C ("AUX" (PRSVEC ,PRSVEC)
                    (PA <1 .PRSVEC>) (SUV ,OBJ-UV) (TUV <TOP .SUV>) PI
                    (LU <LENGTH .TUV>) (HERE ,HERE) (WINNER ,WINNER)
                    (EVERYTHING? <==? <2 .PRSVEC> <FIND-OBJ "EVERY">>))
  #DECL ((PA) VERB (SUV TUV) <UVECTOR [REST OBJECT]> (LU) FIX (HERE) ROOM
         (WINNER) ADV (PI) OBJECT (EVERYTHING?) <OR ATOM FALSE>)
  <COND (<==? .PA ,TAKE!-WORDS>
         <MAPF <>
           <FUNCTION (X) #DECL ((X) OBJECT)
             <COND (<AND <OVIS? .X>
                         <NOT <TRNN .X ,ACTORBIT>>
                         <OR .EVERYTHING? <NOT <0? <OTVAL .X>>>>>
                    <COND (<==? .SUV .TUV>
                           <TELL ,LOSSTR>
                           <MAPLEAVE>)>
                    <SET SUV <BACK .SUV>>
                    <PUT .SUV 1 .X>)>>
           <ROBJS .HERE>>)
        (<==? .PA ,DROP!-WORDS>
         <MAPF <>
           <FUNCTION (X) #DECL ((X) OBJECT)
             <COND (<OR .EVERYTHING? <NOT <0? <OTVAL .X>>>>
                    <SET SUV <BACK .SUV>>
                    <PUT .SUV 1 .X>)>>
           <AOBJS .WINNER>>)
        (<==? .PA ,PUT!-WORDS>
         <SET PI <3 .PRSVEC>>
         <PROG RP ()
           <MAPF <>
             <FUNCTION (X) #DECL ((X) OBJECT)
               <COND (<AND <==? .SUV .TUV>
                           <N==? .X .PI>>
                      <TELL ,LOSSTR>
                      <RETURN T .RP>)>
               <COND (<AND <OVIS? .X>
                           <OR .EVERYTHING? <NOT <0? <OTVAL .X>>>>>
                      <SET SUV <BACK .SUV>>
                      <PUT .SUV 1 .X>)>>
             <ROBJS .HERE>>
           <MAPF <>
             <FUNCTION (X) #DECL ((X) OBJECT)
               <COND (<AND <==? .SUV .TUV>
                           <N==? .X .PI>>
                      <TELL ,LOSSTR>
                      <RETURN T .RP>)>
               <COND (<OR .EVERYTHING? <NOT <0? <OTVAL .X>>>>
                      <SET SUV <BACK .SUV>>
                      <PUT .SUV 1 .X>)>>
             <AOBJS .WINNER>>>)>
  <COND (<EMPTY? .SUV>
         <TELL "I couldn't find any" 1 <COND (.EVERYTHING? "thing.")
                                             (T " valuables.")>>)
        (<FROB-LOTS .SUV>)>>



<DEFINE OPENER OPEN-ACT ("AUX" (PV ,PRSVEC) (PRSO <2 .PV>) (OUTCHAN ,OUTCHAN)) 
        #DECL ((PRSO) OBJECT (PV) <VECTOR [3 ANY]> (OUTCHAN) CHANNEL)
        <COND (<OBJECT-ACTION>)
              (<NOT <TRNN .PRSO ,CONTBIT>>
               <TELL "You must tell me how to do that to a " 1 <ODESC2 .PRSO> ".">)
              (<N==? <OCAPAC .PRSO> 0>
               <COND (<OOPEN? .PRSO> <TELL "It is already open.">)
                     (T
                      <TRO .PRSO ,OPENBIT>
                      <COND (<OR <EMPTY? <OCONTENTS .PRSO>>
                                 <TRANSPARENT? .PRSO>>
                             <TELL "Opened.">)
                            (<SETG TELL-FLAG T>
                             <TELL "Opening the " 0 <ODESC2 .PRSO> " reveals ">
                             <PRINT-CONTENTS <OCONTENTS .PRSO>>
                             <PRINC !\.>
                             <CRLF>)>)>)
              (<TELL "The " 1 <ODESC2 .PRSO> " cannot be opened.">)>>

<DEFINE CLOSER CLOSE-ACT ("AUX" (PV ,PRSVEC) (PRSO <2 .PV>)) 
        #DECL ((PV) <VECTOR [3 ANY]> (PRSO) OBJECT)
        <COND (<OBJECT-ACTION>)
              (<NOT <TRNN .PRSO ,CONTBIT>>
               <TELL "You must tell me how to do that to a " 1 <ODESC2 .PRSO> ".">)
              (<N==? <OCAPAC .PRSO> 0>
               <COND (<OOPEN? .PRSO> <TRZ .PRSO ,OPENBIT> <TELL "Closed.">)
                     (T <TELL "It is already closed.">)>)
              (<TELL "You cannot close that.">)>>

<DEFINE FIND ("AUX" (PRSO <2 ,PRSVEC>))
  #DECL ((PRSO) <OR FALSE OBJECT>)
  <COND (<OBJECT-ACTION>)
        (.PRSO
         <FIND-FROB .PRSO
                    <ROBJS ,HERE>
                    ", which is in the room."
                    "There is a "
                    " here.">
         <FIND-FROB .PRSO
                    <AOBJS ,WINNER>
                    ", which you are carrying."
                    "You are carrying a "
                    ".">)>>

<DEFINE FIND-FROB (PRSO OBJL STR1 STR2 STR3)
  #DECL ((OBJ) OBJECT (OBJL) <LIST [REST OBJECT]> (STR1 STR2 STR3) STRING)
  <MAPF <>
        <FUNCTION (X) #DECL ((X) OBJECT)
                  <COND (<==? .X .PRSO>
                         <TELL .STR2 1 <ODESC2 .X> .STR3>)
                        (<OR <TRANSPARENT? .X>
                             <AND <OPENABLE? .X> <OOPEN? .X>>>
                         <MAPF <>
                               <FUNCTION (Y) #DECL ((Y) OBJECT)
                                         <COND (<==? .Y .PRSO>
                                                <TELL .STR2 1 <ODESC2 .Y> .STR3>
                                                <TELL "It is in the "
                                                      1
                                                      <ODESC2 .X>
                                                      .STR1>)>>
                               <OCONTENTS .X>>)>>
         .OBJL>>

;"OBJECT-ACTION --
        CALL OBJECT FUNCTIONS FOR DIRECT AND INDIRECT OBJECTS"

<DEFINE OBJECT-ACTION ("AUX" (VEC ,PRSVEC) (PRSO <2 .VEC>) (PRSI <3 .VEC>)) 
        #DECL ((PRSO PRSI) <OR OBJECT FALSE> (VEC) VECTOR)
        <PROG ()
              <COND (.PRSI <AND <APPLY-OBJECT .PRSI> <RETURN T>>)>
              <COND (.PRSO <APPLY-OBJECT .PRSO>)>>>

"SIMPLE OBJ-HERE:  IS IT IN THE ROOM OR IN THE GUY'S HAND.  TO DO FULL
SEARCH, USE GET-OBJECT"

<DEFINE OBJ-HERE? (OBJ "AUX" NOBJ (RM ,HERE) (WIN ,WINNER)) 
        #DECL ((OBJ) OBJECT (RM) ROOM (WIN) ADV (NOBJ) <OR FALSE OBJECT>)
        <PROG ()
              <COND (<NOT <OVIS? .OBJ>> <RETURN <>>)
                    (<SET NOBJ <OCAN .OBJ>>
                     <COND (<OOPEN? .NOBJ> <SET OBJ .NOBJ>) (<RETURN <>>)>)>
              <OR <MEMQ .OBJ <ROBJS .RM>> <MEMQ .OBJ <AOBJS .WIN>>>>>

<DEFINE SPLICE-OUT (OBJ AL) 
        #DECL ((AL) LIST)
        <COND (<==? <1 .AL> .OBJ> <REST .AL>)
              (T
               <REPEAT ((NL <REST .AL>) (OL .AL))
                       #DECL ((NL OL) LIST)
                       <COND (<==? <1 .NL> .OBJ>
                              <PUTREST .OL <REST .NL>>
                              <RETURN .AL>)
                             (<SET OL .NL> <SET NL <REST .NL>>)>>)>>

"WEIGHT:  Get sum of OSIZEs of supplied list, recursing to the nth level."

<DEFINE WEIGHT (OBJL "AUX" (BIGFIX ,BIGFIX)) 
        #DECL ((OBJL) <LIST [REST OBJECT]> (BIGFIX) FIX (VALUE) FIX)
        <MAPF ,+
              <FUNCTION (OBJ) 
                      #DECL ((OBJ) OBJECT)
                      <+ <COND (<==? <OSIZE .OBJ> ,BIGFIX> 0)
                               (<OSIZE .OBJ>)>
                         <WEIGHT <OCONTENTS .OBJ>>>>
              .OBJL>>

<DEFINE MOVE ("AUX" (VEC ,PRSVEC) (RM <AROOM ,WINNER>) (OBJ <2 .VEC>)) 
        #DECL ((VEC) VECTOR (RM) ROOM (OBJ) <OR ATOM OBJECT>)
        <COND (<MEMQ .OBJ <ROBJS .RM>>
               <COND (<OBJECT-ACTION>)
                     (<TELL "You can't move the " 1 <ODESC2 .OBJ> ".">)>)
              (.OBJ
               <TELL "I can't get to that to move it.">)>>

<DEFINE VICTIMS? (RM) 
        #DECL ((RM) ROOM)
        <MAPF <>
              <FUNCTION (X) 
                      #DECL ((X) OBJECT)
                      <COND (<TRNN .X ,VICBIT> <MAPLEAVE .X>)>>
              <ROBJS .RM>>>

<DEFINE LAMP-ON LAMPO ("AUX" (PRSVEC ,PRSVEC) (ME ,WINNER) (OBJ <2 .PRSVEC>) (LIT?
                                                             <LIT? ,HERE>)) 
        #DECL ((ME) ADV (OBJ) OBJECT (LAMPO) ACTIVATION)
                  <COND (<OBJECT-ACTION>)
              (<COND (<AND <TRNN .OBJ ,LIGHTBIT>
                           <MEMQ .OBJ <AOBJS .ME>>>)
                     (T <TELL "You can't turn that on."> <RETURN T .LAMPO>)>
               <COND (<TRNN .OBJ ,ONBIT> <TELL "It is already on.">)
                     (<TRO .OBJ ,ONBIT>
                      <TELL "The " 1 <ODESC2 .OBJ> " is now on.">
                      <COND (<NOT .LIT?>
                             <PUT ,PRSVEC 2 <>>
                             <ROOM-INFO <>>)>)>)>>

<DEFINE LAMP-OFF LAMPO ("AUX" (ME ,WINNER) (OBJ <2 ,PRSVEC>)) 
        #DECL ((ME) ADV (OBJ) OBJECT (LAMPO) ACTIVATION)
        <COND (<OBJECT-ACTION>)
              (<COND (<AND <TRNN .OBJ ,LIGHTBIT>
                           <MEMQ .OBJ <AOBJS .ME>>>)
                     (<TELL "You can't turn that off."> <RETURN T .LAMPO>)>
               <COND (<NOT <TRNN .OBJ ,ONBIT>> <TELL "It is already off.">)
                     (<TRZ .OBJ ,ONBIT>
                      <TELL "The " 1 <ODESC2 .OBJ> " is now off.">
                      <OR <LIT? ,HERE> <TELL "It is now pitch black.">>)>)>>

<DEFINE WAIT ("OPTIONAL" (NUM 3))
    #DECL ((NUM) FIX)
    <TELL "Time passes...">
    <REPEAT ((N .NUM))
        #DECL ((N) FIX)
        <COND (<OR <L? <SET N <- .N 1>> 0>
                   <CLOCK-DEMON ,CLOCKER>>
               <RETURN>)>>>

"RUNS ONLY IF PARSE WON, TO PREVENT SCREWS FROM TYPOS."

<DEFINE CLOCK-DEMON (HACK "AUX" CA (FLG <>))
    #DECL ((HACK) HACK (FLG) <OR ATOM FALSE>)
    <COND (,PARSE-WON
           <PUT ,PRSVEC 2 <>>
           <PUT ,PRSVEC 3 <>>
           <MAPF <>
                 <FUNCTION (EV "AUX" (TICK <CTICK .EV>))
                           #DECL ((EV) CEVENT (TICK) FIX)
                           <COND (<NOT <CFLAG .EV>>)
                                 (<0? .TICK>)
                                 (<L? .TICK 0>
                                  <PUT ,PRSVEC 1 ,C-INT!-WORDS>
                                  <COND (<TYPE? <SET CA <CACTION .EV>> NOFFSET>
                                         <DISPATCH .CA>)
                                        (<APPLY .CA>)>)
                                 (<PUT .EV ,CTICK <SET TICK <- .TICK 1>>>
                                  <AND <0? .TICK>
                                       <SET FLG T>
                                       <PUT ,PRSVEC 1 ,C-INT!-WORDS>
                                       <COND (<TYPE? <SET CA <CACTION .EV>> NOFFSET>
                                              <DISPATCH .CA>)
                                             (<APPLY .CA>)>>)>>
                 <HOBJS .HACK>>)>
    .FLG>

<GDECL (CLOCKER) HACK>

<DEFINE CLOCK-INT (CEV "OPTIONAL" (NUM <>) (FLAG? <>) "AUX" (CLOCKER ,CLOCKER))
    #DECL ((CEV) CEVENT (NUM) <OR FIX FALSE> (CLOCKER) HACK (FLAG?) <OR ATOM FALSE>)
    <COND (<NOT <MEMQ .CEV <HOBJS .CLOCKER>>>
           <PUT .CLOCKER ,HOBJS (.CEV !<HOBJS .CLOCKER>)>)>
    <COND (.FLAG?
           <PUT .CEV ,CFLAG T>)>
    <COND (.NUM <PUT .CEV ,CTICK .NUM>)>>

<SETG DEMONS ()>

<OR <LOOKUP "COMPILE" <ROOT>>
    <GASSIGNED? GROUP-GLUE>
    <ADD-DEMON <SETG CLOCKER <CHTYPE [CLOCK-DEMON ()] HACK>>>>

<DEFINE BOARD ("AUX" (OBJ <2 ,PRSVEC>) (WIN ,WINNER) (AV <AVEHICLE .WIN>)) 
        #DECL ((OBJ) OBJECT (WIN) ADV (AV) <OR FALSE OBJECT>)
        <COND (<NOT <MEMQ .OBJ <ROBJS ,HERE>>>
               <TELL "The " 1 <ODESC2 .OBJ> " must be on the ground to be boarded.">)
              (<TRNN .OBJ ,VEHBIT>
               <COND (.AV
                      <TELL "You are already in the "
                            1
                            <ODESC2 .OBJ>
                            ", cretin!">)
                     (T
                      <COND (<OBJECT-ACTION>)
                            (<TELL "You are now in the " 1 <ODESC2 .OBJ> ".">
                             <PUT .WIN ,AVEHICLE .OBJ>
                             <PUT .OBJ
                                  ,OCONTENTS
                                  (<FIND-OBJ "#####"> !<OCONTENTS .OBJ>)>)>)>)
              (<TELL "I suppose you have a theory on boarding "
                     1
                     <ODESC2 .OBJ>
                     "s.">)>>

<DEFINE UNBOARD ("AUX" (OBJ <2 ,PRSVEC>) (WIN ,WINNER) (AV <AVEHICLE .WIN>))
        #DECL ((OBJ) OBJECT (WIN) ADV (AV) <OR FALSE OBJECT>)
        <COND (<==? .AV .OBJ>
               <COND (<OBJECT-ACTION>)
                     (<RTRNN ,HERE ,RLANDBIT>
                      <TELL
"You are on your own feet again.">
                      <PUT .WIN ,AVEHICLE <>>
                      <PUT .OBJ
                           ,OCONTENTS
                           <SPLICE-OUT <FIND-OBJ "#####"> <OCONTENTS .OBJ>>>)
                     (<TELL
"You realize, just in time, that disembarking here would probably be
fatal.">)>)
              (<TELL
"You aren't in that!">)>>

<DEFINE GOTO (RM
              "AUX" (WIN ,WINNER) (AV <AVEHICLE ,WINNER>) (HERE ,HERE)
                    (LB <RTRNN .RM ,RLANDBIT>))
        #DECL ((HERE RM) ROOM (WIN) ADV (AV) <OR FALSE OBJECT>
               (LB) <OR ATOM FALSE>)
        <COND (<OR <AND <NOT .LB> <OR <NOT .AV> <NOT <RTRNN .RM <ORAND .AV>>>>>
                   <AND <RTRNN .HERE ,RLANDBIT>
                        .LB
                        .AV
                        <N==? <ORAND .AV> ,RLANDBIT>
                        <NOT <RTRNN .RM <ORAND .AV>>>>>
               <COND (.AV <TELL "You can't go there in a " 1 <ODESC2 .AV> ".">)
                     (<TELL "You can't go there without a vehicle.">)>
               <>)
              (<RTRNN .RM ,RMUNGBIT> <TELL <RRAND .RM>>)
              (T
               <COND (<N==? .WIN ,PLAYER>
                      <REMOVE-OBJECT <AOBJ .WIN>>
                      <INSERT-OBJECT <AOBJ .WIN> .RM>)>
               <COND (.AV <REMOVE-OBJECT .AV> <INSERT-OBJECT .AV .RM>)>
               <PUT ,WINNER ,AROOM <SETG HERE .RM>>
               <SCORE-ROOM .RM>
               T)>>

<DEFINE BACKER ()
        <TELL
"He who puts his hand to the plow and looks back is not fit for the
kingdom of winners.  In any case, \"back\" doesn't work.">>

<DEFINE MUNG-ROOM (RM STR)
    #DECL ((RM) ROOM (STR) STRING)
    <RTRO .RM ,RMUNGBIT>
    <PUT .RM ,RRAND .STR>>

<DEFINE COMMAND ("AUX" (PV ,PRSVEC) (PO <2 .PV>) (HS ,HERE)
                    (WIN ,WINNER) (PLAY ,PLAYER) (LV ,LEXV) V)
    #DECL ((PO) OBJECT (PV V) VECTOR (HS) ROOM (WIN PLAY) ADV
           (LV) <VECTOR [REST STRING]>)
    <SET V <REST <MEMBER "" .LV>>>
    <COND (<N==? .WIN .PLAY>
           <TELL "You cannot talk through another person!">)
          (<TRNN .PO ,ACTORBIT>
           <SETG WINNER <ORAND .PO>>
           <SETG HERE <AROOM ,WINNER>>
           <RDCOM .V>
           <SETG WINNER .PLAY>
           <SETG HERE .HS>)
          (<TELL "You cannot talk to that!">)>>

