"VOCABULARY"

;"GLOBAL VARIABLES WHICH ARE ROOMS MUST BE HERE!"

<PSETG RMGVALS '![BLOC HERE!]>

;"GLOBAL VARIABLES WHICH ARE OBJECTS MUST BE HERE!"

<PSETG OBJGVALS '![!]>

;"GLOBAL VARIABLES WHICH ARE MONADS MUST BE HERE!"

<PSETG MGVALS
      '![KITCHEN-WINDOW!-FLAG
         TROLL-FLAG!-FLAG
         CAGE-SOLVE!-FLAG
         KEY-FLAG!-FLAG
         BUCKET-TOP!-FLAG
         CAROUSEL-FLIP!-FLAG
         CAROUSEL-ZOOM!-FLAG
         LOW-TIDE!-FLAG
         DOME-FLAG!-FLAG
         GLACIER-FLAG!-FLAG
         ECHO-FLAG!-FLAG
         RIDDLE-FLAG!-FLAG
         LLD-FLAG!-FLAG
         CYCLOPS-FLAG!-FLAG
         MAGIC-FLAG!-FLAG
         TRAP-DOOR!-FLAG
         LIGHT-LOAD!-FLAG
         SAFE-FLAG!-FLAG
         GNOME-FLAG!-FLAG
         GNOME-DOOR!-FLAG
         MIRROR-MUNG!-FLAG
         EGYPT-FLAG!-FLAG
         ON-POLE!-FLAG
         BLAB!-FLAG
         BINF!-FLAG
         BTIE!-FLAG
         BUOY-FLAG!-FLAG
         GRUNLOCK!-FLAG
         GATE-FLAG!-FLAG
         RAINBOW!-FLAG
         CAGE-TOP!-FLAG
         EMPTY-HANDED!-FLAG
         DEFLATE!-FLAG
         LIGHT-SHAFT
         PLAYED-TIME
         MOVES
         BRIEF!-FLAG
         THEN
         SUPER-BRIEF!-FLAG
         RAW-SCORE!]>

<PSETG CNTUSE "You can't use that!">

<SETG BIGFIX </ <CHTYPE <MIN> FIX> 2>>

<SETG WORDS <OR <GET WORDS OBLIST> <MOBLIST WORDS 23>>>

<SETG OBJECT-OBL <OR <GET OBJECTS OBLIST> <MOBLIST OBJECTS>>>

<SETG ROOM-OBL <OR <GET ROOMS OBLIST> <MOBLIST ROOMS>>>

<SETG ACTORS ()>

<SETG STARS ()>

<ADD-BUZZ "BY" "IS" "ONE" "IT" "A" "THE" "AN" "THIS" "OVER">

<ADD-DIRECTIONS "#!#!#" "NORTH" "SOUTH" "EAST" "WEST" "LAUNC" "LAND"
        "SE" "SW" "NE" "NW" "UP" "DOWN" "ENTER" "EXIT" "CROSS" "CLIMB">

<DSYNONYM "NORTH" "N">
<DSYNONYM "SOUTH" "S">
<DSYNONYM "EAST" "E">
<DSYNONYM "WEST" "W">
<DSYNONYM "UP" "U">
<DSYNONYM "DOWN" "D">
<DSYNONYM "ENTER" "IN">
<DSYNONYM "EXIT" "OUT" "LEAVE">
<DSYNONYM "CROSS" "TRAVE">

<ADD-ZORK PREP "WITH" "AT" "TO" "IN" "DOWN" "UP" "UNDER">

<SYNONYM "WITH" "USING" "THROU">

<SYNONYM "IN" "INSID" "INTO">

<SETG ROOMS ()>

<SETG OBJECTS ()>


"CEVENT DEFINITIONS"
<OR <LOOKUP "COMPILE" <ROOT>>
    <CEVENT 0 ,CURE-CLOCK <> "CURIN">>

<OR <LOOKUP "COMPILE" <ROOT>>
    <CEVENT 0 ,MAINT-ROOM T "MNTIN">>

<OR <LOOKUP "COMPILE" <ROOT>>
    <CEVENT 0 ,LANTERN T "LNTIN">>

<OR <LOOKUP "COMPILE" <ROOT>>
    <CEVENT 0 ,MATCH-FUNCTION T MATIN>>

<OR <LOOKUP "COMPILE" <ROOT>>
    <CEVENT 0 ,CANDLES T "CNDIN">>

<OR <LOOKUP "COMPILE" <ROOT>>
    <CEVENT 0 ,BALLOON T "BINT">>

<OR <LOOKUP "COMPILE" <ROOT>>
    <CEVENT 0 ,BURNUP T "BRNIN">>

<OR <LOOKUP "COMPILE" <ROOT>>
    <CEVENT 0 ,FUSE-FUNCTION T "FUSIN">>

<OR <LOOKUP "COMPILE" <ROOT>>
    <CEVENT 0 ,LEDGE-MUNG T "LEDIN">>

<OR <LOOKUP "COMPILE" <ROOT>>
    <CEVENT 0 ,SAFE-MUNG T "SAFIN">>

<OR <LOOKUP "COMPILE" <ROOT>>
    <CEVENT 0 ,VOLGNOME T "VLGIN">>

<OR <LOOKUP "COMPILE" <ROOT>>
    <CEVENT 0 ,GNOME-FUNCTION T "GNOIN">>

<OR <LOOKUP "COMPILE" <ROOT>>
    <CEVENT 0 ,BUCKET T "BCKIN">>

<OR <LOOKUP "COMPILE" <ROOT>>
    <CEVENT 0 ,SPHERE-FUNCTION T "SPHIN">>


; "KLUDGE"

<OBJECT "#####"
         "You are here" "cretin" %<> %<> () %<> %,OVISON>
         
"MAZE"

<PSETG FOREST "Forest">

<PSETG CURRENT #NEXIT "You cannot go upstream due to strong currents.">

<ROOM "PASS1"
"You are in a narrow east-west passageway.  There is a narrow stairway
leading down at the north end of the room."
       "East-West Passage"
       %<>
       <EXIT "EAST" "CAROU" "WEST" "MTROL" "DOWN" "RAVI1" "NORTH" "RAVI1"> 
       () %<> 5>

<ROOM "WHOUS"
"You are in an open field west of a big white house, with a boarded
front door."
       "West of House"
       T
       <EXIT "NORTH" "NHOUS" "SOUTH" "SHOUS" "WEST" "FORE1"
              "EAST" #NEXIT "The door is locked, and there is evidently no key.">
       (<FIND-OBJ "FDOOR"> <FIND-OBJ "MAILB">)>

<ROOM "NHOUS"
       "You are facing the north side of a white house.  There is no door here,
and all the windows are barred."
       "North of House"
       T
       <EXIT "WEST" "WHOUS" "EAST" "EHOUS" "NORTH" "FORE3"
              "SOUTH" #NEXIT "The windows are all barred.">>

<ROOM "SHOUS"
"You are facing the south side of a white house. There is no door here,
and all the windows are barred."
       "South of House"
       T
       <EXIT "WEST" "WHOUS" "EAST" "EHOUS" "SOUTH" "FORE2"
              "NORTH" #NEXIT "The windows are all barred.">
       ()>

<ROOM "EHOUS"
       ""
       "Behind House"
       T
       <EXIT "NORTH" "NHOUS" "SOUTH" "SHOUS" "EAST" "CLEAR"
              "WEST" <CEXIT "KITCHEN-WINDOW" "KITCH">
              "ENTER" <CEXIT "KITCHEN-WINDOW" "KITCH">>
       (<FIND-OBJ "WIND1">)
       EAST-HOUSE>

<ROOM "KITCH"
       ""
       "Kitchen"
       T
       <EXIT "EAST" <CEXIT "KITCHEN-WINDOW" "EHOUS"> "WEST" "LROOM"
              "EXIT" <CEXIT "KITCHEN-WINDOW" "EHOUS"> "UP" "ATTIC"
              "DOWN" #NEXIT "Only Santa Claus climbs down chimneys.">
       (<FIND-OBJ "WIND2"> <FIND-OBJ "SBAG"> <FIND-OBJ "BOTTL">)
       KITCHEN 10>

<ADD-OBJECT
 <OBJECT "SBAG"
          "A sandwich bag is here."
          "sandwich bag"
          "On the table is an elongated brown sack, smelling of hot peppers."
          %<> (<FIND-OBJ "GARLI"> <FIND-OBJ "FOOD">)
          %<> %<+ ,CONTBIT ,FLAMEBIT ,OVISON ,TAKEBIT> 0 0 0 3 15>
["BAG" "SACK" "BAGGI"] ["BROWN"]>

<ADD-OBJECT
 <OBJECT "GARLI"
          "There is a clove of garlic here."
          "clove of garlic"
          %<> %<> () <FIND-OBJ "SBAG"> %<+ ,TAKEBIT ,FOODBIT ,OVISON> 0 0 0 5 0>
["CLOVE"]>


<ADD-OBJECT
 <OBJECT "FOOD"
          "A hot pepper sandwich is here."
          "\.lunch"
          %<>
          %<> () <FIND-OBJ "SBAG"> %<+ ,FOODBIT ,TAKEBIT ,OVISON> 0 0 0 5 0>
["SANDW" "LUNCH" "PEPPE" "DINNE" "SNACK"]>

<ADD-OBJECT
 <OBJECT "GUNK"
          "There is a small piece of vitreous slag here."
          "piece of vitreous slag"
          %<> GUNK-FUNCTION () %<> %<+ ,TRYTAKEBIT ,TAKEBIT ,OVISON> 0 0 0 10 0>
["MESS" "SLAG"] ["VITRE"]>

<ADD-OBJECT
 <OBJECT "COAL"
          "There is a small heap of coal here."
          "small pile of coal"
          %<> %<> () %<> %<+ ,BURNBIT ,TAKEBIT ,OVISON> 0 0 0 20 0>
["HEAP" "CHARC"]>

<ADD-OBJECT
 <OBJECT "JADE"
          "There is an exquisite jade figurine here."
          "jade figurine"
          %<> %<> () %<> %<+ ,TAKEBIT ,OVISON> 0 5 5 10 0>
["FIGUR"]>

<ADD-OBJECT
 <OBJECT "MACHI"
          ""
          "machine"
          %<> MACHINE-FUNCTION () %<> %<+ ,CONTBIT ,OVISON> 0 0 0 %,BIGFIX 50>
["PDP10" "DRYER" "LID"]>

<ADD-OBJECT 
 <OBJECT "DIAMO"
          "There is an enormous diamond (perfectly cut) here."
          "huge diamond"
          %<>
          %<> () %<> %<+ ,TAKEBIT ,OVISON> 0 10 6 5 0>
 ["PERFE"]>

<ADD-OBJECT
 <OBJECT "TCASE"
          "There is a trophy case here."
          "trophy case"
          %<> TROPHY-CASE () %<> %<+ ,CONTBIT ,TRANSBIT ,OVISON>
          0 0 0 %,BIGFIX %,BIGFIX>
 ["CASE"] ["TROPH"]>

<ADD-OBJECT 
 <OBJECT "BOTTL"
         "A clear glass bottle is here."
         "glass bottle"
         "A bottle is sitting on the table."
         BOTTLE-FUNCTION
         (<FIND-OBJ "WATER">)
         %<>
         %<+ ,CONTBIT ,TRANSBIT ,TAKEBIT ,OVISON> 0 0 0 5 4>
["CONTA" "PITCH"] ["GLASS"]>

<ADD-OBJECT
 <OBJECT "WATER"
         "Water"
         "quantity of water"
         "There is some water here"
         WATER-FUNCTION
         ()
         <FIND-OBJ "BOTTL">
         %<+ ,DRINKBIT ,TAKEBIT ,OVISON> 0 0 0 4 0>[ "LIQUI" "H2O"]>

<ROOM "ATTIC"
"You are in the attic.  The only exit is stairs that lead down."
        "Attic"
        %<>
        <EXIT "DOWN" "KITCH">
        (<FIND-OBJ "BRICK"> <FIND-OBJ "ROPE"> <FIND-OBJ "KNIFE">)>

<ADD-OBJECT
 <OBJECT "ROPE"
          "There is a large coil of rope here."
          "rope"
          "A large coil of rope is lying in the corner."
          ROPE-FUNCTION () %<> %<+ ,TIEBIT ,TAKEBIT ,OVISON> 0 0 0 10 0>
["HEMP" "COIL"]>


<ADD-OBJECT
 <OBJECT "KNIFE"
          "There is a nasty-looking knife lying here."
          "knife"
          "On a table is a nasty-looking knife."
          %<> () %<> %<+ ,TAKEBIT ,OVISON ,WEAPONBIT> 0 0 0 5 0>
["BLADE"] ["NASTY"]>

<ADD-MELEE <FIND-OBJ "KNIFE"> ,KNIFE-MELEE>

<ROOM "LROOM"
       ""
       "Living Room"
       T
       <EXIT "EAST" "KITCH"
              "WEST" <CEXIT "MAGIC-FLAG" "BLROO" "The door is nailed shut.">
              "DOWN" <CEXIT "TRAP-DOOR" "CELLA">>
       (<FIND-OBJ "WDOOR"> <FIND-OBJ "DOOR"> <FIND-OBJ "TCASE"> 
        <FIND-OBJ "LAMP"> <FIND-OBJ "RUG"> <FIND-OBJ "PAPER">
        <FIND-OBJ "SWORD">)
       LIVING-ROOM>

<ADD-OBJECT
 <OBJECT "SWORD"
          "There is an elvish sword here."
          "sword"
          "On hooks above the mantelpiece hangs an elvish sword of great
antiquity." SWORD () %<> %<+ ,OVISON ,TAKEBIT ,WEAPONBIT> 0 0 0 30 0>
 ["ORCRI" "GLAMD" "BLADE"] ["ELVIS"]>

<ADD-MELEE <FIND-OBJ "SWORD"> ,SWORD-MELEE>

<ADD-OBJECT
 <OBJECT "LAMP"
          "There is a brass lantern (battery-powered) here."
          "lamp"
          "A battery-powered brass lantern is on the trophy case."
          LANTERN () %<> %<+ ,TAKEBIT ,OVISON> -1 0 0 15 0>
["LANTE"] ["BRASS"]>

<ADD-OBJECT
  <OBJECT "BLAMP"
           "There is a broken brass lantern here."
           "broken lamp"
           %<>
           %<> () %<> %<+ ,TAKEBIT ,OVISON> 0>
["LAMP" "LANTE"] ["BROKE"]>

<ADD-OBJECT
 <OBJECT "RUG"
         ""
         "carpet"
         %<>
         RUG () %<> %<+ ,TRYTAKEBIT ,NDESCBIT ,OVISON> 0 0 0 %,BIGFIX 0>
["CARPE"] ["ORIEN"]>

<ADD-OBJECT
<OBJECT "LEAVE"
          "There is a pile of leaves on the ground."
          "pile of leaves"
          %<>
          LEAF-PILE () %<> %<+ ,BURNBIT ,TAKEBIT ,OVISON> 0 0 0 25 0>
["LEAF" "PILE"]>

<ROOM "CELLA"
       ""
       "Cellar"
       %<>
       <EXIT "EAST" "MTROL" "SOUTH" "CHAS2"
              "UP"
              <CEXIT "TRAP-DOOR"
                      "LROOM"
                      "The trap door has been barred from the other side.">
              "WEST"
              #NEXIT "You try to ascend the ramp, but it is impossible, and you slide back down.">
       (<FIND-OBJ "TDOOR">)
       CELLAR
       25>

<PSETG TCHOMP "The troll fends you off with a menacing gesture.">

<ROOM "MTROL"

"You are in a small room with passages off in all directions. 
Bloodstains and deep scratches (perhaps made by an axe) mar the
walls."
       "The Troll Room"
       %<> <EXIT "WEST" "CELLA"
                  "EAST" <CEXIT "TROLL-FLAG" "CRAW4" %,TCHOMP>
                  "NORTH" <CEXIT "TROLL-FLAG" "PASS1" %,TCHOMP>
                  "SOUTH" <CEXIT "TROLL-FLAG" "MAZE1" %,TCHOMP>>
       (<FIND-OBJ "TROLL">)>

<PSETG TROLLDESC
"A nasty-looking troll, brandishing a bloody axe, blocks all passages
out of the room.">

<PSETG TROLLOUT
"An unconscious troll is sprawled on the floor.  All passages out of
the room are open.">

<SETG VILLAINS (<FIND-OBJ "TROLL"> <FIND-OBJ "THIEF"> <FIND-OBJ "CYCLO">)>
<SETG VILLAIN-PROBS <IUVECTOR <LENGTH ,VILLAINS> 0>>
<SETG OPPV <IVECTOR <LENGTH ,VILLAINS> '<>>>

<ADD-DEMON <SETG SWORD-DEMON
                  <CHTYPE [SWORD-GLOW ,VILLAINS () <1 ,ROOMS> <FIND-OBJ "SWORD"> <>]
                          HACK>>>

 <OBJECT "TROLL"
          %,TROLLDESC
          "troll"
          %<>
          TROLL
          (<FIND-OBJ "AXE">) %<> %<+ ,VICBIT ,OVISON ,VILLAIN> 0 0 0 %,BIGFIX 2>

<ADD-MELEE <FIND-OBJ "TROLL"> ,TROLL-MELEE>

<ADD-DEMON <SETG FIGHT-DEMON
                 <CHTYPE [FIGHTING ,VILLAINS () <1 ,ROOMS> <FIND-OBJ "TROLL"> <>]
                         HACK>>>

<ADD-OBJECT
 <OBJECT "AXE"
          "There is a bloody axe here."
          "bloody axe"
          %<> %<> () %<FIND-OBJ "TROLL"> %<+ ,OVISON ,WEAPONBIT> 0 0 0 25 0>
 []["BLOOD"]>

<PSETG MAZEDESC "You are in a maze of twisty little passages, all alike.">

<PSETG DEADEND "Dead End">

<ROOM "MAZE1"
       %,MAZEDESC %,MAZEDESC %<>
       <EXIT "WEST" "MTROL"
              "NORTH" "MAZE1"
              "SOUTH" "MAZE2"
              "EAST" "MAZE4"> ()>

<ROOM "MAZE2"
       %,MAZEDESC %,MAZEDESC %<>
       <EXIT "SOUTH" "MAZE1"
              "NORTH" "MAZE4"
              "EAST" "MAZE3"> ()>

<ROOM "MAZE3"
       %,MAZEDESC %,MAZEDESC %<>
       <EXIT "WEST" "MAZE2" "NORTH" "MAZE4" "UP" "MAZE5"> ()>

<ROOM "MAZE4"
       %,MAZEDESC %,MAZEDESC %<>
       <EXIT "WEST" "MAZE3" "NORTH" "MAZE1" "EAST" "DEAD1"> ()>

<ROOM "DEAD1"
       %,DEADEND %,DEADEND %<>
       <EXIT "SOUTH" "MAZE4"> ()>

<ROOM "MAZE5"
       %,MAZEDESC %,MAZEDESC %<>
       <EXIT "EAST" "DEAD2" "NORTH" "MAZE3" "SW" "MAZE6">
       (<FIND-OBJ "BONES"> <FIND-OBJ "BAGCO"> <FIND-OBJ "KEYS">
        <FIND-OBJ "BLANT"> <FIND-OBJ "RKNIF">)>

<ADD-OBJECT
 <OBJECT "RKNIF"
          "There is a rusty knife here."
          "rusty knife"
          "Beside the skeleton is a rusty knife."
          RUSTY-KNIFE () %<> %<+ ,OVISON ,TAKEBIT ,WEAPONBIT> 0 0 0 20 0>
 ["KNIFE"] ["RUSTY"]>

<ADD-MELEE <FIND-OBJ "RKNIF"> ,KNIFE-MELEE>

<ADD-OBJECT
 <OBJECT "BLANT"
          "There is a burned-out lantern here."
          "burned-out lantern"
          "The deceased adventurer's useless lantern is here."
          %<> () %<> %<+ ,OVISON ,TAKEBIT> 0 0 0 20 0>
 ["LANTE" "LAMP"] ["USED" "BURNE" "DEAD" "USELE"]>

<OBJECT "KEYS"
         "There is a set of skeleton keys here."
         "set of skeleton keys"
         %<> %<> () %<> %<+ ,TOOLBIT ,TAKEBIT ,OVISON> 0 0 0 10 0>

<ADD-OBJECT
 <OBJECT "BONES"
"A skeleton, probably the remains of a luckless adventurer, lies here."
          "" %<> SKELETON () %<> %<+ ,TRYTAKEBIT ,OVISON> 0 0 0 %,BIGFIX 0>
["SKELE" "BODY"]>

<ADD-OBJECT
 <OBJECT "BAGCO"
          "An old leather bag, bulging with coins, is here."
          "bag of coins"
          %<> %<> () %<> %<+ ,TAKEBIT ,OVISON> 0 10 5 15 0>
["BAG" "COINS"] ["LEATH"]>

<ADD-OBJECT 
 <OBJECT "BAR"
          "There is a large platinum bar here."
          "platinum bar"
          %<> %<> () %<> %<+ ,SACREDBIT ,TAKEBIT ,OVISON> 0 12 10 20 0>
["PLATI"]>

<ADD-OBJECT
 <OBJECT "PEARL"
          "There is a pearl necklace here with hundreds of large pearls."
          "pearl necklace"
          %<> %<> () %<> %<+ ,TAKEBIT ,OVISON> 0 9 5 10 0>
["NECKL"]>

<ROOM "DEAD2"
       %,DEADEND %,DEADEND %<>
       <EXIT "WEST" "MAZE5"> ()>

<ROOM "MAZE6"
       %,MAZEDESC %,MAZEDESC %<>
       <EXIT "DOWN" "MAZE5" "EAST" "MAZE7" "WEST" "MAZE6" "UP" "MAZE9"> ()>

<ROOM "MAZE7"
       %,MAZEDESC %,MAZEDESC %<>
       <EXIT "UP" "MAZ14" "WEST" "MAZE6" "NE" "DEAD1" "EAST" "MAZE8" "SOUTH" "MAZ15">
       ()>

<ROOM "MAZE8"
       %,MAZEDESC %,MAZEDESC %<>
       <EXIT "NE" "MAZE7" "WEST" "MAZE8" "SE" "DEAD3"> ()>

<ROOM "DEAD3"
       %,DEADEND %,DEADEND %<>
       <EXIT "NORTH" "MAZE8"> ()>

<ROOM "MAZE9"
       %,MAZEDESC %,MAZEDESC %<>
       <EXIT "NORTH" "MAZE6" "EAST" "MAZ11" "DOWN" "MAZ10" "SOUTH" "MAZ13"
              "WEST" "MAZ12" "NW" "MAZE9"> ()>

<ROOM "MAZ10"
       %,MAZEDESC %,MAZEDESC %<>
       <EXIT "EAST" "MAZE9" "WEST" "MAZ13" "UP" "MAZ11"> ()>

<ROOM "MAZ11"
       %,MAZEDESC
       %,MAZEDESC
        %<>
       <EXIT "NE" "MGRAT" "DOWN" "MAZ10" "NW" "MAZ13" "SW" "MAZ12">>
              
<ROOM "MGRAT"
       ""
       "Grating Room" %<>
       <EXIT "SW" "MAZ11" "UP" <CEXIT "KEY-FLAG" "CLEAR" "The grating is locked">>
       (<FIND-OBJ "GRAT2">) MAZE-11>

<ROOM "MAZ12"
       %,MAZEDESC %,MAZEDESC %<>
       <EXIT "WEST" "MAZE5" "SW" "MAZ11" "EAST" "MAZ13" "UP" "MAZE9" "NORTH" "DEAD4"> ()>

<ROOM "DEAD4"
       %,DEADEND %,DEADEND %<>
       <EXIT "SOUTH" "MAZ12"> ()>

<ROOM "MAZ13"
       %,MAZEDESC %,MAZEDESC %<>
       <EXIT "EAST" "MAZE9" "DOWN" "MAZ12" "SOUTH" "MAZ10" "WEST" "MAZ11"> ()>

<ROOM "MAZ14"
       %,MAZEDESC %,MAZEDESC %<>
       <EXIT "WEST" "MAZ15" "NW" "MAZ14" "NE" "MAZE7" "SOUTH" "MAZE7">>

<ROOM "MAZ15"
       %,MAZEDESC %,MAZEDESC %<>
       <EXIT "WEST" "MAZ14" "SOUTH" "MAZE7" "NE" "CYCLO">>

<PSETG STFORE        "You are in a forest, with trees in all directions around you.">

<ROOM "FORE1"
       %,STFORE
       %,FOREST T
       <EXIT "NORTH" "FORE1" "EAST" "FORE3" "SOUTH" "FORE2" "WEST" "FORE1"> ()>

<ROOM "FORE4"
       "You are in a large forest, with trees obstructing all views except
to the east, where a small clearing may be seen through the trees."
       %,FOREST
       T
       <EXIT "EAST" "CLTOP" "NORTH" "FORE5" "SOUTH" "FORE4" "WEST" "FORE2">>

<ROOM "FORE5"
       %,STFORE
       %,FOREST
       T
       <EXIT "NORTH" "FORE5" "SE" "CLTOP" "SOUTH" "FORE4" "WEST" "FORE2">>

<PSETG FORDES
"You are in a dimly lit forest, with large trees all around.  To the
east, there appears to be sunlight.">

<ROOM "FORE2"
       %,FORDES
       %,FOREST T
       <EXIT "NORTH" "SHOUS" "EAST" "CLEAR" "SOUTH" "FORE4" "WEST" "FORE1"> ()>

<ROOM "FORE3"
       %,FORDES
       %,FOREST T
       <EXIT "NORTH" "FORE2" "EAST" "CLEAR" "SOUTH" "CLEAR" "WEST" "NHOUS"> ()>

<ROOM "CLEAR"
       ""
       "Clearing" T
       <EXIT "SW" "EHOUS" "SE" "FORE5" "NORTH" "CLEAR" "EAST" "CLEAR"
              "WEST" "FORE3" "SOUTH" "FORE2" "DOWN" <CEXIT "KEY-FLAG" "MGRAT">>
       (<FIND-OBJ "GRAT1"> <FIND-OBJ "LEAVE">) CLEARING>

<ROOM "RAVI1"

"You are in a deep ravine at a crossing with an east-west crawlway. 
Some stone steps are at the south of the ravine and a steep staircase
descends."
       "Deep Ravine"
       %<>
       <EXIT "SOUTH" "PASS1" "DOWN" "RESES" "EAST" "CHAS1" "WEST" "CRAW1">>

<ROOM "CRAW1"

"You are in a crawlway with a three-foot high ceiling.  Your footing
is very unsure here due to the assortment of rocks underfoot. 
Passages can be seen in the east, west, and northwest corners of the
passage."
       "Rocky Crawl"
       %<>
       <EXIT "WEST" "RAVI1" "EAST" "DOME" "NW" "EGYPT">>

<ROOM "RESES"
       ""
       "Reservoir South"
       %<>
       <EXIT "SOUTH" <CEXIT "EGYPT-FLAG"
                              "RAVI1"
                              "The coffin will not fit through this passage."
                              T
                              COFFIN-CURE>
              "WEST" "STREA"
              "CROSS" <CEXIT "LOW-TIDE" "RESEN" "You are not equipped for swimming.">
              "NORTH" <CEXIT "LOW-TIDE" "RESEN" "You are not equipped for swimming.">
              "UP" <CEXIT "EGYPT-FLAG"
                           "CANY1"
                           "The stairs are too steep for carrying the coffin."
                           T
                           COFFIN-CURE>>
       (<FIND-OBJ "TRUNK">)
       RESERVOIR-SOUTH>

<ROOM "RESEN"
       ""
       "Reservoir North"
       %<>
       <EXIT "NORTH" "ATLAN"
              "CROSS" <CEXIT "LOW-TIDE" "RESES" "You are not equipped for swimming.">
              "SOUTH" <CEXIT "LOW-TIDE" "RESES" "You are not equipped for swimming.">>
       (<FIND-OBJ "PUMP">)
       RESERVOIR-NORTH>

<ROOM "STREA"

"You are standing on a path beside a flowing stream.  The path
travels to the north and the east."
       "Stream"
       %<>
       <EXIT "EAST" "RESES" "NORTH" "ICY">
       (<FIND-OBJ "FUSE">)>

<ROOM "EGYPT"
"You are in a room which looks like an Egyptian tomb.  There is an
ascending staircase in the room as well as doors, east and south."
       "Egyptian Room"
       %<>
       <EXIT "UP" "ICY" "SOUTH" "LEDG3"
              "EAST" <CEXIT "EGYPT-FLAG" "CRAW1"
                             "The passage is too narrow to accomodate coffins." T
                             COFFIN-CURE>>
       (<FIND-OBJ "COFFI">)>

<ROOM "ICY"
       ""
       "Glacier Room"
       %<>
       <EXIT "NORTH" "STREA" "EAST" "EGYPT" "WEST" <CEXIT "GLACIER-FLAG" "RUBYR">>
       (<FIND-OBJ "ICE">)
       GLACIER-ROOM>

<ADD-OBJECT
 <OBJECT "REFL1"
          ""
          "mirror"
          %<> MIRROR-MIRROR () %<> %<+ ,TRYTAKEBIT ,VICBIT ,OVISON> 0 0 0 %,BIGFIX 0>
 ["MIRRO"]>

<ADD-OBJECT
 <OBJECT "REFL2"
          ""
          "mirror"
          %<> MIRROR-MIRROR () %<> %<+ ,TRYTAKEBIT ,VICBIT ,OVISON> 0 0 0 %,BIGFIX 0>
 ["MIRRO"]>

<ADD-OBJECT
 <OBJECT "ICE"
          "A mass of ice fills the western half of the room."
          "glacier" %<> GLACIER ()  %<> %<+ ,VICBIT ,OVISON> 0 0 0 %,BIGFIX 0>
["GLACI"]>

<ROOM "RUBYR"
"You are in a small chamber behind the remains of the Great Glacier.
To the south and west are small passageways."
       "Ruby Room"
       %<>
       <EXIT "WEST" "LAVA" "SOUTH" "ICY">
       (<FIND-OBJ "RUBY">)>

<ROOM "ATLAN"
       "You are in an ancient room, long buried by the Reservoir.  There are
exits here to the southeast and upward."
       "Atlantis Room"
       %<>
       <EXIT "SE" "RESEN" "UP" "CAVE1">
       (<FIND-OBJ "TRIDE">)>

<ROOM "CANY1"
"You are on the south edge of a deep canyon.  Passages lead off
to the east, south, and northwest.  You can hear the sound of
flowing water below."
       "Deep Canyon"
       %<>
       <EXIT "NW" "RESES" "EAST" "DAM" "SOUTH" "CAROU">>

<ROOM "ECHO"
"You are in a large room with a ceiling which cannot be detected from
the ground. There is a narrow passage from east to west and a stone
stairway leading upward.  The room is extremely noisy.  In fact, it is
difficult to hear yourself think."
       "Loud Room"
       %<>
       <EXIT "EAST" "CHAS3" "WEST" "PASS5" "UP" "CAVE3">
       (<FIND-OBJ "BAR">)
       ECHO-ROOM>

 <OBJECT "RUBY"
          "There is a moby ruby lying here."
          "ruby"
          "On the floor lies a moby ruby."
          %<>
          ()
          %<>
          %<+ ,TAKEBIT ,OVISON>
          0
          15
          8
          5
          0>

<ADD-OBJECT
 <OBJECT "TRIDE"
          "Neptune's own crystal trident is here."
          "crystal trident"
          "On the shore lies Neptune's own crystal trident."
          %<> () %<> %<+ ,TAKEBIT ,OVISON> 0 4 11 20 0>
["FORK"] ["CRYST"]>

<ADD-OBJECT
 <OBJECT "COFFI"
"There is a solid-gold coffin, used for the burial of Ramses II, here."
          "gold coffin"
          %<> %<> () %<> %<+ ,CONTBIT ,SACREDBIT ,TAKEBIT ,OVISON> 0 3 7 55 35>
["CASKE"] ["GOLD"]>

<ADD-OBJECT
 <OBJECT "TORCH"
          "There is an ivory torch here."
          "torch"
          "Sitting on the pedestal is a flaming torch, made of ivory."
          %<> () %<> %<+ ,TOOLBIT ,FLAMEBIT ,TAKEBIT ,OVISON> 1 14 6 20 0>
[] ["IVORY"]>

<ROOM "MIRR1"
       ""
       "Mirror Room"
       %<>
       <EXIT "WEST" "PASS3" "NORTH" "CRAW2" "EAST" "CAVE1">
       (<FIND-OBJ "REFL1">)
       MIRROR-ROOM>

<ROOM "MIRR2"
       ""
       "Mirror Room"
       T
       <EXIT "WEST" "PASS4" "NORTH" "CRAW3" "EAST" "CAVE2">
       (<FIND-OBJ "REFL2">)
       MIRROR-ROOM>

<ROOM "CAVE1"
"You are in a small cave with an entrance to the north and a stairway
leading down."
       "Cave"
       %<>
       <EXIT "NORTH" "MIRR1" "DOWN" "ATLAN">>

<ROOM "CAVE2"
"You are in a tiny cave with entrances west and north, and a dark,
forbidding staircase leading down."
       "Cave"
       %<>
       <EXIT "NORTH" "CRAW3" "WEST" "MIRR2" "DOWN" "LLD1"> () CAVE2-ROOM>

<ROOM "CRAW2"
"You are in a steep and narrow crawlway.  There are two exits nearby to
the south and southwest."
       "Steep Crawlway"
       %<>
       <EXIT "SOUTH" "MIRR1" "SW" "PASS3">>

<ROOM "CRAW3"
"You are in a narrow crawlway.  The crawlway leads from north to south.
However the south passage divides to the south and southwest."
      "Narrow Crawlway"
       %<>
       <EXIT "SOUTH" "CAVE2" "SW" "MIRR2" "NORTH" "MGRAI">>

<ROOM "PASS3"
"You are in a cold and damp corridor where a long east-west passageway
intersects with a northward path."
       "Cold Passage"
       %<>
       <EXIT "EAST" "MIRR1" "WEST" "SLIDE" "NORTH" "CRAW2">>

<ROOM "PASS4"

"You are in a winding passage.  It seems that there is only an exit
on the east end although the whirring from the round room can be
heard faintly to the north."
       "Winding Passage"
       %<>
       <EXIT "EAST" "MIRR2" "NORTH"
 #NEXIT "You hear the whir of the carousel room but can find no entrance.">>

<ROOM "SLIDE" 

"You are in a small chamber, which appears to have been part of a
coal mine. On the south wall of the chamber the letters \"Granite
Wall\" are etched in the rock. To the east is a long passage and
there is a steep metal slide twisting downward. From the appearance
of the slide, an attempt to climb up it would be impossible.  To the
north is a small opening."
       "Slide Room"
       %<>
       <EXIT "EAST" "PASS3" "DOWN" "CELLA" "NORTH" "ENTRA">>

<ROOM "ENTRA"

"You are standing at the entrance of what might have been a coal
mine. To the northeast and the northwest are entrances to the mine,
and there is another exit on the south end of the room."
       "Mine Entrance"
       %<>
       <EXIT "SOUTH" "SLIDE" "NW" "SQUEE" "NE" "TSHAF">>

<ROOM "SQUEE"
"You are a small room.  Strange squeaky sounds may be heard coming from
the passage at the west end.  You may also escape to the south."
       "Squeaky Room"
       %<>
       <EXIT "WEST" "BATS" "SOUTH" "ENTRA">>

<ROOM "TSHAF"
       "You are in a large room, in the middle of which is a small shaft
descending through the floor into darkness below.  To the west and
the north are exits from this room.  Constructed over the top of the
shaft is a metal framework to which a heavy iron chain is attached."
       "Shaft Room"
       %<>
       <EXIT "DOWN" #NEXIT "You wouldn't fit and would die if you could."
              "WEST" "ENTRA" "NORTH" "TUNNE">
       (<FIND-OBJ "TBASK">)>

<PUT <ADD-OBJECT 
 <OBJECT "TBASK"
          "At the end of the chain is a basket."
          "basket"
          %<>
          DUMBWAITER () %<> %<+ ,CONTBIT ,OVISON ,TRANSBIT> 0 0 0 %,BIGFIX 50>
["CAGE" "DUMBW" "BASKE"]> ,OOPEN? T>

<ADD-OBJECT
 <OBJECT "FBASK"
          "" 
          ""
          %<>
          DUMBWAITER () %<> %,OVISON 0 0 0 %,BIGFIX 0>
["CAGE" "DUMBW" "BASKE"]>

<ROOM "TUNNE"

"You are in a narrow tunnel with large wooden beams running across
the ceiling and around the walls.  A path from the south splits into
paths running west and northeast."
       "Wooden Tunnel"
       %<>
       <EXIT "SOUTH" "TSHAF" "WEST" "SMELL" "NE" "MINE1">>

<ROOM "SMELL"

"You are in a small non-descript room.  However, from the direction
of a small descending staircase a foul odor can be detected.  To the
east is a narrow path."
       "Smelly Room"
       %<>
       <EXIT "DOWN" "BOOM" "EAST" "TUNNE">>

<ROOM "BOOM"
       "You are in a small room which smells strongly of coal gas."
       "Gas Room"
       %<>
       <EXIT "UP" "SMELL">
       (<FIND-OBJ "BRACE">)
       BOOM-ROOM>

<ADD-OBJECT
 <OBJECT "BRACE"
          "There is a sapphire-encrusted bracelet here."
          "sapphire bracelet"
          %<> %<> () %<> %<+ ,TAKEBIT ,OVISON> 0 5 3 10 0>
["JEWEL"] ["SAPPH"]>

<ROOM "TLADD"

"You are in a very small room.  In the corner is a rickety wooden
ladder, leading downward.  It might be safe to descend.  There is
also a staircase leading upward."
       "Ladder Top"
       %<>
       <EXIT "DOWN" "BLADD" "UP" "MINE7">>

<PSETG MINDESC 
"You are in a non-descript part of a coal mine.">

<ROOM "MINE1"
       %,MINDESC
       %,MINDESC
       %<>
       <EXIT "NORTH" "MINE4" "SW" "MINE2" "EAST" "TUNNE">>

<ROOM "MINE2"
       %,MINDESC
       %,MINDESC
       %<>
       <EXIT "SOUTH" "MINE1" "WEST" "MINE5" "UP" "MINE3" "NE" "MINE4">>

<ROOM "MINE3"
       %,MINDESC
       %,MINDESC
       %<>
       <EXIT "WEST" "MINE2" "NE" "MINE5" "EAST" "MINE5">>

<ROOM "MINE4"
       %,MINDESC
       %,MINDESC
       %<>
       <EXIT "UP" "MINE5" "NE" "MINE6" "SOUTH" "MINE1" "WEST" "MINE2">>

<ROOM "MINE5"
       %,MINDESC
       %,MINDESC
       %<>
       <EXIT "DOWN" "MINE6" "NORTH" "MINE7" "WEST" "MINE2" "SOUTH" "MINE3"
              "UP" "MINE3" "EAST" "MINE4">>

<ROOM "MINE6"
       %,MINDESC
       %,MINDESC
       %<>
       <EXIT "SE" "MINE4" "UP" "MINE5" "NW" "MINE7">>

<ROOM "MINE7"
       %,MINDESC
       %,MINDESC
       %<>
       <EXIT "EAST" "MINE1" "WEST" "MINE5" "DOWN" "TLADD" "SOUTH" "MINE6">>

<ROOM "BLADD"

"You are in a rather wide room.  On one side is the bottom of a
narrow wooden ladder.  To the northeast and the south are passages
leaving the room."
       "Ladder Bottom"
       %<>
       <EXIT "NE" "DEAD7" "SOUTH" "TIMBE" "UP" "TLADD">>

<ROOM "DEAD7"
       "Dead End"
       "Dead End"
       %<>
       <EXIT "SOUTH" "BLADD"> (<FIND-OBJ "COAL">)>

<PSETG NOFIT "You cannot fit through this passage with that load.">

<ROOM "TIMBE"
"You are in a long and narrow passage, which is cluttered with broken
timbers.  A wide passage comes from the north and turns at the 
southwest corner of the room into a very narrow passageway."
       "Timber Room"
       %<>
       <EXIT "NORTH" "BLADD"
              "SW" <CEXIT "EMPTY-HANDED" "BSHAF" %,NOFIT>> () NO-OBJS>

<ROOM "BSHAF" 

"You are in a small square room which is at the bottom of a long
shaft. To the east is a passageway and to the northeast a very narrow
passage. In the shaft can be seen a heavy iron chain."
       "Lower Shaft"
       %<>
       <EXIT "EAST" "MACHI"
              "OUT" <CEXIT "EMPTY-HANDED" "TIMBE" %,NOFIT>
              "NE" <CEXIT "EMPTY-HANDED" "TIMBE" %,NOFIT>
              "UP" #NEXIT "Not a chance."
              "CLIMB" #NEXIT "The chain is not climbable.">
       (<FIND-OBJ "FBASK">) NO-OBJS>

<ROOM "MACHI"
       ""
       "Machine Room"
       %<>
       <EXIT "NW" "BSHAF"> (<FIND-OBJ "MSWIT"> <FIND-OBJ "MACHI">) MACHINE-ROOM>

<ROOM "BATS" "" "Bat Room" %<> <EXIT "EAST" "SQUEE"> 
       (<FIND-OBJ "JADE"> <FIND-OBJ "BAT">) BATS-ROOM>

<ROOM "DOME"
       ""
       "Dome Room"
       %<>
       <EXIT "EAST" "CRAW1"
              "DOWN" <CEXIT "DOME-FLAG"
                             "MTORC"
                             "You cannot go down without fracturing many bones.">
              "CLIMB" <CEXIT "DOME-FLAG"
                              "MTORC"
                              "You cannot go down without fracturing many bones.">>
       (<FIND-OBJ "RAILI">)
       DOME-ROOM>

<ROOM "MTORC"
       ""
       "Torch Room"
       %<>
       <EXIT "UP" #NEXIT "You cannot reach the rope." "WEST" "MTORC" "DOWN" "CRAW4">
       (<FIND-OBJ "TORCH">)
       TORCH-ROOM>

<ROOM "CRAW4"
"You are in a north-south crawlway; a passage goes to the east also.
There is a hole above, but it provides no opportunities for climbing."
       "North-South Crawlway"
       %<>
       <EXIT "NORTH" "CHAS2" "SOUTH" "STUDI" "EAST" "MTROL"
              "UP" #NEXIT "Not even a human fly could get up it."> ()>

<ROOM "CHAS2"

"You are on the west edge of a chasm, the bottom of which cannot be
seen. The east side is sheer rock, providing no exits.  A narrow
passage goes west, and the path you are on continues to the north and
south."
       "West of Chasm"
       %<> <EXIT "WEST" "CELLA" "NORTH" "CRAW4" "SOUTH" "GALLE"
                  "DOWN" #NEXIT "The chasm probably leads straight to the infernal regions."> ()>

<ROOM "CAROU"
       ""
       "Round room" %<>
       <EXIT "NORTH" <CEXIT "CAROUSEL-FLIP" "CAVE4" "" %<> CAROUSEL-EXIT>
              "SOUTH" <CEXIT "CAROUSEL-FLIP" "CAVE4" "" %<> CAROUSEL-EXIT>
              "EAST" <CEXIT "CAROUSEL-FLIP" "MGRAI" "" %<> CAROUSEL-EXIT>
              "WEST" <CEXIT "CAROUSEL-FLIP" "PASS1" "" %<> CAROUSEL-EXIT>
              "NW" <CEXIT "CAROUSEL-FLIP" "CANY1" "" %<> CAROUSEL-EXIT>
              "NE" <CEXIT "CAROUSEL-FLIP" "PASS5" "" %<> CAROUSEL-EXIT>
              "SE" <CEXIT "CAROUSEL-FLIP" "PASS4" "" %<> CAROUSEL-EXIT>
              "SW" <CEXIT "CAROUSEL-FLIP" "MAZE1" "" %<> CAROUSEL-EXIT>
              "EXIT" <CEXIT "CAROUSEL-FLIP" "PASS3" "" %<> CAROUSEL-OUT>>
       (<FIND-OBJ "IRBOX">) CAROUSEL-ROOM>

<ADD-OBJECT
 <OBJECT "IRBOX"
          "There is a dented iron box here."
          "iron box"
          %<> %<> (<FIND-OBJ "STRAD">) %<> %<+ ,TAKEBIT ,CONTBIT> 0 0 0 40 20>
 ["BOX"] ["IRON" "DENTE"]>

<ADD-OBJECT
 <OBJECT "STRAD"
          "There is a Stradavarius here."
          "fancy violin"
          %<> %<> () <FIND-OBJ "IRBOX"> %<+ ,OVISON ,TAKEBIT> 0 10 10 10 0>
 ["VIOLI"] ["FANCY"]>

<ROOM "PASS5"
       "You are in a high north-south passage, which forks to the northeast."
       "North-South Passage"
       %<>
       <EXIT "NORTH" "CHAS1" "NE" "ECHO" "SOUTH" "CAROU"> ()>

<ROOM "CHAS1"
"A chasm runs southwest to northeast.  You are on the south edge; the
path exits to the south and to the east."
       "Chasm"
       %<> <EXIT "SOUTH" "RAVI1" "EAST" "PASS5"
                  "DOWN" #NEXIT "Are you out of your mind?"> ()>

<ROOM "CAVE3"

"You are in a cave.  Passages exit to the south and to the east, but
the cave narrows to a crack to the west.  The earth is particularly
damp here."
       "Damp Cave"
       %<> <EXIT "SOUTH" "ECHO" "EAST" "DAM"
                  "WEST" #NEXIT "It is too narrow for most insects.">
       ()>

<ROOM "CHAS3"
"A chasm, evidently produced by an ancient river, runs through the
cave here.  Passages lead off in all directions."
       "Ancient Chasm"
       %<> <EXIT "SOUTH" "ECHO" "EAST" "TCAVE" "NORTH" "DEAD5" "WEST" "DEAD6"> ()>

<ROOM "DEAD5"
       "Dead end"
       "Dead end"
       %<> <EXIT "SW" "CHAS3"> ()>

<ROOM "DEAD6"
       "Dead end"
       "Dead end" %<> <EXIT "EAST" "CHAS3"> ()>

<ROOM "CAVE4"
"You have entered a cave with passages leading north and southeast."
       "Engravings Cave"
       %<> <EXIT "NORTH" "CAROU" "SE" "RIDDL"> (<FIND-OBJ "ENGRA">)>

<ADD-OBJECT <SOBJECT "ENGRA" "wall with engravings" ,OVISON ,READBIT
         ,SACREDBIT>
            ["INSCR"] ["OLD" "ANCIE"]>

<PUT <FIND-OBJ "ENGRA"> ,ODESC1 "There are old engravings on the walls here.">

<ROOM "RIDDL"

"This is a room which is bare on all sides.  There is an exit down. 
To the east is a great door made of stone.  Above the stone, the
following words are written: 'No man shall enter this room without
solving this riddle:
  What is tall as a house,
          round as a cup, 
          and all the king's horses can't draw it up?'"
       "Riddle Room"
       %<>
       <EXIT "DOWN" "CAVE4"
              "EAST" <CEXIT "RIDDLE-FLAG" "MPEAR"
                             "Your way is blocked by an invisible force.">>
       (<FIND-OBJ "SDOOR">)>

<ROOM "MPEAR"
"This is a former broom closet.  The exits are to the east and west."
       "Pearl Room"
       %<> <EXIT "EAST" "BWELL" "WEST" "RIDDL"> (<FIND-OBJ "PEARL">)>

<ROOM "LLD1"
       ""
       "Entrance to Hades"
       T <EXIT "EAST"
                <CEXIT "LLD-FLAG"
                        "LLD2"
                        "Some invisible force prevents you from passing through the gate.">
                "UP" "CAVE2"
                "ENTER"
                <CEXIT "LLD-FLAG"
                        "LLD2"
                        "Some invisible force prevents you from passing through the gate.">>
       (<FIND-OBJ "CORPS"> <FIND-OBJ "GATES"> <FIND-OBJ "GHOST">) LLD-ROOM>

<ADD-OBJECT
 <OBJECT "GHOST"
          ""
          "" %<> GHOST-FUNCTION () %<> %<+ ,VICBIT ,OVISON> 0 0 0
          %,BIGFIX 0>
["SPIRI" "FIEND"]>       

<ROOM "LLD2"
       ""
       "Land of the Living Dead"
       T <EXIT "EAST" "TOMB"
                "EXIT" "LLD1" "WEST" "LLD1"> (<FIND-OBJ "BODIE">) LLD2-ROOM 30>

<ROOM "MGRAI"
"You are standing in a small circular room with a pedestal.  A set of
stairs leads up, and passages leave to the east and west."
       "Grail Room"
       %<> <EXIT "WEST" "CAROU" "EAST" "CRAW3" "UP" "TEMP1">
       (<FIND-OBJ "GRAIL">)>

<ADD-OBJECT
 <OBJECT "GRAIL"
          "There is an extremely valuable (perhaps original) grail here."
          "grail" %<> %<> () %<> %<+ ,CONTBIT ,TAKEBIT ,OVISON> 0 2 5 10 5>[]>

<ROOM "TEMP1"

"You are in the west end of a large temple.  On the south wall is an 
ancient inscription, probably a prayer in a long-forgotten language. 
The north wall is solid granite.  The entrance at the west end of the
room is through huge marble pillars."
       "Temple"
       T <EXIT "WEST" "MGRAI" "EAST" "TEMP2">
       (<FIND-OBJ "PRAYE"> <FIND-OBJ "BELL">)>

<ADD-OBJECT <SOBJECT "PRAYE" "prayer" <+ ,READBIT ,SACREDBIT ,OVISON>>
            ["INSCR"] ["ANCIE" "OLD"]>

<ROOM "TEMP2"
"You are in the east end of a large temple.  In front of you is what
appears to be an altar."
       "Altar"
       T <EXIT "WEST" "TEMP1">
       (<FIND-OBJ "BOOK"> <FIND-OBJ "CANDL">)>

<ADD-OBJECT
 <OBJECT "TRUNK"
          "There is an old trunk here, bulging with assorted jewels."
          "trunk with jewels"
          "Lying half buried in the mud is an old trunk, bulging with jewels."
           %<> () %<> %,TAKEBIT 0 15 8 35 0>
["CHEST"]>

<ADD-OBJECT
 <OBJECT "BELL"
          "There is a small brass bell here."
          "bell"
          "Lying in a corner of the room is a small brass bell."
          %<> () %<> %<+ ,TAKEBIT ,OVISON> 0 0 0 5 0>
[] ["BRASS"]>

<ADD-OBJECT
 <OBJECT "BOOK"
          "There is a large black book here."
          "book"
          "On the altar is a large black book, open to page 569."
          BLACK-BOOK () %<> %<+ ,BURNBIT ,TAKEBIT ,OVISON ,READBIT> 0 0 0 10 0>
["PRAYE" "BIBLE" "GOODB"] ["BLACK"]>

<ADD-OBJECT 
 <OBJECT "CANDL"
          "There are two candles here."
          "pair of candles"
          "On the two ends of the altar are burning candles."
          CANDLES () %<> %<+ ,FLAMEBIT ,TAKEBIT ,OVISON> 1 0 0 10 0>[]>

<ROOM "DAM"
       ""
       "Dam"
       T <EXIT "SOUTH" "CANY1" "DOWN" "DOCK" "EAST" "CAVE3" "NORTH" "LOBBY">
       (<FIND-OBJ "BOLT"> <FIND-OBJ "DAM"> <FIND-OBJ "BUBBL">) DAM-ROOM>

<ROOM "LOBBY"
"This room appears to have been the waiting room for groups touring
the dam.  There are exits here to the north and east marked
'Private', though the doors are open, and an exit to the south."
       "Dam Lobby"
       T
       <EXIT "SOUTH" "DAM"
              "NORTH" "MAINT"
              "EAST" "MAINT">
       (<FIND-OBJ "MATCH"> <FIND-OBJ "GUIDE">)>

<ADD-OBJECT
 <OBJECT "GUIDE"
          "There are tour guidebooks here."
          "tour guidebook"
"Some guidebooks entitled 'Flood Control Dam #3' are on the reception
desk." %<> () %<> %<+ ,BURNBIT ,TAKEBIT ,READBIT ,OVISON>
           0 0 0 5 0>
["BOOK"] ["TOUR"]>

<ADD-OBJECT
 <OBJECT "PAPER"
          ""
          "newspaper"
          %<> %<> () %<> %<+ ,BURNBIT ,TAKEBIT ,READBIT ,OVISON> 0 0 0 2 0>
["NEWSP" "ISSUE" "REPOR" "MAGAZ" "NEWS"]>         

<ROOM "MAINT"

"You are in what appears to have been the maintenance room for Flood
Control Dam #3, judging by the assortment of tool chests around the
room.  Apparently, this room has been ransacked recently, for most of
the valuable equipment is gone. On the wall in front of you is a
panel of buttons, which are labelled in EBCDIC. However, they are of
different colors:  Blue, Yellow, Brown, and Red. The doors to this
room are in the west and south ends."
       "Maintenance Room"
       %<> <EXIT "SOUTH" "LOBBY" "WEST" "LOBBY">
       (<FIND-OBJ "LEAK"> <FIND-OBJ "TUBE"> <FIND-OBJ "WRENC">
        <FIND-OBJ "BLBUT"> <FIND-OBJ "RBUTT"> <FIND-OBJ "BRBUT">
        <FIND-OBJ "YBUTT"> <FIND-OBJ "SCREW">) MAINT-ROOM>

<ADD-OBJECT
 <OBJECT "MATCH"
          "There is a matchbook whose cover says 'Visit Beautiful FCD#3' here."
          "matchbook"
          %<> MATCH-FUNCTION () %<> %<+ ,TAKEBIT ,OVISON ,READBIT> 0 0 0 2 0>
["FLINT"]>

<ADD-OBJECT
 <OBJECT "ADVER"
          "There is a small leaflet here."
          "leaflet"
          %<> %<> () <FIND-OBJ "MAILB"> %<+ ,BURNBIT ,TAKEBIT ,OVISON ,READBIT>
          0 0 0 2 0>
["PAMPH" "LEAFL" "BOOKL"]>

<ADD-OBJECT 
 <OBJECT "MAILB"
          "There is a small mailbox here."
          "mailbox"
          %<> %<> (<FIND-OBJ "ADVER">) %<> %<+ ,CONTBIT ,OVISON> 0 0 0 %,BIGFIX 10>[
 "BOX"]>

 <OBJECT "TUBE"
          "There is an object which looks like a tube of toothpaste here."
          "tube"
          %<> TUBE-FUNCTION (<FIND-OBJ "PUTTY">) %<> %<+ ,CONTBIT ,TAKEBIT ,OVISON> 0 0 0 10 7>

<ADD-OBJECT
 <OBJECT "PUTTY"
          "There is some gunk here"
          "viscous material"
          %<> %<> () <FIND-OBJ "TUBE"> %<+ ,TOOLBIT ,TAKEBIT ,OVISON> 0 0 0 6 0>
 ["MATER" "GUNK" "GLUE"] ["VISCO"]>

<ADD-OBJECT
 <OBJECT "WRENC"
          "There is a wrench here."
          "wrench"
          %<> %<> () %<> %<+ ,TOOLBIT ,TAKEBIT ,OVISON> 0 0 0 10 0>[]>

<ADD-OBJECT 
 <OBJECT "SCREW"
          "There is a screwdriver here."
          "screwdriver"
          %<> %<> () %<> %<+ ,TOOLBIT ,TAKEBIT ,OVISON> 0 0 0 5 0>[]>


<ROOM "CYCLO"
       "" "Cyclops Room"
       %<> <EXIT "WEST" "MAZ15" "NORTH" <CEXIT "MAGIC-FLAG" "BLROO" "The north wall is solid rock.">
                  "UP" <CEXIT "CYCLOPS-FLAG" "TREAS" "The cyclops doesn't look like he'll let you past.">>
       (<FIND-OBJ "CYCLO">) CYCLOPS-ROOM>

<ADD-MELEE <FIND-OBJ "CYCLO"> ,CYCLOPS-MELEE>

<ROOM "BLROO"
"You are in a long passage.  To the south is one entrance.  On the
east there is an old wooden door, with a large hole in it (about
cyclops sized)."
       "Strange Passage"
       %<> <EXIT "SOUTH" "CYCLO" "EAST" "LROOM"> () TIME 10>

<ADD-OBJECT
 <OBJECT "CYCLO"
          "" "cyclops" %<>
          CYCLOPS () %<> %<+ ,VICBIT ,OVISON ,VILLAIN> 0 0 0 %,BIGFIX 10000>
 ["ONE-E" "MONST"]>

<ROOM "TREAS"

"This is a large room, whose north wall is solid granite.  A number
of discarded bags, which crumble at your touch, are scattered about
on the floor."
        "Treasure Room"
        %<> <EXIT "DOWN" "CYCLO"> (<FIND-OBJ "CHALI">) TREASURE-ROOM 25>

<ADD-OBJECT
 <OBJECT "CHALI"
          "There is a silver chalice, intricately engraved, here."
          "chalice" %<> CHALICE () %<> %<+ ,CONTBIT ,TAKEBIT ,OVISON> 0 10 10 10 5>
 ["CUP" "GOBLE"]>

<ROOM "STUDI" 

"You are in what appears to have been an artist's studio.  The walls
and floors are splattered with paints of 69 different colors. 
Strangely enough, nothing of value is hanging here.  At the north and
northwest of the room are open doors (also covered with paint).  An
extremely dark and narrow chimney leads up from a fireplace; although
you might be able to get up it, it seems unlikely you could get back
down."
       "Studio"
       %<> <EXIT "NORTH" "CRAW4"
                  "NW" "GALLE"
                  "UP"
                  <CEXIT "LIGHT-LOAD"
                          "KITCH"
                          "The chimney is too narrow for you and all of your baggage."
                          %<> CHIMNEY-FUNCTION>>
       () %<>>

<ROOM "GALLE"
"You are in an art gallery.  Most of the paintings which were here
have been stolen by vandals with exceptional taste.  The vandals
left through either the north or south exits."
       "Gallery"
       T <EXIT "NORTH" "CHAS2" "SOUTH" "STUDI"> (<FIND-OBJ "PAINT">)>


<ADD-OBJECT
 <OBJECT "PAINT"
          "A masterpiece by a neglected genius is here."
          "painting"
"Fortunately, there is still one chance for you to be a vandal, for on
the far wall is a work of unparalleled beauty."
          PAINTING () %<> %<+ ,BURNBIT ,TAKEBIT ,OVISON> 0 4 7 15 0>
["ART" "CANVA" "MASTE"]>

"LISTS OF CRUFT:  WEAPONS, AND IMMOVABLE OBJECTS"

<ADD-DEMON <SETG ROBBER-DEMON
                 <CHTYPE [ROBBER () ,ROOMS <1 ,ROOMS> <FIND-OBJ "THIEF"> <>] HACK>>>

<PSETG ROBBER-C-DESC
"There is a suspicious-looking individual, holding a bag, leaning
against one wall.  He is armed with a vicious-looking stilletto.">

<PSETG ROBBER-U-DESC
"There is a suspicious-looking individual lying unconscious on the
ground.  His bag and stilletto seem to have vanished.">

<ADD-OBJECT
 <OBJECT "THIEF"
          %,ROBBER-C-DESC
          "thief"
          %<>
          ROBBER-FUNCTION (<FIND-OBJ "STILL">) %<> %<+ ,VICBIT ,OVISON ,VILLAIN> 0 0 0 %,BIGFIX 4>[
         "ROBBE" "CROOK" "CRIME" "CRIMI" "BANDI" "GENT" "GENTL"
 "MAN" "SHADY" "THUG" "BAGMA" "MAFIA"]>

<ADD-MELEE <FIND-OBJ "THIEF"> ,THIEF-MELEE>

<ADD-OBJECT
 <OBJECT "STILL"
          "There is a vicious-looking stilletto here."
          "stilletto"
          %<> %<> () %<FIND-OBJ "THIEF"> %<+ ,OVISON ,WEAPONBIT> 0 0 0 10 0>
 [] ["VICIO"]>

<SETG WEAPONS (<FIND-OBJ "STICK"> <FIND-OBJ "KNIFE">)>

<SETG RANDOM-LIST
      (<FIND-ROOM "LROOM">
       <FIND-ROOM "KITCH">
       <FIND-ROOM "CLEAR">
       <FIND-ROOM "FORE3">
       <FIND-ROOM "FORE2">
       <FIND-ROOM "SHOUS">
       <FIND-ROOM "FORE2">
       <FIND-ROOM "KITCH">
       <FIND-ROOM "EHOUS">)>

<ADD-DESC <FIND-OBJ "BOOK">
"               COMMANDMENT #12592
Oh ye who go about saying unto each:   \"Hello sailor\":
dost thou know the magnitude of thy sin before the gods?
Yea, verily, thou shalt be ground between two stones.
Shall the angry gods cast thy body into the whirlpool?
Surely, thy eye shall be put out with a sharp stick!
Even unto the ends of the earth shalt thou wander and
unto the land of the dead shalt thou be sent at last.
Surely thou shalt repent of thy cunning.">

<ADD-DESC <FIND-OBJ "GUIDE">
"\"                Guide Book to
                Flood Control Dam #3

  Flood Control Dam #3 (FCD#3) was constructed in year 783 of the
Great Underground Empire to harness the destructive power of the
Frigid River.  This work was supported by a grant of 37 million
zorkmids from the Central Bureaucracy and your omnipotent local
tyrant Lord Dimwit Flathead the Excessive. This impressive
structure is composed of 3.7 cubic feet of concrete, is 256 feet
tall at the center, and 193 feet wide at the top.  The reservoir
created behind the dam has a volume of 37 billion cubic feet, an
area of 12 million square feet, and a shore line of 36 thousand
feet.

  The construction of FCD#3 took 112 days from ground breaking to
the dedication. It required a work force of 384 slaves, 34 slave
drivers, 12 engineers, 2 turtle doves, and a partridge in a pear
tree. The work was managed by a command team composed of 2345
bureaucrats, 2347 secretaries (at least two of which can type),
12,256 paper shufflers, 52,469 rubber stampers, 245,193 red tape
processors, and nearly one million dead trees.

  We will now point out some of the more interesting features
of FCD#3 as we conduct you on a guided tour of the facilities:
        1) You start your tour here in the Dam Lobby.
           You will notice on your right that .........">

<ADD-DESC <FIND-OBJ "PAPER">
"               US NEWS & DUNGEON REPORT
12/12/77                                       Late Dungeon Edition

     In order to get a more-or-less working version, we have
installed one with some known bugs.  In particular, the following
sequence will not work correctly, nor will anything resembling it:
>take
take what?
>frob
what do you want me to do with it?
     Note that if you now respond 'take', the right thing will
happen. In short, the current parser can't handle verbs with missing
objects.  Since it is completely new, we'd appreciate reports of any
other bugs encountered.

FLASH!
     An important change has been made.  When you have been killed,
and the 'patch' question is asked, or if you are confirming a 'quit',
it is now necessary to terminate the response to the question with a
carriage return (you may be surprised to find that this wasn't true
before).  Also, the answer to the 'patch' question is taken to be yes
unless something starting with n, N, f, or F is typed; the answer to
the 'quit' question is no unless something starting with y, Y, t, or
T is typed.

FLASH!
     Another FLAG DAY has been declared for save files.  Yes, ladies
and gentlemen, yet another incompatible change has been made to the
save/restore code.  When will it end?

     Things like the bucket should resume working in this version.

     Many people have reported the following message:
'GIN FREE STORAGE- VECTOR ...GOUT TIME= n.nn'
This indicates that a garbage collection is occurring.  Some reports
have this taking up to 30 sec. of cpu time, during which your dungeon
will refuse to respond.  We have added a feature which should prevent
this; if you see such a message, please send mail to DUNGEON@DM
describing the circumstances (particularly number of moves,
save/restore status, and the TIME).  A garbage collection is not
fatal:  your dungeon should be perfectly all right once it finishes
(after the GOUT TIME= message is printed).
">

<ADD-DESC <FIND-OBJ "ADVER">
"                       WELCOME TO DUNGEON

    DUNGEON is a game of adventure, danger, and low cunning.  In it
you will explore some of the most amazing territory ever seen by
mortal man. Hardened adventurers have run screaming from the terrors
contained within!

    In DUNGEON the intrepid explorer delves into the forgotten
secrets of a lost labyrinth deep in the bowels of the earth,
searching for vast treasures long hidden from prying eyes, treasures
guarded by fearsome monsters and diabolical traps!

    No PDP-10 should be without one!

    DUNGEON was created at the Programming Technology Division of the
MIT Laboratory for Computer Science, by Tim Anderson, Marc Blank,
Bruce Daniels, and Dave Lebling.  It was inspired by the ADVENTURE
game of Crowther and Woods, and Dungeons and Dragons, by Gygax and
Arneson.  DUNGEON is written in MDL (alias MUDDLE).

    Direct inquiries by Net mail to DUNGEON@MIT-DMS.
">

<ADD-DESC <FIND-OBJ "MATCH">
"       [close cover before striking BKD]

You too can make BIG MONEY in the exciting field of
                PAPER SHUFFLING!
Mr. TAA of Muddle, Mass. says: \"Before I took
this course I used to be a lowly bit twiddler.
Now with what I learned at MIT Tech I feel really
important and can obfuscate and confuse with the best.\"
Mr. MARC had this to say: \"Ten short days ago all I could
look forward to was a dead-end job as a doctor.  Now
I have a promising future and make really big Zorkmids.\"

MIT Tech can't promise these fantastic results to everyone.
But when you earn your MDL degree from MIT Tech your future
will be brighter. Send for our free brochure today.">

<ADD-DESC <FIND-OBJ "ENGRA">
"The engravings were incised in the living rock of the cave wall by
an unknown hand.  They depict, in symbolic form, the beliefs of the
ancient peoples of Zork.  Skillfully interwoven with the bas reliefs
are excerpts illustrating the major tenets expounded by the sacred
texts of the religion of that time.  Unfortunately a later age seems
to have considered them blasphemous and just as skillfully excised
them.">

<ADD-DESC <FIND-OBJ "PRAYE">
"The prayer is inscribed in an ancient script which is hardly
remembered these days, much less understood.  What little of it can
be made out seems to be a phillipic against small insects,
absent-mindedness, and the picking up and dropping of small objects. 
The final verse seems to consign trespassers to the land of the
dead.  All evidence indicates that the beliefs of the ancient
Zorkers were obscure.">

; "ASSORTED DOORS"

<PSETG BUTSTR "button">
<PSETG DOORSTR "door">

<ADD-OBJECT
   <AOBJECT "WIND1" "window" WINDOW-FUNCTION ,OVISON ,DOORBIT ,NDESCBIT>
   ["WINDO"] []>

<ADD-OBJECT
   <AOBJECT "WIND2" "window" WINDOW-FUNCTION ,OVISON ,DOORBIT ,NDESCBIT>
   ["WINDO"] []>

<ADD-OBJECT <AOBJECT "BOLT" "bolt" BOLT-FUNCTION ,TURNBIT ,OVISON ,DOORBIT ,NDESCBIT>
            ["BOLT" "NUT"] []>

<ADD-OBJECT
  <AOBJECT "GRAT1" "grating" GRAT1-FUNCTION ,DOORBIT ,NDESCBIT>
  ["GRATI" "GRATE"] []>

<ADD-OBJECT
  <AOBJECT "GRAT2" "grating" GRAT2-FUNCTION ,OVISON ,DOORBIT ,NDESCBIT>
  ["GRATI" "GRATE"] []>

<ADD-OBJECT <AOBJECT "DOOR" ,DOORSTR TRAP-DOOR ,DOORBIT ,NDESCBIT>
            ["TRAPD" "TRAP-"] ["TRAP"]>

<ADD-OBJECT <AOBJECT "TDOOR" ,DOORSTR TRAP-DOOR ,DOORBIT ,NDESCBIT>
            ["TRAPD" "TRAP-"] ["TRAP"]>

<ADD-OBJECT <AOBJECT "WDOOR" ,DOORSTR DDOOR-FUNCTION ,OVISON ,NDESCBIT ,READBIT>
            ["DOOR"] ["WOODE"]>

<ADD-DESC <FIND-OBJ "WDOOR">
"The engravings translate to 'This space intentionally left blank'">

<ADD-OBJECT <AOBJECT "FDOOR" ,DOORSTR DDOOR-FUNCTION ,OVISON ,NDESCBIT>
            ["DOOR"] ["FRONT"]>

<ADD-OBJECT <AOBJECT "SDOOR" ,DOORSTR DDOOR-FUNCTION ,OVISON ,NDESCBIT>
            ["DOOR"] ["STONE"]>

<ADD-OBJECT <AOBJECT "MSWIT" "switch" MSWITCH-FUNCTION ,OVISON ,NDESCBIT ,TURNBIT>
            ["SWITC"]>

; "ASSORTED GARBAGE"

<ADD-OBJECT <SOBJECT "HPOLE" "head on a pole" ,OVISON> ["HEAD"]>
<ADD-OBJECT <SOBJECT "CORPS" "corpses" ,OVISON> [] ["MANGL"]>
<ADD-OBJECT <AOBJECT "BODIE" "pile of bodies" BODY-FUNCTION
                     ,OVISON ,NDESCBIT ,TRYTAKEBIT>
            ["BODY" "CORPS"]>

<ADD-OBJECT <SOBJECT "DAM" "dam" ,OVISON ,NDESCBIT> ["GATE" "GATES" "FCD"]>
<ADD-OBJECT <SOBJECT "RAILI" "railing" ,OVISON ,NDESCBIT> ["RAIL"]>
<ADD-OBJECT <SOBJECT "BUTTO" "button" ,OVISON ,NDESCBIT> ["SWITC"]>
<SOBJECT "BUBBL" "bubble" ,OVISON ,NDESCBIT>
<ADD-OBJECT <AOBJECT "LEAK" "leak" LEAK-FUNCTION ,OVISON ,NDESCBIT> ["DRIP" "HOLE"]>
<ADD-STAR <ADD-OBJECT
           <AOBJECT "EVERY" "everything"
                   EVERYTHING ,OVISON ,TAKEBIT ,NO-CHECK-BIT ,NDESCBIT>
           ["ALL"]>>
<ADD-STAR <ADD-OBJECT
           <AOBJECT "VALUA" "valuables"
                    VALUABLES ,OVISON ,TAKEBIT ,NO-CHECK-BIT ,NDESCBIT>
           ["TREAS"]>>
<ADD-STAR <SOBJECT "SAILO" "sailor" ,OVISON ,NDESCBIT>>
<ADD-STAR <SOBJECT "TEETH" "set of teeth" ,OVISON ,NDESCBIT>>
<ADD-STAR <SOBJECT "WALL" "wall" ,OVISON ,NDESCBIT>>
<ADD-STAR <FIND-OBJ "GRUE">>
<ADD-STAR <ADD-OBJECT <SOBJECT "HANDS" "pair of hands" ,OVISON ,NDESCBIT ,TOOLBIT>
                      ["HAND"] ["BARE"]>>
<ADD-STAR <ADD-OBJECT <SOBJECT "LUNGS" "breath" ,OVISON ,NDESCBIT ,TOOLBIT>
                      ["LUNG" "AIR"]>>
<ADD-STAR <SOBJECT "AVIAT" "flyer" ,OVISON ,NDESCBIT>>

<ADD-OBJECT <SOBJECT "RBUTT" ,BUTSTR ,OVISON ,NDESCBIT>
            ["BUTTO" "SWITC"]
            ["RED"]>
<ADD-OBJECT <SOBJECT "YBUTT" ,BUTSTR ,OVISON ,NDESCBIT>
            ["BUTTO" "SWITC"]
            ["YELLO"]>

<ADD-OBJECT <SOBJECT "BLBUT" ,BUTSTR ,OVISON ,NDESCBIT>
            ["BUTTO" "SWITC"]
            ["BLUE"]>

<ADD-OBJECT <SOBJECT "BRBUT" ,BUTSTR ,OVISON ,NDESCBIT>
            ["BUTTO" "SWITC"]
            ["BROWN"]>

<ADD-OBJECT <AOBJECT "BAT" "bat" FLY-ME ,OVISON ,NDESCBIT ,TRYTAKEBIT> ["VAMPI"][]>

"MORE VOCABULARY"

<SOBJECT "RAINB" "rainbow" ,OVISON ,NDESCBIT>

<PSETG CLIFFS #NEXIT "The White Cliffs prevent your landing here.">
<PSETG RIVERDESC "Frigid River">

<ROOM "DOCK"
"You are at the base of Flood Control Dam #3, which looms above you
and to the north.  The river Frigid is flowing by here.  Across the
river are the White Cliffs which seem to form a giant wall stretching
from north to south along the east shore of the river as it winds its
way downstream."
       "Dam Base"
       T
       <EXIT "NORTH" "DAM" "UP" "DAM" "LAUNC" "RIVR1">
       (<FIND-OBJ "IBOAT"> <FIND-OBJ "STICK">)
       %<>>

<ROOM "RIVR1"
"You are on the River Frigid in the vicinity of the Dam.  The river
flows quietly here.  There is a landing on the west shore."
       %,RIVERDESC
       %<>
       <EXIT "UP" %,CURRENT "WEST" "DOCK" "LAND" "DOCK" "DOWN" "RIVR2"
              "EAST" %,CLIFFS>
       () %<> 0 %,RWATERBIT>

<ROOM "RIVR2"
"The River turns a corner here making it impossible to see the
Dam.  The White Cliffs loom on the east bank and large rocks prevent
landing on the west."
       %,RIVERDESC
       %<>
       <EXIT "UP" %,CURRENT "DOWN" "RIVR3" "EAST" %,CLIFFS> () %<> 0
       %,RWATERBIT>

<ROOM "RIVR3"
"The river descends here into a valley.  There is a narrow beach on
the east below the cliffs and there is some shore on the west which
may be suitable.  In the distance a faint rumbling can be heard."
       %,RIVERDESC
       %<>
       <EXIT "UP" %,CURRENT "DOWN" "RIVR4" "EAST" "WCLF1" "WEST" "RCAVE"
              "LAND" #NEXIT "You must specify which direction here.">
       () %<> 0 %,RWATERBIT>

<PSETG NARROW "The path is too narrow.">

<ROOM "WCLF1"
"You are on a narrow strip of beach which runs along the base of the
White Cliffs. The only path here is a narrow one, heading south
along the Cliffs."
       "White Cliffs Beach"
       %<>
       <EXIT "SOUTH" <CEXIT "DEFLATE" "WCLF2" %,NARROW> "LAUNC" "RIVR3">
       () CLIFF-FUNCTION 0>

<ROOM "WCLF2"

"You are on a rocky, narrow strip of beach beside the Cliffs.  A
narrow path leads north along the shore."
       "White Cliffs Beach"
       %<>
       <EXIT "NORTH" <CEXIT "DEFLATE" "WCLF1" %,NARROW> "LAUNC" "RIVR4">
       () CLIFF-FUNCTION 0>

<ROOM "RIVR4"

"The river is running faster here and the sound ahead appears to be
that of rushing water.  On the west shore is a sandy beach.  A small
area of beach can also be seen below the Cliffs."
       %,RIVERDESC
       %<>
       <EXIT "UP" %,CURRENT "DOWN" "RIVR5" "EAST" "WCLF2" "WEST" "BEACH"
              "LAND" #NEXIT "Specify the direction to land.">
       (<FIND-OBJ "BUOY">)
       RIVR4-ROOM 0 %,RWATERBIT>

<ROOM "RIVR5"
"The sound of rushing water is nearly unbearable here.  On the west
shore is a large landing area."
       %,RIVERDESC
       %<>
       <EXIT "UP" %,CURRENT "DOWN" "FCHMP" "LAND" "FANTE"> () %<> 0
       %,RWATERBIT>

<ROOM "FCHMP"
       ""
       "Moby lossage" %<> <EXIT "NORTH" #NEXIT ""> () OVER-FALLS>

<ROOM "FANTE"
"You are on the shore of the River.  The river here seems somewhat
treacherous.  A path travels from north to south here, the south end
quickly turning around a sharp corner."
       "Shore"
       %<>
       <EXIT "LAUNC" "RIVR5" "NORTH" "BEACH"
              "SOUTH" "FALLS">
       () %<> 0>

<ROOM "BEACH"
"You are on a large sandy beach at the shore of the river, which is
flowing quickly by.  A path runs beside the river to the south here."
       "Sandy Beach"
       %<>
       <EXIT "LAUNC" "RIVR4" "SOUTH" "FANTE">
       (<FIND-OBJ "STATU">)
       BEACH-ROOM 0>

<ROOM "RCAVE"
"You are on the west shore of the river.  An entrance to a cave is
to the northwest.  The shore is very rocky here."
       "Rocky Shore"
       %<>
       <EXIT "LAUNC" "RIVR3" "NW" "TCAVE"> () %<>
       0>

<ROOM "TCAVE"
"You are in a small cave whose exits are on the south and northwest."
       "Small Cave"
       %<>
       <EXIT "SOUTH" "RCAVE" "NW" "CHAS3">
       (<FIND-OBJ "GUANO"> <FIND-OBJ "SHOVE">)
       TCAVE-ROOM>

<ROOM "BARRE"
"You are in a barrel.  Congratulations.  Etched into the side of the
barrel is the word 'Geronimo!'."
       "Barrel"
       %<>
       <EXIT "EXIT" "FALLS">>

<ROOM "FALLS"
       ""
       "Aragain Falls"
       %<>
       <EXIT "EAST" <CEXIT "RAINBOW" "RAINB"> "DOWN" "FCHMP" "NORTH" "FANTE"
              "ENTER" "BARRE" "UP" <CEXIT "RAINBOW" "RAINB">>
       (<FIND-OBJ "RAINB"> <FIND-OBJ "BARRE">) FALLS-ROOM>

<ROOM "RAINB"
"You are on top of a rainbow (I bet you never thought you would walk
on a rainbow), with a magnificent view of the Falls.  The rainbow
travels east-west here.  There is an NBC Commissary here."
       "Rainbow Room"
       T
       <EXIT "EAST" "POG" "WEST" "FALLS">>

<SETG CRAIN <CEXIT "RAINBOW" "RAINB">>

<ROOM "POG"
"You are on a small beach on the continuation of the Frigid River
past the Falls.  The beach is narrow due to the presence of the White
Cliffs.  The river canyon opens here and sunlight shines in from
above. A rainbow crosses over the falls to the west and a narrow path
continues to the southeast."
       "End of Rainbow"
       T
       <EXIT "UP" %,CRAIN "NW" %,CRAIN "WEST" %,CRAIN "SE" "CLBOT">
       (<FIND-OBJ "RAINB"> <FIND-OBJ "POT">) %<> 0>

<ROOM "CLBOT"
"You are beneath the walls of the river canyon which may be climbable
here.  There is a small stream here, which is the lesser part of the
runoff of Aragain Falls. To the north is a narrow path."
       "Canyon Bottom"
       T
       <EXIT "UP" "CLMID" "CLIMB" "CLMID" "NORTH" "POG">>

<ROOM "CLMID"

"You are on a ledge about halfway up the wall of the river canyon.
You can see from here that the main flow from Aragain Falls twists
along a passage which it is impossible to enter.  Below you is the
canyon bottom.  Above you is more cliff, which still appears
climbable."
       "Rocky Ledge"
       T
       <EXIT "UP" "CLTOP" "CLIMB" "CLTOP" "DOWN" "CLBOT">>

<ROOM "CLTOP"

"You are at the top of the Great Canyon on its south wall.  From here
there is a marvelous view of the Canyon and parts of the Frigid River
upstream.  Across the canyon, the walls of the White Cliffs still
appear to loom far above.  Following the Canyon upstream (north and
northwest), Aragain Falls may be seen, complete with rainbow. 
Fortunately, my vision is better than average and I can discern the
top of the Flood Control Dam #3 far to the distant north.  To the
west and south can be seen an immense forest, stretching for miles
around.  It is possible to climb down into the canyon from here."
       "Canyon View"
       T
       <EXIT "DOWN" "CLMID" "CLIMB" "CLMID" "SOUTH" "FORE4" "WEST" "FORE5">>

<ADD-OBJECT
 <OBJECT "POT"
          "There is a pot of gold here."
          "pot filled with gold"
          "At the end of the rainbow is a pot of gold."
          %<> () %<> %,TAKEBIT 0 10 10 15 0>
[] ["GOLD"]>

<ADD-OBJECT
 <OBJECT "STATU"
          "There is a beautiful statue here."
          "statue"
          %<> %<> () %<> %,TAKEBIT 0 10 13 8 0>[
 "SCULP" "ROCK"]>

<ADD-OBJECT
 <OBJECT "IBOAT"

"There is a folded pile of plastic here which has a small valve
attached." "plastic inflatable boat" %<> IBOAT-FUNCTION ()
          %<> %<+ ,BURNBIT ,OVISON ,TAKEBIT> 0 0 0 20 0>[
 "BOAT" "PLAST" "PILE"]>

<ADD-OBJECT
 <OBJECT "DBOAT"
          "There is a pile of plastic here with a large hole in it."
          "plastic boat (with hole)"
          %<> DBOAT-FUNCTION () %<> %<+ ,BURNBIT ,OVISON ,TAKEBIT> 0 0 0 20 0>[
 "BOAT" "PLAST" "PILE"]>

<ADD-OBJECT 
 <OBJECT "PUMP"
          "There is a small pump here."
          "hand-held air pump"
          %<> %<> () %<> %<+ ,TOOLBIT ,OVISON ,TAKEBIT> 0 0 0 5 0>[
 "AIR-P" "AIRPU"]>

<ADD-OBJECT
 <OBJECT "RBOAT"
          "There is an inflated boat here."
          "magic boat"
          %<>
          RBOAT-FUNCTION (<FIND-OBJ "LABEL">) %<> 
          %<+ ,VEHBIT ,BURNBIT ,OVISON ,TAKEBIT>
          0 0 0 20 100>
["BOAT"] ["PLAST" "SEAWO"]>

<PUT <FIND-OBJ "RBOAT"> ,OOPEN? T>
<PUT <FIND-OBJ "RBOAT"> ,ORAND ,RWATERBIT>

<ADD-OBJECT
 <OBJECT "LABEL"
          "There is a tan label here."
          "tan label"
          %<> %<> () <FIND-OBJ "RBOAT"> %<+ ,BURNBIT ,OVISON ,READBIT ,TAKEBIT>
          0 0 0 2 0>
["FINEP"] ["TAN"]>

<ADD-DESC <FIND-OBJ "LABEL">
"         !!!!  FROBOZZ MAGIC BOAT COMPANY  !!!!

Hello, Sailor!

Instructions for use:
   
   To get into boat, say 'Board'
   To leave boat, say 'Disembark'

   To get into a body of water, say 'Launch'
   To get to shore, say 'Land'
    
Warranty:

  This boat is guaranteed against all defects in parts and
workmanship for a period of 76 milliseconds from date of purchase or
until first used, whichever comes first.

Warning:
   This boat is made of plastic.                Good Luck!
">

<ADD-OBJECT
 <OBJECT "STICK"
          "There is a broken sharp stick here."
          "broken sharp stick"
          "A sharp stick, which appears to have been broken at one end, is here."
          STICK-FUNCTION () %<> %<+ ,OVISON ,TAKEBIT> 0 0 0 3 0>
[] ["SHARP" "BROKE"]>

<SOBJECT "BARRE" "barrel" ,OVISON>

<ADD-OBJECT
 <OBJECT "BUOY"
          "There is a red buoy here (probably a warning)."
          "red buoy"
          %<> %<> (<FIND-OBJ "EMERA">) %<> %<+ ,CONTBIT ,FINDMEBIT ,OVISON ,TAKEBIT>
          0 0 0 10 20>
[]["RED"]>

<ADD-OBJECT
 <OBJECT "EMERA"
          "There is an emerald here."
          "large emerald"
          %<> %<> () <FIND-OBJ "BUOY"> %<+ ,OVISON ,TAKEBIT> 0 5 10 5 0>[]>

<ADD-OBJECT
 <OBJECT "SHOVE"
          "There is a large shovel here."
          "shovel"
          %<> %<> () %<> %<+ ,TOOLBIT ,OVISON ,TAKEBIT> 0 0 0 15 0>[]>

<ADD-OBJECT
 <OBJECT "GUANO"
          "There is a hunk of bat guano here."
          "hunk of bat guano"
          %<> %<> () %<> %<+ ,OVISON ,TAKEBIT> 0 0 0 20 0>[
 "CRAP" "SHIT" "HUNK"]>

<ADD-OBJECT
 <OBJECT "GRUE"
          "" "lurking grue" %<> GRUE-FUNCTION () %<> %,OVISON 0 0 0 0 0>
 [] ["LURKI"]>

<ROOM "VLBOT"
"You are at the bottom of a large dormant volcano.  High above you
light may be seen entering from the cone of the volcano.  The only
exit here is to the north."
       "Volcano Bottom"
       %<>
       <EXIT "NORTH" "LAVA">
       (<FIND-OBJ "BALLO">)>

<PSETG VOLCORE "Volcano Core">

<SETG NULEXIT <EXIT "#!#!#" "!">>

<ROOM "VAIR1"
"You are about one hundred feet above the bottom of the volcano.  The
top of the volcano is clearly visible here."
       %,VOLCORE %<> %,NULEXIT () %<> 0 %,RAIRBIT>

<ROOM "VAIR2"
"You are about two hundred feet above the volcano floor.  Looming
above is the rim of the volcano.  There is a small ledge on the west
side."
       %,VOLCORE
       %<>
       <EXIT "WEST" "LEDG2" "LAND" "LEDG2">
       () %<> 0 %,RAIRBIT>

<ROOM "VAIR3"
"You are high above the floor of the volcano.  From here the rim of
the volcano looks very narrow and you are very near it.  To the 
east is what appears to be a viewing ledge, too thin to land on."
       %,VOLCORE %<> %,NULEXIT () %<> 0 %,RAIRBIT>

<ROOM "VAIR4"
"You are near the rim of the volcano which is only about 15 feet
across.  To the west, there is a place to land on a wide ledge."
       %,VOLCORE
       %<>
       <EXIT "LAND" "LEDG4" "EAST" "LEDG4">
       () %<> 0 %,RAIRBIT>

<SETG CXGNOME <CEXIT "GNOME-DOOR" "VLBOT">>

<ROOM "LEDG2"
"You are on a narrow ledge overlooking the inside of an old dormant
volcano.  This ledge appears to be about in the middle between the
floor below and the rim above. There is an exit here to the south."
       "Narrow Ledge"
       %<>
       <EXIT "DOWN" #NEXIT "I wouldn't jump from here."
              "LAUNC" "VAIR2" "WEST" %,CXGNOME "SOUTH" "LIBRA">
       (<FIND-OBJ "HOOK1"> <FIND-OBJ "ZORKM">)>

<ROOM "LIBRA"
"You are in a room which must have been a large library, probably
for the royal family.  All of the shelves appear to have been gnawed
to pieces by unfriendly gnomes.  To the north is an exit."
       "Library"
       %<>
       <EXIT "NORTH" "LEDG2" "OUT" "LEDG2">
       (<FIND-OBJ "BLBK"> <FIND-OBJ "GRBK"> <FIND-OBJ "PUBK">
        <FIND-OBJ "WHBK">)>

<ROOM "LEDG3"
"You are on a ledge in the middle of a large volcano.  Below you
the volcano bottom can be seen and above is the rim of the volcano.
A couple of ledges can be seen on the other side of the volcano;
it appears that this ledge is intermediate in elevation between
those on the other side.  The exit from this room is to the east."
       "Volcano View"
       %<>
       <EXIT "DOWN" #NEXIT "I wouldn't try that."
              "CROSS" #NEXIT "It is impossible to cross this distance."
              "EAST" "EGYPT">>

<ROOM "LEDG4"
       ""
       "Wide Ledge"
       %<>
       <EXIT "DOWN" #NEXIT "It's a long way down."
              "LAUNC" "VAIR4" "WEST" %,CXGNOME "SOUTH" "SAFE">
       (<FIND-OBJ "HOOK2">)
       LEDGE-FUNCTION>

<ROOM "SAFE"
       ""
       "Dusty Room"
       T
       <EXIT "NORTH" "LEDG4">
       (<FIND-OBJ "SSLOT"> <FIND-OBJ "SAFE">)
       SAFE-ROOM>

<ROOM "LAVA"
"You are in a small room, whose walls are formed by an old lava flow.
There are exits here to the west and the south."
       "Lava Room"
       %<>
       <EXIT "SOUTH" "VLBOT" "WEST" "RUBYR">>

<ADD-OBJECT
 <OBJECT "BALLO"
"There is a very large and extremely heavy wicker basket with a cloth
bag here. Inside the basket is a metal receptacle of some kind. 
Attached to the basket on the outside is a piece of wire."
          "basket"
          %<>
          BALLOON (<FIND-OBJ "CBAG"> <FIND-OBJ "BROPE"> <FIND-OBJ "RECEP">)
          %<> %<+ ,VEHBIT ,OVISON> 0 0 0 70 100>
 ["BASKE"] ["WICKE"]>

<PUT <FIND-OBJ "BALLO"> ,OOPEN? T>
<PUT <FIND-OBJ "BALLO"> ,ORAND ,RAIRBIT>

 <OBJECT "RECEP"
          ""
          "receptacle"
          %<> %<> () <FIND-OBJ "BALLO"> %<+ ,CONTBIT ,OVISON ,SEARCHBIT> 0 0 0 %,BIGFIX 6>

<ADD-OBJECT
 <OBJECT "CBAG"
          ""
          "cloth bag"
          %<> %<> () <FIND-OBJ "BALLO"> %,OVISON 0 0 0 %,BIGFIX 0>
 ["BAG"] ["CLOTH"]>

<ADD-OBJECT
 <OBJECT "BROPE"
          "" "braided wire" %<> WIRE-FUNCTION ()
          <FIND-OBJ "BALLO"> %<+ ,TIEBIT ,OVISON> 0 0 0 %,BIGFIX 0>
 ["WIRE"] ["BRAID"]>

 <ADD-OBJECT
 <OBJECT "HOOK1"
          "There is a small hook attached to the rock here."
          "hook"
          %<> %<> () %<> %,OVISON 0 0 0 %,BIGFIX 0>
 ["HOOK"]>

<ADD-OBJECT
 <OBJECT "HOOK2"
          "There is a small hook attached to the rock here."
          "hook"
          %<> %<> () %<> %,OVISON 0 0 0 %,BIGFIX 0>
 ["HOOK"]>

<ADD-OBJECT
 <OBJECT "ZORKM"
          "There is an engraved zorkmid coin here."
          "priceless zorkmid"
          "On the floor is a gold zorkmid coin (a valuable collector's item)."
          %<> () %<> %<+ ,READBIT ,OVISON ,TAKEBIT> 0 10 12 10 0>
 ["COIN"] ["GOLD"]>

<ADD-DESC <FIND-OBJ "ZORKM">
          "
               --------------------------
              /      Gold Zorkmid        \\
             /  T e n   T h o u s a n d   \\
            /        Z O R K M I D S       \\
           /                                \\
          /        ||||||||||||||||||        \\
         /        !||||          ||||!        \\
        |          |||   ^^  ^^   |||          |
        |          |||   OO  OO   |||          |
        | In Frobs  |||    <<    |||  We Trust |
        |            || (______) ||            |
        |             |          |             |
        |             |__________|             |
         \\                                    /
          \\    -- Lord Dimwit Flathead --    /
           \\    -- Beloved of Zorkers --    /
            \\                              /
             \\       * 722 G.U.E. *       /
              \\                          /
               --------------------------
">


<ADD-OBJECT 
 <OBJECT "SAFE"
          ""
          "box"
          %<> SAFE-FUNCTION (<FIND-OBJ "CROWN"> <FIND-OBJ "CARD">) %<> %<+ ,CONTBIT ,OVISON>
          0 0 0 %,BIGFIX 15>
 ["BOX"]>

<ADD-OBJECT
 <OBJECT "CARD"
          "There is a card with writing on it here."
          "card"
          %<> %<> () <FIND-OBJ "SAFE">
          %<+ ,OVISON ,TAKEBIT ,READBIT ,BURNBIT> 0 0 0 1 0>
 ["NOTE"]>

<ADD-DESC <FIND-OBJ "CARD">
          "
Warning:
    This room was constructed over very weak rock strata.  Detonation
of explosives in this room is strictly prohibited!
                        Frobozz Magic Cave Company
                        per M. Agrippa, foreman
">

<ADD-OBJECT
 <OBJECT "SSLOT"
          ""
          "hole"
          %<> %<> () %<> %,OVISON 0 0 0 %,BIGFIX 10>
 ["SLOT" "HOLE"]>

<PUT <FIND-OBJ "SSLOT"> ,OOPEN? T>

<ADD-OBJECT
 <OBJECT "CROWN"
          "Lord Dimwit's crown is here."
          "crown"
          "The excessively gaudy crown of Lord Dimwit Flathead is here."
          %<> () <FIND-OBJ "SAFE"> %<+ ,OVISON ,TAKEBIT> 0 15 10 10 0>
 [] ["GAUDY"]>

<ADD-OBJECT 
 <OBJECT "BRICK"
          "There is a square brick here which feels like clay."
          "brick"
          %<> %<> () %<> %<+ ,BURNBIT ,SEARCHBIT ,OVISON ,TAKEBIT> 0 0 0 9 2>
 ["BRICK"] ["SQUAR" "CLAY"]>

<PUT <FIND-OBJ "BRICK"> ,OOPEN? T>

<ADD-OBJECT
 <OBJECT "FUSE"
          "There is a coil of thin shiny wire here."
          "wire coil"
          %<> FUSE-FUNCTION () %<> %<+ ,BURNBIT ,OVISON ,TAKEBIT> 0 0 0 1 0>
 ["COIL" "WIRE"] ["SHINY" "THIN"]>


<ADD-OBJECT
 <OBJECT "GNOME"
          "There is a nervous Volcano Gnome here."
          "Volcano Gnome"
          %<> GNOME-FUNCTION () %<> %<+ ,VICBIT ,OVISON> 0 0 0 %,BIGFIX 0>
 ["TROLL"]>

<ADD-OBJECT
 <OBJECT "BLABE"
          "There is a blue label here."
          "blue label" %<> %<> () <FIND-OBJ "BALLO">
          %<+ ,OVISON ,TAKEBIT ,READBIT ,BURNBIT> 0 0 0 1 0>
 ["LABEL"] ["BLUE"]>

<ADD-DESC <FIND-OBJ "BLABE">
          "
          !!!!  FROBOZZ MAGIC BALLOON COMPANY !!!!

Hello, Aviator!

Instructions for use:
   
   To get into balloon, say 'Board'
   To leave balloon, say 'Disembark'
   To land, say 'Land'
    
Warranty:
   
   No warranty is expressed or implied.  You're on your own, sport!

                                        Good Luck.
">

<ADD-OBJECT 
 <OBJECT "DBALL"
          "There is a balloon here, broken into pieces."
          "broken balloon"
          %<> %<> () %<> %<+ ,TAKEBIT ,OVISON> 0 0 0 40 0>
 ["BALLO" "BASKE"] ["BROKE"]>

<ADD-OBJECT
 <OBJECT "BLBK"
          "There is a blue book here."
          "blue book"
          %<> %<> () %<> %<+ ,CONTBIT ,TAKEBIT ,OVISON ,READBIT> 0 0 0 10 2>
 ["BOOK"] ["BLUE"]>

<ADD-OBJECT
 <OBJECT "GRBK"
          "There is a green book here."
          "green book"
          %<> %<> () %<> %<+ ,CONTBIT ,TAKEBIT ,OVISON ,READBIT> 0 0 0 10 2>
 ["BOOK"] ["GREEN"]>

<ADD-OBJECT
 <OBJECT "PUBK"
          "There is a purple book here."
          "purple book"
          %<> %<> (<FIND-OBJ "STAMP">) %<> %<+ ,TAKEBIT ,OVISON ,READBIT ,CONTBIT>
          0 0 0 10 2>
 ["BOOK"] ["PURPL"]>

<ADD-OBJECT
 <OBJECT "WHBK"
          "There is a white book here."
          "white book"
          %<> %<> () %<> %<+ ,CONTBIT ,TAKEBIT ,OVISON ,READBIT> 0 0 0 10 2>
 ["BOOK"] ["WHITE"]>

<PSETG GREEK-TO-ME 
"This book is written in a tongue with which I am unfamiliar.">

<ADD-DESC <FIND-OBJ "BLBK"> ,GREEK-TO-ME>
<ADD-DESC <FIND-OBJ "GRBK"> ,GREEK-TO-ME>
<ADD-DESC <FIND-OBJ "PUBK"> ,GREEK-TO-ME>
<ADD-DESC <FIND-OBJ "WHBK"> ,GREEK-TO-ME>

 <OBJECT "STAMP"        
          "There is a Flathead Commemorative stamp here."
          "stamp"
          %<> %<> () <FIND-OBJ "PUBK"> %<+ ,TAKEBIT ,READBIT ,BURNBIT ,OVISON>
          0 4 10 1 0>

<ADD-DESC <FIND-OBJ "STAMP">
          "
---v----v----v----v----v----v----v----v---
|                                        |
|          ||||||||||        LORD        |
>         !||||      |      DIMWIT       <
|         ||||    ---|     FLATHEAD      |
|         |||C     CC \\                  |
>          ||||       _\\                 <
|           ||| (____|                   |
|            ||      |                   |
>             |______|       Our         <
|               /   \\     Excessive      |
|              /     \\      Leader       |
>             |       |                  <
|             |       |                  |
|                                        |
>    G.U.E. POSTAGE        3 Zorkmids    <
|                                        |
---^----^----^----^----^----^----^----^---
">

<SETG BLOC <FIND-ROOM "VLBOT">>

; "SET UP LIGHT INTERRUPTS, ETC."

<PUT <FIND-OBJ "LAMP"> ,ORAND [0 <CLOCK-DISABLE <CLOCK-INT ,LNTIN 350>>]>

<PUT <FIND-OBJ "CANDL"> ,ORAND <>>

<PUT <FIND-OBJ "MATCH"> ,ORAND 5>               ; "NUMBER OF MATCHES"

<PSETG INDENTSTR <REST <ISTRING 8 !\ > 8>>

<ROOM "TOMB"
"You are in the Tomb of the Unknown Implementer.
A hollow voice says:  \"That's not a bug, it's a feature!\""
       "Tomb of the Unknown Implementer"
        %<> <EXIT "WEST" "LLD2"> (<FIND-OBJ "TOMB">
                                    <FIND-OBJ "HEADS">
                                    <FIND-OBJ "COKES">
                                    <FIND-OBJ "LISTS">)
        %<> 0>

<ADD-OBJECT
 <OBJECT "TOMB"
"There is a tomb here, made of the finest marble, and large enough
for four headless corpses.  On one end is the cryptic inscription:
                    
                      \"Feel Free.\"
"
          "tomb" %<>
          HEAD-FUNCTION () %<> %<+ ,TRYTAKEBIT ,READBIT ,OVISON>>
 ["GRAVE"]>

<ADD-DESC <FIND-OBJ "TOMB">
"Here lie the implementers, whose heads were placed on poles by the
Keeper of the Dungeon for amazing untastefulness.">

<ADD-OBJECT
 <OBJECT "HEADS"
          "There are four heads here, mounted securely on poles."
          "set of poled heads" %<>
          HEAD-FUNCTION
          () %<> %<+ ,TRYTAKEBIT ,SACREDBIT ,OVISON>>
 ["HEAD" "POLE" "POLES" "PDL" "BKD" "TAA" "MARC" "IMPLE" "LOSER"]>

<ADD-OBJECT
 <OBJECT "COKES"
"Many empty Coke bottles are here.  Alas, they can't hold water."
          "bunch of Coke bottles"
"There is a large pile of empty Coke bottles here, evidently produced
by the implementers during their long struggle to win totally."
          COKE-BOTTLES
          () %<> %<+ ,OVISON ,TAKEBIT> 0 0 0 15>
 ["BOTTL"] ["COKE"]>

<ADD-OBJECT
 <OBJECT "LISTS"
"There is an enormous stack of line-printer paper here.  It is barely
readable."
          "stack of listings"
"There is a gigantic pile of line-printer output here.  Although the
paper once contained useful information, almost nothing can be
distinguished now."
          %<> () %<> %<+ ,READBIT ,BURNBIT ,OVISON ,TAKEBIT> 0 0 0 70>
 ["PAPER" "LIST" "PRINT" "LISTI" "STACK"]>

<ADD-DESC <FIND-OBJ "LISTS">
          "<DEFINE FEEL-FREE (LOSER)
                   <TELL \"FEEL FREE, CHOMPER!\">>
                        ...
The rest is, alas, unintelligible (as were the implementers).">

<ADD-OBJECT
 <OBJECT "LCASE"
"There is a large case here, containing objects which you used to
possess."
"large case" %<> %<> () %<> %<+ ,OVISON ,TRANSBIT>>
 ["CASE"] ["LARGE"]>

<MAPF <>
   <FUNCTION (X) <RTRO <FIND-ROOM <SPNAME .X>> ,RFILLBIT>>
 ![RESEN!-ROOMS RESES!-ROOMS DAM!-ROOMS STREA!-ROOMS
   RIVR1!-ROOMS RIVR2!-ROOMS RIVR3!-ROOMS RIVR4!-ROOMS RIVR5!-ROOMS
   BEACH!-ROOMS RCAVE!-ROOMS DOCK!-ROOMS WCLF1 WCLF2 FANTE POG]>

<MAPF <>
  <FUNCTION (X) <RTRO <FIND-ROOM .X> ,RHOUSEBIT>>
  ["LROOM" "KITCH" "ATTIC"]>

<MAPF <>
   <FUNCTION (X) <RTRO <FIND-ROOM .X> ,RSACREDBIT>>
      ["BSHAF"
       "RIVR1"
       "DOCK"
       "FANTE"
       "FALLS"
       "BEACH"
       "RCAVE"
       "VAIR1"
       "VAIR2"
       "VAIR3"
       "VAIR4"
       "RIVR2"
       "RIVR3"
       "RIVR4"
       "RIVR5"
       "TIMBE"
       "WHOUS"
       "NHOUS"
       "EHOUS"
       "SHOUS"
       "KITCH"
       "LROOM"
       "FORE1"
       "FORE2"
       "FORE3"
       "FORE4"
       "FORE5"
       "CLEAR"
       "TEMP1"
       "TEMP2"
       "CLTOP"
       "CLMID"
       "CLBOT"
       "RAINB"
       "FALLS"]>

<SETG BUCKET-TOP!-FLAG <>>

<SETG MAGCMACH <CEXIT "FROBOZZ" "CMACH" "">>
<SETG MAGALICE <CEXIT "FROBOZZ" "ALICE" "">>

<ROOM "MAGNE"
       ""
       "Low Room"
       %<>
       <EXIT "NORTH" %,MAGCMACH "SOUTH" %,MAGCMACH "WEST" %,MAGCMACH "NE" %,MAGCMACH
              "NW" %,MAGALICE "SW" %,MAGALICE "SE" %,MAGALICE "EAST" %,MAGCMACH>
       (<FIND-OBJ "RBTLB"> <FIND-OBJ "ROBOT">) MAGNET-ROOM>

<ROOM "CMACH"
       ""
       "Machine Room"
       %<>
       <EXIT "WEST" "MAGNE" "SOUTH" "CAGER">
       (<FIND-OBJ "SQBUT"> <FIND-OBJ "RNBUT"> <FIND-OBJ "TRBUT">)
       CMACH-ROOM>

<ROOM "CAGER"
"You are in a dingy closet adjacent to the machine room.  On one wall
is a small sticker which says
                Protected by
                  FROBOZZ
             Magic Alarm Company
              (Hello, footpad!)
"
       "Dingy Closet"
       %<>
       <EXIT "NORTH" "CMACH">
       (<FIND-OBJ "SPHER">)>

<ROOM "CAGED"
"You are trapped inside an iron cage."
       "Cage"
       %<>
       <EXIT "NORTH" #NEXIT "">
       (<FIND-OBJ "CAGE">) CAGED-ROOM>

<ADD-OBJECT
 <OBJECT "CAGE"
          "There is a mangled cage here."
          "mangled cage"
          %<> %<> () %<> %<+ ,OVISON ,NDESCBIT> 0 0 0 60 0>
 [] []>

<ADD-OBJECT 
 <OBJECT "RCAGE"
          "There is an iron cage in the middle of the room."
          "iron cage"
          %<> %<> () %<> %,OVISON 0 0 0 0 0>
 ["CAGE"] ["IRON"]>

<ADD-OBJECT 
 <OBJECT "SPHER"
          "There is a beautiful crystal sphere here."
          "crystal sphere"
          %<> SPHERE-FUNCTION () %<> %<+ ,TRYTAKEBIT ,SACREDBIT ,OVISON> 0 6 6 10 0>
 ["BALL"] ["CRYST" "GLASS"]>

<ADD-OBJECT <AOBJECT "SQBUT" ,BUTSTR BUTTONS ,OVISON ,NDESCBIT> ["BUTTO"] ["SQUAR"]>
<ADD-OBJECT <AOBJECT "RNBUT" ,BUTSTR BUTTONS ,OVISON ,NDESCBIT> ["BUTTO"] ["ROUND"]>
<ADD-OBJECT <AOBJECT "TRBUT" ,BUTSTR BUTTONS ,OVISON ,NDESCBIT> ["BUTTO"] ["TRIAN"]>

<ROOM "TWELL"

"You are at the top of the well.  Well done.  There are etchings on
the side of the well. There is a small crack across the floor at the
entrance to a room on the east, but it can be crossed easily."
       "Top of Well"
       %<>
       <EXIT "EAST" "ALICE" "DOWN" #NEXIT "It's a long way down!">
       (<FIND-OBJ "ETCH2">) %<> 10 %<+ ,RLANDBIT ,RBUCKBIT>>

<ROOM "BWELL"
       
"You are in a damp circular room, whose walls are made of brick and
mortar.  The roof of this room is not visible, but there appear to be
some etchings on the walls.  There is a passageway to the west."
       "Circular Room"
       %<>
       <EXIT "WEST" "MPEAR" "UP" #NEXIT "The walls cannot be climbed.">
       (<FIND-OBJ "BUCKE"> <FIND-OBJ "ETCH1">) %<> 0 %<+ ,RLANDBIT ,RBUCKBIT>>

<PSETG EWALLS ["ETCHI" "WALLS" "WALL"]>
<ADD-OBJECT <SOBJECT "ETCH1" "wall with etchings" ,OVISON ,NDESCBIT ,READBIT> ,EWALLS>
<ADD-OBJECT <SOBJECT "ETCH2" "wall with etchings" ,OVISON ,NDESCBIT ,READBIT> ,EWALLS>

<ADD-DESC <FIND-OBJ "ETCH2">
"                       o  b  o
                    r             z
                 f   M  A  G  I  C   z
                 c    W  E   L  L    y
                    o             n
                        m  p  a
">

<ADD-DESC <FIND-OBJ "ETCH1">
"                       o  b  o
                                  
                        A  G  I  
                         E   L  
                                  
                        m  p  a
">

<ROOM "ALICE"

"You are in a small square room, in the center of which is a large
oblong table, no doubt set for afternoon tea.  It is clear from the
objects on the table that the users were indeed mad.  In the eastern
corner of the room is a small hole (no more that four inches high). 
There are passageways leading away to the west and the northwest."
       "Tea Room"
       %<>
       <EXIT "EAST" #NEXIT "Only a mouse could get in there."
              "WEST" "TWELL" "NW" "MAGNE">
       (<FIND-OBJ "ATABL"> <FIND-OBJ "ECAKE"> <FIND-OBJ "ORICE">
        <FIND-OBJ "RDICE"> <FIND-OBJ "BLICE">)>

<PSETG SMDROP #NEXIT "There is a chasm too large to jump across.">

<ROOM "ALISM"

"You are in an enormous room, in the center of which are four wooden
posts delineating a rectanular area, above which is what appears to
be a wooden roof.  In fact, all objects in this room appear to be
abnormally large. To the east is a passageway.  There is a large
chasm on the west and the northwest."
       "Posts Room"
       %<>
       <EXIT "NW" %,SMDROP "EAST" "ALITR" "WEST" %,SMDROP "DOWN" %,SMDROP>
       (<FIND-OBJ "POSTS">)>

<ROOM "ALITR"

"You are in a large room, one half of which is depressed.  There is a
large leak in the ceiling through which brown colored goop is
falling.  The only exit to this room is to the west."
       "Pool Room"
       %<>
       <EXIT "EXIT" "ALISM" "WEST" "ALISM">
       (<FIND-OBJ "FLASK"> <FIND-OBJ "POOL"> <FIND-OBJ "SAFFR">)>

<ADD-OBJECT
 <OBJECT "FLASK"
"A stoppered glass flask with a skull-and-crossbones marking is here.
The flask is filled with some clear liquid."
          "glass flask filled with liquid"
          %<> FLASK-FUNCTION () %<> %<+ ,TRANSBIT ,OVISON ,TAKEBIT> 0 0 0 10 5>
 [] ["GLASS"]>

<ADD-OBJECT
 <OBJECT "POOL"
          "The leak has submerged the depressed area in a pool of sewage."
          "pool of sewage"
          %<> %<> () %<> %<+ ,OVISON ,VICBIT> 0 0 0 0 0>
 ["SEWAG"] ["LARGE"]>

<ADD-OBJECT 
 <OBJECT "SAFFR"
          "There is a tin of rare spices here."
          "tin of spices"
          %<> %<> () %<> %,TAKEBIT 0 5 5 8 0>
 ["TIN" "SPICE"] ["RARE"]>

<ADD-OBJECT <SOBJECT "ATABL" "large oblong table" ,OVISON> [] ["LARGE" "OBLON"]>

<ADD-OBJECT <SOBJECT "POSTS" "wooden posts" ,OVISON> ["POST"] ["WOODE"]>

<ADD-OBJECT
 <OBJECT "BUCKE"
"There is a wooden bucket here, 3 feet in diameter and 3 feet high."
          "wooden bucket"
          %<> BUCKET () %<> %<+ ,VEHBIT ,OVISON> 0 0 0 100 100>
 [] ["WOODE"]>

<ADD-OBJECT
 <OBJECT "ECAKE"
 "There is a piece of cake here with the words 'Eat Me' on it."
          "piece of 'Eat Me' cake"
          %<> EATME-FUNCTION () %<> %<+ ,OVISON ,TAKEBIT ,FOODBIT> 0 0 0 10 0>
 ["CAKE"] ["EATME" "EAT-M"]>

<ADD-OBJECT
 <OBJECT "ORICE"
 "There is a piece of cake with orange icing here."
          "piece of cake with orange icing"
          %<> CAKE-FUNCTION () %<> %<+ ,READBIT ,OVISON ,TAKEBIT ,FOODBIT> 0 0 0 4 0>
 ["CAKE" "ICING"] ["ORANG"]>

<ADD-OBJECT
 <OBJECT "RDICE"
 "There is a piece of cake with red icing here."
          "piece of cake with red icing"
          %<> CAKE-FUNCTION () %<> %<+ ,READBIT ,OVISON ,TAKEBIT ,FOODBIT> 0 0 0 4 0>
 ["CAKE" "ICING"] ["RED"]>

<ADD-OBJECT
 <OBJECT "BLICE"
 "There is a piece of cake with blue (ecch) icing here."
          "piece of cake with blue icing"
          %<> CAKE-FUNCTION () %<> %<+ ,READBIT ,OVISON ,TAKEBIT ,FOODBIT> 0 0 0 4 0>
 ["CAKE" "ICING"] ["BLUE" "ECCH"]>

<PUT <PUT <FIND-OBJ "BUCKE"> ,OOPEN? T> ,ORAND ,RBUCKBIT>

<ADD-OBJECT
 <OBJECT "ROBOT"
          "There is a robot here."
          "robot"
          %<> ROBOT-FUNCTION () %<> %<+ ,SACREDBIT ,VICBIT ,OVISON ,ACTORBIT> 0 0 0 0 0>
 ["R2D2" "C3PO" "ROBBY"]>

<PUT <FIND-OBJ "ROBOT">
     ,ORAND
     <ADD-ACTOR 
        <CHTYPE [<FIND-ROOM "MAGNE"> () 0 <> <FIND-OBJ "ROBOT"> ROBOT-ACTOR 3 T 0] ADV>>>

<ADD-OBJECT
 <OBJECT "RBTLB"
          "There is a green piece of paper here."
          "green piece of paper"
          %<>  %<> () %<> %<+ ,OVISON ,TAKEBIT ,READBIT ,BURNBIT> 0 0 0 3 0>
 ["PAPER"] ["GREEN"]>

<ADD-DESC <FIND-OBJ "RBTLB">
"         !!!!  FROBOZZ MAGIC ROBOT COMPANY  !!!!

Hello, Master!
   
   I am a late-model robot, trained at MIT Tech to perform various
simple household functions. 

Instructions for use:
   To activate me, use the following formula:
        >TELL ROBOT '<something to do>' <cr>
   The quotation marks are required!
       
Warranty:
   No warranty is expressed or implied.
                                
                                        At your service!
" >
;"VERBS"

<SADD-ACTION "BACK" BACKER>

<SADD-ACTION "REPEN" REPENT>

<SADD-ACTION "TIME" PLAY-TIME>

<SADD-ACTION "WAIT" WAIT>

<SADD-ACTION "CURSE" CURSES>
<VSYNONYM "CURSE" "SHIT" "FUCK" "DAMN">

<SADD-ACTION "JARGON" JARGON>
<VSYNONYM "JARGON" "FOO" "BLETCH">

<ADD-ACTION "PUT"
            "Put"
            [OBJ "IN" OBJ ["PUT" PUTTER] DRIVER]
            ["DOWN" OBJ ["DROP" DROPPER]]> 
        
<ADD-ACTION "PICK"
            "Pick"
            ["UP" OBJ ["TAKE" TAKE]]>

<VSYNONYM "PUT" "STUFF" "PLACE" "INSER">

<1ADD-ACTION "LOWER" "Lower" R/L>

<ADD-ACTION "RAISE"
            "Raise"
            [OBJ ["RAISE" R/L] DRIVER]
            ["UP" OBJ ["RAISE" R/L]]>

<VSYNONYM "RAISE" "LIFT">

<1ADD-ACTION "MELT" "Melt" MELTER>
<VSYNONYM "MELT" "LIQUI">

<ADD-ACTION "LIGHT"
            "Light"
            [(,LIGHTBIT AOBJS ROBJS NO-TAKE) ["LIGHT" LAMP-ON] DRIVER]
            [(,LIGHTBIT AOBJS ROBJS NO-TAKE) "WITH" (,FLAMEBIT AOBJS)
                                             ["LIGHT" LAMP-ON]]>

<ADD-ACTION "EXTIN"
            "Turn off"
            [(,LIGHTBIT AOBJS ROBJS) ["EXTIN" LAMP-OFF]]>
<VSYNONYM "EXTIN" "DOUSE">

<ADD-ACTION "TURN"
            "Turn"
            [(,TURNBIT AOBJS ROBJS NO-TAKE)
             "WITH"
             (,TOOLBIT ROBJS AOBJS)
             ["TURN" TURNER]
             DRIVER]
            ["ON" (,LIGHTBIT AOBJS ROBJS) ["TURN-ON" LAMP-ON]]
            ["OFF" (,LIGHTBIT AOBJS ROBJS) ["TURN-OFF" LAMP-OFF]]
            [(,TURNBIT AOBJS ROBJS NO-TAKE)
             "TO"
             (-1 ROBJS)
             ["TURN-TO" TIME]]>

<ADD-ACTION "TAKE" "Take" [(-1 ROBJS AOBJS NO-TAKE) ["TAKE" TAKE]]>
<VSYNONYM "TAKE" "GET" "HOLD" "CARRY">

<ADD-ACTION "LOOK"
            "Look"
            [["LOOK" ROOM-DESC]]
            ["AT" OBJ ["LOOK-AT" ROOM-DESC]]
            ["UNDER" OBJ ["LOOK-UNDER" LOOK-UNDER]]>

<ADD-ACTION "GIVE"
            "Give"
            [OBJ "TO" (,VICBIT ROBJS NO-TAKE) ["GIVE" DROPPER] DRIVER]
            [(,VICBIT ROBJS NO-TAKE) OBJ ["GIVE" DROPPER] FLIP]>
<VSYNONYM "GIVE" "HAND" "DONAT">

<ADD-ACTION "STRIK"
            "Strike"
            [(,VICBIT = ROBJS NO-TAKE)
             "WITH"
             (,WEAPONBIT AOBJS ROBJS)
             ["ATTAC" ATTACKER]]
            [(,VICBIT = ROBJS NO-TAKE) ["ATTAC" ATTACKER] DRIVER]
            [(-1 ROBJS AOBJS) ["LIGHT" LAMP-ON]]>

<AADD-ACTION "MOVE" "Move" MOVE>
<VSYNONYM "MOVE" "PULL" "TUG">

<AADD-ACTION "WAVE" "Wave" WAVER>
<VSYNONYM "BRAND" "FLAUN">

<ADD-ACTION "DROP"
            "Drop"
            [(-1 AOBJS) ["DROP" DROPPER] DRIVER]
            [(-1 AOBJS) "IN" OBJ ["DROP" DROPPER]]>
<VSYNONYM "DROP" "RELEA">

<ADD-ACTION "POUR"
            "Pour"
            [(-1 AOBJS) ["POUR" DROPPER] DRIVER]
            [(-1 AOBJS) "IN" OBJ ["POUR" DROPPER]]>
<VSYNONYM "POUR" "SPILL">

<ADD-ACTION "THROW"
            "Throw"
            [(-1 AOBJS) "AT" (,VICBIT ROBJS NO-TAKE) ["THROW" DROPPER]]>
<VSYNONYM "THROW" "HURL" "CHUCK">

<ADD-ACTION "TELL"
            "Tell"
            [(,ACTORBIT) ["TELL" COMMAND]]>
<VSYNONYM "TELL" "COMMA" "REQUE">

<VSYNONYM "LOOK" "L" "STARE" "GAZE">

<SADD-ACTION "BRIEF" BRIEF>

<SADD-ACTION "UNBRI" UN-BRIEF>

<SADD-ACTION "SUPER" SUPER-BRIEF>

<SADD-ACTION "UNSUP" UN-SUPER-BRIEF>

<1ADD-ACTION "EXAMI" "Examine" ROOM-INFO>
<VSYNONYM "EXAMI" "DESCR" "WHAT" "WHATS" "WHAT'">

<1ADD-ACTION "FIND" "Find" FIND>
<VSYNONYM "WHERE" "FIND" "SEEK" "SEE">

<SADD-ACTION "INVEN" INVENT>
<VSYNONYM "INVEN" "LIST">

<SADD-ACTION "VERSI" VERSION>

<SADD-ACTION "SCRIP" DO-SCRIPT>

<SADD-ACTION "UNSCR" DO-UNSCRIPT>

<SADD-ACTION "SAVE" DO-SAVE>

<SADD-ACTION "RESTO" DO-RESTORE>

<SADD-ACTION "WALK-IN" TIME>

<SADD-ACTION "C-INT" TIME>      ;"funny verb for clock ints"

<SADD-ACTION "DEAD!" TIME>      ;"funny verb for killing villains"

<SADD-ACTION "FIRST?" TIME>     ;"funny verb for surprise by villains"

<SADD-ACTION "IN!" TIME>        ;"villain regains consciousness"

<SADD-ACTION "OUT!" TIME>       ;"villain loses consciousness"

<SADD-ACTION "DIAGN" DIAGNOSE>

<SADD-ACTION "HACK?" TIME>      ;"funny verb for villain fight decisions"

<SADD-ACTION "SCORE" SCORE>

<SADD-ACTION "QUIT" FINISH>

<SADD-ACTION "INFO" INFO>

<SADD-ACTION "HELP" HELP>

<ADD-ACTION "PLUG"
            "Plug"
            [OBJ "WITH" OBJ ["PLUG" PLUGGER]]>
<VSYNONYM "PLUG" "GLUE" "PATCH">

<1ADD-ACTION "RUB" "Rub" RUBBER>
<VSYNONYM "RUB" "CARES" "TOUCH" "FONDL">

<SADD-ACTION "SWIM" SWIMMER>
<VSYNONYM "SWIM" "BATHE" "WADE">

<ADD-ACTION "BURN"
            "Burn"
            [(,BURNBIT AOBJS ROBJS NO-TAKE) "WITH" (,FLAMEBIT AOBJS ROBJS)
                        ["BURN" BURNER]]>
<VSYNONYM "BURN" "INCIN" "IGNIT">

<ADD-ACTION "KILL"
            "Kill"
            [(,VILLAIN ROBJS NO-TAKE) "WITH" (,WEAPONBIT AOBJS) ["KILL" KILLER]]>
<VSYNONYM "KILL"
         "MURDE"
         "SLAY"
         "DISPA">

<ADD-ACTION "ATTAC"
            "Attack"
            [(,VILLAIN ROBJS NO-TAKE) "WITH" (,WEAPONBIT AOBJS) ["ATTAC" ATTACKER]]>
<VSYNONYM "ATTAC"
         "FIGHT"
         "MUNG"
         "HACK"
         "FROB"
         "HURT"
         "INJUR"
         "DAMAG"
         "HIT">

<ADD-ACTION "SWING"
            "Swing"
            [(,WEAPONBIT AOBJS) "AT" (,VILLAIN ROBJS NO-TAKE) ["SWING" SWINGER]]>
<VSYNONYM "SWING"
         "THRUS">

<ADD-ACTION "POKE"
            "Poke"
            [(,VILLAIN ROBJS NO-TAKE) "WITH" (,WEAPONBIT AOBJS) ["POKE" MUNGER]]>
<VSYNONYM "POKE"
         "JAB"
         "BREAK">

<1ADD-ACTION "KICK" "Kick" KICKER>
<VSYNONYM "KICK"
         "BITE"
         "TAUNT">

<1ADD-ACTION "PUSH" "Push" PUSHER>
<VSYNONYM "PUSH" "PRESS">

<ADD-ACTION "OPEN"
            "Open"
            [(<+ ,DOORBIT ,CONTBIT> AOBJS ROBJS NO-TAKE) ["OPEN" OPENER]]>
<VSYNONYM "OPEN">

<ADD-ACTION "CLOSE"
            "Close"
            [(<+ ,DOORBIT ,CONTBIT> AOBJS ROBJS NO-TAKE) ["CLOSE" CLOSER]]>
<VSYNONYM "CLOSE">

<ADD-ACTION "UNLOC"
            "Unlock"
            [(-1 ROBJS NO-TAKE) "WITH" (,TOOLBIT AOBJS ROBJS) ["UNLOC" UNLOCKER]]>

<ADD-ACTION "LOCK"
            "Lock"
            [(-1 ROBJS NO-TAKE) ["LOCK" LOCKER]]>

<ADD-ACTION "TIE"
            "Tie"
            [OBJ "TO" OBJ ["TIE" TIE]]>
<VSYNONYM "TIE" "KNOT" "FASTE">

<1ADD-ACTION "RING" "Ring" RING>
<VSYNONYM "RING" "PEAL">

<ADD-ACTION "EAT"
            "Eat"
            [(,FOODBIT AOBJS ROBJS) ["EAT" EAT]]>
<VSYNONYM "EAT" "CONSU" "GOBBL" "MUNCH" "TASTE">

<ADD-ACTION "DRINK"
            "Drink"
            [(,DRINKBIT AOBJS ROBJS) ["DRINK" EAT]]>
<VSYNONYM "DRINK" "IMBIB" "SWALL">

<ADD-ACTION "BRUSH"
            "Brush"
            [(-1 AOBJS ROBJS) ["BRUSH" BRUSH] DRIVER]
            [(-1 AOBJS ROBJS) "WITH" OBJ ["BRUSH" BRUSH]]>
<VSYNONYM "BRUSH" "CLEAN">

<1ADD-ACTION "UNTIE" "Untie" UNTIE>
<VSYNONYM "UNTIE" "RELEA" "FREE">

<SADD-ACTION "EXORC" EXORCISE>
<VSYNONYM "EXORC" "XORCI">

<SADD-ACTION "CHOMP" CHOMP>
<VSYNONYM "CHOMP" "LOSE" "BARF">

<SADD-ACTION "YELL" YELL>
<VSYNONYM "YELL" "SCREA" "SHOUT">

<SADD-ACTION "WIN" WIN>
<VSYNONYM "WIN" "WINNA">

<SADD-ACTION "FROBO" FROBOZZ>

<SADD-ACTION "TREAS" TREAS>

<SADD-ACTION "TEMPL" TREAS>

<SADD-ACTION "PRAY" PRAYER>

<SADD-ACTION "JUMP" LEAPER>

<SADD-ACTION "SKIP" SKIPPER>
<VSYNONYM "SKIP" "HOP">

<SADD-ACTION "MUMBL" MUMBLER>
<VSYNONYM "MUMBL" "SIGH">

<SADD-ACTION "ZORK" ZORK>

<SADD-ACTION "DUNGE" DUNGEON>

<ADD-ACTION "WAKE"
            "Wake"
            [(,VICBIT ROBJS NO-TAKE) ["WAKE" ALARM]]>
<VSYNONYM "WAKE" "AWAKE" "SURPR" "START">

<ADD-ACTION "HELLO"
            "Hello"
            [["HELLO" HELLO] DRIVER]
            [OBJ ["HELLO" HELLO]]>
<VSYNONYM "HELLO" "HI">

<1ADD-ACTION "GRANI" "Granite" GRANITE>

<VSYNONYM "JUMP" "LEAP" "VAULT">

<1ADD-ACTION "FILL" "Fill" FILL>

<SADD-ACTION "WELL" WELL>

<SADD-ACTION "ODYSS" SINBAD>
<VSYNONYM "ODYSS" "ULYSS">

<ADD-ACTION "READ"
            "Read"
            [(,READBIT AOBJS ROBJS NO-TAKE) ["READ" READER] DRIVER]
            [(,READBIT AOBJS ROBJS NO-TAKE) "WITH" OBJ ["READ" READER]]>
<VSYNONYM "READ" "SKIM" "SCAN">

<1ADD-ACTION "DEFLA" "Deflate" DEFLATER>

<ADD-ACTION "INFLA"
            "Inflate"
            [OBJ "WITH" (,TOOLBIT ROBJS AOBJS NO-TAKE) ["INFLA" INFLATER]]>

<ADD-ACTION "DISEM"
            "Disembark from"
            [(,VEHBIT ROBJS NO-TAKE) ["DISEM" UNBOARD]]>

<ADD-ACTION "DIG"
            "Dig"
            ["WITH" (,TOOLBIT AOBJS) ["DIG" DIGGER]]>

<ADD-ACTION "BOARD"
            "Board"
            [(,VEHBIT ROBJS NO-TAKE) ["BOARD" BOARD]]>

<ADD-ACTION "KNOCK"
            "Knock"
            ["AT" OBJ ["KNOCK" KNOCK] DRIVER]
            ["ON" OBJ ["KNOCK" KNOCK]]
            ["DOWN" (,VICBIT = ROBJS NO-TAKE) ["ATTAC" ATTACKER]]>

<SADD-ACTION "GERON" GERONIMO>

<SADD-ACTION "BLAST" BLAST>

<1ADD-ACTION "WALK" "Walk" WALK>

<ADD-BUZZ "RUN" "GO" "PROCE">

<SETG ROBOT-ACTIONS ![,WALK!-WORDS ,TAKE!-WORDS ,DROP!-WORDS ,PUT!-WORDS
    ,JUMP!-WORDS ,PUSH!-WORDS ,THROW!-WORDS ,TURN!-WORDS]>

<SETG PLAYER 
      <ADD-ACTOR <CHTYPE [,WHOUS!-ROOMS
                          () 0 <> <FIND-OBJ "#####"> <> 0 T 0]
                         ADV>>>
