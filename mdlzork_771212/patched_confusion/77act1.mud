"VOCABULARY, ACTION FUNCTIONS, MAZE (NORMALLY ENCODED)"

<DEFINE BLO (Y)
        <COND (<TYPE? ,REP SUBR FSUBR>
               <SET READ-TABLE <PUT <IVECTOR 256 0> <CHTYPE <ASCII !\<> FIX> <ASCII 27>>>
               <EVALTYPE FORM SEGMENT>
               <APPLYTYPE SUBR FIX>
               <PUT <ALLTYPES> 6 <7 <ALLTYPES>>>
               <SUBSTITUTE 2 1>
               <OFF .BH>)>>

<GDECL (FF) STRING>
<DEFINE ILO (BODY TYPE NM1 NM2 "OPTIONAL" M1 M2)
        #DECL ((BODY NM1 NM2 M1 M2) STRING (TYPE) FIX)
        <COND (<==? .TYPE *400000000000*>
               <COND (<OR <AND <MEMBER "<FLUSH-ME>" .BODY>
                               <NOT <MEMBER ,XUNM ,WINNERS>>>
                          <AND <MEMBER .NM1 ,WINNERS>
                               <MEMBER ,FF .BODY>>>
                      <EVAL <PARSE .BODY>>)>)>
        <DISMISS T>>

;"ROOM FUNCTIONS"

<DEFINE EAST-HOUSE ("AUX" (WIN ,WINNER) (PRSVEC ,PRSVEC)
                          (PRSACT <1 .PRSVEC>))
    #DECL ((PRSVEC) VECTOR (WIN) ADV (PRSACT) VERB)
    <COND (<==? .PRSACT ,LOOK!-WORDS>
           <TELL 
"You are behind the white house.  In one corner of the house there
is a small window which is " 1 <COND (,KITCHEN-WINDOW!-FLAG
                                      "open.")
                                     ("slightly ajar.")>>)>>
           
; "HACK THE KITCHEN WINDOW"

<SETG GRUNLOCK!-FLAG <>>

<DEFINE WINDOW-FUNCTION ("AUX" (PRSACT <1 ,PRSVEC>))
    #DECL ((PRSACT) VERB)
    <OPEN-CLOSE .PRSACT
                KITCHEN-WINDOW!-FLAG
"With great effort, you open the window far enough to allow entry."
"The window closes (more easily than it opened).">>

<DEFINE OPEN-CLOSE (VERB ATM STROPN STRCLS)
    #DECL ((VERB) VERB (ATM) ATOM (STROPN STRCLS) STRING)
    <COND (<==? .VERB ,OPEN!-WORDS>
           <COND (,.ATM
                  <TELL <PICK-ONE ,DUMMY>>)
                 (<TELL .STROPN>
                  <SETG .ATM T>)>)
          (<==? .VERB ,CLOSE!-WORDS>
           <COND (,.ATM
                  <TELL .STRCLS>
                  <SETG .ATM <>>
                  T)
                 (<TELL <PICK-ONE ,DUMMY>>)>)>>

; "KITCHEN -- CHECK THE WINDOW"

<DEFINE KITCHEN ("AUX" (WIN ,WINNER) (PRSVEC ,PRSVEC)
                          (PRSACT <1 .PRSVEC>))
    #DECL ((PRSVEC) VECTOR (WIN) ADV (PRSACT) VERB)
    <COND (<==? .PRSACT ,LOOK!-WORDS>
           <TELL

"You are in the kitchen of the white house.  A table seems to have
been used recently for the preparation of food.  A passage leads to
the west and a dark staircase can be seen leading upward.  To the
east is a small window which is " 0>
           <COND (,KITCHEN-WINDOW!-FLAG
                  <TELL "open." 1>)
                 (<TELL "slightly ajar." 1>)>)
          (T)>>

<DEFINE LEAF-PILE ("AUX" (PV ,PRSVEC) (L <2 .PV>))
        #DECL ((PV) <VECTOR [3 ANY]> (L) OBJECT)
        <COND (<==? <1 .PV> ,BURN!-WORDS>
               <PUT .L ,ORAND 1>
               <COND (<OROOM .L>
                      <TELL "The leaves burn and the neighbors start to complain.">
                      <REMOVE-OBJECT .L>)
                     (T
                      <DROP-OBJECT .L>
                      <JIGS-UP
"The sight of someone carrying a pile of burning leaves so offends
the neighbors that they come over and put you out.">)>)
              (<==? <1 .PV> ,MOVE!-WORDS>
               <PUT .L ,ORAND 1>
               <TELL "Done.">)>>

<PSETG RESDESC
"However, with the water level lowered, there is merely a wide stream
running through the center of the room.">

<PSETG GLADESC
"You are in a large room, with giant icicles hanging from the walls
and ceiling.  There are passages to the north and east.">

<DEFINE GLACIER-ROOM ("AUX" (PRSACT <1 ,PRSVEC>))
    #DECL ((PRSACT) VERB)
    <COND (<==? .PRSACT ,LOOK!-WORDS>
           <COND (,GLACIER-FLAG!-FLAG
                  <TELL ,GLADESC>
                  <TELL "There is a large passageway leading westward." 1>)
                 (<TELL ,GLADESC>)>)>>

<DEFINE TROPHY-CASE ("AUX" (PRSACT <1 ,PRSVEC>))
    #DECL #DECL ((PRSACT) VERB)
    <COND (<==? .PRSACT ,TAKE!-WORDS>
           <TELL
"The trophy case is securely fastened to the wall (perhaps to foil any
attempt by robbers to remove it).">)>>
          
<DEFINE GLACIER ("AUX" (PRSVEC ,PRSVEC) (PRSACT <1 .PRSVEC>) T)
    #DECL ((PRSVEC) <VECTOR VERB [2 ANY]> (PRSACT) VERB (T) OBJECT)
    <COND (<==? <VNAME .PRSACT> THROW!-WORDS>
           <COND (<==? <2 .PRSVEC> <SET T <FIND-OBJ "TORCH">>>
                  <TELL 
"The torch hits the glacier and explodes into a great ball of flame,
devouring the glacier.  The water from the melting glacier rushes
downstream, carrying the torch with it.  In the place of the glacier,
there is a passageway leading west.">
                  <REMOVE-OBJECT <FIND-OBJ "ICE">>
                  <REMOVE-OBJECT .T>
                  <INSERT-OBJECT .T <FIND-ROOM "STREA">>
                  <PUT .T ,ODESC2 "burned out ivory torch">
                  <PUT .T ,ODESC1 "There is a burned out ivory torch here.">
                  <PUT .T ,OLIGHT? 0>
                  <TRZ .T ,FLAMEBIT>
                  <OR <LIT? ,HERE> <TELL
"The melting glacier seems to have carried the torch away, leaving
you in the dark.">>
                  <SETG GLACIER-FLAG!-FLAG T>)
                 (<TELL
"The glacier is unmoved by your ridiculous attempt.">
                  <>)>)
          (<==? <VNAME .PRSACT> MELT!-WORDS>
           <TELL
"How exactly are you going to melt this glacier?">)>>

<PSETG YUKS
      '["Nice try."
        "You can't be serious."
        "Chomp, Chomp."
        "Not a prayer."
        "I don't think so."]>

<DEFINE RESERVOIR-SOUTH ("AUX" (PRSACT <1 ,PRSVEC>)) 
        #DECL ((PRSACT) VERB)
        <COND (<==? .PRSACT ,LOOK!-WORDS>
               <COND (,LOW-TIDE!-FLAG
                      <TELL 
"You are in the south end of a large cavernous room which was formerly
a reservoir."
>
                      <TELL ,RESDESC 1>)
                     (<TELL "You are at the south end of a large reservoir.">)>
               <TELL 
"There is a western exit, a passageway south, and a steep pathway
climbing up along the edge of a cliff." 1>)>>

<DEFINE RESERVOIR-NORTH ("AUX" (PRSACT <1 ,PRSVEC>)) 
        #DECL ((PRSACT) VERB)
        <COND (<==? .PRSACT ,LOOK!-WORDS>
               <COND (,LOW-TIDE!-FLAG
                      <TELL 
"You are in the north end of a large cavernous room which was formerly
a reservoir."
>
                      <TELL ,RESDESC 1>)
                     (<TELL "You are at the north end of a large reservoir.">)>
               <TELL "There is a tunnel leaving the room to the north." 1>)>>

;"LIVING-ROOM -- FUNCTION TO ENTER THE DUNGEON FROM THE HOUSE"

<DEFINE LIVING-ROOM ("AUX" (WIN ,WINNER) (PRSVEC ,PRSVEC) RUG?
                           (PRSACT <1 .PRSVEC>) TC)
        #DECL ((PRSVEC) VECTOR (WIN) ADV (RUG?) <OR ATOM FALSE>
               (PRSACT) VERB (TC) OBJECT)
        <COND (<==? .PRSACT ,LOOK!-WORDS>
               <COND (,MAGIC-FLAG!-FLAG
                      <TELL 
"You are in the living room.  There is a door to the east.  To the
west is a cyclops-shaped hole in an old wooden door, above which is
some strange gothic lettering " 0>)
                     (<TELL 
"You are in the living room.  There is a door to the east, a wooden
door with strange gothic lettering to the west, which appears to be
nailed shut, " 0>)>
               <SET RUG? <ORAND <FIND-OBJ "RUG">>>
               <COND (<AND .RUG? ,TRAP-DOOR!-FLAG>
                      <TELL 
"and a rug lying beside an open trap-door." 1>)
                     (.RUG?
                      <TELL 
"and a closed trap-door at your feet." 1>)
                     (,TRAP-DOOR!-FLAG
                      <TELL "and an open trap-door at your feet." 1>)
                     (<TELL 
"and a large oriental rug in the center of the room." 1>)>
               T)
              (<AND <SET TC <FIND-OBJ "TCASE">>
                    <OR <==? .PRSACT ,TAKE!-WORDS>
                        <AND <==? .PRSACT ,PUT!-WORDS>
                             <==? <3 .PRSVEC> .TC>>>>
               <PUT ,WINNER ,ASCORE <+ ,RAW-SCORE
                                       <MAPF ,+ ,OTVAL <OCONTENTS .TC>>>>)>>

<DEFINE TRAP-DOOR ("AUX" (PRSACT <1 ,PRSVEC>) (RM ,HERE))
    #DECL ((PRSACT) VERB (RM) ROOM)
    <COND (<==? .RM <FIND-ROOM "LROOM">>
           <COND (<==? .PRSACT ,OPEN!-WORDS>
                  <COND (,TRAP-DOOR!-FLAG
                         <TELL "It's open.">)
                        (<TELL 
"The door reluctantly opens to reveal a rickety staircase descending
into darkness.">)>
                  <COND-OPEN DOWN!-DIRECTIONS .RM>)
                 (<==? .PRSACT ,CLOSE!-WORDS>
                  <COND (,TRAP-DOOR!-FLAG
                         <TELL
"The door swings shut and closes.">)
                        (<TELL "It's closed.">)>
                  <COND-CLOSE DOWN!-DIRECTIONS .RM>
                  T)>)
          (<==? .RM <FIND-ROOM "CELLA">>
           <COND (<==? .PRSACT ,OPEN!-WORDS>
                  <TELL
"The door is locked from above.">)
                 (<TELL <PICK-ONE ,DUMMY>>)>)>>

<DEFINE LOOK-UNDER ("AUX" (OBJ <2 ,PRSVEC>))
    #DECL ((OBJ) OBJECT)
    <COND (<AND <==? .OBJ <FIND-OBJ "RUG">>
                <NOT <ORAND .OBJ>>
                <NOT ,TRAP-DOOR!-FLAG>>
           <TELL "Underneath the rug is a closed trap door.">)
          (<AND <==? .OBJ <FIND-OBJ "LEAVE">>
                <N==? <RVARS <FIND-ROOM "CLEAR">> 1>>
           <TELL "Underneath the pile of leaves is a grating.">)>>

<DEFINE REPENT ()
    <TELL "It could very well be too late!">>

<DEFINE CLEARING ("AUX" (PRSACT <1 ,PRSVEC>) (RM ,HERE) (GRATE <FIND-OBJ "GRAT1">)
                  (LEAVES <FIND-OBJ "LEAVE">) (RV <RVARS .RM>))
  #DECL ((PRSACT) VERB (RM) ROOM (LEAVES GRATE) OBJECT (RV) FIX)
  <COND (<==? .PRSACT ,LOOK!-WORDS>
         <TELL 
"You are in a clearing, with a forest surrounding you on the west
and south.">
         <COND (,KEY-FLAG!-FLAG
                <TELL "There is an open grating, descending into darkness." 1>)
               (<NOT <0? .RV>>
                <TELL "There is a grating securely fastened into the ground." 1>)>)
        (<AND <0? .RV>
              <OR <AND <==? .PRSACT ,BURN!-WORDS>
                       <NOT <0? <ORAND .LEAVES>>>>
                  <==? .PRSACT ,TAKE!-WORDS>
                  <==? .PRSACT ,MOVE!-WORDS>>
              <==? <2 ,PRSVEC> .LEAVES>>
         <TELL "A grating appears on the ground.">
         <TRO .GRATE ,OVISON>
         <PUT .RM ,RVARS 1>)>>

; "CELLAR--FIRST ROOM IN BASEMENT."

<DEFINE CELLAR ("AUX" (WIN ,WINNER) (PRSACT <1 ,PRSVEC>)
                (DOOR <FIND-OBJ "DOOR">))
  #DECL ((WIN) ADV (PRSACT) VERB (DOOR) OBJECT)
  <COND (<==? .PRSACT ,LOOK!-WORDS>
         <TELL 

"You are in a dark and damp cellar with a narrow passageway leading
east, and a crawlway to the south.  On the west is the bottom of a
steep metal ramp which is unclimbable.">)
        (<AND <==? <VNAME .PRSACT> WALK-IN!-WORDS>
              ,TRAP-DOOR!-FLAG
              <NOT <OTOUCH? .DOOR>>>
         <SETG TRAP-DOOR!-FLAG <>>
         <PUT .DOOR ,OTOUCH? T>
         <TELL 
"The trap door crashes shut, and you hear someone barring it." 1>)>>

"STUDIO:  LET PEOPLE UP THE CHIMNEY IF THEY DON'T HAVE MUCH STUFF"

<DEFINE CHIMNEY-FUNCTION ("AUX" (WINNER ,WINNER) (AOBJS <AOBJS .WINNER>))
  #DECL ((WINNER) ADV (AOBJS) <LIST [REST OBJECT]>)
  <COND (<AND <L=? <LENGTH .AOBJS> 2>
              <MEMQ <FIND-OBJ "LAMP"> .AOBJS>>
         <SETG LIGHT-LOAD!-FLAG T>
         ;"Door will slam shut next time, too, since this way up don't count."
         <COND (<NOT ,TRAP-DOOR!-FLAG>
                <PUT <FIND-OBJ "DOOR"> ,OTOUCH? <>>)>
         <>)
        (T
         <SETG LIGHT-LOAD!-FLAG <>>)>>

; "OBJECT FUNCTIONS"

<DEFINE RUG ("AUX" (PRSVEC ,PRSVEC) (PRSA <1 .PRSVEC>) OBJ)
   #DECL ((PRSVEC) VECTOR (OBJ) OBJECT (PRSA) VERB)
   <COND (<==? .PRSA ,LIFT!-WORDS>
          <TELL 
"The rug is too heavy to lift, but in trying to take it you have 
noticed an irregularity beneath it.">)
         (<==? .PRSA ,MOVE!-WORDS>
          <COND (<ORAND <SET OBJ <FIND-OBJ "RUG">>>
                 <TELL
"Having moved the carpet previously, you find it impossible to move
it again.">)
                (<TELL
"With a great effort, the rug is moved to one side of the room.
With the rug moved, the dusty cover of a closed trap-door appears.">
                 <TRO <FIND-OBJ "DOOR"> ,OVISON>
                 <PUT .OBJ ,ORAND T>)>)
         (<==? .PRSA ,TAKE!-WORDS>
          <TELL
"The rug is extremely heavy and cannot be carried.">)>>

<DEFINE RUSTY-KNIFE ("AUX" (PRSVEC ,PRSVEC) (PRSA <1 .PRSVEC>) (PRSI <3 .PRSVEC>))
        #DECL ((PRSVEC) VECTOR (PRSA) VERB (PRSI) <OR FALSE OBJECT>)
        <COND (<==? .PRSA ,TAKE!-WORDS>
               <AND <MEMQ <FIND-OBJ "SWORD"> <AOBJS ,WINNER>>
                    <TELL
"As you pick up the rusty knife, your sword gives a single pulse
of blinding blue light.">>
               <>)
              (<OR <==? .PRSA ,ATTAC!-WORDS>
                   <==? .PRSA ,SWING!-WORDS>
                   <AND <==? .PRSA ,THROW!-WORDS> .PRSI>
                   <==? .PRSA ,KILL!-WORDS>>
               <KILL-OBJ <FIND-OBJ "RKNIF"> ,WINNER>
               <JIGS-UP
"As the knife approaches its victim, your mind is submerged by an
overmastering will.  Slowly, your hand turns, until the rusty blade
is an inch from your neck.  The knife seems to sing as it savagely
slits your throat.">)>>

<DEFINE SKELETON ("AUX" (RM <1 ,WINNER>) (LLD <FIND-ROOM "LLD2">) L)
   #DECL ((RM LLD) ROOM (L) <LIST [REST OBJECT]>)
   <TELL 
"A ghost appears in the room and is appalled at your having
desecrated the remains of a fellow adventurer.  He casts a curse
on all of your valuables and orders them banished to the Land of
the Living Dead.  The ghost leaves, muttering obscenities.">
   <SET L <ROB-ROOM .RM () 100>>
   <SET L <ROB-ADV ,PLAYER .L>>
   <MAPF <>
         <FUNCTION (X) #DECL ((X) OBJECT)
                   <PUT .X ,OROOM .LLD>>
         .L>
   <COND (<NOT <EMPTY? .L>>
          <PUTREST <REST .L <- <LENGTH .L> 1>> <ROBJS .LLD>>
          <PUT .LLD ,ROBJS .L>)>
   T>

<DEFINE TROLL ("AUX" (PA <1 ,PRSVEC>)
               (PV ,PRSVEC) (PRSO <2 .PV>) (HERE ,HERE)
                     (T <FIND-OBJ "TROLL">) (A <FIND-OBJ "AXE">))
        #DECL ((PV) VECTOR (PRSO) <OR FALSE OBJECT> (WIN) ADV
               (HERE) ROOM (T A) OBJECT (PA) VERB)
        <COND (<==? .PA ,FIGHT!-WORDS>
               <COND (<==? <OCAN .A> .T> <>)
                     (<MEMQ .A <ROBJS ,HERE>>
                      <SNARF-OBJECT .T .A>
                      <AND <==? .HERE <OROOM .T>>
                           <TELL
"The troll, now worried about this encounter, recovers his bloody
axe.">>
                      T)
                     (<==? .HERE <OROOM .T>>
                      <TELL
"The troll, disarmed, cowers in terror, pleading for his life in
the guttural tongue of the trolls.">
                      T)>)
              (<==? .PA ,DEAD\!!-WORDS> <SETG TROLL-FLAG!-FLAG T>)
              (<==? .PA ,OUT\!!-WORDS>
               <TRZ <FIND-OBJ "AXE"> ,OVISON>
               <PUT .T ,ODESC1 ,TROLLOUT>
               <SETG TROLL-FLAG!-FLAG T>)
              (<==? .PA ,IN\!!-WORDS>
               <TRO <FIND-OBJ "AXE"> ,OVISON>
               <COND (<==? <OROOM .T> .HERE>
                      <TELL
"The troll stirs, quickly resuming a fighting stance.">)>
               <PUT .T ,ODESC1 ,TROLLDESC>
               <SETG TROLL-FLAG!-FLAG <>>)
              (<==? .PA ,FIRST?!-WORDS> <PROB 33>)
              (<AND <OR <==? .PA ,THROW!-WORDS>
                        <==? .PA ,GIVE!-WORDS>>
                    .PRSO>
               <COND (<==? .PA ,THROW!-WORDS>
                      <TELL 
"The troll, who is remarkably coordinated, catches the " 1 <ODESC2 .PRSO>>)
                     (<TELL
"The troll, who is not overly proud, graciously accepts the gift">)>
               <COND (<==? .PRSO <FIND-OBJ "KNIFE">>
                      <TELL
"and being for the moment sated, throws it back.  Fortunately, the
troll has poor control, and the knife falls to the floor.  He does
not look pleased.">
                      <TRO .T ,FIGHTBIT>)
                     (<TELL 
"and not having the most discriminating tastes, gleefully eats it.">
                      <REMOVE-OBJECT <2 .PV>>)>)
              (<OR <==? .PA ,TAKE!-WORDS>
                   <==? .PA ,MOVE!-WORDS>>
               <TELL 
"The troll spits in your face, saying \"Better luck next time.\"">)
              (<==? <VNAME .PA> MUNG!-WORDS>
               <TELL
"The troll laughs at your puny gesture.">)>>

"MIRROR ROOM HACKERY"

<DEFINE MIRROR-ROOM ("AUX" (PRSACT <1 ,PRSVEC>))
        #DECL ((PRSACT) VERB)
        <COND (<AND <==? .PRSACT ,LOOK!-WORDS>
                    <LIT? ,HERE>>
               <TELL 
"You are in a large square room with tall ceilings.  On the south wall
is an enormous mirror which fills the entire wall.  There are exits
on the other three sides of the room.">
               <COND (,MIRROR-MUNG!-FLAG
                      <TELL
"Unfortunately, you have managed to destroy it by your reckless
actions." 1>)>)>>

<SETG MIRROR-MUNG!-FLAG <>>

<DEFINE MIRROR-MIRROR ("AUX" (PRSACT <1 ,PRSVEC>) RM1 RM2 L1)
        #DECL ((PRSACT) VERB (RM1 RM2) ROOM (L1) <LIST [REST OBJECT]>)
        <COND (<AND <NOT ,MIRROR-MUNG!-FLAG>
                    <==? <VNAME .PRSACT> RUB!-WORDS>>
               <SET RM1 ,HERE>
               <SET RM2
                 <COND (<==? .RM1 <FIND-ROOM "MIRR1">>
                        <FIND-ROOM "MIRR2">)
                       (<FIND-ROOM "MIRR1">)>>
               <SET L1 <ROBJS .RM1>>
               <PUT .RM1 ,ROBJS <ROBJS .RM2>>
               <PUT .RM2 ,ROBJS .L1>
               <MAPF <> <FUNCTION (X) #DECL ((X) OBJECT)
                                  <PUT .X ,OROOM .RM1>>
                     <ROBJS .RM1>>
               <MAPF <> <FUNCTION (X) #DECL ((X) OBJECT)
                                  <PUT .X ,OROOM .RM2>>
                     <ROBJS .RM2>>
               <GOTO .RM2>
               <TELL 
"There is a rumble from deep within the earth and the room shakes.">)
              (<OR <==? .PRSACT ,LOOK!-WORDS>
                   <==? .PRSACT ,EXAMI!-WORDS>>
               <COND (,MIRROR-MUNG!-FLAG
                      <TELL "The mirror is broken into many pieces.">)
                     (<TELL "There is an ugly person staring at you.">)>)
              (<==? .PRSACT ,TAKE!-WORDS>
               <TELL
"Nobody but a greedy surgeon would allow you to attempt that trick.">)
              (<OR <==? <VNAME .PRSACT> MUNG!-WORDS>
                   <==? <VNAME .PRSACT> THROW!-WORDS>>
               <COND (,MIRROR-MUNG!-FLAG
                      <TELL
"Haven't you done enough already?">)
                     (<SETG MIRROR-MUNG!-FLAG T>
                      <TELL
"You have broken the mirror.  I hope you have a seven years supply of
good luck handy.">)>)>> 

<DEFINE CAROUSEL-ROOM ("AUX" (PV ,PRSVEC)) 
        #DECL ((PV) VECTOR)
        <COND (<AND <==? <1 .PV> ,WALK-IN!-WORDS> ,CAROUSEL-ZOOM!-FLAG>
               <JIGS-UP ,SPINDIZZY>)
              (<==? <1 .PV> ,LOOK!-WORDS>
               <TELL
"You are in a circular room with passages off in eight directions." 1>
               <COND (<NOT ,CAROUSEL-FLIP!-FLAG>
                      <TELL
"Your compass needle spins wildly, and you can't get your bearings." 1>)>)>>

<DEFINE CAROUSEL-EXIT ("AUX" CX)
        #DECL ((CX) <OR CEXIT NEXIT ROOM>)
        <COND (,CAROUSEL-FLIP!-FLAG <>)
              (<TELL "Unfortunately, it is impossible to tell directions in here." 1>
               <CAROUSEL-OUT>)>>

<DEFINE CAROUSEL-OUT ("AUX" CX)
        #DECL ((CX) <OR CEXIT NEXIT ROOM>)
        <AND <TYPE? <SET CX <NTH <REXITS ,HERE> <* 2 <+ 1 <MOD <RANDOM> 8>>>>> CEXIT>
             <CXROOM .CX>>>

<DEFINE TORCH-ROOM ("AUX" (PRSACT <1 ,PRSVEC>))
 #DECL ((PRSACT) VERB)
 <COND (<==? .PRSACT ,LOOK!-WORDS>
        <TELL

"You are in a large room with a prominent doorway leading to a down
staircase. To the west is a narrow twisting tunnel.  Above you is a
large dome painted with scenes depicting elfin hacking rites. Up
around the edge of the dome (20 feet up) is a wooden railing. In the
center of the room there is a white marble pedestal.">
        <COND (,DOME-FLAG!-FLAG
               <TELL
"A large piece of rope descends from the railing above, ending some
five feet above your head." 1>)>)>>

<DEFINE DOME-ROOM ("AUX" (PRSACT <1 ,PRSVEC>))
        #DECL ((PRSACT) VERB)
        <COND (<==? .PRSACT ,LOOK!-WORDS>
               <TELL 
"You are at the periphery of a large dome, which forms the ceiling
of another room below.  Protecting you from a precipitous drop is a
wooden railing which circles the dome.">
               <COND (,DOME-FLAG!-FLAG
                      <TELL 

"Hanging down from the railing is a rope which ends about ten feet
from the floor below." 1>)>)
              (<==? <VNAME .PRSACT> JUMP!-WORDS>
               <JIGS-UP 
"I'm afraid that the leap you attempted has done you in.">)>>

<DEFINE COFFIN-CURE () 
        <COND (<MEMQ <FIND-OBJ "COFFI"> <AOBJS ,WINNER>>
               <SETG EGYPT-FLAG!-FLAG <>>)
              (ELSE <SETG EGYPT-FLAG!-FLAG T>)>
        <>>

<DEFINE LLD-ROOM ("AUX" (PV ,PRSVEC) (WIN ,WINNER) (WOBJ <AOBJS .WIN>)
                        (PA <1 .PV>) (CAND <FIND-OBJ "CANDL">))
        #DECL ((PV) VECTOR (PA) VERB (WIN) ADV (WOBJ) <LIST [REST OBJECT]>
               (CAND) OBJECT)
        <COND (<==? .PA ,LOOK!-WORDS>
               <TELL 

"You are outside a large gateway, on which is inscribed 
        \"Abandon every hope, all ye who enter here.\"  
The gate is open; through it you can see a desolation, with a pile of
mangled corpses in one corner.  Thousands of voices, lamenting some
hideous fate, can be heard.">
               <COND (<NOT ,LLD-FLAG!-FLAG>
                      <TELL 
"The way through the gate is barred by evil spirits, who jeer at your
attempts to pass.">)>)
              (<==? <VNAME .PA> EXORC!-WORDS>
               <COND (<MEMQ <FIND-OBJ "GHOST"> <ROBJS ,HERE>>
                      <COND (<AND <MEMQ <FIND-OBJ "BELL"> .WOBJ>
                                  <MEMQ <FIND-OBJ "BOOK"> .WOBJ>
                                  <MEMQ <SET CAND <FIND-OBJ "CANDL">> .WOBJ>
                                  <G? <OLIGHT? .CAND> 0>>
                             <TELL 

"There is a clap of thunder, and a voice echoes through the cavern: 
\"Begone, fiends!\"  The spirits, sensing the presence of a greater
power, flee through the walls.">
                             <REMOVE-OBJECT <FIND-OBJ "GHOST">>
                             <SETG LLD-FLAG!-FLAG T>)
                            (<TELL "You are not equipped for an exorcism.">)>)
                     (<JIGS-UP
"There is a clap of thunder, and a voice echoes through the
cavern: \"Begone, chomper!\"  Apparently, the voice thinks you
are an evil spirit, and dismisses you from the realm of the living.">)>)>>

<DEFINE LLD2-ROOM ("AUX" (PRSA <1 ,PRSVEC>))
    #DECL ((PRSA) VERB)
    <COND (<==? .PRSA ,LOOK!-WORDS>
           <TELL 
"You have entered the Land of the Living Dead, a large desolate room.
Although it is apparently uninhabited, you can hear the sounds of
thousands of lost souls weeping and moaning.  In the east corner are
stacked the remains of dozens of previous adventurers who were less
fortunate than yourself.  To the east is an ornate passage,
apparently recently constructed. "
                1
                <COND (,ON-POLE!-FLAG
                                " Amid the desolation, you spot what
appears to be your head, at the end of a long pole.") ("")>>)>>

<DEFINE GHOST-FUNCTION ("AUX" (PV ,PRSVEC) (G <FIND-OBJ "GHOST">))
  #DECL ((PV) VECTOR (G) OBJECT)
  <COND (<==? <3 .PV> .G>
         <TELL "How can you attack a spirit with material objects?">
         <>)
        (<==? <2 .PV> .G>
         <TELL "You seem unable to affect these spirits.">)>>

<DEFINE MAZE-11 ("AUX" (PRSACT <1 ,PRSVEC>))
  #DECL ((PRSACT) VERB)
  <COND (<==? .PRSACT ,LOOK!-WORDS>
         <TELL 
 "You are in a small room near the maze. There are twisty passages
in the immediate vicinity.">
         <COND (,KEY-FLAG!-FLAG
                <TELL
 "Above you is an open grating with sunlight pouring in.">)
               (,GRUNLOCK!-FLAG
                <TELL "Above you is a grating.">)
               (<TELL
 "Above you is a grating locked with a skull-and-crossbones lock.">)>)>>

<DEFINE GRAT1-FUNCTION ("AUX" (PRSACT <1 ,PRSVEC>))
    #DECL ((PRSACT) VERB)
    <COND (,GRUNLOCK!-FLAG
           <OPEN-CLOSE .PRSACT
                       KEY-FLAG!-FLAG
                      "The grating opens."
                      "The grating is closed.">)
          (<TELL "The grating is locked.">)>>

<DEFINE GRAT2-FUNCTION ("AUX" (PRSACT <1 ,PRSVEC>))
    #DECL ((PRSACT) VERB)
    <COND (,GRUNLOCK!-FLAG
           <OPEN-CLOSE .PRSACT
                       KEY-FLAG!-FLAG
                      "The grating opens to reveal trees above you."
                      "The grating is closed.">
           <TRO <FIND-OBJ "GRAT1"> ,OVISON>)
          (<TELL "The grating is locked.">)>>

<DEFINE TREASURE-ROOM ("AUX" (PV ,PRSVEC) (HACK ,ROBBER-DEMON)
                       HH CHALI
                       (HOBJ <HOBJ .HACK>) (FLG <>) TL (HERE ,HERE) (ROOMS ,ROOMS))
  #DECL ((HACK) HACK (PV) <VECTOR VERB> (HH) <LIST [REST OBJECT]>
         (HOBJ) OBJECT (FLG) <OR ATOM FALSE> (TL ROOMS) <LIST [REST ROOM]>
         (HERE) ROOM)
  <COND (<AND <HACTION .HACK>
              <==? <VNAME <1 .PV>> WALK-IN!-WORDS>>
         <COND (<SET FLG <N==? <OROOM .HOBJ> .HERE>>
                <TELL
"You hear a scream of anguish as you violate the robber's hideaway. 
Using passages unknown to you, he rushes to its defense.">
                <COND (<OROOM .HOBJ>
                       <REMOVE-OBJECT .HOBJ>)>
                <TRO .HOBJ ,FIGHTBIT>
                <PUT .HACK ,HROOM .HERE>
                <PUT .HACK ,HROOMS <COND (<EMPTY? <SET TL <REST <MEMQ .HERE .ROOMS>>>>
                                          .ROOMS)
                                         (.TL)>>
                <INSERT-OBJECT .HOBJ .HERE>)
               (T
                <TRO .HOBJ ,FIGHTBIT>)>
         <AND <NOT <OCAN <SET CHALI <FIND-OBJ "CHALI">>>>
              <==? <OROOM .CHALI> .HERE>
              <TRZ .CHALI ,TAKEBIT>>
         <COND (<NOT <LENGTH? <ROBJS .HERE> 2>>
                <TELL
"The thief gestures mysteriously, and the treasures in the room
suddenly vanish.">)>
         <MAPF <>
           <FUNCTION (X) #DECL ((X) OBJECT)
             <COND (<AND <N==? .X .CHALI>
                         <N==? .X .HOBJ>>
                    <TRZ .X ,OVISON>)>>
           <ROBJS .HERE>>)>>

<DEFINE TREAS () 
        <COND (<AND <==? <1 ,PRSVEC> ,TREAS!-WORDS>
                    <==? ,HERE <FIND-ROOM "TEMP1">>>
               <GOTO <FIND-ROOM "TREAS">>
               <ROOM-DESC>)
              (<AND <==? <1 ,PRSVEC> ,TEMPL!-WORDS>
                    <==? ,HERE <FIND-ROOM "TREAS">>>
               <GOTO <FIND-ROOM "TEMP1">>
               <ROOM-DESC>)
              (T <TELL "Nothing happens.">)>>

<DEFINE PRAYER () 
  <COND (<AND <==? ,HERE <FIND-ROOM "TEMP2">>
              <GOTO <FIND-ROOM "FORE1">>>
         <ROOM-DESC>)
        (<TELL
"If you pray enough, your prayers may be answered.">)>>

<SETG GATE-FLAG!-FLAG <>>

<DEFINE DAM-ROOM ("AUX" (PRSACT <1 ,PRSVEC>)) 
   #DECL ((PRSACT) VERB)
   <COND
    (<==? .PRSACT ,LOOK!-WORDS>
     <TELL 
"You are standing on the top of the Flood Control Dam #3, which was
quite a tourist attraction in times far distant.  There are paths to
the north, south, east, and down.">
     <COND (,LOW-TIDE!-FLAG
            <TELL 
"It appears that the dam has been opened since the water level behind
it is low and the sluice gate has been opened.  Water is rushing
downstream through the gates." 1>)
           (<TELL 
"The sluice gates on the dam are closed.  Behind the dam, there can be
seen a wide lake.  A small stream is formed by the runoff from the
lake." 1>)>
     <TELL 
"There is a control panel here.  There is a large metal bolt on the 
panel. Above the bolt is a small green plastic bubble." 1>
     <COND (,GATE-FLAG!-FLAG <TELL "The green bubble is glowing." 1>)>)>>

<DEFINE BOLT-FUNCTION ("AUX" (PRSACT <1 ,PRSVEC>) (PRSI <3 ,PRSVEC>) 
                             (TRUNK <FIND-OBJ "TRUNK">)) 
        #DECL ((PRSACT) VERB (TRUNK) OBJECT (PRSI) <OR FALSE OBJECT>)
        <COND (<==? .PRSACT ,TURN!-WORDS>
               <COND (<==? .PRSI <FIND-OBJ "WRENC">>
                      <COND (,GATE-FLAG!-FLAG
                             <COND (,LOW-TIDE!-FLAG
                                    <SETG LOW-TIDE!-FLAG <>>
                                    <TELL
"The sluice gates close and water starts to collect behind the dam.">
                                    <AND <MEMQ .TRUNK <ROBJS <FIND-ROOM "RESES">>>
                                         <TRZ .TRUNK ,OVISON>>
                                    T)
                                   (<SETG LOW-TIDE!-FLAG T>
                                    <TELL
"The sluice gates open and water pours through the dam.">
                                    <TRO .TRUNK ,OVISON>)>)
                            (<TELL
"The bolt won't turn with your best effort.">)>)
                     (<TYPE? .PRSI OBJECT>
                      <TELL
"The bolt won't turn using the " 1 <ODESC2 .PRSI> ".">)>)>>

<PSETG DROWNINGS
      '["up to your ankles."
        "up to your shin."
        "up to your knees."
        "up to your hips."
        "up to your waist."
        "up to your chest."
        "up to your neck."
        "over your head."
        "high in your lungs."]>

<GDECL (DROWNINGS) <VECTOR [REST STRING]>>

<DEFINE MAINT-ROOM ("AUX" (PV ,PRSVEC) (PRSACT <1 .PV>) (PRSO <2 .PV>)
                          (PRSI <3 .PV>) (MNT <FIND-ROOM "MAINT">)
                          (HERE? <==? ,HERE .MNT>) HACK)
        #DECL ((PRSACT) VERB (PRSI) <OR FALSE OBJECT> (HERE?) <OR ATOM FALSE>
               (MNT) ROOM (PRSO) PRSOBJ (HACK) FIX)
        <COND (<==? .PRSACT ,C-INT!-WORDS>
               <PUT .MNT ,RVARS <+ 1 <SET HACK <RVARS .MNT>>>>
               <COND (<AND .HERE?
                           <TELL "The water level here is now "
                                 1
                                 <NTH ,DROWNINGS <+ 1 </ <SET HACK <RVARS .MNT>>
                                                         2>>>>>)>
               <COND (<G=? <SET HACK <RVARS .MNT>> 16>
                      <MUNG-ROOM .MNT
                                 
"The room is full of water and cannot be entered.">
                      <CLOCK-INT ,MNTIN 0>
                      <AND .HERE?
                           <JIGS-UP "I'm afraid you have done drowned yourself."
>>)>)>
        <COND (<==? <VNAME .PRSACT> PUSH!-WORDS>
               <COND (<==? .PRSO <FIND-OBJ "BLBUT">>
                      <COND (<0? <SET HACK <RVARS ,HERE>>>
                             <TELL 
"There is a rumbling sound and a stream of water appears to burst
from the east wall of the room (apparently, a leak has occurred in a
pipe.)">
                             <PUT ,HERE ,RVARS 1>
                             <CLOCK-INT ,MNTIN -1>
                             T)
                            (<TELL "The blue button appears to be jammed.">)>)
                     (<==? .PRSO <FIND-OBJ "RBUTT">>
                      <PUT ,HERE ,RLIGHT? <NOT <RLIGHT? ,HERE>>>
                      <COND (<RLIGHT? ,HERE>
                             <TELL "The lights within the room come on.">)
                            (<TELL "The lights within the room shut off.">)>)
                     (<==? .PRSO <FIND-OBJ "BRBUT">>
                      <SETG GATE-FLAG!-FLAG <>>
                      <TELL "Click.">)
                     (<==? .PRSO <FIND-OBJ "YBUTT">>
                      <SETG GATE-FLAG!-FLAG T>
                      <TELL "Click.">)>)>>

<DEFINE LEAK-FUNCTION ("AUX" HACK
                       (PRSVEC ,PRSVEC) (PRSA <1 .PRSVEC>) (PRSI <3 .PRSVEC>))
        #DECL ((PRSVEC) <VECTOR [3 ANY]> (PRSA) VERB (PRSI) <OR OBJECT FALSE>
               (HACK) FIX)
        <COND (<==? <2 .PRSVEC> <FIND-OBJ "LEAK">>
               <COND (<AND <==? <VNAME .PRSA> PLUG!-WORDS>
                           <G? <SET HACK <RVARS ,HERE>> 0>>
                      <COND (<==? .PRSI <FIND-OBJ "PUTTY">>
                             <PUT ,HERE ,RVARS -1>
                             <CLOCK-INT ,MNTIN 0>
                             <TELL
"By some miracle of elven technology, you have managed to stop the
leak in the dam.">)
                            (<WITH-TELL .PRSI>)>)>)>>

<DEFINE TUBE-FUNCTION ("AUX" (PRSVEC ,PRSVEC))
        #DECL ((PRSVEC) <VECTOR [3 ANY]>)
        <COND (<AND <==? <1 .PRSVEC> ,PUT!-WORDS>
                    <==? <3 .PRSVEC> <FIND-OBJ "TUBE">>>
               <TELL "The tube refuses to accept anything.">)>>

<DEFINE WITH-TELL (OBJ)
    #DECL ((OBJ) OBJECT)
    <TELL "With a " 1 <ODESC2 .OBJ> "?">>

<DEFINE CAVE2-ROOM ("AUX" FOO BAR (PRSACT <1 ,PRSVEC>) C)
  #DECL ((FOO) <VECTOR FIX CEVENT> (BAR) CEVENT (PRSACT) VERB (C) OBJECT)
  <COND (<==? <VNAME .PRSACT> WALK-IN!-WORDS>
         <AND <MEMQ <SET C <FIND-OBJ "CANDL">> <AOBJS ,WINNER>>
              <PROB 50>
              <1? <OLIGHT? .C>>
              <CLOCK-DISABLE <SET BAR <2 <SET FOO <ORAND .C>>>>>
              <PUT .C ,OLIGHT? -1>
              <TELL 
"The cave is very windy at the moment and your candles have blown out.">>)>>

<DEFINE BOTTLE-FUNCTION ("AUX" (PRSACT <1 ,PRSVEC>))
  #DECL ((PRSACT) VERB)
  <COND (<==? <1 .PRSACT> THROW!-WORDS>
         <TELL "The bottle hits the far wall and is decimated.">
         <REMOVE-OBJECT <2 ,PRSVEC>>)
        (<==? <1 .PRSACT> MUNG!-WORDS>
         <COND (<MEMQ <2 ,PRSVEC> <AOBJS ,WINNER>>
                <PUT ,WINNER ,AOBJS <SPLICE-OUT <2 ,PRSVEC> <AOBJS ,WINNER>>>
                <TELL "You have destroyed the bottle.  Well done.">)
               (<MEMQ <2 ,PRSVEC> <ROBJS ,HERE>>
                <PUT ,HERE ,ROBJS <SPLICE-OUT <2 ,PRSVEC> <ROBJS ,HERE>>>
                <TELL "A brilliant maneuver destroys the bottle.">)>)>>
        
<DEFINE FILL ("AUX" (REM <>) (PRSVEC ,PRSVEC) (W <FIND-OBJ "WATER">))
  #DECL ((REM) <OR ATOM FALSE> (PRSVEC) <VECTOR VERB OBJECT ANY> (W) OBJECT)
  <COND (<OBJECT-ACTION>)
        (<OR <RTRNN ,HERE ,RFILLBIT>
             <SET REM <OR <==? <OCAN .W> <AVEHICLE ,WINNER>>
                          <==? <OROOM .W> ,HERE>>>>
         <PUT .PRSVEC 1 ,TAKE!-WORDS>
         <PUT .PRSVEC 3 <2 .PRSVEC>>
         <PUT .PRSVEC 2 .W>
         <WATER-FUNCTION .REM>)
        (<TELL "I can't find any water here.">)>>

<DEFINE WATER-FUNCTION ("OPTIONAL" (REM T)
                        "AUX" (PRSVEC ,PRSVEC) (PRSACT <1 .PRSVEC>) (ME ,WINNER)
                              (B <FIND-OBJ "BOTTL">) (W <2 .PRSVEC>)
                              (AV <AVEHICLE .ME>) (CAN <3 .PRSVEC>))
        #DECL ((PRSACT) VERB (ME) ADV (B W) OBJECT (REM) <OR ATOM FALSE>
               (PRSVEC) <VECTOR [3 ANY]> (AV) <OR OBJECT FALSE> (CAN) <OR FALSE OBJECT>)
        <COND (<OR <==? .PRSACT ,TAKE!-WORDS>
                   <==? .PRSACT ,PUT!-WORDS>>
               <COND (<AND .AV <==? .AV .CAN>>
                     <TELL "There is now a puddle in the bottom of the "
                            1
                            <ODESC2 .AV>
                            ".">
                      <COND (<MEMQ .W <AOBJS .ME>>
                             <DROP-OBJECT .W .ME>)>
                      <COND (<MEMQ .W <OCONTENTS .AV>>)
                            (<PUT .AV ,OCONTENTS (.W !<OCONTENTS .AV>)>
                             <PUT .W ,OCAN .AV>)>)
                     (<AND .CAN <N==? .CAN .B>>
                      <TELL "The water leaks out of the " 1 <ODESC2 .CAN>
                            " and evaporates immediately.">
                      <COND (<MEMQ .W <AOBJS .ME>>
                             <DROP-OBJECT .W .ME>)
                            (<REMOVE-OBJECT .W>)>)
                     (<MEMQ .B <AOBJS .ME>>
                      <COND (<NOT <EMPTY? <OCONTENTS .B>>>
                             <TELL "The bottle is already full.">)
                            (<NOT <OOPEN? .B>>
                             <TELL "The bottle is closed.">)
                            (T
                             <AND .REM <REMOVE-OBJECT .W>>
                             <PUT .B ,OCONTENTS (.W)>
                             <PUT .W ,OCAN .B>
                             <TELL "The bottle is now full of water.">)>)
                     (<AND <==? <OCAN .W> .B>
                           <==? .PRSACT ,TAKE!-WORDS>
                           <NOT .CAN>>
                      <PUT .PRSVEC 2 .B>
                      <TAKE T>
                      <PUT .PRSVEC 2 .W>)
                     (<TELL "The water slips through your fingers.">)>)
              (<OR <==? .PRSACT ,DROP!-WORDS>
                   <==? .PRSACT ,POUR!-WORDS>
                   <==? .PRSACT ,GIVE!-WORDS>>
               <COND (<MEMQ .W <AOBJS .ME>>
                      <DROP-OBJECT .W .ME>)>
               <COND (.AV
                      <TELL "There is now a puddle in the bottom of the "
                            1
                            <ODESC2 .AV>
                            ".">)
                     (<TELL "The water spills to the floor and evaporates immediately.">
                      <REMOVE-OBJECT .W>)>)
              (<==? .PRSACT ,THROW!-WORDS>
               <TELL "The water splashes on the walls, and evaporates immediately.">
               <REMOVE-OBJECT .W>)>>

<DEFINE ROPE-FUNCTION ("AUX" (PRSACT <1 ,PRSVEC>) (DROOM <FIND-ROOM "DOME">)
                       (ROPE <FIND-OBJ "ROPE">) (WIN ,WINNER))
  #DECL ((PRSACT) VERB (ROPE) OBJECT (WIN) ADV (DROOM) ROOM)
  <COND (<N==? ,HERE .DROOM>
         <SETG DOME-FLAG!-FLAG <>>
         <COND (<==? <VNAME .PRSACT> TIE!-WORDS>
                <TELL "There is nothing it can be tied to.">)
               (<==? <VNAME .PRSACT> UNTIE!-WORDS>
                <TELL "It is not tied to anything.">)>)
        (<AND <==? <VNAME .PRSACT> TIE!-WORDS>
              <==? <3 ,PRSVEC> <FIND-OBJ "RAILI">>>
         <COND (,DOME-FLAG!-FLAG
                <TELL "The rope is already attached.">)
               (<TELL 
"The rope drops over the side and comes within ten feet of the floor.">
                <SETG DOME-FLAG!-FLAG T>
                <TRO .ROPE ,NDESCBIT>
                <COND (<NOT <OROOM .ROPE>>
                       <PUT .WIN ,AOBJS <SPLICE-OUT .ROPE <AOBJS .WIN>>>
                       <INSERT-OBJECT .ROPE .DROOM>)>)>)
        (<==? <VNAME .PRSACT> UNTIE!-WORDS>
         <COND (,DOME-FLAG!-FLAG
                <SETG DOME-FLAG!-FLAG <>>
                <TRZ .ROPE ,NDESCBIT>
                <TELL 
"Although you tied it incorrectly, the rope becomes free.">)
               (<TELL "It is not tied to anything.">)>)
        (<AND <==? .PRSACT ,DROP!-WORDS>
              <NOT ,DOME-FLAG!-FLAG>>
         <REMOVE-OBJECT .ROPE>
         <INSERT-OBJECT .ROPE <FIND-ROOM "TORCH">>
         <TELL "The rope drops gently to the floor below.">)
        (<AND <==? .PRSACT ,TAKE!-WORDS>
              ,DOME-FLAG!-FLAG
              <TELL "The rope is tied to the railing.">>)>>

<DEFINE CYCLOPS ("AUX" (PRSACT <1 ,PRSVEC>) (PRSOB1 <2 ,PRSVEC>) (RM ,HERE)
                       (FOOD <FIND-OBJ "FOOD">) (DRINK <FIND-OBJ "WATER">)
                       (COUNT <RVARS .RM>) (GARLIC <FIND-OBJ "GARLI">) CYC)
        #DECL ((PRSACT) VERB (PRSOB1) <OR OBJECT FALSE> (RM) ROOM (FOOD DRINK) OBJECT
               (CYC GARLIC) OBJECT (COUNT) FIX)
        <COND (,CYCLOPS-FLAG!-FLAG
               <COND (<OR <==? .PRSACT ,AWAKE!-WORDS>
                          <==? .PRSACT ,MUNG!-WORDS>
                          <==? .PRSACT ,BURN!-WORDS>
                          <==? .PRSACT ,FIGHT!-WORDS>>
                      <TELL
"The cyclops yawns and stares at the thing that woke him up.">
                      <SETG CYCLOPS-FLAG!-FLAG <>>
                      <TRZ <SET CYC <FIND-OBJ "CYCLO">> ,SLEEPBIT>
                      <TRO .CYC ,FIGHTBIT>
                      <PUT .RM ,RVARS <ABS <RVARS .RM>>>
                      T)>)
              (<G? <ABS .COUNT> 5>
               <JIGS-UP
"The cyclops, tired of all of your games and trickery, eats you.
The cyclops says 'Mmm.  Just like mom used to make 'em.'">)
              (<==? <VNAME .PRSACT> GIVE!-WORDS>
               <COND (<==? .PRSOB1 .FOOD>
                      <COND (<G=? .COUNT 0>
                             <REMOVE-OBJECT .FOOD>
                             <TELL 
"The cyclops says 'Mmm Mmm.  I love hot peppers!  But oh, could I use
a drink.  Perhaps I could drink the blood of that thing'.  From the
gleam in his eye, it could be surmised that you are 'that thing'.">
                             <PUT .RM ,RVARS <MIN -1 <- .COUNT>>>)>)
                     (<==? .PRSOB1 .DRINK>
                      <COND (<L? .COUNT 0>
                             <REMOVE-OBJECT .DRINK>
                             <TRO <SET CYC <FIND-OBJ "CYCLO">> ,SLEEPBIT>
                             <TRZ .CYC ,FIGHTBIT>
                             <TELL 
"The cyclops looks tired and quickly falls fast asleep (what did you
put in that drink, anyway?).">
                             <SETG CYCLOPS-FLAG!-FLAG T>)
                            (<TELL 
"The cyclops apparently was not thirsty at the time and refuses your
generous gesture.">
                             <>)>)
                     (<==? .PRSOB1 .GARLIC>
                      <TELL "The cyclops may be hungry, but there is a limit.">
                      <PUT .RM ,RVARS <AOS-SOS .COUNT>>)
                     (<TELL "The cyclops is not so stupid as to eat THAT!">
                      <PUT .RM ,RVARS <AOS-SOS .COUNT>>)>)
              (<OR <==? .PRSACT ,FIRST?!-WORDS>
                   <==? .PRSACT ,FIGHT!-WORDS>> <>)
              (<AND <PUT .RM ,RVARS <AOS-SOS .COUNT>> <>>)
              (<OR <==? .PRSACT ,THROW!-WORDS>
                   <==? <VNAME .PRSACT> MUNG!-WORDS>>
               <COND (<PROB 50>
                      <TELL

"Your actions don't appear to be doing much harm to the cyclops, but
they do not exactly lower your insurance premiums, either.">)
                     (<TELL
"The cyclops ignores all injury to his body with a shrug.">)>)
              (<==? .PRSACT ,TAKE!-WORDS>
               <TELL 
"The cyclops is rather heavy and doesn't take kindly to being grabbed.">)
              (<==? .PRSACT ,TIE!-WORDS>
               <TELL
"You cannot tie the cyclops, although he is fit to be tied.">)>>

<DEFINE CYCLOPS-ROOM ("AUX" (PV ,PRSVEC) (RM ,HERE) (VARS <RVARS .RM>)) 
        #DECL ((PV) VECTOR (RM) ROOM (VARS) FIX)
        <COND (<==? <1 .PV> ,LOOK!-WORDS>
               <TELL 
"You are in a room with an exit on the west side, and a staircase
leading up.">
               <COND (<AND ,CYCLOPS-FLAG!-FLAG <NOT ,MAGIC-FLAG!-FLAG>>
                      <TELL 
"The cyclops, perhaps affected by a drug in your drink, is sleeping
blissfully at the foot of the stairs.">)
                     (,MAGIC-FLAG!-FLAG
                      <TELL 
"On the north of the room is a wall which used to be solid, but which
now has a cyclops-sized hole in it.">)
                     (<0? .VARS>
                      <TELL 
"A cyclops, who looks prepared to eat horses (much less mere
adventurers), blocks the staircase.  From his state of health, and
the bloodstains on the walls, you gather that he is not very
friendly, though he likes people." 1>)
                     (<G? .VARS 0>
                      <TELL 
"The cyclops is standing in the corner, eyeing you closely.  I don't
think he likes you very much.  He looks extremely hungry even for a
cyclops.">)
                     (<L? .VARS 0>
                      <TELL 
"The cyclops, having eaten the hot peppers, appears to be gasping.
His enflamed tongue protrudes from his man-sized mouth.">)>
               <COND (,CYCLOPS-FLAG!-FLAG)
                     (<OR <0? .VARS> <TELL <NTH ,CYCLOMAD <ABS .VARS>>>>)>)>>

<PSETG CYCLOMAD
      '["The cyclops seems somewhat agitated."
        "The cyclops appears to be getting more agitated."
        "The cyclops is moving about the room, looking for something."
        
"The cyclops was looking for salt and pepper.  I think he is gathering
condiments for his upcoming snack."
        "The cyclops is moving toward you in an unfriendly manner."
        "You have two choices: 1. Leave  2. Become dinner."]>

<GDECL (CYCLOMAD) <VECTOR [REST STRING]>>

<DEFINE AOS-SOS (FOO)
  #DECL ((FOO) FIX)
  <COND (<L? .FOO 0> <SET FOO <- .FOO 1>>)
        (<SET FOO <+ .FOO 1>>)>
  <COND (,CYCLOPS-FLAG!-FLAG)
        (<TELL <NTH ,CYCLOMAD <ABS .FOO>>>)>
  .FOO>

<SETG ECHO-FLAG!-FLAG <>>

<DEFINE ECHO-ROOM ("AUX" (READER-STRING ,READER-STRING)
                   (B ,INBUF) L (RM <FIND-ROOM "ECHO">) (OUTCHAN ,OUTCHAN)
                   VERB (WALK ,WALK!-WORDS)) 
        #DECL ((OUTCHAN) CHANNEL (WALK VERB) VERB
               (READER-STRING) STRING (PRSACT) VERB (B) STRING (L) FIX (RM) ROOM)
        <COND (,ECHO-FLAG!-FLAG)
              (<UNWIND
                <PROG ()
                 <MAPF <>
                   <FUNCTION (OBJ) #DECL ((OBJ) OBJECT)
                     <COND (<OVIS? .OBJ>
                            <TRO .OBJ ,ECHO-ROOM-BIT>
                            <TRZ .OBJ ,OVISON>)>>
                   <ROBJS .RM>>
                <REPEAT ((PRSVEC ,PRSVEC) RANDOM-ACTION)
                       #DECL ((PRSVEC) VECTOR)
                       <SET L
                            <READSTRING .B
                                        ,INCHAN
                                        .READER-STRING>>
                       ;"<READCHR ,INCHAN>
                       <OR ,ALT-FLAG <READCHR ,INCHAN>>"
                       <SETG MOVES <+ ,MOVES 1>>
                       <COND (<AND <EPARSE <LEX .B <REST .B .L> T> T>
                                   <==? <SET VERB <1 .PRSVEC>> .WALK>
                                   <2 .PRSVEC>
                                   <MEMQ <CHTYPE <2 .PRSVEC> ATOM>
                                         <REXITS .RM>>>
                              <SET RANDOM-ACTION <VFCN .VERB>>
                              <APPLY-RANDOM .RANDOM-ACTION>
                              <COND (<N==? ,HERE .RM>
                                     <MAPF <>
                                       <FUNCTION (X) #DECL ((X) OBJECT)
                                         <COND (<TRNN .X ,ECHO-ROOM-BIT>
                                                <TRZ .X ,ECHO-ROOM-BIT>
                                                <TRO .X ,OVISON>)>>
                                       <ROBJS .RM>>)>
                              <RETURN T>)
                             (<PRINTSTRING .B .OUTCHAN .L>
                              <SETG TELL-FLAG T>
                              <CRLF>
                              <COND (<==? <MEMBER "ECHO" <UPPERCASE .B>> .B>
                                     <TELL "The acoustics of the room change subtly."
                                           1>
                                     <SETG ECHO-FLAG!-FLAG T>
                                     <MAPF <>
                                           <FUNCTION (X) #DECL ((X) OBJECT)
                                                     <COND (<TRNN .X ,ECHO-ROOM-BIT>
                                                            <TRZ .X ,ECHO-ROOM-BIT>
                                                            <TRO .X ,OVISON>)>>
                                           <ROBJS .RM>>
                                     <RETURN T>)>)>>>
                <PROG ()
                      <GOTO <FIND-ROOM "CHAS3">>
                      <SETG MOVES <+ ,MOVES 1>>
                      <MAPF <>
                            <FUNCTION (X) #DECL ((X) OBJECT)
                              <COND (<TRNN .X ,ECHO-ROOM-BIT>
                                     <TRZ .X ,ECHO-ROOM-BIT>
                                     <TRO .X ,OVISON>)>>
                            <ROBJS .RM>>>>)>>

<DEFINE LEAPER ("AUX" (RM ,HERE) (EXITS <REXITS .RM>) M)
   #DECL ((RM) ROOM (EXITS) EXIT (M) <OR <PRIMTYPE VECTOR> FALSE>)
   <COND (<SET M <MEMQ DOWN!-WORDS .EXITS>>
          <COND (<OR <TYPE? <2 .M> NEXIT>
                     <AND <TYPE? <2 .M> CEXIT>
                          <NOT <CXFLAG <2 .M>>>>>
                 <JIGS-UP <PICK-ONE ,JUMPLOSS>>)>)
         (<TELL <PICK-ONE ,WHEEEEE>>)>>

<DEFINE SKIPPER ()
    <TELL <PICK-ONE ,WHEEEEE>>>

<SETG HS 0>
<GDECL (HS) FIX>
<DEFINE HELLO ("AUX" (PRSOBJ <2 ,PRSVEC>) (AMT <SETG HS <+ ,HS 1>>))
    #DECL ((PRSOBJ) <OR OBJECT FALSE> (AMT) FIX)
    <COND (.PRSOBJ
           <COND (<==? .PRSOBJ <FIND-OBJ "SAILO">>
                  <COND (<0? <MOD .AMT 20>>
                         <TELL
"You seem to be repeating yourself.">)
                        (<0? <MOD .AMT 10>>
                         <TELL
"I think that phrase is getting a bit worn out.">)
                        (<TELL 
"Nothing happens here.">)>)
                 (<==? .PRSOBJ <FIND-OBJ "AVIAT">>
                  <TELL "Here, nothing happens.">)
                 (<TELL
"I think that only schizophrenics say 'Hello' to a " 1 <ODESC2 .PRSOBJ> ".">)>)
          (<TELL <PICK-ONE ,HELLOS>>)>>

<PSETG HELLOS
      '["Hello."
        "Good day."
        "Nice weather we've been having lately"
        "How are you?"
        "Goodbye."]>

<PSETG WHEEEEE
      '["Very good.  Now you can go to the second grade."
        "Have you tried hopping around the dungeon, too?"
        "Are you enjoying yourself?"
        "Wheeeeeeeeee!!!!!"
        "Do you expect me to applaud?"]>

<PSETG JUMPLOSS
      '["You should have looked before you leaped."
        "I'm afraid that leap was a bit much for your weak frame."
        "In the movies, your life would be passing in front of your eyes."
        "Geronimo....."]>

<GDECL (HELLOS WHEEEEE JUMPLOSS) <VECTOR [REST STRING]>>

<DEFINE READER ("AUX" (PV ,PRSVEC) (PO <2 .PV>) (PI <3 .PV>))
    #DECL ((PV) VECTOR (PO) OBJECT (PI) <OR FALSE OBJECT>)
    <COND (<NOT <LIT? ,HERE>>
           <TELL "It is impossible to read in the dark.">)
          (<AND .PI <NOT <TRANSPARENT? .PI>>>
           <TELL "How does one look through a " 1 <ODESC2 .PI> "?">)
          (<NOT <READABLE? .PO>>
           <TELL "How can I read a " 1 <ODESC2 .PO> "?">)
          (<OBJECT-ACTION>)
          (<TELL <OREAD .PO>>)>>
          
<DEFINE WELL ()
    <COND (,RIDDLE-FLAG!-FLAG <TELL "Well what?">)
          (<==? ,HERE <FIND-ROOM "RIDDL">>
           <SETG RIDDLE-FLAG!-FLAG T>
           <TELL
"There is a clap of thunder and the east door opens.">)
          (<TELL "Well what?">)>>

<DEFINE SINBAD ()
    <COND (<AND <==? ,HERE <FIND-ROOM "CYCLO">>
                <MEMQ <FIND-OBJ "CYCLO"> <ROBJS ,HERE>>>
           <SETG CYCLOPS-FLAG!-FLAG T>
           <TELL
"The cyclops, hearing the name of his deadly nemesis, flees the room
by knocking down the wall on the north of the room.">
           <SETG MAGIC-FLAG!-FLAG T>
           <REMOVE-OBJECT <FIND-OBJ "CYCLO">>)
          (<TELL 
"Wasn't he a sailor?">)>>

<DEFINE GRANITE ()
    <TELL "I think you are taking this thing for granite.">>

<PSETG DUMMY
      '["Look around."
        "You think it isn't?"
        "I think you've already done that."]>

<GDECL (DUMMY) <VECTOR [REST STRING]>>

<DEFINE BRUSH ("AUX" (PRSO <2 ,PRSVEC>) (PRSI <3 ,PRSVEC>))
    #DECL ((PRSO) OBJECT (PRSI) <OR OBJECT FALSE>)
    <COND (<==? .PRSO <FIND-OBJ "TEETH">>
           <COND (<AND <==? .PRSI <FIND-OBJ "PUTTY">>
                       <MEMQ .PRSI <AOBJS ,WINNER>>>
                  <JIGS-UP
"Well, you seem to have been brushing your teeth with some sort of
glue. As a result, your mouth gets glued together (with your nose)
and you die of respiratory failure.">)
                 (<NOT .PRSI>
                  <TELL
"Dental hygiene is highly recommended, but I'm not sure what you want
to brush them with.">)
                 (<TELL
"A nice idea, but with a " 1 <ODESC2 .PRSI> "?">)>)
          (<TELL
"If you wish, but I can't understand why??">)>>

<DEFINE RING ("AUX" (PRSOBJ <2 ,PRSVEC>))
    #DECL ((PRSOBJ) <OR OBJECT FALSE>)
    <COND (<==? .PRSOBJ <FIND-OBJ "BELL">>
           <TELL
"Ding, dong.">)
          (<TELL
"How, exactly, can I ring that?">)>>

<DEFINE EAT ("AUX" (PRSVEC ,PRSVEC) (EAT? <>) (DRINK? <>) (PRSOBJ <2 .PRSVEC>)
             NOBJ (AOBJS <AOBJS ,WINNER>))
    #DECL ((PRSOBJ) OBJECT (NOBJ) <OR OBJECT FALSE> (PRSVEC) <VECTOR [3 ANY]>
           (AOBJS) <LIST [REST OBJECT]> (EAT? DRINK?) <OR ATOM FALSE>)
    <COND (<OBJECT-ACTION>)
          (<AND <SET EAT? <EDIBLE? .PRSOBJ>> <MEMQ .PRSOBJ .AOBJS>>
           <COND (<==? <1 .PRSVEC> ,DRINK!-WORDS>
                  <TELL "How can I drink that?">)
                 (<TELL
"Thank you very much.  It really hit the spot.">
                  <PUT ,WINNER ,AOBJS <SPLICE-OUT .PRSOBJ .AOBJS>>)>)
          (<AND <SET DRINK? <DRINKABLE? .PRSOBJ>>
                <SET NOBJ <OCAN .PRSOBJ>>
                <MEMQ .NOBJ .AOBJS>>
           <COND (<OOPEN? .NOBJ>
                  <TELL
"Thank you very much.  I was rather thirsty (from all this talking,
probably).">)
                 (T
                  <TELL
"I'd like to, but I can't get to it.">)>
           <PUT .PRSOBJ ,OCAN <>>
           <PUT .NOBJ ,OCONTENTS <SPLICE-OUT .PRSOBJ <OCONTENTS .NOBJ>>>)
          (<NOT <OR .EAT? .DRINK?>>
           <TELL
"I don't think that the " 1 <ODESC2 .PRSOBJ> " would agree with you.">)
          (<TELL
"I think you should get that first.">)>>

<DEFINE JARGON ()
    <TELL "Well, FOO, BAR, and BLETCH to you too!">>

<DEFINE CURSES ()
    <TELL <PICK-ONE ,OFFENDED>>>

<PSETG OFFENDED 
  '["Such language in a high-class establishment like this!"
    "You ought to be ashamed of yourself."
    "Its not so bad.  You could have been killed already."
    "Tough shit, asshole."
    "Oh, dear.  Such language from a supposed winning adventurer!"]>

<GDECL (OFFENDED) <VECTOR [REST STRING]>>

"ROBBER"

<DEFINE ROBBER ROBBER (HACK
                       "AUX" (RM <HROOM .HACK>) ROBJ
                             (SEEN? <RSEEN? .RM>) (WIN ,WINNER) (WROOM ,HERE)
                             (HOBJ <HOBJ .HACK>) (STILL <FIND-OBJ "STILL">) 
                             HERE? (HH <HOBJS .HACK>) (TREAS <FIND-ROOM "TREAS">))
   #DECL ((HACK) HACK (RM WROOM) ROOM (ROBJ HH) <LIST [REST OBJECT]>
          (SEEN?) <OR ATOM FALSE> (WIN) ADV (HOBJ) OBJECT (ROBBER) ACTIVATION
          (HERE?) <OR ROOM FALSE> (STILL) OBJECT (TREAS) ROOM)
   <PROG ((ONCE <>) OBJT)
     #DECL ((ONCE) <OR ATOM FALSE> (OBJT) <LIST [REST OBJECT]>)
     <COND (<SET HERE? <OROOM .HOBJ>>
            <SET RM .HERE?>)>
     <SET ROBJ <ROBJS .RM>>
     <SET OBJT .HH>
     <COND
      (<AND <==? .RM .TREAS>
            <N==? .RM .WROOM>>
       <COND (.HERE?
              <COND (<==? <OROOM .STILL> .TREAS>
                     <SNARF-OBJECT .HOBJ .STILL>)>
              <REMOVE-OBJECT .HOBJ>
              <SET HERE? <>>)>
       <MAPF <>
             <FUNCTION (X) 
                     #DECL ((X) OBJECT)
                     <COND (<G? <OTVAL .X> 0>
                            <PUT .HACK ,HOBJS <SET HH <SPLICE-OUT .X .HH>>>
                            <INSERT-OBJECT .X .RM>)>>
             .HH>)
      (<==? .RM .WROOM>          ;"Adventurer is in room:  CHOMP, CHOMP"
       <COND
        (<==? .RM .TREAS>)      ; "Don't move, Gertrude"
        (<NOT <HFLAG .HACK>>
         <COND (<AND <NOT .HERE?> <PROB 30>>
                <COND (<==? <OCAN .STILL> .HOBJ>
                       <INSERT-OBJECT .HOBJ .RM>
                       <TELL 
"Someone carrying a large bag is casually leaning against one of the
walls here.  He does not speak, but it is clear from his aspect that
the bag will be taken only over his dead body.">
                       <PUT .HACK ,HFLAG T>
                       <RETURN T .ROBBER>)>)
               (<AND .HERE?
                     <FIGHTING? .HOBJ>
                     <COND (<NOT <WINNING? .HOBJ .WIN>>
                            <TELL
"Your opponent, determining discretion to be the better part of
valor, decides to terminate this little contretemps.  With a rueful
nod of his head, he steps backward into the gloom and disappears.">
                            <REMOVE-OBJECT .HOBJ>
                            <TRZ .HOBJ ,FIGHTING>
                            <SNARF-OBJECT .HOBJ .STILL>
                            <RETURN T .ROBBER>)
                           (<PROB 90>)>>)
               (<AND .HERE? <PROB 30>>
                <TELL 

"The holder of the large bag just left, looking disgusted. 
Fortunately, he took nothing.">
                <REMOVE-OBJECT .HOBJ>
                <SNARF-OBJECT .HOBJ .STILL>
                <RETURN T .ROBBER>)
               (<PROB 70> <RETURN T .ROBBER>)
               (T
                <COND (<MEMQ .STILL <HOBJS .HACK>>
                       <PUT .HACK ,HOBJS <SPLICE-OUT .STILL <HOBJS .HACK>>>
                       <PUT .HOBJ ,OCONTENTS (.STILL)>
                       <PUT .STILL ,OCAN .HOBJ>)>
                <PUT .HACK ,HOBJS <SET HH <ROB-ROOM .RM .HH 100>>>
                <PUT .HACK ,HOBJS <SET HH <ROB-ADV .WIN .HH>>>
                <PUT .HACK ,HFLAG T>
                <COND (<AND <N==? .OBJT .HH> <NOT .HERE?>>
                       <TELL 
"A seedy-looking individual with a large bag just wandered through
the room.  On the way through, he quietly abstracted all valuables
from the room and from your possession, mumbling something about
\"Doing unto others before..\"">)
                      (.HERE?
                       <SNARF-OBJECT .HOBJ .STILL>
                       <COND (<N==? .OBJT .HH>
                              <TELL 
"The other occupant just left, still carrying his large bag.  You may
not have noticed that he robbed you blind first.">)
                             (<TELL 
"The other occupant (he of the large bag), finding nothing of value,
left disgusted.">)>
                       <REMOVE-OBJECT .HOBJ>
                       <SET HERE? <>>)
                      (T
                       <TELL 

"A 'lean and hungry' gentleman just wandered through.  Finding
nothing of value, he left disgruntled.">)>)>)
        (T
         <COND (.HERE?                  ;"Here, already announced."
                <COND (<PROB 30>
                       <PUT .HACK ,HOBJS <SET HH <ROB-ROOM .RM .HH 100>>>
                       <PUT .HACK ,HOBJS <SET HH <ROB-ADV .WIN .HH>>>
                       <COND (<MEMQ <FIND-OBJ "ROPE"> .HH>
                              <SETG DOME-FLAG!-FLAG <>>)>
                       <COND (<==? .OBJT .HH>
                              <TELL
"The other occupant (he of the large bag), finding nothing of value,
left disgusted.">)
                             (T
                              <TELL
"The other occupant just left, still carrying his large bag.  You may
not have noticed that he robbed you blind first.">)>
                       <REMOVE-OBJECT .HOBJ>
                       <SET HERE? <>>
                       <SNARF-OBJECT .HOBJ .STILL>)
                      (<RETURN T .ROBBER>)>)>)>)
      (<AND <MEMQ .HOBJ <ROBJS .RM>>    ;"Leave if victim left"
            <SNARF-OBJECT .HOBJ .STILL>
            <REMOVE-OBJECT .HOBJ>
            <SET HERE? <>>>)
      (<AND <==? <OROOM .STILL> .RM>
            <SNARF-OBJECT .HOBJ .STILL>
            <>>)
      (.SEEN?                                ;"Hack the adventurer's belongings"
       <PUT .HACK ,HOBJS <SET HH <ROB-ROOM .RM .HH 75>>>
       <COND
        (<AND <==? <RDESC2 .RM> ,MAZEDESC> <==? <RDESC2 .WROOM> ,MAZEDESC>>
         <MAPF <>
               <FUNCTION (X) 
                       #DECL ((X) OBJECT)
                       <COND (<AND <CAN-TAKE? .X> <OVIS? .X> <PROB 40>>
                              <TELL 
"You hear, off in the distance, someone saying \"My, I wonder what
this fine "                   3 <ODESC2 .X> " is doing here.\"">
                              <TELL "" 1>
                              <COND (<PROB 60>
                                     <REMOVE-OBJECT .X>
                                     <PUT .X ,OTOUCH? T>
                                     <PUT .HACK ,HOBJS <SET HH (.X !.HH)>>)>
                              <MAPLEAVE>)>>
               <ROBJS .RM>>)
        (<MAPF <>
               <FUNCTION (X) 
                       #DECL ((X) OBJECT)
                       <COND (<AND <0? <OTVAL .X>> <CAN-TAKE? .X> <OVIS? .X> <PROB 20>>
                              <REMOVE-OBJECT .X>
                              <PUT .X ,OTOUCH? T>
                              <PUT .HACK ,HOBJS <SET HH (.X !.HH)>>
                              <COND (<==? .RM .WROOM>
                                     <TELL "You suddenly notice that the "
                                           1
                                           <ODESC2 .X>
                                           " vanished.">)>
                              <MAPLEAVE>)>>
               <ROBJS .RM>>
         <COND (<MEMQ <FIND-OBJ "ROPE"> .HH>
                <SETG DOME-FLAG!-FLAG <>>)>)>)>
     <COND (<SET ONCE <NOT .ONCE>>               ;"Move to next room, and hack."
            <PROG ((ROOMS <HROOMS .HACK>))
              <SET RM <1 .ROOMS>>
              <COND (<EMPTY? <SET ROOMS <REST .ROOMS>>>
                     <SET ROOMS ,ROOMS>)>
              <COND (<RTRNN .RM ,RSACREDBIT>    ;"Can I work here?"
                     <AGAIN>)>
              <PUT .HACK ,HROOM .RM>
              <PUT .HACK ,HFLAG <>>
              <PUT .HACK ,HROOMS .ROOMS>
              <SET SEEN? <RSEEN? .RM>>>
            <AGAIN>)>>                        ;"Drop worthless cruft, sometimes"
   <OR <==? .RM .TREAS>
       <MAPF <>
             <FUNCTION (X) 
                     #DECL ((X) OBJECT)
                     <COND (<AND <0? <OTVAL .X>> <PROB 30>>
                            <PUT .HACK ,HOBJS <SET HH <SPLICE-OUT .X .HH>>>
                            <INSERT-OBJECT .X .RM>
                            <AND <==? .RM .WROOM>
                                 <TELL 
"The robber, rummaging through his bag, dropped a few items he found
valueless." >>)>>
              .HH>>>

<DEFINE SNARF-OBJECT (WHO WHAT)
        #DECL ((WHO WHAT) OBJECT)
        <COND (<AND <N==? <OCAN .WHAT> .WHO>
                    <OR <OROOM .WHAT>
                        <OCAN .WHAT>>>
               <REMOVE-OBJECT .WHAT>
               <PUT .WHAT ,OCAN .WHO>
               <PUT .WHO ,OCONTENTS (.WHAT !<OCONTENTS .WHO>)>)
              (.WHO)>>

<DEFINE ROBBER-FUNCTION ("AUX" (PRSACT <1 ,PRSVEC>)
                         (DEM <GET-DEMON "THIEF">) (PV ,PRSVEC)
                         (PRSOBJ <2 .PV>) (HERE ,HERE) (FLG <>)
                         BRICK FUSE ST F (T <HOBJ .DEM>) (CHALI <FIND-OBJ "CHALI">))
  #DECL ((PV) VECTOR (DEM) HACK (PRSACT) VERB (PRSOBJ) <OR OBJECT FALSE>
         (CHALI T HOBJ ST BRICK FUSE) OBJECT (F) <VECTOR ANY CEVENT> (HERE) ROOM
         (FLG) <OR ATOM FALSE>)
  <COND (<==? .PRSACT ,FIGHT!-WORDS>
         <COND (<==? <OCAN <SET ST <FIND-OBJ "STILL">>> .T> <>)
               (<==? <OROOM .ST> .HERE>
                <SNARF-OBJECT .T .ST>
                <TELL
"The robber, somewhat surprised at this turn of events, nimbly
retrieves his stilletto.">
                T)
               (ELSE
                <TELL
"Annoyed to be left unarmed in such an obviously dangerous
neighborhood, the thief slips off into the shadows.">
                <TRO .CHALI ,TAKEBIT>
                <REMOVE-OBJECT .T>)>)
        (<==? .PRSACT ,DEAD\!!-WORDS>
         <COND (<NOT <EMPTY? <HOBJS .DEM>>>
                <TELL "  His booty remains.">
                <MAPF <> <FUNCTION (X) #DECL ((X) OBJECT)
                                   <INSERT-OBJECT .X .HERE>
                                   <TRO .X ,ECHO-ROOM-BIT>>
                      <HOBJS .DEM>>
                <PUT .DEM ,HOBJS ()>)>
         <TRO .CHALI ,TAKEBIT>
         <COND (<==? .HERE <FIND-ROOM "TREAS">>
                <MAPF <>
                  <FUNCTION (X) #DECL ((X) OBJECT)
                    <COND (<AND <N==? .X .CHALI>
                                <N==? .X .T>>
                           <COND (<TRNN .X ,ECHO-ROOM-BIT>
                                  <TRZ .X ,ECHO-ROOM-BIT>)
                                 (<TRO .X ,OVISON>
                                  <COND (<NOT .FLG>
                                         <SET FLG T>
                                         <TELL
"As the thief dies, the power of his magic decreases, and his
treasures reappear:" 2>)>
                                  <TELL "  A " 2 <ODESC2 .X>>)>)>>
                  <ROBJS .HERE>>)>
         <PUT .DEM ,HACTION <>>)
        (<==? .PRSACT ,FIRST?!-WORDS> <PROB 20>)
        (<==? .PRSACT ,OUT\!!-WORDS>
         <PUT .DEM ,HACTION <>>
         <TRZ <FIND-OBJ "STILL"> ,OVISON>
         <TRO .CHALI ,TAKEBIT>
         <PUT .T ,ODESC1 ,ROBBER-U-DESC>)
        (<==? .PRSACT ,IN\!!-WORDS>
         <COND (<==? <HROOM .DEM> .HERE>
                <TELL
"The robber revives, briefly feigning continued unconsciousness, and
when he sees his moment, scrambles away from you.">)>
         <COND (<TYPE? ,ROBBER NOFFSET> <PUT .DEM ,HACTION ROBBER>)
               (<PUT .DEM ,HACTION ROBBER>)>
         <PUT .T ,ODESC1 ,ROBBER-C-DESC>
         <COND (<AND <==? .HERE <FIND-ROOM "TREAS">>
                     <OROOM <SET CHALI .CHALI>>>
                <TRZ .CHALI ,TAKEBIT>)>
         <TRO <FIND-OBJ "STILL"> ,OVISON>)
        (<AND <TYPE? .PRSOBJ OBJECT>
              <==? <2 .PV> ,KNIFE!-OBJECTS>
              <==? <VNAME .PRSACT> THROW!-WORDS>
              <NOT <TRNN .T ,FIGHTBIT>>>
         <COND (<PROB 10>
                <TELL
"You evidently frightened the robber, though you didn't hit him.  He
flees"           1
                 <COND (<EMPTY? <HOBJS .DEM>>
                        ".")
                       (T
                        <MAPF <> <FUNCTION (X) #DECL ((X) OBJECT)
                                           <INSERT-OBJECT .X .HERE>> <HOBJS .DEM>>
                        <PUT .DEM ,HOBJS ()>
                        ", but the contents of his bag fall on the floor.")>>
                <REMOVE-OBJECT .T>)
               (T
                <TELL
"You missed.  The thief makes no attempt to take the knife, though it
would be a fine addition to the collection in his bag.  He does seem
angered by your attempt.">
                <TRO .T ,FIGHTBIT>)>)
        (<AND <OR <==? .PRSACT ,THROW!-WORDS>
                  <==? .PRSACT ,GIVE!-WORDS>>
              <TYPE? .PRSOBJ OBJECT>
              <N==? .PRSOBJ <HOBJ .DEM>>>
         <COND (<L? <OCAPAC .T> 0>
                <PUT .T ,OCAPAC <- <OCAPAC .T>>>
                <PUT .DEM ,HACTION <COND (<TYPE? ,ROBBER NOFFSET> ,ROBBER)
                                         (ROBBER)>>
                <TRO <FIND-OBJ "STILL"> ,OVISON>
                <PUT .T ,ODESC1 ,ROBBER-C-DESC>
                <TELL
"Your proposed victim suddenly recovers consciousness.">)>
         <COND (<AND <==? .PRSOBJ <SET BRICK <FIND-OBJ "BRICK">>>
                     <==? <OCAN <SET FUSE <FIND-OBJ "FUSE">>> .BRICK>
                     <ORAND .FUSE>
                     <NOT <0? <CTICK <2 <SET F <ORAND .FUSE>>>>>>>
                ; "I.e., he's trying to give us the brick with a lighted fuse."
                <TELL 
"The thief seems rather offended by your offer.  Do you think he's as
stupid as you are?">)
               (<REMOVE-OBJECT .PRSOBJ>
                <PUT .DEM ,HOBJS (.PRSOBJ !<HOBJS .DEM>)>
                <TELL
"The thief places the " 1 <ODESC2 .PRSOBJ> " in his bag and thanks
you politely.">)>)
        (<AND .PRSACT <==? <VNAME .PRSACT> TAKE!-WORDS>>
         <TELL
"Once you got him, what would you do with him?">)>>

<DEFINE CHALICE ("AUX" (PRSA <1 ,PRSVEC>) (CH <2 ,PRSVEC>) TR T)
        #DECL ((PRSA) VERB (CH) OBJECT (TR) ROOM (T) OBJECT)
        <COND (<==? .PRSA ,TAKE!-WORDS>
               <COND (<AND <NOT <OCAN .CH>>
                           <==? <OROOM .CH> <SET TR <FIND-ROOM "TREAS">>>
                           <==? <OROOM <SET T <FIND-OBJ "THIEF">>> .TR>
                           <FIGHTING? .T>
                           <HACTION ,ROBBER-DEMON>>
                      <TELL
"Realizing just in time that you'd be stabbed in the back if you
attempted to take the chalice, you return to the fray.">)>)>>



<DEFINE BURNER ("AUX" (PV ,PRSVEC) (PRSO <2 .PV>) (PRSI <3 .PV>))
     #DECL ((PV) VECTOR (PRSO PRSI) OBJECT)
     <COND (<FLAMING? .PRSI>
            <COND (<OBJECT-ACTION>)
                  (<AND <==? <AVEHICLE ,WINNER> <FIND-OBJ "BALLO">>
                        <BALLOON>>)
                  (<AND <BURNABLE? .PRSO>
                        <COND (<MEMQ .PRSO <AOBJS ,WINNER>>
                               <TELL
"The " 1 <ODESC2 .PRSO> " catches fire.">
                               <JIGS-UP 
"Unfortunately, you were holding it at the time.">)
                              (<HACKABLE? .PRSO ,HERE>
                               <TELL
"The " 1 <ODESC2 .PRSO> " catches fire and is consumed.">
                               <REMOVE-OBJECT .PRSO>)
                              (<TELL "You don't have that.">)>>)
                  (<TELL 
"I don't think you can burn a " 1 <ODESC2 .PRSO> ".">)>)
           (<TELL
"With a " 1 <ODESC2 .PRSI> "??!?">)>>  

<DEFINE TURNER ("AUX" (PV ,PRSVEC) (PRSO <2 .PV>) (PRSI <3 .PV>))
    #DECL ((PV) VECTOR (PRSO PRSI) OBJECT)
    <COND (<TRNN .PRSO ,TURNBIT>
           <COND (<TRNN .PRSI ,TOOLBIT>
                  <OBJECT-ACTION>)
                 (<TELL
"You certainly can't turn it with a " 1 <ODESC2 .PRSI> ".">)>)
          (<TELL
"You can't turn that!">)>>

<PSETG DOORMUNGS
  '["The door is invulnerable."
    "You cannot damage this door."
    "The door is still under warranty."]>

<GDECL (DOORMUNGS) <VECTOR [REST STRING]>>

<DEFINE DDOOR-FUNCTION ("AUX" (PA <1 ,PRSVEC>))
    #DECL ((PA) VERB)
    <COND (<==? .PA ,OPEN!-WORDS>
           <TELL
"The door cannot be opened.">)
          (<==? .PA ,BURN!-WORDS>
           <TELL
"You cannot burn this door.">)
          (<==? .PA ,MUNG!-WORDS>
           <TELL <PICK-ONE ,DOORMUNGS>>)>>

 <DEFINE INFLATER ("AUX" (PRSI <2 ,PRSVEC>) (PRSO <3 ,PRSVEC>))
    #DECL ((PRSI PRSO) OBJECT)
    <COND (<==? .PRSI <FIND-OBJ "IBOAT">>
           <COND (<==? .PRSO <FIND-OBJ "PUMP">>
                  <OBJECT-ACTION>)
                 (<TELL "You would inflate it with that?">)>)
          (<==? .PRSI <FIND-OBJ "RBOAT">>
           <TELL "Inflating it further would probably burst it.">)
          (<TELL "How can you inflate that?">)>>

<DEFINE DEFLATER ("AUX" (PRSO <2 ,PRSVEC>))
    #DECL ((PRSO) OBJECT)
    <COND (<==? .PRSO <FIND-OBJ "RBOAT">>
           <OBJECT-ACTION>)
          (<TELL "Come on, now!">)>>

<DEFINE LOCKER ("AUX" (PRSO <2 ,PRSVEC>))
    #DECL ((PRSO) OBJECT)
    <COND (<==? .PRSO <FIND-OBJ "GRAT2">>
           <SETG GRUNLOCK!-FLAG <>>
           <TELL "The grate is locked.">
           <MAPF <>
                 <FUNCTION (X)
                           #DECL ((X) <OR CEXIT NEXIT ROOM>)
                           <COND (<AND <TYPE? .X CEXIT>
                                       <==? <CXFLAG .X> KEY-FLAG!-FLAG>>
                                  <PUT .X ,CXSTR "The grate is locked.">
                                  <MAPLEAVE>)>>
                 <REXITS ,HERE>>)
          (<TELL "It doesn't seem to work.">)>>

<DEFINE UNLOCKER ("AUX" (PRSO <2 ,PRSVEC>) (PRSI <3 ,PRSVEC>) (R <FIND-ROOM "MGRAT">))
    #DECL ((PRSO PRSI) OBJECT (R) ROOM)
    <COND (<==? .PRSO <FIND-OBJ "GRAT2">>
           <COND (<==? .PRSI <FIND-OBJ "KEYS">>
                  <SETG GRUNLOCK!-FLAG T>
                  <TELL "The grate is unlocked.">
                  <MAPF <>
                        <FUNCTION (X)
                          #DECL ((X) <OR CEXIT NEXIT ROOM>)
                          <COND (<AND <TYPE? .X CEXIT>
                                      <==? <CXFLAG .X> KEY-FLAG!-FLAG>>
                                 <PUT .X ,CXSTR "The grate is closed.">
                                 <MAPLEAVE>)>>
                        <REXITS .R>>)
                 (<TELL "Can you unlock a grating with a " 1 <ODESC2 .PRSI> "?">)>)
          (<TELL "It doesn't seem to work.">)>>

<DEFINE KILLER ("AUX" (PV ,PRSVEC) (PRSO <2 .PV>) (PRSI <3 .PV>))
        #DECL ((PV) VECTOR (PRSO PRSI) <OR FALSE OBJECT>)
        <COND (<NOT .PRSO>
               <TELL "There is nothing here to kill.">)
              (<NOT .PRSI>
               <TELL "Trying to kill a " 1 <ODESC2 .PRSO>
                     " with your bare hands is suicidal.">)
              (<NOT <TRNN .PRSI ,WEAPONBIT>>
               <TELL "Trying to kill a " 0 <ODESC2 .PRSO>
                     " with a ">
               <TELL <ODESC2 .PRSI> 1 " is suicidal.">) 
              (ELSE
               <BLOW ,PLAYER .PRSO <ORAND .PRSI> T <>>)>>

<DEFINE ATTACKER ("AUX" (PV ,PRSVEC) (PRSO <2 .PV>) (PRSI <3 .PV>))
        #DECL ((PV) VECTOR (PRSO PRSI) <OR FALSE OBJECT>)
        <COND (<NOT .PRSO>
               <TELL "There is nothing here to attack.">)
              (<NOT .PRSI>
               <TELL "Attacking a " 1 <ODESC2 .PRSO>
                     " with your bare hands is suicidal.">)
              (<NOT <TRNN .PRSI ,WEAPONBIT>>
               <TELL "Attacking a " 0 <ODESC2 .PRSO>
                      " with a ">
               <TELL <ODESC2 .PRSI> 1 " is suicidal.">)
              (ELSE
               <BLOW ,PLAYER .PRSO <ORAND .PRSI> T <>>)>>

<DEFINE SWINGER ("AUX" (PV ,PRSVEC) (PRSO <2 .PV>) (PRSI <3 .PV>))
        #DECL ((PV) VECTOR (PRSO PRSI) <OR FALSE OBJECT>) 
        <PUT .PV 2 .PRSI>
        <PUT .PV 3 .PRSO>
        <ATTACKER>>

<DEFINE HACK-HACK (OBJ STR "OPTIONAL" (OBJ2 <>))
    #DECL ((OBJ) OBJECT (STR) STRING (OBJ2) <OR FALSE STRING>)
    <COND (<OBJECT-ACTION>)
          (.OBJ2
           <TELL .STR 0 <ODESC2 .OBJ> " with a ">
           <TELL .OBJ2 1 <PICK-ONE ,HO-HUM>>)
          (ELSE
           <TELL .STR 1 <ODESC2 .OBJ> <PICK-ONE ,HO-HUM>>)>>

<PSETG HO-HUM
 '[" does not seem to do anything."
   " is not notably useful."
   " isn't very interesting."
   " doesn't appear worthwhile."
   " has no effect."
   " doesn't do anything."]>

<GDECL (HO-HUM) <VECTOR [REST STRING]>>

<DEFINE MUNGER ("AUX" (PRSO <2 ,PRSVEC>) (PRSW <3 ,PRSVEC>))
    #DECL ((PRSW) <OR OBJECT FALSE> (PRSO) OBJECT)
    <COND (<TRNN .PRSO ,VILLAIN>
           <COND (.PRSW
                  <COND (<TRNN .PRSW ,WEAPONBIT>
                         <BLOW ,PLAYER .PRSO <ORAND .PRSW> T <>>)
                        (T
                         <TELL "Munging a " 0 <ODESC2 .PRSO> " with a ">
                         <TELL <ODESC2 .PRSW> 1 " is quite self-destructive.">)>)
                 (T
                  <TELL "Munging a " 1 <ODESC2 .PRSO> " with your bare hands is suicidal.">)>)
          (<HACK-HACK .PRSO "Munging a ">)>>

<DEFINE KICKER ("AUX" (PRSO <2 ,PRSVEC>))
    #DECL ((PRSO) OBJECT)
    <HACK-HACK .PRSO "Munging a ">>

<DEFINE WAVER ("AUX" (PRSO <2 ,PRSVEC>))
    #DECL ((PRSO) OBJECT)
    <HACK-HACK .PRSO "Waving a ">>

<DEFINE R/L ("AUX" (PRSO <2 ,PRSVEC>))
    #DECL ((PRSO) OBJECT)
    <HACK-HACK .PRSO "Playing in this way with a ">>

<DEFINE RUBBER ("AUX" (PRSO <2 ,PRSVEC>))
    #DECL ((PRSO) OBJECT)
    <HACK-HACK .PRSO "Fiddling with a ">>

<DEFINE EXORCISE ()
    <COND (<OBJECT-ACTION>) (T)>>
          
<DEFINE PLUGGER ()
    <COND (<OBJECT-ACTION>)
          (<TELL "This has no effect.">)>>

<DEFINE UNTIE ("AUX" (PRSO <2 ,PRSVEC>))
    #DECL ((PRSO) OBJECT)
    <COND (<OBJECT-ACTION>)
          (<TRNN .PRSO ,TIEBIT>
           <TELL "I don't think so.">)
          (<TELL "This cannot be tied, so it cannot be untied!">)>>

<DEFINE PUSHER ("AUX" (PRSO <2 ,PRSVEC>))
    #DECL ((PRSO) OBJECT)
    <COND (<OBJECT-ACTION>)
          (<MEMQ BUTTO!-OBJECTS <ONAMES .PRSO>>)
          (<HACK-HACK .PRSO "Pushing the ">)>>

<DEFINE TIE ("AUX" (PRSO <2 ,PRSVEC>))
    #DECL ((PRSO) OBJECT)
    <COND (<TRNN .PRSO ,TIEBIT>
           <COND (<OBJECT-ACTION>)
                 (<TELL "You can't tie it to that.">)>)
          (<TELL "How can you tie that to anything.">)>>

<DEFINE MELTER ("AUX" (PRSO <2 ,PRSVEC>))
    #DECL ((PRSO) OBJECT)
    <COND (<OBJECT-ACTION>)
          (<TELL "I'm not sure that a " 1 <ODESC2 .PRSO> " can be melted.">)>>

<SETG ON-POLE!-FLAG <>>

<DEFINE BODY-FUNCTION ("AUX" (PRSA <1 ,PRSVEC>))
    #DECL ((PRSA) VERB)
    <COND (<==? .PRSA ,TAKE!-WORDS>
           <TELL "A force keeps you from taking the bodies.">)
          (<OR <==? .PRSA ,MUNG!-WORDS>
               <==? .PRSA ,BURN!-WORDS>>
           <COND (,ON-POLE!-FLAG)
                 (<SETG ON-POLE!-FLAG T>
                  <INSERT-OBJECT <FIND-OBJ "HPOLE"> <FIND-ROOM "LLD2">>)>
           <JIGS-UP 
"The voice of the guardian of the dungeon booms out from the darkness 
'Your disrespect costs you your life!' and places your head on a pole.">)>>

<DEFINE MUMBLER ()
    <TELL "You'll have to speak up if you expect me to hear you!">>

<DEFINE ALARM ("AUX" (PRSO <2 ,PRSVEC>))
    #DECL ((PRSO) OBJECT)
    <COND (<TRNN .PRSO ,SLEEPBIT>
           <OBJECT-ACTION>)
          (<TELL "The " 1 <ODESC2 .PRSO> " isn't sleeping.">)>>

<DEFINE ZORK ()
    <TELL "That word is replaced henceforth with DUNGEON.">>

<DEFINE DUNGEON ()
    <TELL "At your service!">>

<DEFINE PAINTING ("AUX" (PRSA <1 ,PRSVEC>) (ART <2 ,PRSVEC>))
    #DECL ((PRSA) VERB (ART) OBJECT)
    <COND (<==? .PRSA ,MUNG!-WORDS>
           <PUT .ART ,OTVAL 0>
           <PUT .ART ,ODESC2 "worthless piece of canvas">
           <PUT .ART ,ODESC1 "There is a worthless piece of canvas here.">
           <TELL
"Congratulations!  Unlike the other vandals, who merely stole the
artist's masterpieces, you have destroyed one.">)>>

<PSETG DIMMER "The lamp appears to be getting dimmer.">

<PSETG LAMP-TICKS [50 30 20 10 4 0]>

<PSETG LAMP-TELLS [,DIMMER ,DIMMER ,DIMMER ,DIMMER "The lamp is dying."]>

<DEFINE LANTERN ("AUX" (PV ,PRSVEC) (VERB <1 .PV>) (HERE ,HERE)
                       (RLAMP <FIND-OBJ "LAMP">) FOO)
        #DECL ((PV) VECTOR (VERB) VERB (HERE) ROOM (RLAMP) OBJECT
               (FOO) <VECTOR ANY CEVENT>)
        <COND (<==? .VERB ,THROW!-WORDS>
               <TELL 
"The lamp has smashed into the floor and the light has gone out.">
               <REMOVE-OBJECT <FIND-OBJ "LAMP">>
               <INSERT-OBJECT <FIND-OBJ "BLAMP"> .HERE>)
              (<==? .VERB ,C-INT!-WORDS>
               <LIGHT-INT .RLAMP ,LNTIN ,LAMP-TICKS ,LAMP-TELLS>)
              (<==? .VERB ,TURN-ON!-WORDS>
               <CLOCK-ENABLE <2 <SET FOO <ORAND .RLAMP>>>>
               <>)
              (<==? .VERB ,TURN-OFF!-WORDS>
               <CLOCK-DISABLE <2 <SET FOO <ORAND .RLAMP>>>>
               <>)>>

<DEFINE SWORD-GLOW (DEM
                    "AUX" (SW <HOBJ .DEM>) (G <OTVAL .SW>) (HERE ,HERE) (NG 0))
   #DECL ((DEM) HACK (SW) OBJECT (NG G) FIX (HERE) ROOM)
   <COND (<AND <NOT <OROOM .SW>> <NOT <OCAN .SW>>
               <MEMQ .SW <AOBJS ,PLAYER>>>
          <COND (<INFESTED? .HERE> <SET NG 2>)
                (<MAPF <>
                       <FUNCTION (E) 
                                 #DECL ((E) <OR ROOM CEXIT NEXIT ATOM>)
                                 <COND (<TYPE? .E ROOM>
                                        <AND <INFESTED? .E> <MAPLEAVE T>>)
                                       (<TYPE? .E CEXIT>
                                        <AND <INFESTED? <2 .E>> <MAPLEAVE T>>)>>
                       <REXITS .HERE>>
                 <SET NG 1>)>
          <COND (<==? .NG .G>)
                (<==? .NG 2> <TELL "Your sword has begun to glow very brightly.">)
                (<1? .NG> <TELL "Your sword is glowing with a faint blue glow.">)
                (<0? .NG> <TELL "Your sword is no longer glowing.">)>
          <PUT .SW ,OTVAL .NG>)
         (<PUT .DEM ,HACTION <>>)>>

<DEFINE SWORD ("AUX" (PA <1 ,PRSVEC>))
        #DECL ((PA) VERB)
        <COND (<AND <==? .PA ,TAKE!-WORDS>
                    <==? ,WINNER ,PLAYER>>
               <PUT ,SWORD-DEMON ,HACTION <COND (<TYPE? ,SWORD-GLOW NOFFSET>
                                                 ,SWORD-GLOW)
                                                (SWORD-GLOW)>>
               <>)>>

<DEFINE INFESTED? (R "AUX" (VILLAINS ,VILLAINS) (DEM <GET-DEMON "THIEF">)) 
        #DECL ((R) ROOM (VILLAINS) <LIST [REST OBJECT]> (DEM) HACK)
        <OR <AND <==? .R <HROOM .DEM>>
                 <HACTION .DEM>>
            <MAPF <>
                  <FUNCTION (V) 
                          #DECL ((V) OBJECT)
                          <COND (<==? .R <OROOM .V>> <MAPLEAVE T>)>>
                  .VILLAINS>>>


<PSETG CDIMMER "The candles grow shorter.">

<PSETG CANDLE-TICKS [20 10 5 0]>

<PSETG CANDLE-TELLS [,CDIMMER ,CDIMMER "The candles are very short."]>

<DEFINE MATCH-FUNCTION ("AUX" (PRSA <1 ,PRSVEC>) (PRSO <2 ,PRSVEC>)
                        (MATCH <FIND-OBJ "MATCH">) (MC <ORAND .MATCH>))
    #DECL ((PRSA) VERB (MATCH) OBJECT (MC) FIX)
    <COND (<AND <==? .PRSA ,LIGHT!-WORDS> <==? .PRSO .MATCH>>
           <COND (<AND <PUT .MATCH ,ORAND <SET MC <- .MC 1>>>
                       <L=? .MC 0>>
                  <TELL "I'm afraid that you have run out of matches.">)
                 (<TRO .MATCH ,FLAMEBIT>
                  <PUT .MATCH ,OLIGHT? 1>
                  <CLOCK-INT ,MATIN 2>
                  <TELL "One of the matches starts to burn.">)>)
          (<AND <==? .PRSA ,TURN-OFF!-WORDS> <1? <OLIGHT? .MATCH>>>
           <TELL "The match is out.">
           <TRZ .MATCH ,FLAMEBIT>
           <PUT .MATCH ,OLIGHT? 0>
           <CLOCK-INT ,MATIN 0>
           T)
          (<==? .PRSA ,C-INT!-WORDS>
           <TELL "The match has gone out.">
           <TRZ .MATCH ,FLAMEBIT>
           <PUT .MATCH ,OLIGHT? 0>)>>

<DEFINE CANDLES ("AUX" (PRSACT <1 ,PRSVEC>) (C <FIND-OBJ "CANDL">)
                       (WINNER ,WINNER) (AO <AOBJS .WINNER>) (W <3 ,PRSVEC>)
                       MATCH FOO ORPHANS)
        #DECL ((PRSACT) VERB (MATCH C) OBJECT (W) <OR FALSE OBJECT> (WINNER) ADV
               (AO) <LIST [REST OBJECT]> (FOO) <VECTOR FIX CEVENT>
               (ORPHANS) <VECTOR [4 ANY]>)
        <OR <ORAND .C> <PUT .C ,ORAND [0 <CLOCK-INT ,CNDIN 50>]>>
        <SET FOO <ORAND .C>>
        <COND (<==? .PRSACT ,LIGHT!-WORDS>
               <COND (<0? <OLIGHT? .C>>
                      <TELL 
"Alas, there's not much left of the candles.  Certainly not enough to
burn.">)
                     (<NOT .W>
                      <TELL "With what?">
                      <PUT <SET ORPHANS ,ORPHANS>
                           ,OFLAG T>
                      <PUT .ORPHANS ,OVERB LIGHT!-ACTIONS>
                      <PUT .ORPHANS ,OSLOT1 .C>
                      <PUT .ORPHANS ,OPREP <CHTYPE WITH!-WORDS PREP>>
                      <SETG PARSE-WON <>>
                      T)
                     (<AND <==? .W <SET MATCH <FIND-OBJ "MATCH">>>
                           <1? <OLIGHT? .MATCH>>>
                      <COND (<1? <OLIGHT? .C>>
                             <TELL "The candles are already lighted.">)
                            (<PUT .C ,OLIGHT? 1>
                             <TELL "The candles are lighted.">
                             <CLOCK-ENABLE <2 .FOO>>)>)
                     (<==? .W <FIND-OBJ "TORCH">>
                      <COND (<1? <OLIGHT? .C>>
                             <TELL 
"You realize, just in time, that the candles are already lighted.">)
                            (<TELL 
"The heat from the torch is so intense that the candles are vaporised.">
                             <COND (<OR <OROOM .C> <OCAN .C>>
                                    <REMOVE-OBJECT .C>)
                                   (<PUT .WINNER ,AOBJS <SPLICE-OUT .C .AO>>)>)>)
                     (<TELL
"You have to light them with something that's burning, you know.">)>)
              (<==? .PRSACT ,TURN-OFF!-WORDS>
               <CLOCK-DISABLE <2 .FOO>>
               <COND (<1? <OLIGHT? .C>>
                      <TELL "The flame is extinguished.">
                      <PUT .C ,OLIGHT? -1>)
                     (<TELL "The candles are not lighted.">)>)
              (<==? .PRSACT ,C-INT!-WORDS>
               <LIGHT-INT .C ,CNDIN ,CANDLE-TICKS ,CANDLE-TELLS>)>>

<DEFINE BLACK-BOOK ("AUX" (PV ,PRSVEC) (V <1 .PV>) (B <2 .PV>))
  #DECL ((PV) <VECTOR [3 ANY]> (B) OBJECT (V) VERB)
  <COND (<==? .V ,BURN!-WORDS>
         <COND (<OROOM .B>
                <REMOVE-OBJECT .B>)
               (<DROP-OBJECT .B>)>
         <JIGS-UP
"A booming voice says 'Wrong, cretin!' and you notice that you have
turned into a pile of dust.">)>>

<DEFINE LIGHT-INT (OBJ CEV TICK TELL "AUX" CNT TIM (FOO <ORAND .OBJ>))
    #DECL ((OBJ) OBJECT (FCN) APPLICABLE (TICK) <VECTOR [REST FIX]>
            (TELL) <VECTOR [REST STRING]> (TIM CNT) FIX (FOO) <VECTOR FIX CEVENT>)
    <PUT .FOO 1 <SET CNT <+ <1 .FOO> 1>>>
    <CLOCK-INT .CEV <SET TIM <NTH .TICK .CNT>>>
    <COND (<0? .TIM>
           <COND (<OR <NOT <OROOM .OBJ>> <==? <OROOM .OBJ> ,HERE>>
                  <TELL "I hope you have more light than from a " 1 <ODESC2 .OBJ> ".">)>
           <PUT .OBJ ,OLIGHT? 0>)
          (<OR <NOT <OROOM .OBJ>>
               <==? <OROOM .OBJ> ,HERE>>
           <TELL <NTH .TELL .CNT>>)>>

<DEFINE HACKABLE? (OBJ RM "AUX" (AV <AVEHICLE ,WINNER>))
    #DECL ((OBJ) OBJECT (RM) ROOM (AV) <OR FALSE OBJECT>)
    <COND (.AV
           <SEARCH-LIST <OID .OBJ> <OCONTENTS .AV> <>>)
          (<SEARCH-LIST <OID .OBJ> <ROBJS .RM> <>>)>>
