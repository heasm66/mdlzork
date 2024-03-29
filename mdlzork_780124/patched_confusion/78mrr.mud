; "GLOBAL OBJECTS"

<OR <GASSIGNED? ROSE!-OBJECTS>
    <PROG ()
        <GOBJECT ["MIRRO" "STRUC"] "mirror" MIRROR-FUNCTION MIRRORBIT ,OVISON>
        <GOBJECT ["ROSE" "COMPA"] "compass rose" <> ROSEBIT ,OVISON>
        <GOBJECT ["CHANN"] "stone channel" <> CHANBIT ,OVISON>
        <GOBJECT ["WALL"] "wooden wall" WALL-FUNCTION WALLBIT ,OVISON>>>


; "ROOMS"
<SETG MR-D <CEXIT "FROBOZZ" "MRD" "" %<> MRGO>>
<SETG MR-G <CEXIT "FROBOZZ" "MRG" "" %<> MRGO>>
<SETG MR-C <CEXIT "FROBOZZ" "MRC" "" %<> MRGO>>
<SETG MR-B <CEXIT "FROBOZZ" "MRB" "" %<> MRGO>>
<SETG MR-A <CEXIT "FROBOZZ" "MRA" "" %<> MRGO>>
<SETG MOUT <CEXIT "FROBOZZ" "MRA" "" %<> MIROUT>>
<SETG MIREX <CEXIT "MIRROR-OPEN" "INMIR" "" %<> MIRIN>>

<ROOM "MRD"
       "" "Hallway" T
       <EXIT "NORTH" "FDOOR" "NE" "FDOOR" "NW" "FDOOR"
              "SOUTH" %,MR-G "SE" %,MR-G "SW" %,MR-G>
       ()
       %<> 0 %,RLANDBIT %<+ ,ROSEBIT ,CHANBIT ,WALLBIT>> 

<ROOM "MRG"
       "" "Hallway" T
       <EXIT "NORTH" %,MR-D "SOUTH" %,MR-C>
       ()
       GUARDIANS>

<ROOM "MRC"
       "" "Hallway" T
       <EXIT "NORTH" %,MR-G "NW" %,MR-G "NE" %,MR-G
              "ENTER" %,MIREX "SOUTH" %,MR-B "SW" %,MR-B "SE" %,MR-B>
       ()
       MRCF 0 %,RLANDBIT %<+ ,MIRRORBIT ,ROSEBIT ,CHANBIT ,WALLBIT>>

<ROOM "MRB"
       "" "Hallway" T
       <EXIT "NORTH" %,MR-C "NW" %,MR-C "NE" %,MR-C
              "ENTER" %,MIREX "SOUTH" %,MR-A "SW" %,MR-A "SW" %,MR-A>
       ()
       MRBF 0 %,RLANDBIT %<+ ,MIRRORBIT ,ROSEBIT ,CHANBIT ,WALLBIT>>

<ROOM "MRA"
       "" "Hallway" T
       <EXIT "NORTH" %,MR-B "NW" %,MR-B "NE" %,MR-B
              "ENTER" %,MIREX "SOUTH" "MREYE">
       ()
       MRAF 0 %,RLANDBIT %<+ ,MIRRORBIT ,ROSEBIT ,CHANBIT ,WALLBIT>>

<ROOM "MRGE"
       "" "Narrow Room" T
       %,NULEXIT
       ()
       GUARDIANS 0 %,RLANDBIT %,MIRRORBIT>

<ROOM "MRCE"
       "" "Narrow Room" T
       %,NULEXIT
       ()
       GUARDIANS 0 %,RLANDBIT %,MIRRORBIT>

<ROOM "MRCE"
       "" "Narrow Room" T
       <EXIT "ENTER" %,MIREX "NORTH" "MRG" "SOUTH" "MRB">
       ()
       MRCEW 0 %,RLANDBIT %,MIRRORBIT>

<ROOM "MRCW"
       "" "Narrow Room" T
       <EXIT "ENTER" %,MIREX "NORTH" "MRG" "SOUTH" "MRB">
       ()
       MRCEW 0 %,RLANDBIT %,MIRRORBIT>

<ROOM "MRBE"
       "" "Narrow Room" T
       <EXIT "ENTER" %,MIREX "NORTH" "MRC" "SOUTH" "MRA">
       ()
       MRBEW 0 %,RLANDBIT %,MIRRORBIT>

<ROOM "MRBW"
       "" "Narrow Room" T
       <EXIT "ENTER" %,MIREX "NORTH" "MRC" "SOUTH" "MRA">
       ()
       MRBEW 0 %,RLANDBIT %,MIRRORBIT>

<ROOM "MRAE"
       "" "Narrow Room" T
       <EXIT "ENTER" %,MIREX "NORTH" "MRB">
       ()
       MRAEW 0 %,RLANDBIT %,MIRRORBIT>

<ROOM "MRAW"
       "" "Narrow Room" T
       <EXIT "ENTER" %,MIREX "NORTH" "MRB">
       ()
       MRAEW 0 %,RLANDBIT %,MIRRORBIT>

<ROOM "INMIR"
       "" "Inside Mirror" T
       <EXIT "NORTH" %,MOUT "SOUTH" %,MOUT "EAST" %,MOUT "WEST" %,MOUT
              "NE" %,MOUT "NW" %,MOUT "SE" %,MOUT "SW" %,MOUT>
       (<FIND-OBJ "YLWAL"> <FIND-OBJ "WHWAL">
        <FIND-OBJ "RDWAL"> <FIND-OBJ "BLWAL">
        <FIND-OBJ "OAKND"> <FIND-OBJ "PINND">
        <FIND-OBJ "WDBAR"> <FIND-OBJ "LPOLE">
        <FIND-OBJ "SPOLE">)
       MAGIC-MIRROR
       0 %,RLANDBIT %<+ ,ROSEBIT ,CHANBIT ,WALLBIT>>

<ADD-OBJECT
 <GOBJECT ["MASTE" "KEEPE" "DUNGE"] "dungeon master" MASTER-FUNCTION MASTERBIT
         ,OVISON ,VICBIT ,ACTORBIT>
 ["KEEPE"] ["DUNGE"]>

<PUT <FIND-OBJ "MASTE">
     ,ODESC1
     "The dungeon master is quietly leaning on his staff here.">

<PUT <FIND-OBJ "MASTE">
     ,ORAND
     <ADD-ACTOR 
        <SETG MASTER <CHTYPE [<FIND-ROOM "BDOOR"> () 0 <> <FIND-OBJ "MASTE"> MASTER-ACTOR 3 T 0]
                ADV>>>>

<ADD-OBJECT <AOBJECT "YLWAL" "yellow panel" MPANELS ,OVISON ,NDESCBIT>
            ["WALL" "PANEL"] ["YELLO"]>
<ADD-OBJECT <AOBJECT "RDWAL" "red panel" MPANELS ,OVISON ,NDESCBIT>
            ["WALL" "PANEL"] ["RED"]>
<ADD-OBJECT <AOBJECT "BLWAL" "black panel" MPANELS ,OVISON ,NDESCBIT>
            ["WALL" "PANEL"] ["BLACK"]>
<ADD-OBJECT <AOBJECT "WHWAL" "white panel" MPANELS ,OVISON ,NDESCBIT>
            ["WALL" "PANEL"] ["WHITE"]>
<ADD-OBJECT <AOBJECT "PINND" "pine wall" MENDS ,OVISON ,NDESCBIT ,DOORBIT>
            ["WALL" "PANEL" "DOOR"] ["PINE"]>
<ADD-OBJECT <AOBJECT "OAKND" "oak wall" MENDS ,OVISON ,NDESCBIT>
            ["WALL" "PANEL"] ["OAK"]>
<ADD-OBJECT <SOBJECT "WDBAR" "wooden bar" ,OVISON ,NDESCBIT>
            ["BAR"] ["WOODE"]>
<ADD-OBJECT <SOBJECT "LPOLE" "long pole" ,OVISON ,NDESCBIT>
            ["POLE" "POST"] ["LONG" "CENTE"]>
<ADD-OBJECT <AOBJECT "SPOLE" "short pole" SHORT-POLE ,OVISON ,NDESCBIT>
            ["POLE" "POST"] ["SHORT"]>

<ADD-OBJECT <AOBJECT "DIAL" "sundial" DIAL ,OVISON ,NDESCBIT ,TURNBIT>
            ["SUNDI"] ["SUN"]>
<ADD-OBJECT <AOBJECT "DBUTT" "large button" DIALBUTTON ,OVISON ,NDESCBIT>
            ["BUTTO"] ["LARGE"]>

<ADD-OBJECT <SOBJECT "ONE" "number one" ,OVISON ,NDESCBIT>
            ["1"]>
<ADD-OBJECT <SOBJECT "TWO" "number two" ,OVISON ,NDESCBIT>
            ["2"]>
<ADD-OBJECT <SOBJECT "THREE" "number three" ,OVISON ,NDESCBIT>
            ["3"]>
<ADD-OBJECT <SOBJECT "FOUR" "number four" ,OVISON ,NDESCBIT>
            ["4"]>
<ADD-OBJECT <AOBJECT "FIVE" "number five" TAKE-FIVE ,OVISON ,NDESCBIT>
            ["5"]>
<ADD-OBJECT <SOBJECT "SIX" "number six" ,OVISON ,NDESCBIT>
            ["6"]>
<ADD-OBJECT <SOBJECT "SEVEN" "number seven" ,OVISON ,NDESCBIT>
            ["7"]>
<ADD-OBJECT <SOBJECT "EIGHT" "number eight" ,OVISON ,NDESCBIT>
            ["8"]>

<ROOM "MRANT"

"You are standing near one end of a long, dimly lit hall.  At the
south stone stairs ascend.  To the north the corridor is illuminated
by torches set high in the walls, out of reach.  On one wall is a red
button."
       "Stone Room" T
       <EXIT "SOUTH" "TSTRS" "UP" "TSTRS" "NORTH" "MREYE">
       (<FIND-OBJ "RSWIT">)>

<ADD-OBJECT <AOBJECT "RSWIT" "red switch" MRSWITCH ,OVISON ,NDESCBIT>
            ["SWITC" "BUTTO"] ["RED"]>

<ROOM "MREYE"
       ""
       "Small Room"
       T
       <EXIT "NORTH" "MRA" "SOUTH" "MRANT">
       ()
       MREYE-ROOM>

<SETG CD <DOOR "TOMB" "TOMB" "CRYPT" %<> %<>>>

<ROOM "TOMB"
       ""
       "Tomb of the Unknown Implementer"
        %<>
        <EXIT "WEST" "LLD2" "NORTH" %,CD "ENTER" %,CD>
        (<FIND-OBJ "TOMB">
         <FIND-OBJ "HEADS">
         <FIND-OBJ "COKES">
         <FIND-OBJ "LISTS">)
        TOMB-FUNCTION 0 %,RLANDBIT>

<ROOM "CRYPT"
       ""
       "Crypt"
       %<>
       <EXIT "SOUTH" %,CD "LEAVE" %,CD>
       (<FIND-OBJ "TOMB">)
       CRYPT-FUNCTION 0 %,RLANDBIT>

<ADD-OBJECT
 <OBJECT "TOMB"
          ""
          "crypt door"
          %<> CRYPT-OBJECT () %<> %<+ ,OVISON ,DOORBIT ,NDESCBIT>>
 ["CRYPT" "GRAVE" "TOMB" "DOOR"] ["CRYPT"]>

<ROOM "TSTRS"
"You are standing at the top of a flight of stairs that lead down to
a passage below.  Dim light, as from torches, can be seen in the
passage.  Behind you the stairs lead into untouched rock."
       "Top of Stairs"
       T
       <EXIT "NORTH" "MRANT"
              "DOWN" "MRANT"
              "SOUTH" #NEXIT "The wall is solid rock.">
       ()
       %<> 0>

<ROOM "ECORR"
"You are in a corridor with polished marble walls.  The corridor
widens into larger areas as it turns west at its northern and
southern ends."
      "East Corridor"
      T
      <EXIT "NORTH" "NCORR" "SOUTH" "SCORR">>

<ROOM "WCORR"
"You are in a corridor with polished marble walls.  The corridor
widens into larger areas as it turns east at its northern and
southern ends."
      "West Corridor"
      T
      <EXIT "NORTH" "NCORR" "SOUTH" "SCORR">>

<SETG OD <DOOR "ODOOR" "SCORR" "CELL" "" MAYBE-DOOR>> ; "south cell door"
<SETG ODOOR!-FLAG <>>   ;"t if door 'exists'"

<SETG WD <DOOR "WDOOR" "BDOOR" "FDOOR">> ; "wooden door, entrance to cell area"
<SETG CD <DOOR "CDOOR" "NCORR" "CELL">> ; "cell door"
<SETG ND <DOOR "NDOOR" "NCELL" "NIRVA">> ; "winnage door"

<ROOM "SCORR"
       ""
       "South Corridor"
       T
       <EXIT "WEST" "WCORR"
              "EAST" "ECORR"
              "NORTH" %,OD
              "SOUTH" "BDOOR">
       (<FIND-OBJ "ODOOR">)
       SCORR-ROOM>

<ROOM "BDOOR"
"You are in a narrow north-south corridor.  At the south end is a door
and at the north end is an east-west corridor."
       "Narrow Corridor"
       T
       <EXIT "NORTH" "SCORR" "SOUTH" %,WD>>

<ROOM "FDOOR"
       ""
       "Dungeon Entrance"
       T
       <EXIT "NORTH" %,WD "ENTER" %,WD "SOUTH" "MRD">
       (<FIND-OBJ "WDOOR">) FDOOR-FUNCTION>

<ADD-OBJECT <AOBJECT "WDOOR" "wooden door" WOOD-DOOR ,OVISON ,NDESCBIT ,DOORBIT>
            ["DOOR"] ["WOODE"]> 

<ROOM "NCORR"
       ""
       "North Corridor"
       T
       <EXIT "EAST" "ECORR" "WEST" "WCORR" "NORTH" "PARAP"
              "SOUTH" %,CD "ENTER" %,CD>
       (<FIND-OBJ "CDOOR">)
       NCORR-ROOM>

<ROOM "PARAP"
       ""
       "Parapet"
       T
       <EXIT "SOUTH" "NCORR"
              "NORTH" #NEXIT "You would be burned to a crisp in no time.">
       (<FIND-OBJ "DBUTT"> <FIND-OBJ "DIAL">
        <FIND-OBJ "ONE"> <FIND-OBJ "TWO">
        <FIND-OBJ "THREE"> <FIND-OBJ "FOUR">
        <FIND-OBJ "FIVE"> <FIND-OBJ "SIX">
        <FIND-OBJ "SEVEN"> <FIND-OBJ "EIGHT">) PARAPET>

<SETG NUMOBJS
     [<FIND-OBJ "ONE"> 1 <FIND-OBJ "TWO"> 2
      <FIND-OBJ "THREE"> 3 <FIND-OBJ "FOUR"> 4
      <FIND-OBJ "FIVE"> 5 <FIND-OBJ "SIX"> 6
      <FIND-OBJ "SEVEN"> 7 <FIND-OBJ "EIGHT"> 8]>

<ADD-OBJECT <AOBJECT "CDOOR" "cell door" CELL-DOOR ,OVISON ,NDESCBIT ,DOORBIT>
            ["DOOR"] ["CELL"]>
<ADD-OBJECT <AOBJECT "ODOOR" "ornate door" ORNATE-DOOR ,OVISON ,NDESCBIT ,DOORBIT>
            ["DOOR"] ["ORNAT"]>

<ROOM "CELL" 
       ""
       "Prison Cell"
       T
       <EXIT "OUT" %,CD
              "NORTH" %,CD
              "SOUTH" %,OD>
       (<FIND-OBJ "CDOOR"> <FIND-OBJ "ODOOR">)
       CELL-ROOM 0 %,RLANDBIT %,MASTERBIT>

<SETG FOUT #NEXIT "The door is securely fastened.">

<ADD-OBJECT <AOBJECT "LDOOR" "locked door" LOCKED-DOOR ,OVISON ,NDESCBIT>
            ["DOOR"] ["LOCKE"]>
<ADD-OBJECT <AOBJECT "MDOOR" "locked door" LOCKED-DOOR ,OVISON ,NDESCBIT>
            ["DOOR"] ["LOCKE"]>

<ROOM "PCELL"
       ""
       "Prison Cell"
       T
       <EXIT "OUT" %,FOUT>
       (<FIND-OBJ "LDOOR">)
       PCELL-ROOM>

<ROOM "NCELL"
       ""
       "Prison Cell"
       T
       <EXIT "OUT" %,FOUT "NORTH" %,ND>
       (<FIND-OBJ "NDOOR"> <FIND-OBJ "MDOOR">)
       NCELL-ROOM>

<SETG CELLS <IUVECTOR 8 '()>>

<SADD-ACTION "ANSWE" ANSWER>

<ADD-ACTION "FOLLOW" "Follow" [["FOLLO" FOLLOW]] [OBJ ["FOLLO" FOLLOW]]>

<SADD-ACTION "STAY" STAY>

<SETG MASTER-ACTIONS
      [,TAKE!-WORDS ,PUSH!-WORDS ,TURN!-WORDS ,FOLLO!-WORDS
       ,TURN-TO!-WORDS ,SPIN!-WORDS ,STAY!-WORDS ,KILL!-WORDS]>

