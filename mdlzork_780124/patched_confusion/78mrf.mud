
<OR <GASSIGNED? END-GAME!-FLAG> <BLOAT 20000 0 0 500>>

"============ ZORK END-GAME FUNCTIONS ============="

<SETG END-GAME-EXISTS? T>

;"enable endgame"

<SETG END-GAME!-FLAG <>>

;"endgame has begun?"

<DEFMAC DOPEN ('OBJ) <FORM TRO .OBJ ,OPENBIT>>

<DEFMAC DCLOSE ('OBJ) <FORM TRZ .OBJ ,OPENBIT>>

<DEFINE DPR (OBJ)
        #DECL ((OBJ) OBJECT)
        <COND (<OOPEN? .OBJ> "open.")("closed.")>>

"============ Is There Life after Death? =========="

<DEFINE TOMB-FUNCTION ("AUX" (VB <1 ,PRSVEC>))
  #DECL ((VB) VERB)
  <COND (<==? .VB ,LOOK!-WORDS>
         <TELL
"You are in the Tomb of the Unknown Implementer.
A hollow voice says:  \"That's not a bug, it's a feature!\"
In the north wall of the room is the Crypt of the Implementers.  It
is made of the finest marble, and apparently large enough for four
headless corpses.  The crypt is " 1 <DPR <FIND-OBJ "TOMB">>
                                         " Above the entrance is the
cryptic inscription:

                     \"Feel Free.\"
">)>>

<DEFINE CRYPT-FUNCTION ("AUX" (VB <1 ,PRSVEC>) (EG? ,END-GAME!-FLAG))
  #DECL ((VB) VERB (EG?) <OR ATOM FALSE>)
  <COND (<AND .EG? <==? .VB ,LOOK!-WORDS>>
         <TELL
"Though large and esthetically pleasing the marble crypt is empty; the
sarcophagi, bodies, and rich treasure to be expected in a tomb of
this magnificence are missing. Inscribed on one wall is the motto of
the implementers, \"Feel Free\".  There is a door leading out of the
crypt to the south.  The door is "
                1
                <DPR <FIND-OBJ "TOMB">>>)>>

<DEFINE CRYPT-OBJECT ("AUX" (VB <1 ,PRSVEC>) (EG? ,END-GAME!-FLAG)
                      (C <FIND-OBJ "TOMB">))
  #DECL ((VB) VERB (EG?) <OR ATOM FALSE> (C) OBJECT)
  <COND (<AND <NOT .EG?> <HEAD-FUNCTION>>)
        (<AND .EG? <==? .VB ,OPEN!-WORDS>>
         <COND (<NOT <OOPEN? .C>>
                <DOPEN .C>
                <TELL
"The door of the crypt is extremely heavy, but it opens easily.">)
               (ELSE
                <TELL "The crypt is already open.">)>
         T)
        (<AND .EG? <==? .VB ,CLOSE!-WORDS>>
         <COND (<OOPEN? .C>
                <DCLOSE .C>
                <TELL "The crypt is closed.">)
               (ELSE <TELL "The crypt is already closed.">)>
         <COND (<==? ,HERE <FIND-ROOM "CRYPT">>
                <CLOCK-INT ,STRTE 3>)>)>>

<DEFINE START-END ("AUX" (HERE ,HERE) LAMP)
        #DECL ((HERE) ROOM (LAMP) OBJECT)
        <COND (<==? .HERE <FIND-ROOM "CRYPT">>
               <COND (<LIT? .HERE>
                      <CLOCK-INT ,STRTE 3>)
                     (ELSE
                      <TELL

"Suddenly, as you wait in the dark, you begin to feel somewhat
disoriented.  The feeling passes, but something seems different.">
                      <SET LAMP <FIND-OBJ "LAMP">>
                      <TRO .LAMP ,LIGHTBIT>
                      <TRZ .LAMP ,ONBIT>
                      <PUT <1 <SET C <ORAND .LAMP>>> ,ORAND 0>
                      <PUT <2 .C> ,CTICK 350>
                      <PUT <2 .C> ,CFLAG <>>
                      <PUT ,WINNER ,AOBJS (.LAMP)>
                      <GOTO <FIND-ROOM "TSTRS">>)>)>>



"========== It's All Done with Mirrors =========="

<SETG MR1!-FLAG T>

<SETG MR2!-FLAG T>

<SETG MLOC <FIND-ROOM "MRB">>

<SETG MIRROR-OPEN!-FLAG <>>

<SETG WOOD-OPEN!-FLAG <>>

<SETG MRSWPUSH!-FLAG <>>

<DEFINE MRGO ("AUX" (DIR <CHTYPE <2 ,PRSVEC> ATOM>)
                    (NRM <MEMQ .DIR <REXITS ,HERE>>) (CEX <2 .NRM>)
                    (TORM <CXROOM .CEX>))
        #DECL ((DIR) ATOM (NRM) <<PRIMTYPE VECTOR> ATOM CEXIT>
               (CEX) CEXIT (TORM) ROOM)
        <COND (<MEMQ .DIR '[NORTH!-DIRECTIONS SOUTH!-DIRECTIONS]>
               <COND (<==? ,MLOC .TORM>
                      <COND (<N-S ,MDIR>
                             <TELL "There is a wooden wall blocking your way.">)
                            (<TELL "A large mirror blocks your way.">)>
                      <>)
                     (.TORM)>)
              (<==? ,MLOC .TORM>
               <COND (<N-S ,MDIR> <GO-E-W .TORM .DIR>)
                     (<TELL "There is a large mirror blocking your way."> <>)>)
              (<GO-E-W .TORM .DIR>)>>

<DEFINE GO-E-W (RM DIR
                "AUX" (SPR <SPNAME <RID .RM>>) (SPD <SPNAME .DIR>)
                      (STR ,MRESTR))
        #DECL ((RM) ROOM (DIR) ATOM (SPR SPD STR) STRING)
        <OR <==? <2 .SPD> !\E> <SET STR ,MRWSTR>>
        <FIND-ROOM <SUBSTRUC .SPR 0 3 .STR>>>

<SETG MRESTR "   E">

<SETG MRWSTR "MRBW">

<DEFMAC N-S ('FX) <FORM 0? <FORM MOD .FX 180>>>

<DEFMAC E-W ('FX) <FORM OR <FORM ==? .FX 90> <FORM ==? .FX 270>>>

<DEFINE EWTELL (RM "AUX" (EAST? <==? <4 <SPNAME <RID .RM>>> !\E>) BROKEN M1?) 
        #DECL ((RM) ROOM (EAST? MWIN M1?) <OR FALSE ATOM>)
        <SET MWIN
             <COND (<SET M1? <==? 180 <+ ,MDIR <COND (.EAST? 0) (180)>>>>
                    ,MR1!-FLAG)
                   (,MR2!-FLAG)>>
        <TELL "You are in a narrow room, whose "
              0
              <COND (.EAST? "west") ("east")>
              " wall is a large ">
        <TELL <COND (.MWIN "mirror.") ("broken mirror.")>>
        <AND .M1? ,MIRROR-OPEN!-FLAG <TELL ,MIROPEN>>
        <TELL "The opposite wall is solid rock.">>

<SETG MIROPEN "The mirror is mounted on a panel which has been opened outward.">

<DEFINE MRCEW ("AUX" (PRSA <1 ,PRSVEC>)) 
        #DECL ((PRSA) VERB)
        <COND (<==? .PRSA ,LOOK!-WORDS> <EWTELL ,HERE> <TELL ,GUARDSTR>)>>

<DEFINE MRBEW ("AUX" (PRSA <1 ,PRSVEC>)) 
        #DECL ((PRSA) VERB)
        <COND (<==? .PRSA ,LOOK!-WORDS>
               <EWTELL ,HERE>
               <TELL "To the north and south are large hallways.">)>>

<DEFINE MRAEW ("AUX" (PRSA <1 ,PRSVEC>)) 
        #DECL ((PRSA) VERB)
        <COND (<==? .PRSA ,LOOK!-WORDS>
               <EWTELL ,HERE>
               <TELL "To the north is a large hallway.">)>>

<DEFINE LOOK-TO (STR NORTH?
                 "AUX" (RM <FIND-ROOM .STR>) (MDIR ,MDIR) MIR? (M1? <>)
                       (DIR <COND (.NORTH? "north") ("south")>))
        #DECL ((STR DIR) STRING (NORTH? MIR? M1?) <OR ATOM FALSE> (RM) ROOM
               (MDIR) FIX)
        <SET MIR?
             <COND (<OR <AND .NORTH? <G? .MDIR 180> <L? .MDIR 359>>
                        <AND <NOT .NORTH?> <G? .MDIR 0> <L? .MDIR 179>>>
                    <SET M1? T>
                    ,MR1!-FLAG)
                   (,MR2!-FLAG)>>
        <COND (<==? ,MLOC .RM>
               <COND (<E-W .MDIR>
                      <TELL "A large mirror fills the "
                            1
                            .DIR
                            " side of the hallway.">
                      <AND .M1?
                           ,MIRROR-OPEN!-FLAG
                           <TELL ,MIROPEN>>
                      <OR .MIR?
                          <TELL "The mirror is shattered into little pieces.">>)
                     (<TELL "The "
                            0
                            .DIR
                            
" side of the room is divided by a wooden wall into small
hallways to the ">
                      <TELL .DIR 0 "east and ">
                      <TELL .DIR 1 "west.">)>)>>

<SETG HALLWAY
      
"You are in a part of the long hallway.  The east and west walls are
dressed stone.  In the center of the hall is a shallow stone channel.
In the center of the room the channel widens into a large hole around
which is engraved a compass rose.">

<DEFINE MRCF ("AUX" (PRSA <1 ,PRSVEC>)) 
        #DECL ((PRSA) VERB)
        <COND (<==? .PRSA ,LOOK!-WORDS>
               <TELL ,HALLWAY>
               <TELL ,GUARDSTR>
               <LOOK-TO "MRG" T>
               <LOOK-TO "MRB" <>>)>>

<DEFINE MRBF ("AUX" (PRSA <1 ,PRSVEC>)) 
        #DECL ((PRSA) VERB)
        <COND (<==? .PRSA ,LOOK!-WORDS>
               <TELL ,HALLWAY>
               <LOOK-TO "MRC" T>
               <LOOK-TO "MRA" <>>)>>

<DEFINE MRAF ("AUX" (PRSA <1 ,PRSVEC>)) 
        #DECL ((PRSA) VERB)
        <COND (<==? .PRSA ,LOOK!-WORDS>
               <TELL ,HALLWAY>
               <LOOK-TO "MRB" T>
               <TELL 
"A passage enters from the south.">)>>

<SETG GUARDKILL
      
"The Guardians awake, and in perfect unison, utterly destroy you with
their stone bludgeons.  Satisfied, they resume their posts.">

<DEFINE GUARDIANS ("AUX" (PRSA <1 ,PRSVEC>))
        #DECL ((PRSA) VERB)
        <COND (<==? .PRSA ,WALK-IN!-WORDS>
               <JIGS-UP ,GUARDKILL>)>>

<DEFINE MIRROR-DIR? (DIR RM "AUX" M (MDIR ,MDIR))
    #DECL ((MDIR) FIX (DIR) ATOM (RM) ROOM
           (M) <OR FALSE <<PRIMTYPE VECTOR> ATOM CEXIT>>)
    <AND <SET M <MEMQ NORTH!-DIRECTIONS <REXITS .RM>>>
         <==? ,MLOC <CXROOM <2 .M>>>
         <COND (<OR <AND <==? .DIR NORTH!-DIRECTIONS>
                         <G? .MDIR 180>
                         <L? .MDIR 360>>
                    <AND <==? .DIR SOUTH!-DIRECTIONS>
                         <G? .MDIR 0>
                         <L? .MDIR 180>>>
                1)
               (2)>>>

<DEFINE MIRROR-HERE? (RM "AUX" (SP <SPNAME <RID .RM>>) (MDIR ,MDIR)) 
        #DECL ((RM) ROOM (SP) STRING (MDIR) FIX)
        <COND (<==? <LENGTH .SP> 4>
               <COND (<==? 180 <+ .MDIR <COND (<==? <4 .SP> !\E> 0) (180)>>> 1)
                     (2)>)
              (<N-S .MDIR> <>)
              (<MIRROR-DIR? NORTH!-DIRECTIONS .RM>)
              (<MIRROR-DIR? SOUTH!-DIRECTIONS .RM>)>>

<SETG MIRBREAK "The mirror breaks, revealing a wooden panel behind it.">

<SETG MIRBROKE "The mirror has already been broken.">

<DEFINE WALL-FUNCTION ("AUX" (PV ,PRSVEC) (PA <1 .PV>) (HERE ,HERE) (NORTH? <>)
                             (MLOC ,MLOC))
        #DECL ((PV) VECTOR (PA) VERB (MLOC HERE) ROOM (NORTH?) <OR FALSE FIX>)
        <COND (<AND <N-S ,MDIR>
                    <OR <SET NORTH? <MIRROR-DIR? NORTH!-DIRECTIONS .HERE>>
                        <MIRROR-DIR? SOUTH!-DIRECTIONS .HERE>>>
               <COND (<==? .PA ,PUSH!-WORDS>
                      <COND (<SET RM <MIRNS .NORTH?>>
                             <MIRMOVE .NORTH? .RM>
                             <GOTO .MLOC>)
                            (<TELL "The structure won't budge.">)>)>)
              (<TELL "I don't see a wooden wall here.">)>>

<DEFINE MIRROR-FUNCTION ("AUX" (PV ,PRSVEC) (PA <1 .PV>) MIRROR)
        #DECL ((PV) VECTOR (PA) VERB (MIRROR) <OR FIX FALSE>)
        <COND (<NOT <SET MIRROR <MIRROR-HERE? ,HERE>>>
               <TELL
"I can't see a mirror here.">)
              (<==? .PA ,C-INT!-WORDS>
               <SETG MIRROR-OPEN!-FLAG <>>
               <TELL "The mirror slams shut.">)
              (<OR <==? .PA ,BREAK!-WORDS>
                   <==? .PA ,PUSH!-WORDS>
                   <==? .PA ,MUNG!-WORDS>>
               <COND (<1? .MIRROR>
                      <COND (,MR1!-FLAG
                             <SETG MR1!-FLAG <>>
                             <TELL ,MIRBREAK>)
                            (<TELL ,MIRBROKE>)>)
                     (,MR2!-FLAG
                      <SETG MR2!-FLAG <>>
                      <TELL ,MIRBREAK>)
                     (<TELL ,MIRBROKE>)>)>>

<SETG DIRVEC
      [NORTH!-DIRECTIONS
       0
       NE!-DIRECTIONS
       45
       EAST!-DIRECTIONS
       90
       SE!-DIRECTIONS
       135
       SOUTH!-DIRECTIONS
       180
       SW!-DIRECTIONS
       225
       WEST!-DIRECTIONS
       270
       NW!-DIRECTIONS
       315]>

<DEFINE MIROUT ("AUX" (DIR <2 <MEMQ <CHTYPE <2 ,PRSVEC> ATOM> ,DIRVEC>>) (MDIR ,MDIR)
                      RM)
        #DECL ((DIR MDIR) FIX (RM) <OR FALSE ROOM>)
        <COND (,MIRROR-OPEN!-FLAG
               <COND (<==? <MOD <+ .MDIR 270> 360> .DIR>
                      <COND (<N-S .MDIR>
                             <MIREW>)
                            (<MIRNS>)>)
                     (<TELL ,NOWAY>
                      <>)>)
              (,WOOD-OPEN!-FLAG
               <COND (<==? <MOD <+ .MDIR 180> 360> .DIR>
                      <COND (<SET RM <MIRNS <N==? 0 .MDIR>>>
                             <TELL "As you leave, the door swings shut.">
                             <SETG WOOD-OPEN!-FLAG <>>
                             .RM)
                            (<TELL ,NOWAY>)>)
                     (<TELL ,NOWAY>
                      <>)>)
              (<TELL ,NOWAY>
               <>)>>

<SETG NOWAY "There is no way to go in that direction.">

<DEFINE MIRNS ("OPTIONAL" (NORTH? <L? ,MDIR 180>)
               "AUX" (MLOC ,MLOC) (REX <REXITS .MLOC>) M EXIT)
        #DECL ((MLOC) ROOM (REX) EXIT (M) <OR FALSE <<PRIMTYPE VECTOR> ATOM>>
               (EXIT) <OR DOOR ROOM CEXIT NEXIT> (NORTH?) <OR FALSE FIX ATOM>)
        <COND (<SET M
                    <MEMQ <COND (.NORTH? NORTH!-DIRECTIONS) (SOUTH!-DIRECTIONS)>
                          .REX>>
               <SET EXIT <2 .M>>
               <COND (<TYPE? .EXIT CEXIT> <CXROOM <2 .M>>)
                     (<TYPE? .EXIT ROOM> .EXIT)>)>>

<DEFINE MIREW ()
    <FIND-ROOM <SUBSTRUC <SPNAME <RID ,MLOC>>
                         0
                         3
                         <COND (<0? ,MDIR> ,MRWSTR)
                               (,MRESTR)>>>>

<DEFINE MIRIN ()
    <COND (<AND <==? <MIRROR-HERE? ,HERE> 1>
                ,MIRROR-OPEN!-FLAG>
           <FIND-ROOM "INMIR">)>>

<DEFINE MREYE-ROOM ("AUX" (PRSA <1 ,PRSVEC>))
    #DECL ((PRSA) VERB)
    <COND (<==? .PRSA ,LOOK!-WORDS>
           <TELL
"You are in a small room, with narrow passages exiting to the north
and south. " 0>
           <COND (<EMPTY? <ROBJS ,HERE>>
                  <TELL "A narrow red beam of light crosses the room at the
north end, inches above the floor.">)>)>>

<DEFINE MRSWITCH ("AUX" (PRSA <1 ,PRSVEC>) (HERE ,HERE)) 
        #DECL ((PRSA) VERB (HERE) ROOM)
        <COND (<==? .PRSA ,PUSH!-WORDS>
               <COND (,MRSWPUSH!-FLAG <TELL "The button is already depressed.">)
                     (<TELL "The button becomes depressed.">
                      <SETG MRSWPUSH!-FLAG T>
                      <COND (<EMPTY? <ROBJS <FIND-ROOM "MREYE">>>)
                            (<CLOCK-ENABLE <CLOCK-INT ,MRINT 6>>
                             <SETG MIRROR-OPEN!-FLAG T>)>)>)
              (<==? .PRSA ,C-INT!-WORDS>
               <SETG MRSWPUSH!-FLAG <>>
               <SETG MIRROR-OPEN!-FLAG <>>
               <COND (<OR <==? <MIRROR-HERE? .HERE> 1>
                          <==? .HERE <FIND-ROOM "INMIR">>>
                      <TELL "The mirror quietly swings shut.">)
                     (<==? .HERE <FIND-ROOM "MRANT">>
                      <TELL "The button pops back to its original position.">)>)
>>

<SETG GUARDSTR
      
"Somewhat to the north, identical stone statues face each other from
pedestals on opposite sides of the corridor.  The statues represent
Guardians of Zork, a military order of ancient lineage.  They are
portrayed as heavily armored warriors standing at ease, hands clasped
around formidable bludgeons.">

<SETG MDIR 270>

;"mirror points... 0 = north"

<SETG STARTROOM <SETG MLOC <FIND-ROOM "MRB">>>

<SETG ENDROOM <FIND-ROOM "FROBN">>

;"FIX THIS"

<SETG POLEUP!-FLAG <>>

;"pole raised?"

<DEFINE MAGIC-MIRROR ("AUX" (PV ,PRSVEC) (PA <1 .PV>)
                      (MDIR ,MDIR) (MLOC ,MLOC) (STARTER <>))
        #DECL ((PV) VECTOR (PA) VERB (MDIR) FIX (MLOC) ROOM)
        <COND (<==? .PA ,LOOK!-WORDS>
               <SET STARTER <==? .MLOC ,STARTROOM>>
               <TELL

"You are inside a rectangular box of wood whose structure is rather
complicated.  Four sides and the roof are filled in, and the floor is
open.
     As you face the side opposite the entrance, two short sides of
carved and polished wood are to your left and right.  The left panel
is oak, the right pine.  The wall you face is red on its left half
and black on its right.  On the entrance side, the wall is white
opposite the red part of the wall it faces, and yellow opposite the
black section.  The painted walls are at least twice the length of
the unpainted ones.  The ceiling is painted blue.
     In the floor is a stone channel about six inches wide and a foot
deep.  The channel is oriented in a north-south direction.  In the
exact center of the room the channel widens into a circular
depression perhaps two feet wide.  Incised in the stone around this
area is a compass rose.
     Running from one short wall to the other at about waist height
is a wooden bar, carefully carved and drilled.  This bar is pierced
in two places.  The first hole is in the center of the bar (and thus
the center of the room).  The second is at the left end of the room
(as you face opposite the entrance).  Through each hole runs a wooden
pole.
     The pole at the left end of the bar extends only about a foot
above the bar, and ends in a hand grip.  The pole " 0>
               <COND (<AND .STARTER <==? .MDIR 270>>
                      <COND (,POLEUP!-FLAG
                             <TELL
"has been lifted out
of a hole carved in the stone floor.  There is evidently enough
friction to keep the pole from dropping back down.">)
                            (ELSE
                             <TELL "has been dropped
into a hole carved in the stone floor.">)>)
                     (<OR <0? .MDIR> <==? .MDIR 180>> 
                      <COND (,POLEUP!-FLAG
                             <TELL "is positioned above
the stone channel in the floor.">)
                            (ELSE
                             <TELL "has been dropped
into the stone channel incised in the floor.">)>)
                     (ELSE
                      <TELL "is resting on the
stone floor.">)>
               <TELL

"     The pole at the center of the bar extends from the ceiling
through the bar to the circular area in the stone channel.  This
bottom end of the pole has a T-bar a bit less than two feet long
attached to it, and on the T-bar is carved an arrow.  The arrow and
T-bar are pointing " 1
                     <NTH ,LONGDIRS <+ </ .MDIR 45> 1>>
                     ".">)>>

<SETG LONGDIRS
      '["north"
        "northeast"
        "east"
        "southeast"
        "south"
        "southwest"
        "west"
        "northwest"]>

;"MOVEMENT"

<DEFINE MPANELS ("AUX" (PV ,PRSVEC) (PA <1 .PV>) (PO <2 .PV>) (MDIR ,MDIR))
    #DECL ((PV) VECTOR (PA) VERB (PO) OBJECT (MDIR) FIX)
    <COND (<==? .PA ,PUSH!-WORDS>
           <COND (,POLEUP!-FLAG
                  <AND <==? ,MLOC <FIND-ROOM "MRG">>
                       <TELL "The movement of the structure alerts the Guardians.">
                       <JIGS-UP ,GUARDKILL>>
                  <COND (<OR <==? .PO <FIND-OBJ "RDWAL">>
                             <==? .PO <FIND-OBJ "YLWAL">>>
                         <SET MDIR <MOD <+ .MDIR 45> 360>>
                         <TELL "The structure rotates clockwise.">)
                        (<SET MDIR <MOD <+ .MDIR 315> 360>>
                         <TELL "The structure rotates counterclockwise.">)>
                  <TELL "The arrow on the compass rose now indicates " 
                        1
                        <NTH ,LONGDIRS <+ 1 </ .MDIR 45>>>
                        ".">
                  <SETG MDIR .MDIR>)
                 (<N-S .MDIR>
                  <TELL "The short pole prevents the structure from rotating.">)
                 (<TELL "The structure shakes slightly but doesn't move.">)>)>>

<DEFINE MENDS ("AUX" (PV ,PRSVEC) (PA <1 .PV>) (PO <2 .PV>) (MDIR ,MDIR) RM
                     (MRG <FIND-ROOM "MRG">) (MLOC ,MLOC))
        #DECL ((PV) VECTOR (PA) VERB (PO) <OR FALSE OBJECT> (MDIR) FIX
               (RM) <OR FALSE ROOM> (MRG MLOC) ROOM)
        <COND (<==? .PA ,PUSH!-WORDS>
               <COND (<NOT <N-S .MDIR>>
                      <TELL 
"The structure rocks back and forth slightly but doesn't move.">)
                     (<==? .PO <FIND-OBJ "OAKND">>
                      <COND (<SET RM <MIRNS>> <MIRMOVE <0? .MDIR> .RM>)>)
                     (<==? .MLOC <FIND-ROOM "FDOOR">>
                      <TELL "The pine wall is blocked by something and won't open.">)
                     (<TELL "The pine wall swings open.">
                      <AND <OR <==? .MLOC .MRG>
                               <AND <==? .MLOC <FIND-ROOM "MRD">>
                                    <==? .MDIR 0>>>
                           <TELL 
"The pine door opens into the field of view of the Guardians.">
                           <JIGS-UP ,GUARDKILL>>
                      <SETG WOOD-OPEN!-FLAG T>
                      <CLOCK-ENABLE <CLOCK-INT ,PININ 5>>)>)
              (<==? .PA ,C-INT!-WORDS> <SETG WOOD-OPEN!-FLAG <>> T)>>

<DEFINE MIRMOVE (NORTH? RM "AUX" (MRG <FIND-ROOM "MRG">)) 
        #DECL ((NORTH?) <OR FIX ATOM FALSE> (RM MRG) ROOM)
        <TELL <COND (,POLEUP!-FLAG "The structure wobbles ")
                    ("The structure slides ")>
              1
              <COND (.NORTH? "north") ("south")>
              " and stops over another compass rose.">
        <SETG MLOC .RM>
        <AND <==? .RM .MRG>
             <==? ,HERE <FIND-ROOM "INMIR">>
             <COND (,POLEUP!-FLAG
                    <TELL
"The structure wobbles as it moves, alerting the Guardians.">)
                   (<OR <NOT ,MR1!-FLAG> <NOT ,MR2!-FLAG>>
                    <TELL

"A Guardian notices a wooden structure creeping by, and his
suspicions are aroused.">)>
             <JIGS-UP

"Suddenly the Guardians realize someone is trying to sneak by them in
the structure.  They awake, and in perfect unison, hammer the box and
its contents (including you) to pulp.  They then resume their posts,
satisfied.">>
        T>

<DEFINE SHORT-POLE ("AUX" (PA <1 ,PRSVEC>) (MDIR ,MDIR))
    #DECL ((PA) VERB (MDIR) FIX)
    <COND (<==? .PA ,RAISE!-WORDS>
           <COND (,POLEUP!-FLAG
                  <TELL "The pole cannot be raised further.">)
                 (<SETG POLEUP!-FLAG T>
                  <TELL "The pole is now slightly above the floor.">)>)
          (<OR <==? .PA ,PUSH!-WORDS>
               <==? .PA ,LOWER!-WORDS>>
           <COND (,POLEUP!-FLAG
                  <COND (<N-S .MDIR>
                         <TELL "The pole is lowered into the channel.">
                         <SETG POLEUP!-FLAG <>>
                         T)
                        (<AND <==? .MDIR 270>
                              <==? ,MLOC <FIND-ROOM "MRA">>>
                         <SETG POLEUP!-FLAG <>>
                         <TELL "The pole is lowered into the stone hole.">)
                        (<TELL "The pole rests on the floor.">)>)
                 (<TELL "The pole cannot be lowered further.">)>)>>



"========== The Spanish Inquisition =========="

<NEWSTRUC QUESTION VECTOR QSTR STRING                         ;"question to ask"
          QANS VECTOR                           ;"answers (as returned by LEX)">

<SETG EQUESTION <CHTYPE ["FOO" []] QUESTION>>

<SETG QVEC <REST <IUVECTOR 15 ,EQUESTION> 15>>

<SETG NQVEC <IUVECTOR 3 ,EQUESTION>>

<SETG NQATT 0>

;"tries recorded for this question"

<SETG NUMS ["one" "two" "three" "four"]>

<SETG INQOBJS ()>

<DEFINE ADD-QUESTION (STR VEC)
    <PUT <SETG QVEC <BACK ,QVEC>>
         1
         <CHTYPE [.STR .VEC] QUESTION>>
    <AND <TYPE? <1 .VEC> OBJECT>
         <ADD-INQOBJ <1 .VEC>>>>

<DEFINE ADD-INQOBJ (OBJ)
    <SETG INQOBJS (.OBJ !,INQOBJS)>>

<DEFINE CORRECT? (ANS CORRECT "AUX" (1CORR <1 .CORRECT>)) 
        #DECL ((ANS) <VECTOR [REST STRING]> (CORRECT) VECTOR
               (1CORR) <OR OBJECT ACTION FALSE STRING>)
        <REPEAT (W)
                #DECL ((W) <OR ATOM FALSE>)
                <COND (<EMPTY? .ANS> <RETURN>)
                      (<AND <SET W <LOOKUP <1 .ANS> ,WORDS>>
                            <TYPE? ,.W BUZZ>>
                       <SET ANS <REST .ANS>>)
                      (ELSE <RETURN>)>>
        <COND (<TYPE? .1CORR STRING> <MEMBER <1 .ANS> .CORRECT>)
              (<REPEAT ((LV .ANS) STR ATM OBJ (ADJ <>) VAL)
                       #DECL ((LV) <VECTOR [REST STRING]> (STR) STRING
                              (ATM) <OR FALSE ATOM> (VAL) ANY
                              (ADJ) <OR FALSE ADJECTIVE>
                              (OBJ) <OR FALSE OBJECT>)
                       <AND <EMPTY? <SET STR <1 .LV>>> <RETURN <>>>
                       <COND (<SET ATM <LOOKUP .STR ,ACTIONS>>
                              <RETURN <==? ,.ATM .1CORR>>)
                             (<SET ATM <LOOKUP .STR ,WORDS>>
                              <COND (<TYPE? <SET VAL ,.ATM> ADJECTIVE>
                                     <SET ADJ .VAL>)>)
                             (<SET ATM <LOOKUP .STR ,OBJECT-OBL>>
                              <COND (<SET OBJ <SEARCH-LIST .ATM ,INQOBJS .ADJ>>
                                     <RETURN <==? .OBJ .1CORR>>)>)>
                       <SET LV <REST .LV>>>)>>

<DEFINE INQUISITOR ("OPTIONAL" (ANS <>)
                    "AUX" (NQV ,NQVEC) (QUES <1 .NQV>) NQATT)
        #DECL ((ANS) <OR FALSE <VECTOR [REST STRING]>>
               (NQV) <UVECTOR [REST QUESTION]> (QUES) QUESTION (NQATT) FIX)
        <COND (<==? <1 ,PRSVEC> ,C-INT!-WORDS>
               <TELL "The booming voice asks:
\"" 1 <QSTR .QUES> "\"">
               <CLOCK-INT ,INQIN 2>)
              (.ANS
               <COND (<CORRECT? .ANS <QANS .QUES>>
                      <TELL "The dungeon master says \"Excellent\".">
                      <COND (<EMPTY? <SET NQV <REST .NQV>>>
                             <CLOCK-ENABLE <CLOCK-INT ,FOLIN -1>>
                             <TELL 
"The dungeon master, obviously pleased, says \"You are indeed a
master of lore. I am proud to be at your service.\"  The massive
wooden door swings open, and the master motions for you to enter.">
                             <DOPEN <FIND-OBJ "WDOOR">>
                             <CLOCK-DISABLE ,INQIN>)
                            (<SETG NQATT 0>
                             <SETG NQVEC .NQV>
                             <TELL "The booming voice asks:
\""
                                   1
                                   <QSTR <1 .NQV>>
                                   "\"">
                             <CLOCK-INT ,INQIN 2>)>)
                     (<SET NQATT <SETG NQATT <+ 1 ,NQATT>>>
                      <TELL "The dungeon master says \"You are wrong." 0>
                      <COND (<==? .NQATT 5>
                             <TELL 
"\" The dungeon master,
obviously disappointed in your lack of knowledge, shakes his head and
mumbles \"I guess they'll let anyone in the Dungeon these days\".  With
that, he departs.">
                             <REMOVE-OBJECT <FIND-OBJ "MASTE">>
                             <CLOCK-DISABLE ,INQIN>)
                            (<TELL " You have "
                                   1
                                   <NTH ,NUMS <- 5 .NQATT>>
                                   " more chances.\"">)>)>)>>

<SETG INQSTART? <>>

;"if D.M. has stated the rules."

<DEFINE INQSTART ("AUX" (QV ,QVEC) (NQV ,NQVEC))
    #DECL ((QV NQV) <UVECTOR [REST QUESTION]>)
    <COND (<NOT ,INQSTART?>
           <INSERT-OBJECT <FIND-OBJ "MASTE"> ,HERE>
           <CLOCK-ENABLE <CLOCK-INT ,INQIN 2>>
           <TELL

"The knock reverberates along the hall.  For a time it seems there
will be no answer.  Then you hear someone unlatching the small wooden
panel.  Through the bars of the great door, the wrinkled face of an
old man appears.  He gazes down at you and intones as follows:

     \"I am the Master of the Dungeon, whose task it is to insure
that none but the most scholarly and masterful adventurers are
admitted into the secret realms of the Dungeon.  To ascertain whether
you meet the stringent requirements laid down by the Great
Implementers, I will ask three questions which should be easy for one
of your reputed excellence to answer.  You have undoubtedly
discovered their answers during your travels through the Dungeon. 
Should you answer each of these questions correctly within five
attempts, then I am obliged to acknowledge your skill and daring and
admit you to these regions.
     \"All answers should be in the form 'ANSWER \"<answer>\"'\"">
           <SETG INQSTART? T>
           <REPEAT ()
                   <SET Q <PICK-ONE .QV>>
                   <COND (<MEMQ .Q <TOP .NQV>>)
                         (<PUT .NQV 1 .Q>
                          <SET NQV <REST .NQV>>
                          <AND <EMPTY? .NQV> <RETURN>>)>>
           <TELL "The booming voice asks:
\"" 1 <QSTR <1 ,NQVEC>> "\"">)
          (<TELL
"The Dungeonmaster gazes at you impatiently, and says, \"My conditions
have been stated, abide by them or depart!\"">)>>

<DEFINE ANSWER ("AUX" (LV ,LEXV) M)
    #DECL ((LV M) <VECTOR [REST STRING]>)
    <COND (<SET M <MEMBER "" .LV>>
           <INQUISITOR <REST .M>>)>>

<DEFINE MASTER-ACTOR ("AUX" (PV ,PRSVEC) (PA <1 .PV>) (PO <2 .PV>) C
                     (R <FIND-OBJ "DUNGM">) RACT) 
        #DECL ((C) ROOM (PA) VERB (PV) VECTOR (PO) <OR FALSE OBJECT DIRECTION>
               (R) OBJECT (RACT) ADV)
        <COND (<NOT <OOPEN? <FIND-OBJ "WDOOR">>> <TELL "There is no reply.">)
              (<MEMQ .PA ,MASTER-ACTIONS> <>)
              (<TELL "\"I cannot perform that action for you.\"">)>>

<DEFINE FDOOR-FUNCTION ("AUX" (PA <1 ,PRSVEC>))
    #DECL ((PA) VERB)
    <COND (<==? .PA ,LOOK!-WORDS>
           <TELL 

"You are in a north-south hallway which ends in a large wooden door. 
The wooden door has a closed panel in it at about head height.  The
great door is " 1 <DPR <FIND-OBJ "WDOOR">>>)>>

<DEFINE WOOD-DOOR ("AUX" (PA <1 ,PRSVEC>))
    #DECL ((PA) VERB)
    <COND (<OR <==? .PA ,OPEN!-WORDS> <==? .PA ,CLOSE!-WORDS>>
           <TELL "The door won't budge.">)
          (<==? .PA ,KNOCK!-WORDS>
           <COND (,INQSTART?
                  <TELL "There is no answer.">)
                 (<INQSTART>)>)>>

<SETG FOLFLAG T>

<DEFINE FOLLOW ("AUX" (WIN ,WINNER) (MAST <ORAND <FIND-OBJ "MASTE">>)
                      (HERE ,HERE) (MROOM <AROOM .MAST>))
        #DECL ((WIN MAST) ADV (HERE MROOM) ROOM)
        <COND (<==? <1 ,PRSVEC> ,C-INT!-WORDS>
               <COND (<OR <==? .HERE .MROOM> <==? .HERE <FIND-ROOM "FDOOR">>>)
                     (<N==? .HERE <FIND-ROOM "CELL">>
                      <AND <MEMQ <AOBJ .MAST> <ROBJS .MROOM>>
                           <PUT .MROOM
                                ,ROBJS
                                <SPLICE-OUT <AOBJ .MAST> <ROBJS .MROOM>>>>
                      <PUT .MAST ,AROOM .HERE>
                      <SETG FOLFLAG T>
                      <INSERT-OBJECT <AOBJ .MAST> .HERE>
                      <TELL
"The dungeon master follows you.">)
                     (,FOLFLAG
                      <TELL 
"You notice that the dungeon master does not follow.">
                      <SETG FOLFLAG <>>
                      T)>)
              (<==? .WIN .MAST>
               <CLOCK-INT ,FOLIN -1>
               <TELL "The dungeon master answers, 'I will follow.'">)>>

<DEFINE STAY ()
    <COND (<==? ,WINNER <ORAND <FIND-OBJ "MASTE">>>
           <CLOCK-INT ,FOLIN 0>
           <TELL "The dungeon master says, 'I will stay.'">)
          (<==? ,WINNER ,PLAYER>
           <TELL "You will be lost without me.">)>>



"===== 'She reached her end, and this was it; he cast her in the fiery pit' ===="

<SETG LCELL 1> ;"cell in slot"

<SETG PNUMB 1> ;"cell pointed at"

<SETG ACELL <>> ;"cell player is in"

<SETG DCELL <>> ;"cell d.m. is in"

<DEFINE CELL-MOVE ("AUX" (NEW ,PNUMB) (OLD ,LCELL) (CELL <FIND-ROOM "CELL">)
                         (NCELL <FIND-ROOM "NCELL">) (PCELL <FIND-ROOM "PCELL">)
                         (CELLS ,CELLS) PO (ME ,PLAYER) (DM ,MASTER))
        #DECL ((NEW OLD) FIX (CELL) ROOM (CELLS) <UVECTOR [REST LIST]>)
        <PUT .CELLS .OLD <ROBJS .CELL>>
        <PUT .CELL ,ROBJS <SET PO <NTH .CELLS .NEW>>>
        <COND (<==? .OLD 4> <PUT .NCELL ,ROBJS .PO>)
              (ELSE <PUT .PCELL ,ROBJS .PO>)>
        <DCLOSE <FIND-OBJ "CDOOR">>
        <DCLOSE <FIND-OBJ "NDOOR">>
        <DCLOSE <FIND-OBJ "ODOOR">>
        <COND (<==? <AROOM .ME> .CELL>
               <SETG ACELL .OLD>
               <GOTO <COND (<==? .OLD 4> .NCELL) (ELSE .PCELL)>>)
              (<==? ,ACELL .NEW>
               <SETG ACELL <>>
               <GOTO <FIND-ROOM "CELL">>)>
        <COND (<==? <AROOM .DM> .CELL>
               <SETG DCELL .OLD>)
              (<==? ,DCELL .NEW>
               <SETG DCELL <>>)>
        <SETG LCELL .NEW>>

<DEFINE PARAPET ("AUX" (PV ,PRSVEC) (PA <1 .PV>)) 
        <COND (<==? .PA ,LOOK!-WORDS>
               <TELL 
"You are standing behind a stone retaining wall which rims a large
parapet overlooking a fiery pit.  It is difficult to see through the
smoke and flame which fills the pit, but it seems to be more or less
bottomless.  It also extends upward out of sight.  The pit itself is
of roughly dressed stone and circular in shape.  It is about two
hundred feet in diameter.  The flames generate considerable heat, so
it is rather uncomfortable standing here.
There is an object here which looks like a sundial.  On it are an
indicator arrow and (in the center) a large button.  On the face of
the dial are numbers 'one' through 'eight'.  The indicator points to
the number '"
                     1
                     <NTH ,NUMS ,PNUMB>
                     "'.">)>>

<DEFINE DIAL ("AUX" (PV ,PRSVEC) (PA <1 .PV>) (PO <2 .PV>) (PI <3 .PV>))
        <COND (<OR <==? .PA ,SET!-WORDS>
                   <==? .PA ,PUT!-WORDS>
                   <==? .PA ,MOVE!-WORDS>
                   <==? .PA ,TURN-TO!-WORDS>>
               <COND (.PI
                      <COND (<SET N <MEMQ .PI ,NUMOBJS>>
                             <SETG PNUMB <2 .N>>
                             <TELL "The dial now points to '" 1
                                   <NTH ,NUMS <2 .N>> "'.">)
                            (<TELL "The dial face only contains numbers.">)>)
                     (<TELL "You must specify what to set the dial to.">)>)
              (<==? .PA ,SPIN!-WORDS>
               <SETG PNUMB <+ 1 <MOD <RANDOM> 7>>>
               <TELL
"The dial spins and comes to a stop pointing at '" 1 <NTH ,NUMS ,PNUMB> "'.">)>>

<DEFINE DIALBUTTON ("AUX" (PA <1 ,PRSVEC>) (CDOOR <OOPEN? <FIND-OBJ "CDOOR">>))
        <COND (<==? .PA ,PUSH!-WORDS>
               <CELL-MOVE>
               <TELL
"The button depresses with a slight click, and pops back.">
               <AND .CDOOR <TELL "The cell door is now closed.">>
               T)>>

<DEFINE TAKE-FIVE ("AUX" (PV ,PRSVEC) (PA <1 .PV>))
        #DECL ((PA) VERB)
        <COND (<==? .PA ,TAKE!-WORDS>
               <PUT .PV 1 ,WAIT!-WORDS>
               <WAIT>)>>

<DEFINE CELL-ROOM ("AUX" (PA <1 ,PRSVEC>))
    #DECL ((PA) VERB)
    <COND (<==? .PA ,LOOK!-WORDS>
           <TELL 

"You are in a featureless prison cell.  You can see "
                1
                <COND (<OOPEN? <FIND-OBJ "CDOOR">>
                       "the east-west
corridor outside the open wooden door in front of you.")
                      ("only the flames
and smoke of the pit out the small window in a closed door in front
of you.")>>
           <COND (<==? ,LCELL 4>
                  <TELL
"Behind you is an ornately decorated door which seems to be "
                        1
                        <COND (<OOPEN? <FIND-OBJ "ODOOR">>
                               "open.")
                              ("closed.")>>)>)>>
                 
<DEFINE PCELL-ROOM ("AUX" (PA <1 ,PRSVEC>))
    #DECL ((PA) VERB)
    <COND (<==? .PA ,LOOK!-WORDS>
           <TELL 
"You are in a featureless prison cell.  Its wooden door is securely
fastened, and you can see only the flames and smoke of the pit out
the small window.">)>>

<DEFINE NCELL-ROOM ("AUX" (PA <1 ,PRSVEC>))
    #DECL ((PA) VERB)
    <COND (<==? .PA ,LOOK!-WORDS>
           <TELL 
"You are in a featureless prison cell.  Its wooden door is securely
fastened, and you can see only the flames and smoke of the pit out
its small window.">
           <TELL
"On the other side of the cell is an ornately decorated door which
seems to be " 1 <DPR <FIND-OBJ "NDOOR">>>)>>

<DEFINE NCORR-ROOM ("AUX" (PA <1 ,PRSVEC>))
        #DECL ((PA) VERB)
        <COND (<==? .PA ,LOOK!-WORDS>
               <TELL
"You are in a large east-west corridor which opens onto a northern
parapet at its center.  You can see flames and smoke as you peer
towards the parapet.  The corridor turns south at its east and west
ends, and due south is a massive wooden door.  In the door is a small
window barred with iron.  The door is " 1
                          <DPR <FIND-OBJ "CDOOR">>>)>>

<DEFINE SCORR-ROOM ("AUX" (PA <1 ,PRSVEC>))
        #DECL ((PA) VERB)
        <COND (<==? .PA ,LOOK!-WORDS>
               <TELL
"You are in an east-west corridor which turns north at its eastern
and western ends.  The walls of the corridor are marble.  An
additional passage leads south at the center of the corridor.">
               <COND (<==? ,LCELL 4>
                      <TELL
"In the center of the north wall of the passage is an ornately
decorated door which is " 1 <DPR <FIND-OBJ "ODOOR">>>)>)>>

<DEFINE CELL-DOOR ("AUX" (PA <1 ,PRSVEC>))
        #DECL ((PA) VERB)
        <COND (<OR <==? .PA ,OPEN!-WORDS> <==? .PA ,CLOSE!-WORDS>>
               <OPEN-CLOSE .PA <FIND-OBJ "CDOOR">
                           "The wooden door opens."
                           "The wooden door closes.">)>>

<DEFINE ORNATE-DOOR ("AUX" (PA <1 ,PRSVEC>))
        #DECL ((PA) VERB)
        <COND (<OR <==? .PA ,OPEN!-WORDS> <==? .PA ,CLOSE!-WORDS>>
               <OPEN-CLOSE .PA <FIND-OBJ "NDOOR">
                           "The ornate door opens."
                           "The ornate door closes.">)>>

<DEFINE MAYBE-DOOR ()
        <TELL "There is no way to go in that direction.">
        <>>
                                 
<DEFINE LOCKED-DOOR ("AUX" (PA <1 ,PRSVEC>))
        #DECL ((PA) VERB)
        <COND (<==? .PA ,OPEN!-WORDS>
               <TELL "The door is securely fastened.">)>>

 

"=========== The Ultimate Winnage =========="

<DEFINE NIRVANA ()
        <TELL

"     You are in a room of large size, richly appointed and decorated in
a style that bespeaks exquisite taste.  To judge from its contents, it
is the ultimate storehouse of the treasures of Zork.
     There are chests here containing precious jewels, mountains of
zorkmids, rare paintings, ancient statuary, and beguiling curios.
     In one corner of the room is a bookcase boasting such volumes
as 'The History of the Great Underground Empire,' 'The Lives of the
Twelve Flatheads,' 'The Wisdom of the Implementors,' and other
informative and inspiring works.
     On one wall is a completely annotated map of the Dungeon of
Zork, showing points of interest, various troves of treasure, and
indicating the locations of several superior scenic views.
     On a desk at the far end of the room may be found stock
certificates representing a controlling interest in Frobozco
International, the multinational conglomerate and parent company of
the Frobozz Magic Boat Co., etc.
">>


<GUNASSIGN TURNTO>      ;"Release TURNTO and reattach to new routine."
<DEFINE TURNTO ()
    <COND (<OBJECT-ACTION>)
          (<TELL "That cannot be turned.">)>>

"=========== CEVENTs and such ============="

<OR <LOOKUP "COMPILE" <ROOT>>
    <PROG ()
          <CEVENT 0 ,MRSWITCH <> "MRINT">
          <CEVENT 0 ,START-END T "STRTE">
          <CEVENT 0 ,MENDS <> "PININ">
          <CEVENT 0 ,INQUISITOR <> "INQIN">
          <CEVENT 0 ,FOLLOW <> "FOLIN">>>

