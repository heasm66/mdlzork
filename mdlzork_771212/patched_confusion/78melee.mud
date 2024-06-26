
"
0 -- attacker misses
1 -- defender unconscious
2 -- defender dead
3 -- defender lightly wounded
4 -- defender seriously wounded
5 -- staggered
6 -- loses weapon
7 -- hesitate (miss on free swing)
8 -- sitting duck (crunch!)
"

<DEFINE ADD-MELEE (OBJ REM)
        #DECL ((OBJ) OBJECT (REM) UVECTOR)
        <PUT .OBJ ,ORAND .REM>>

<PSETG SWORD-MELEE
      '![![["Your swing misses the " D " by an inch."]
           ["A mighty blow, but it misses the " D " by a mile."]
           ["You charge, but the " D " jumps nimbly aside."]
           ["Clang! Crash! The " D " parries."]
           ["A good stroke, but it's too slow, the " D " dodges."]!]
         ![["Your sword crashes down, knocking the " D " into dreamland."]
           ["The " D " is battered into unconsciousness."]
           ["A furious exchange, and the " D " is knocked out!"]!]
         ![["It's curtains for the " D " as your sword removes his head."]
           ["The fatal blow strikes the " D " square in the heart:  He dies."]
           ["The " D " takes a final blow and slumps to the floor dead."]!]
         ![["The " D " is struck on the arm, blood begins to trickle down."]
           ["Your sword pinks the " D " on the wrist, but it's not serious."]
           ["Your stroke lands, but it was only the flat of the blade."]
           ["The blow lands, making a shallow gash in the " D "'s arm!"]!]
         ![["The " D " receives a deep gash in his side."]
           ["A savage blow on the thigh!  The " D " is stunned but can still fight!"]
           ["Slash!  Your blow lands!  That one hit an artery, it could be serious!"]!]
         ![["The " D " is staggered, and drops to his knees."]
           ["The " D " is momentarily disoriented and can't fight back."]
           ["The force of your blow knocks the " D " back, stunned."]!]
         ![["The " D "'s weapon is knocked to the floor, leaving him unarmed."]!]!]>

<PSETG KNIFE-MELEE
      '![![["Your stab misses the " D " by an inch."]
           ["A good slash, but it misses the " D " by a mile."]
           ["You charge, but the " D " jumps nimbly aside."]
           ["A quick stroke, but the " D " is on guard."]
           ["A good stroke, but it's too slow, the " D " dodges."]!]
         ![["The haft of your knife knocks out the " D "."]
           ["The " D " drops to the floor, unconscious."]
           ["The " D " is knocked out!"]!]
         ![["The end for the " D " as your knife severs his jugular."]
           ["The fatal thrust strikes the " D " square in the heart:  He dies."]
           ["The " D " takes a final blow and slumps to the floor dead."]!]
         ![["The " D " is slashed on the arm, blood begins to trickle down."]
           ["Your knife point pinks the " D " on the wrist, but it's not serious."]
           ["Your stroke lands, but it was only the flat of the blade."]
           ["The blow lands, making a shallow gash in the " D "'s arm!"]!]
         ![["The " D " receives a deep gash in his side."]
           ["A savage cut on the leg stuns the " D ", but he can still fight!"]
           ["Slash!  Your stroke connects!  The " D " could be in serious trouble!"]!]
         ![["The " D " drops to his knees, staggered."]
           ["The " D " is confused and can't fight back."]
           ["The quickness of your thrust knocks the " D " back, stunned."]!]
         ![["The " D " is disarmed by a subtle feint past his guard."]!]!]>

<PSETG CYCLOPS-MELEE
      '![![["The Cyclops misses, but the backwash almost knocks you over."]
           ["The Cyclops rushes you, but runs into the wall."]
           ["The Cyclops trips over his feet trying to get at you."]
           ["The Cyclops unleashes a roundhouse punch, but you have time to dodge."]!]
         ![["The Cyclops knocks you unconscious."]
           ["The Cyclops sends you crashing to the floor, unconscious."]!]
         ![["The Cyclops raises his arms and crushes your skull."]
           ["The Cyclops has just essentially ripped you to shreds."]
           ["The Cyclops decks you.  In fact, you are dead."]
           ["The Cyclops breaks your neck with a massive smash."]!]
         ![["A quick punch, but it was only a glancing blow."]
           ["The Cyclops grabs but you twist free, leaving part of your cloak."]
           ["A glancing blow from the Cyclops' fist."]
           ["The Cyclops chops at you with the side of his hand, and it connects,
but not solidly."]!]
         ![["The Cyclops gets a good grip and breaks your arm."]
           ["The monster smashes his huge fist into your chest, breaking several
ribs."]
           ["The Cyclops almost knocks the wind out of you with a quick punch."]
           ["A flying drop kick breaks your jaw."]
           ["The Cyclops breaks your leg with a staggering blow."]!]
         ![["The Cyclops knocks you silly, and you reel back."]
           ["The Cyclops lands a punch that knocks the wind out of you."]
           ["Heedless of your weapons, the Cyclops tosses you against the rock
wall of the room."]
           ["The Cyclops grabs you, and almost strangles you before you wiggle
free, breathless."]!]
         ![["The Cyclops grabs you by the arm, and you drop your " W "."]
           ["The Cyclops kicks your " W " out of your hand."]
           ["The Cyclops grabs your " W ", tastes it, and throws it to the
ground in disgust."]
           ["The monster grabs you on the wrist, squeezes, and you drop your
" W " in pain."]!]
         ![["The Cyclops is so excited by his success that he neglects to kill
you."]
           ["The Cyclops, momentarily overcome by remorse, holds back."]
           ["The Cyclops seems unable to decide whether to broil or stew his
dinner."]]
         ![["The Cyclops, no sportsman, dispatches his unconscious victim."]]!]>

<PSETG TROLL-MELEE
      '![![["The troll swings his axe, but it misses."]
           ["The troll's axe barely misses your ear."]
           ["The axe sweeps past as you jump aside."]
           ["The axe crashes against the rock, throwing sparks!"]!]
         ![["The flat of the troll's axe hits you delicately on the head, knocking
you out."]!]
         ![["The troll lands a killing blow.  You are dead."]
           ["The troll neatly removes your head."]
           ["The troll's axe stroke cleaves you from the nave to the chops."]
           ["The troll's axe removes your head."]!]
         ![["The axe gets you right in the side.  Ouch!"]
           ["The flat of the troll's axe skins across your forearm."]
           ["The troll's swing almost knocks you over as you barely parry
in time."]
           ["The troll swings his axe, and it nicks your arm as you dodge."]!]
         ![["The troll charges, and his axe slashes you on your " W " arm."]
           ["An axe stroke makes a deep wound in your leg."]
           ["The troll's axe swings down, gashing your shoulder."]
           ["The troll sees a hole in your defense, and a lightning stroke
opens a wound in your left side."]!]
         ![["The troll hits you with a glancing blow, and you are momentarily
stunned."]
           ["The troll swings; the blade turns on your armor but crashes
broadside into your head."]
           ["You stagger back under a hail of axe strokes."]
           ["The troll's mighty blow drops you to your knees."]!]
         ![["The axe hits your " W " and knocks it spinning."]
           ["The troll swings, you parry, but the force of his blow disarms you."]
           ["The axe knocks your " W " out of your hand.  It falls to the floor."]
           ["Your " W " is knocked out of your hands, but you parried the blow."]!]
         ![["The troll strikes at your unconscious form, but misses in his rage."]
           ["The troll hesitates, fingering his axe."]
           ["The troll scratches his head ruminatively:  Might you be magically
protected, he wonders?"]
           ["The troll seems afraid to approach your crumpled form."]]
         ![["Conquering his fears, the troll puts you to death."]]!]>

<PSETG THIEF-MELEE
      '![![["The thief stabs nonchalantly with his stilletto and misses."]
           ["You dodge as the thief comes in low."]
           ["You parry a lightning thrust, and the thief salutes you with
a grim nod."]
           ["The thief tries to sneak past your guard, but you twist away."]!]
         ![["Shifting in the midst of a thrust, the thief knocks you unconscious
with the haft of his stilletto."]
           ["The thief knocks you out."]!]
         ![["Finishing you off, a lightning throw right to the heart."]
           ["The stilletto severs your jugular.  It looks like the end."]
           ["The thief comes in from the side, feints, and inserts the blade
into your ribs."]
           ["The thief bows formally, raises his stilletto, and with a wry grin,
ends the battle and your life."]!]
         ![["A quick thrust pinks your left arm, and blood starts to
trickle down."]
           ["The thief draws blood, raking his stilletto across your arm."]
           ["The stilletto flashes faster than you can follow, and blood wells
from your leg."]
           ["The thief slowly approaches, strikes like a snake, and leaves
you wounded."]!]
         ![["The thief strikes like a snake!  The resulting wound is serious."]
           ["The thief stabs a deep cut in your upper arm."]
           ["The stilletto touches your forehead, and the blood obscures your
vision."]
           ["The thief strikes at your wrist, and suddenly your grip is slippery
with blood."]]
         ![["The butt of his stilletto cracks you on the skull, and you stagger
back."]
           ["You are forced back, and trip over your own feet, falling heavily
to the floor."]
           ["The thief rams the haft of his blade into your stomach, leaving
you out of breath."]
           ["The thief attacks, and you fall back desperately."]!]
         ![["A long, theatrical slash.  You catch it on your " W ", but the
thief twists his knife, and the " W " goes flying."]
           ["The thief neatly flips your " W " out of your hands, and it drops
to the floor."]
           ["You parry a low thrust, and your " W " slips out of your hand."]
           ["Avoiding the thief's stilletto, you stumble to the floor, dropping
your " W "."]!]
         ![["The thief, a man of good breeding, refrains from attacking a helpless
opponent."]
           ["The thief amuses himself by searching your pockets."]
           ["The thief entertains himself by rifling your pack."]]
         ![["The thief, noticing you begin to stir, reluctantly finishes you off."]
           ["The thief, forgetting his essentially genteel upbringing, cuts your
throat."]
           ["The thief, who is essentially a pragmatist, dispatches you as a
threat to his livelihood."]]!]>



<MSETG MISSED 0>

<MSETG UNCONSCIOUS 1>

<MSETG KILLED 2>

<MSETG LIGHT-WOUND 3>

<MSETG SERIOUS-WOUND 4>

<MSETG STAGGER 5>

<MSETG LOSE-WEAPON 6>

<MSETG HESITATE 7>

<MSETG SITTING-DUCK 8>

<PSETG DEF1
       <UVECTOR
          ,MISSED ,MISSED ,MISSED ,MISSED
          ,STAGGER ,STAGGER
          ,UNCONSCIOUS ,UNCONSCIOUS
          ,KILLED ,KILLED ,KILLED ,KILLED ,KILLED>>

<PSETG DEF2A
       <UVECTOR
          ,MISSED ,MISSED ,MISSED ,MISSED ,MISSED
          ,STAGGER ,STAGGER
          ,LIGHT-WOUND ,LIGHT-WOUND
          ,UNCONSCIOUS>>

<PSETG DEF2B
       <UVECTOR
          ,MISSED ,MISSED ,MISSED
          ,STAGGER ,STAGGER
          ,LIGHT-WOUND ,LIGHT-WOUND ,LIGHT-WOUND
          ,UNCONSCIOUS
          ,KILLED ,KILLED ,KILLED>>

<PSETG DEF3A
       <UVECTOR
          ,MISSED ,MISSED ,MISSED ,MISSED ,MISSED
          ,STAGGER ,STAGGER
          ,LIGHT-WOUND ,LIGHT-WOUND
          ,SERIOUS-WOUND ,SERIOUS-WOUND>>

<PSETG DEF3B
       <UVECTOR
          ,MISSED ,MISSED ,MISSED
          ,STAGGER ,STAGGER
          ,LIGHT-WOUND ,LIGHT-WOUND ,LIGHT-WOUND
          ,SERIOUS-WOUND ,SERIOUS-WOUND ,SERIOUS-WOUND>>

<PSETG DEF3C
       <UVECTOR
          ,MISSED
          ,STAGGER ,STAGGER
          ,LIGHT-WOUND ,LIGHT-WOUND ,LIGHT-WOUND ,LIGHT-WOUND
          ,SERIOUS-WOUND ,SERIOUS-WOUND ,SERIOUS-WOUND>>

<PSETG DEF1-RES <UVECTOR ,DEF1 <REST ,DEF1> <REST ,DEF1 2>>>

<PSETG DEF2-RES <UVECTOR ,DEF2A ,DEF2B <REST ,DEF2B> <REST ,DEF2B 2>>>

<PSETG DEF3-RES <UVECTOR ,DEF3A <REST ,DEF3A> ,DEF3B <REST ,DEF3B> ,DEF3C>>

<SETG STRENGTH-MAX 7>

<SETG STRENGTH-MIN 2>

<SETG CURE-WAIT 30>

<GDECL (DEF1-RES DEF2-RES DEF3-RES)
       <UVECTOR [REST UVECTOR]>
       (DEF1 DEF2A DEF2B DEF3A DEF3B DEF3C)
       <UVECTOR [REST FIX]>
       (OPPV) VECTOR
       (VILLAINS) <LIST [REST OBJECT]>
       (VILLAIN-PROBS) <UVECTOR [REST FIX]>
       (STRENGTH-MIN STRENGTH-MAX CURE-WAIT) FIX>


<DEFINE FIGHTING (FROB "AUX" (HERE ,HERE) (OPPS ,OPPV) (HERO ,PLAYER) (FIGHT? <>)
                  RANDOM-ACTION) 
        #DECL ((FROB) HACK (OPPS) <VECTOR [REST <OR OBJECT FALSE>]> (HERO) ADV
               (HERE) ROOM (FIGHT?) <OR ATOM FALSE>
               (RANDOM-ACTION) <OR ATOM NOFFSET FALSE>)
      <COND
       (,PARSE-WON
        <MAPR <>
              <FUNCTION (OO OV VOUT "AUX" (O <1 .OO>) (S <OCAPAC .O>))
                      #DECL ((OO) <LIST [REST OBJECT]> (OV) VECTOR
                             (VOUT) <UVECTOR [REST FIX]> (O) OBJECT (S) FIX)
                      <PUT .OV 1 <>>
                      <SET RANDOM-ACTION <OACTION .O>>
                      <COND (<==? .HERE <OROOM .O>>
                             <COND (<L? .S 0>
                                    <COND (<AND <NOT <0? <1 .VOUT>>> <PROB <1 .VOUT>>>
                                           <PUT .O ,OCAPAC <- .S>>
                                           <PUT .VOUT 1 0>
                                           <COND (.RANDOM-ACTION
                                                  <PUT ,PRSVEC 1 ,IN\!!-WORDS>
                                                  <APPLY-RANDOM .RANDOM-ACTION>)>)
                                          (<PUT .VOUT 1 <+ <1 .VOUT> 10>>)>)
                                   (<FIGHTING? .O>
                                    <SET FIGHT? T>
                                    <PUT .OV 1 .O>)
                                   (.RANDOM-ACTION
                                    <PUT ,PRSVEC 1 ,FIRST?!-WORDS>
                                    <COND (<APPLY-RANDOM .RANDOM-ACTION>
                                           <SET FIGHT? T>
                                           <TRO .O ,FIGHTBIT>
                                           <PUT .OV 1 .O>)>)>)
                            (<N==? .HERE <OROOM .O>>
                             <COND (<FIGHTING? .O>
                                    <COND (.RANDOM-ACTION
                                           <PUT ,PRSVEC 1 ,FIGHT!-WORDS>
                                           <APPLY-RANDOM .RANDOM-ACTION>)>)>
                             <TRZ .HERO ,ASTAGGERED>
                             <TRZ .O ,STAGGERED>
                             <TRZ .O ,FIGHTBIT>
                             <COND (<L? .S 0>
                                    <PUT .O ,OCAPAC <- .S>>
                                    <COND (.RANDOM-ACTION
                                           <PUT ,PRSVEC 1 ,IN\!!-WORDS>
                                           <APPLY-RANDOM .RANDOM-ACTION>)>)>)>>
              ,VILLAINS
              .OPPS
              ,VILLAIN-PROBS>
        <COND (.FIGHT?
               <CLOCK-INT ,CURIN>
               <REPEAT ((OUT <>) RES)
                #DECL ((OUT) <OR FIX FALSE> (RES) <OR FIX FALSE>)
                <COND (<MAPF <>
                             <FUNCTION (O) 
                                  #DECL ((O) <OR OBJECT FALSE>)
                                  <COND (<NOT .O>)
                                        (<AND <SET RANDOM-ACTION <OACTION .O>>
                                              <PUT ,PRSVEC 1 ,FIGHT!-WORDS>
                                              <APPLY-RANDOM .RANDOM-ACTION>>)
                                        (<NOT <SET RES
                                                   <BLOW .HERO .O <ORAND .O> <> .OUT>>>
                                         <MAPLEAVE <>>)
                                        (<==? .RES ,UNCONSCIOUS>
                                         <SET OUT <+ 2 <MOD <RANDOM> 3>>>)
                                        (T)>>
                             .OPPS>
                       <COND (<NOT .OUT> <RETURN>)
                             (<0? <SET OUT <- .OUT 1>>> <RETURN>)>)
                      (ELSE <RETURN>)>>)>)>>

<DEFINE PRES (TAB A D W "AUX" (L <LENGTH .TAB>))
        #DECL ((TAB) <UVECTOR [REST VECTOR]> (A D) STRING
               (W) <OR STRING FALSE>)
        <MAPF <>
              <FUNCTION (S)
                <COND (<TYPE? .S STRING> <TELL .S 0>)
                      (<TYPE? .S ATOM>
                       <COND (<==? .S A> <TELL .A 0>)
                             (<==? .S D> <TELL .D 0>)
                             (<AND .W <==? .S W>> <TELL .W 0>)>)>>
              <NTH .TAB <+ 1 <MOD <RANDOM> .L>>>>
        <TELL "" 1>>

<DEFINE FIGHT-STRENGTH (HERO "OPTIONAL" (ADJUST? T)
                        "AUX" S (SMAX ,STRENGTH-MAX) (SMIN ,STRENGTH-MIN))
        #DECL ((HERO) ADV (S SMAX SMIN VALUE) FIX (ADJUST?) <OR ATOM FALSE>)
        <SET S
             <+ .SMIN
                <FIX <+ .5
                        <* <- .SMAX .SMIN>
                           </ <FLOAT <ASCORE .HERO>>
                              <FLOAT ,SCORE-MAX>>>>>>>
        <COND (.ADJUST? <+ .S <ASTRENGTH .HERO>>)(ELSE .S)>>

<GDECL (CURIN) CEVENT>

<DEFINE BLOW (HERO VILLAIN REMARKS HERO? OUT?
              "AUX" DWEAPON (VDESC <ODESC2 .VILLAIN>) ATT DEF OA OD TBL RES
              NWEAPON RANDOM-ACTION)
        #DECL ((HERO) ADV (VILLAIN) OBJECT (DWEAPON NWEAPON) <OR OBJECT FALSE>
               (RES OA OD ATT DEF FIX) FIX (REMARKS) <UVECTOR [REST UVECTOR]>
               (HERO?) <OR ATOM FALSE> (VDESC) STRING (TBL) <UVECTOR [REST FIX]>
               (OUT?) <OR FIX FALSE> (RANDOM-ACTION) <OR ATOM FALSE NOFFSET>)
        <PROG ()
              <COND (.HERO?
                     <TRO .VILLAIN ,FIGHTBIT>
                     <COND (<STAGGERED? .HERO>
                            <TELL 
"You are still recovering from that last blow, so your attack is
ineffective.">
                            <TRZ .HERO ,ASTAGGERED>
                            <RETURN>)>
                     <SET OA <SET ATT <FIGHT-STRENGTH .HERO>>>
                     <COND (<0? <SET OD <SET DEF <OCAPAC .VILLAIN>>>>
                            <COND (<==? .VILLAIN <FIND-OBJ "#####">>
                                   <RETURN <JIGS-UP
"Well, you really did it that time.  Is suicide painless?">>)>
                            <TELL "Attacking a dead " 1 .VDESC " is pointless.">
                            <RETURN>)>
                     <SET DWEAPON
                          <AND <NOT <EMPTY? <OCONTENTS .VILLAIN>>>
                               <1 <OCONTENTS .VILLAIN>>>>)
                    (ELSE
                     <COND (<STAGGERED? .HERO> <TRZ .HERO ,ASTAGGERED>)>
                     <COND (<TRNN .VILLAIN ,STAGGERED>
                            <TELL "The "
                                  1
                                  .VDESC
                                  " slowly regains his feet.">
                            <TRZ .VILLAIN ,STAGGERED>
                            <RETURN 0>)>
                     <SET OA <SET ATT <OCAPAC .VILLAIN>>>
                     <COND (<L=? <SET DEF <FIGHT-STRENGTH .HERO>> 0> <RETURN>)>
                     <SET OD <FIGHT-STRENGTH .HERO <>>>
                     <SET DWEAPON <FWIM ,WEAPONBIT <AOBJS .HERO> T>>)>
              <COND (<L? .DEF 0>
                     <COND (.HERO?
                            <TELL "The unconscious " 1 .VDESC
                                  " cannot defend himself:  He dies.">)>
                     <SET RES ,KILLED>)
                    (ELSE
                     <COND (<1? .DEF>
                            <COND (<G? .ATT 2> <SET ATT 3>)>
                            <SET TBL <NTH ,DEF1-RES .ATT>>)
                           (<==? .DEF 2>
                            <COND (<G? .ATT 3> <SET ATT 4>)>
                            <SET TBL <NTH ,DEF2-RES .ATT>>)
                           (<G? .DEF 2>
                            <SET ATT <- .ATT .DEF>>
                            <COND (<L? .ATT -1> <SET ATT -2>)
                                  (<G? .ATT 1> <SET ATT 2>)>
                            <SET TBL <NTH ,DEF3-RES <+ .ATT 3>>>)>
                     <SET RES <NTH .TBL <+ 1 <MOD <RANDOM> 9>>>>
                     <COND (.OUT?
                            <COND (<==? .RES ,STAGGER> <SET RES ,HESITATE>)
                                  (ELSE <SET RES ,SITTING-DUCK>)>)>
                     <COND (<AND <==? .RES ,STAGGER> .DWEAPON <PROB 25>>
                            <SET RES ,LOSE-WEAPON>)>
                     <PRES <NTH .REMARKS <+ .RES 1>>
                           <COND (.HERO? "Adventurer") (ELSE .VDESC)>
                           <COND (.HERO? .VDESC) (ELSE "Adventurer")>
                           <AND .DWEAPON <ODESC2 .DWEAPON>>>)>
              <COND (<OR <==? .RES ,MISSED> <==? .RES ,HESITATE>>)
                    (<==? .RES ,UNCONSCIOUS>
                     <COND (.HERO? <SET DEF <- .DEF>>)>)
                    (<OR <==? .RES ,KILLED> <==? .RES ,SITTING-DUCK>> <SET DEF 0>)
                    (<==? .RES ,LIGHT-WOUND> <SET DEF <MAX 0 <- .DEF 1>>>)
                    (<==? .RES ,SERIOUS-WOUND> <SET DEF <MAX 0 <- .DEF 2>>>)
                    (<==? .RES ,STAGGER>
                     <COND (.HERO? <TRO .VILLAIN ,STAGGERED>)
                           (ELSE <TRO .HERO ,ASTAGGERED>)>)
                    (<AND <==? .RES ,LOSE-WEAPON> .DWEAPON>
                     <COND (.HERO?
                            <REMOVE-OBJECT .DWEAPON>
                            <INSERT-OBJECT .DWEAPON ,HERE>)
                           (ELSE
                            <DROP-OBJECT .DWEAPON .HERO>
                            <INSERT-OBJECT .DWEAPON ,HERE>
                            <COND (<SET NWEAPON <FWIM ,WEAPONBIT <AOBJS .HERO> T>>
                                   <TELL
"Fortunately, you still have a " 1 <ODESC2 .NWEAPON> ".">)>)>)
                    (ELSE <ERROR MELEE "CHOMPS" .RES>)>
              <COND (<NOT .HERO?>
                     <PUT .HERO ,ASTRENGTH <COND (<0? .DEF> -10000)(<- .DEF .OD>)>>
                     <COND (<L? <- .DEF .OD> 0>
                            <CLOCK-ENABLE ,CURIN>
                            <PUT ,CURIN ,CTICK ,CURE-WAIT>)>
                     <COND (<L=? <FIGHT-STRENGTH .HERO> 0>
                            <PUT .HERO ,ASTRENGTH <+ 1 <- <FIGHT-STRENGTH .HERO <>>>>>
                            <JIGS-UP 
"It appears that that last blow was too much for you.  I'm afraid you
are dead.">
                            <>)
                           (.RES)>)
                    (ELSE
                     <PUT .VILLAIN ,OCAPAC .DEF>
                     <COND (<0? .DEF>
                            <TRZ .VILLAIN ,FIGHTBIT>
                            <TELL
"Almost as soon as the " 0 .VDESC " breathes his last breath, a cloud
of sinister black fog envelops him, and when the fog lifts, the
carcass has disappeared.">
                            <REMOVE-OBJECT .VILLAIN>
                            <COND (<SET RANDOM-ACTION <OACTION .VILLAIN>>
                                   <PUT ,PRSVEC 1 ,DEAD\!!-WORDS>
                                   <APPLY-RANDOM .RANDOM-ACTION>)>
                            <TELL "">
                            .RES)
                           (<==? .RES ,UNCONSCIOUS>
                            <COND (<SET RANDOM-ACTION <OACTION .VILLAIN>>
                                   <PUT ,PRSVEC 1 ,OUT\!!-WORDS>
                                   <APPLY-RANDOM .RANDOM-ACTION>)>
                            .RES)
                           (.RES)>)>>>

<DEFINE WINNING? (V H "AUX" (VS <OCAPAC .V>) (PS <- .VS <FIGHT-STRENGTH .H>>))
        #DECL ((V) OBJECT (H) ADV (VS PS) FIX)
        <COND (<G? .PS 3> <PROB 90>)
              (<G? .PS 0> <PROB 75>)
              (<0? .PS> <PROB 50>)
              (<G? .VS 1> <PROB 25>)
              (ELSE <PROB 10>)>> 

<DEFINE CURE-CLOCK ("AUX" (HERO ,PLAYER) (S <ASTRENGTH .HERO>) (I ,CURIN))
        #DECL ((HERO) ADV (S) FIX (I) CEVENT)
        <COND (<G? .S 0> <PUT .HERO ,ASTRENGTH <SET S 0>>)
              (<L? .S 0> <PUT .HERO ,ASTRENGTH <SET S <+ .S 1>>>)>
        <COND (<L? .S 0> <PUT .I ,CTICK ,CURE-WAIT>)
              (ELSE <CLOCK-DISABLE .I>)>>

<DEFINE DIAGNOSE ("AUX" (W ,WINNER) (MS <FIGHT-STRENGTH .W <>>)
                        (WD <ASTRENGTH .W>) (RS <+ .MS .WD>) (I <CTICK ,CURIN>))
        #DECL ((W) ADV (MS WD RD I) FIX)
        <COND (<NOT <CFLAG ,CURIN>>
               <SET WD 0>)
              (<SET WD <- .WD>>)>
        <COND (<0? .WD> <TELL "You are in perfect health.">)
              (<1? .WD> <TELL "You have a light wound," 0>)
              (<==? .WD 2> <TELL "You have a serious wound," 0>)
              (<==? .WD 3> <TELL "You have several wounds," 0>)
              (<G? .WD 3> <TELL "You have serious wounds," 0>)>
        <COND (<NOT <0? .WD>>
               <TELL " which will be cured after " 0>
               <PRINC <+ <* ,CURE-WAIT <- .WD 1>> .I>>
               <TELL " moves.">)>
        <COND (<0? .RS> <TELL "You are dead.">)
              (<1? .RS> <TELL "You can be killed by one more light wound.">)
              (<==? .RS 2> <TELL "You can be killed by a serious wound.">)
              (<==? .RS 3> <TELL "You can survive one serious wound.">)
              (<G? .RS 3> <TELL "You are strong enough to take several wounds.">)>
        <COND (<NOT <0? ,DEATHS>>
               <TELL "You have been killed " 1 <COND (<1? ,DEATHS> "once.")
                                                     (T "twice.")>>)>>
