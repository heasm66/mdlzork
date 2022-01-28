;"AACT - DUNG.56 Dec 12, 1977
         ACT.37 Dec 10, 1977
  This is by far the biggest file and in later versions it got split into DUNG and ACT1-ACT4.
  I've used the same disposition as in the DUNG.56 and ACT.37 putting the DUNG first."

;"VOCABULARY"

;"GLOBAL VARIABLES WHICH ARE MONADS MUST BE HERE!"

<GLOBAL NOT-DROWNED T>      ;"Was DROWNED. Reversed usage from the original DROWNED flag."
<GLOBAL RIDDLE-FLAG <>>
<GLOBAL LIGHT-LOAD <>>
<GLOBAL LLD-FLAG <>>
<GLOBAL GLACIER-FLAG <>>
<GLOBAL LOW-TIDE <>>
<GLOBAL EGYPT-FLAG T>       ;"Reversed usage from the original. T = Not carrying the coffin, <> = Carrying the coffin."
<GLOBAL DOME-FLAG <>>
<GLOBAL MAGIC-FLAG <>>
<GLOBAL CYCLOPS-FLAG <>>
<GLOBAL KEY-FLAG <>>
<GLOBAL TRAP-DOOR <>>
<GLOBAL KITCHEN-WINDOW <>>
<GLOBAL TROLL-FLAG <>>
<GLOBAL FROBOZZ <>>
<GLOBAL MOVES <>>
<GLOBAL DEATHS <>>
<GLOBAL HERE <>>

;"Buzzwords. These are ignored in the input."
<BUZZ TO THIS AT TURN THE OVER AN A>

<DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN ENTER EXIT CLIMB CROSS>
<SYNONYM NORTH N>
<SYNONYM EAST E>
<SYNONYM WEST W>
<SYNONYM SOUTH S>
<SYNONYM UP U>
<SYNONYM DOWN D>
<SYNONYM EXIT OUT>          ;"Can't define LEAVE as synonym because it conflicts with LEAVES. See EPARSE."
<SYNONYM ENTER IN>
<SYNONYM CROSS TRAVE>

<OBJECT ROOMS>

;"ROOM DEFINITIONS
  Use ZIL standard handling of defining rooms and the built in object
  hiarchy. Empty strings are defined as <> instead because code
  becomes simpler when testing T/<> instead of empty strings with ZIL.
  The order they are defined is important because the robber will in
  reverse order from definitions. I.e. Starting in TREAS-R and moving
  backwards, skipping sacred rooms."

<ROOM CAROU
      (IN ROOMS)
      (RDESC1 
"You are in a circular room, with passages off in eight directions.|
Your compass needle is spinning wildly, and you can't get your bearings.")
      (RDESC2 "Round room")
      (RSEEN? <>)
      (RLIGHT? <>)
      (NORTH TO CAVE4)
      (SOUTH TO CAVE4)
      (EAST TO MGRAI)
      (WEST TO PASS1)
      (NW TO CANY1)
      (NE TO PASS5)
      (SE TO PASS4)
      (SW TO MAZE1)
      (OUT TO PASS3)
      (RACTION CAROUSEL-ROOM)
      (RVARS 0)
      (RVAL 0)>

<ROOM MTROL
      (IN ROOMS)
      (RDESC1 
"You are in a small room with passages off in all directions.  Bloodstains|
and deep scratches (perhaps made by an axe) mar the walls.")
      (RDESC2 "The Troll Room")
      (RSEEN? <>)
      (RLIGHT? <>)
      (WEST TO CELLA)
      (EAST TO CRAW4 IF TROLL-FLAG ELSE "The troll fends you off with a menacing gesture.")
      (NORTH TO PASS1 IF TROLL-FLAG ELSE "The troll fends you off with a menacing gesture.")
      (SOUTH TO MAZE1 IF TROLL-FLAG ELSE "The troll fends you off with a menacing gesture.")
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM RAVI1
      (IN ROOMS)
      (RDESC1 
"You are in a deep ravine at a crossing with a east-west crawlway.  Some|
stone steps are at the south of the ravine and a steep staircase descends.")
      (RDESC2 "Deep Ravine")
      (RSEEN? <>)
      (RLIGHT? <>)
      (SOUTH TO PASS1)
      (DOWN TO RESES)
      (EAST TO CHAS1)
      (WEST TO CRAW1)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM PASS1
      (IN ROOMS)
      (RDESC1 
"You are in a narrow east-west passageway.  There is a narrow stairway|
leading down at the north end of the room.")
      (RDESC2 "East-West Passage")
      (RSEEN? <>)
      (RLIGHT? <>)
      (EAST TO CAROU)
      (WEST TO MTROL)
      (DOWN TO RAVI1)
      (NORTH TO RAVI1)
      (RACTION <>)
      (RVARS 0)
      (RVAL 5)>

<ROOM NHOUS
      (IN ROOMS)
      (RDESC1 
"You are facing the north side of a white house.  There is no door here,|
and all the windows are barred.")
      (RDESC2 "North of House.")
      (RSEEN? <>)
      (RLIGHT? T)
      (WEST TO WHOUS)
      (EAST TO EHOUS)
      (NORTH TO FORE3)
      (SOUTH "The windows are all barred.")
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM SHOUS
      (IN ROOMS)
      (RDESC1 
"You are facing the south side of a white house. There is no door here,|
and all the windows are barred.")
      (RDESC2 "South of House.")
      (RSEEN? <>)
      (RLIGHT? T)
      (WEST TO WHOUS)
      (EAST TO EHOUS)
      (SOUTH TO FORE2)
      (NORTH "The windows are all barred.")
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM FORE1
      (IN ROOMS)
      (RDESC1 "You are in a forest, with trees in all directions around you.")
      (RDESC2 "Forest")
      (RSEEN? <>)
      (RLIGHT? T)
      (NORTH TO FORE1)
      (EAST TO FORE3)
      (SOUTH TO FORE2)
      (WEST TO FORE1)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM WHOUS
      (IN ROOMS)
      (RDESC1 
"You are in an open field west of a big white house, with a closed, locked|
front door.")
      (RDESC2 "West of House.")
      (RSEEN? <>)
      (RLIGHT? T)
      (NORTH TO NHOUS)
      (SOUTH TO SHOUS)
      (WEST TO FORE1)
      (EAST "The door is locked, and there is evidently no key.")
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM EHOUS
      (IN ROOMS)
      (RDESC1 <>)
      (RDESC2 "Behind House.")
      (RSEEN? <>)
      (RLIGHT? T)
      (NORTH TO NHOUS)
      (SOUTH TO SHOUS)
      (EAST TO CLEAR)
      (WEST TO KITCH IF KITCHEN-WINDOW)
      (ENTER TO KITCH IF KITCHEN-WINDOW)
      (RACTION EAST-HOUSE)
      (RVARS 0)
      (RVAL 0)>

<ROOM FORE3
      (IN ROOMS)
      (RDESC1 
"You are in a dimly lit forest, with large trees all around.  To the|
east, there appears to be sunlight.")
      (RDESC2 "Forest")
      (RSEEN? <>)
      (RLIGHT? T)
      (NORTH TO FORE2)
      (EAST TO CLEAR)
      (SOUTH TO CLEAR)
      (WEST TO NHOUS)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM FORE2
      (IN ROOMS)
      (RDESC1 
"You are in a dimly lit forest, with large trees all around.  To the|
east, there appears to be sunlight.")
      (RDESC2 "Forest")
      (RSEEN? <>)
      (RLIGHT? T)
      (NORTH TO SHOUS)
      (EAST TO CLEAR)
      (SOUTH TO FORE2)
      (WEST TO FORE1)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM KITCH
      (IN ROOMS)
      (RDESC1 <>)
      (RDESC2 "Kitchen")
      (RSEEN? <>)
      (RLIGHT? T)
      (EAST TO EHOUS IF KITCHEN-WINDOW)
      (WEST TO LROOM)
      (EXIT TO EHOUS IF KITCHEN-WINDOW)
      (UP TO ATTIC)
      (DOWN "Only Santa Claus climbs down chimneys.")
      (RACTION KITCHEN)
      (RVARS 0)
      (RVAL 10)>

<ROOM CLEAR
      (IN ROOMS)
      (RDESC1 <>)
      (RDESC2 "Clearing")
      (RSEEN? <>)
      (RLIGHT? T)
      (SW TO EHOUS)
      (NORTH TO CLEAR)
      (EAST TO CLEAR)
      (WEST TO FORE3)
      (SOUTH TO FORE2)
      (DOWN TO MAZ11 IF KEY-FLAG)
      (RACTION CLEARING)
      (RVARS 0)
      (RVAL 0)>

<ROOM LROOM
      (IN ROOMS)
      (RDESC1 <>)
      (RDESC2 "Living Room")
      (RSEEN? <>)
      (RLIGHT? T)
      (EAST TO KITCH)
      (WEST TO BLROO IF MAGIC-FLAG ELSE "The door is nailed shut.")
      (DOWN TO CELLA IF TRAP-DOOR)
      (RACTION LIVING-ROOM)
      (RVARS 0)
      (RVAL 0)>

<ROOM ATTIC
      (IN ROOMS)
      (RDESC1 "You are in the attic.  The only exit is stairs that lead down.")
      (RDESC2 "Attic")
      (RSEEN? <>)
      (RLIGHT? <>)
      (DOWN TO KITCH)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM BLROO
      (IN ROOMS)
      (RDESC1 
"You are in a long passage.  To the south is one entrance.  On the east there|
is an old wooden door, with a large hole in it (about cyclops sized).")
      (RDESC2 "Strange Passage")
      (RSEEN? <>)
      (RLIGHT? <>)
      (SOUTH TO CYCLO-R)
      (EAST TO LROOM)
      (RACTION TIME)            
      (RVARS 0)
      (RVAL 10)>

<ROOM CELLA
      (IN ROOMS)
      (RDESC1 <>)
      (RDESC2 "Cellar")
      (RSEEN? <>)
      (RLIGHT? <>)
      (EAST TO MTROL)
      (SOUTH TO CHAS2)
      (UP "The trap door has been barred from the other side.")
      (WEST "You try to ascend the ramp, but it is impossible, and you slide back down.")
      (RACTION CELLAR)
      (RVARS 0)
      (RVAL 25)>

<ROOM CHAS2
      (IN ROOMS)
      (RDESC1 
"You are on the west edge of a chasm, the bottom of which cannot be|
seen. The east side is sheer rock, providing no exits.  A narrow passage|
goes west, and the path you are on continues to the north and south.")
      (RDESC2 "West of Chasm")
      (RSEEN? <>)
      (RLIGHT? <>)
      (WEST TO CELLA)
      (NORTH TO CRAW4)
      (SOUTH TO GALLE)
      (DOWN "The chasm probably leads straight to the infernal regions.")
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM CRAW4
      (IN ROOMS)
      (RDESC1 
"You are in a north-south crawlway; a passage goes to the east also.|
There is a hole above, but it provides no opportunities for climbing.")
      (RDESC2 "North-South Crawlway")
      (RSEEN? <>)
      (RLIGHT? <>)
      (NORTH TO CHAS2)
      (SOUTH TO STUDI)
      (EAST TO MTROL)
      (UP "Not even a human fly could get up it.")
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM MAZE1
      (IN ROOMS)
      (RDESC1 "You are in a maze of twisty little passages, all alike.")
      (RDESC2 "You are in a maze of twisty little passages, all alike.")
      (RSEEN? <>)
      (RLIGHT? <>)
      (WEST TO MTROL)
      (NORTH TO MAZE1)
      (SOUTH TO MAZE2)
      (EAST TO MAZE4)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM MAZE2
      (IN ROOMS)
      (RDESC1 "You are in a maze of twisty little passages, all alike.")
      (RDESC2 "You are in a maze of twisty little passages, all alike.")
      (RSEEN? <>)
      (RLIGHT? <>)
      (SOUTH TO MAZE1)
      (NORTH TO MAZE4)
      (EAST TO MAZE3)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM MAZE4
      (IN ROOMS)
      (RDESC1 "You are in a maze of twisty little passages, all alike.")
      (RDESC2 "You are in a maze of twisty little passages, all alike.")
      (RSEEN? <>)
      (RLIGHT? <>)
      (WEST TO MAZE3)
      (NORTH TO MAZE1)
      (EAST TO DEAD1)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM MAZE3
      (IN ROOMS)
      (RDESC1 "You are in a maze of twisty little passages, all alike.")
      (RDESC2 "You are in a maze of twisty little passages, all alike.")
      (RSEEN? <>)
      (RLIGHT? <>)
      (WEST TO MAZE2)
      (NORTH TO MAZE4)
      (UP TO MAZE5)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM MAZE5
      (IN ROOMS)
      (RDESC1 "You are in a maze of twisty little passages, all alike.")
      (RDESC2 "You are in a maze of twisty little passages, all alike.")
      (RSEEN? <>)
      (RLIGHT? <>)
      (EAST TO DEAD2)
      (NORTH TO MAZE3)
      (SW TO MAZE6)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM DEAD1
      (IN ROOMS)
      (RDESC1 "Dead end.")
      (RDESC2 "Dead end.")
      (RSEEN? <>)
      (RLIGHT? <>)
      (SOUTH TO MAZE4)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM DEAD2
      (IN ROOMS)
      (RDESC1 "Dead end.")
      (RDESC2 "Dead end.")
      (RSEEN? <>)
      (RLIGHT? <>)
      (WEST TO MAZE5)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM MAZE6
      (IN ROOMS)
      (RDESC1 "You are in a maze of twisty little passages, all alike.")
      (RDESC2 "You are in a maze of twisty little passages, all alike.")
      (RSEEN? <>)
      (RLIGHT? <>)
      (DOWN TO MAZE5)
      (EAST TO MAZE7)
      (WEST TO MAZE6)
      (UP TO MAZE9)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM MAZE7
      (IN ROOMS)
      (RDESC1 "You are in a maze of twisty little passages, all alike.")
      (RDESC2 "You are in a maze of twisty little passages, all alike.")
      (RSEEN? <>)
      (RLIGHT? <>)
      (UP TO MAZ14)
      (WEST TO MAZE6)
      (NE TO DEAD1)
      (EAST TO MAZE8)
      (SOUTH TO MAZ15)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM MAZE9
      (IN ROOMS)
      (RDESC1 "You are in a maze of twisty little passages, all alike.")
      (RDESC2 "You are in a maze of twisty little passages, all alike.")
      (RSEEN? <>)
      (RLIGHT? <>)
      (NORTH TO MAZE6)
      (EAST TO MAZ11)
      (DOWN TO MAZ10)
      (SOUTH TO MAZ13)
      (WEST TO MAZ12)
      (NW TO MAZE9)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM MAZ14
      (IN ROOMS)
      (RDESC1 "You are in a maze of twisty little passages, all alike.")
      (RDESC2 "You are in a maze of twisty little passages, all alike.")
      (RSEEN? <>)
      (RLIGHT? <>)
      (WEST TO MAZ15)
      (NW TO MAZ14)
      (NE TO MAZE7)
      (SOUTH TO MAZE7)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM MAZE8
      (IN ROOMS)
      (RDESC1 "You are in a maze of twisty little passages, all alike.")
      (RDESC2 "You are in a maze of twisty little passages, all alike.")
      (RSEEN? <>)
      (RLIGHT? <>)
      (NE TO MAZE7)
      (WEST TO MAZE8)
      (SE TO DEAD3)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM MAZ15
      (IN ROOMS)
      (RDESC1 "You are in a maze of twisty little passages, all alike.")
      (RDESC2 "You are in a maze of twisty little passages, all alike.")
      (RSEEN? <>)
      (RLIGHT? <>)
      (WEST TO MAZ14)
      (SOUTH TO MAZE7)
      (NE TO CYCLO-R)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM DEAD3
      (IN ROOMS)
      (RDESC1 "Dead end.")
      (RDESC2 "Dead end.")
      (RSEEN? <>)
      (RLIGHT? <>)
      (NORTH TO MAZE8)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM MAZ11
      (IN ROOMS)
      (RDESC1 <>)
      (RDESC2 "You are in a maze of twisty little passages, all alike.")
      (RSEEN? <>)
      (RLIGHT? <>)
      (DOWN TO MAZ10)
      (NW TO MAZ13)
      (SW TO MAZ12)
      (UP TO CLEAR IF KEY-FLAG ELSE "The grating is locked")
      (RACTION MAZE-11)
      (RVARS 0)
      (RVAL 0)>

<ROOM MAZ10
      (IN ROOMS)
      (RDESC1 "You are in a maze of twisty little passages, all alike.")
      (RDESC2 "You are in a maze of twisty little passages, all alike.")
      (RSEEN? <>)
      (RLIGHT? <>)
      (EAST TO MAZE9)
      (WEST TO MAZ13)
      (UP TO MAZ11)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM MAZ13
      (IN ROOMS)
      (RDESC1 "You are in a maze of twisty little passages, all alike.")
      (RDESC2 "You are in a maze of twisty little passages, all alike.")
      (RSEEN? <>)
      (RLIGHT? <>)
      (EAST TO MAZE9)
      (DOWN TO MAZ12)
      (SOUTH TO MAZ10)
      (WEST TO MAZ11)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM MAZ12
      (IN ROOMS)
      (RDESC1 "You are in a maze of twisty little passages, all alike.")
      (RDESC2 "You are in a maze of twisty little passages, all alike.")
      (RSEEN? <>)
      (RLIGHT? <>)
      (WEST TO MAZE5)
      (SW TO MAZ11)
      (EAST TO MAZ13)
      (UP TO MAZE9)
      (NORTH TO DEAD4)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM DEAD4
      (IN ROOMS)
      (RDESC1 "Dead end.")
      (RDESC2 "Dead end.")
      (RSEEN? <>)
      (RLIGHT? <>)
      (SOUTH TO MAZ12)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM CYCLO-R         ;"Was CYCLO"
      (IN ROOMS)
      (RDESC1 <>)
      (RDESC2 "Cyclops Room")
      (RSEEN? <>)
      (RLIGHT? <>)
      (WEST TO MAZ15)
      (NORTH TO BLROO IF MAGIC-FLAG ELSE "The north wall is solid rock.")
      (UP TO TREAS-R IF CYCLOPS-FLAG ELSE "The cyclops doesn't look like he'll let you past.")
      (RACTION CYCLOPS-ROOM)
      (RVARS 0)
      (RVAL 0)>

<ROOM RESES
      (IN ROOMS)
      (RDESC1 <>)
      (RDESC2 "Reservoir South")
      (RSEEN? <>)
      (RLIGHT? <>)
      (SOUTH TO RAVI1 IF EGYPT-FLAG ELSE "The coffin will not fit through this passage.")
      (WEST TO STREA)
      (CROSS TO RESEN IF LOW-TIDE ELSE "You are not equipped for swimming.")
      (NORTH TO RESEN IF LOW-TIDE ELSE "You are not equipped for swimming.")
      (UP TO CANY1 IF EGYPT-FLAG ELSE "The stairs are too steep for carrying the coffin.")
      (RACTION RESERVOIR-SOUTH)
      (RVARS 0)
      (RVAL 0)>
                  
<ROOM CHAS1
      (IN ROOMS)
      (RDESC1 
"A chasm runs southwest to northeast.  You are on the south edge; the|
path exits to the south and to the east.")
      (RDESC2 "Chasm")
      (RSEEN? <>)
      (RLIGHT? <>)
      (SOUTH TO RAVI1)
      (EAST TO PASS5)
      (DOWN "Are you out of your mind?")
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM CRAW1
      (IN ROOMS)
      (RDESC1 
"You are in a crawlway with a three-foot high ceiling.  Your footing is|
very unsure here due to the assortment of rocks underfoot.  Passages can be|
seen in the east, west, and northwest corners of the passage.")
      (RDESC2 "Rocky Crawl")
      (RSEEN? <>)
      (RLIGHT? <>)
      (WEST TO RAVI1)
      (EAST TO DOME)
      (NW TO EGYPT)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM DOME
      (IN ROOMS)
      (RDESC1 <>)
      (RDESC2 "Dome Room")
      (RSEEN? <>)
      (RLIGHT? <>)
      (EAST TO CRAW1)
      (DOWN TO MTORC IF DOME-FLAG ELSE "You cannot go down without fracturing many bones.")
      (CLIMB TO MTORC IF DOME-FLAG ELSE "You cannot go down without fracturing many bones.")
      (RACTION DOME-ROOM)
      (RVARS 0)
      (RVAL 0)>

<ROOM EGYPT
      (IN ROOMS)
      (RDESC1 "You are in a room which looks like an Egyptian tomb.")
      (RDESC2 "Egyptian Room")
      (RSEEN? <>)
      (RLIGHT? <>)
      (UP TO ICY)
      (EAST TO CRAW1 IF EGYPT-FLAG ELSE "The passage is too narrow to accomodate coffins.")
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM RESEN
      (IN ROOMS)
      (RDESC1 <>)
      (RDESC2 "Reservoir North")
      (RSEEN? <>)
      (RLIGHT? <>)
      (NORTH TO ATLAN)
      (CROSS TO RESES IF LOW-TIDE ELSE "You are not equipped for swimming.")
      (SOUTH TO RESES IF LOW-TIDE ELSE "You are not equipped for swimming.")
      (RACTION RESERVOIR-NORTH)
      (RVARS 0)
      (RVAL 0)>

<ROOM CANY1
      (IN ROOMS)
      (RDESC1 
"You are along the south edge of a deep canyon.  Passages lead off|
to the east, south, and southeast.  You can here the sound of|
flowing water below.")
      (RDESC2 "Deep Canyon")
      (RSEEN? <>)
      (RLIGHT? <>)
      (SE TO RESES)
      (EAST TO DAM-R)
      (SOUTH TO CAROU)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM STREA
      (IN ROOMS)
      (RDESC1 
"You are standing on a path alongside a flowing stream.  The path|
travels to the north and the east.")
      (RDESC2 "Stream")
      (RSEEN? <>)
      (RLIGHT? <>)
      (EAST TO RESES)
      (NORTH TO ICY)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM ATLAN
      (IN ROOMS)
      (RDESC1 "You are in an ancient room, long buried by the Reservoir.")
      (RDESC2 "Atlantis Room")
      (RSEEN? <>)
      (RLIGHT? <>)
      (SE TO RESEN)
      (UP TO CAVE1)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM ICY
      (IN ROOMS)
      (RDESC1 <>)
      (RDESC2 "Glacier Room")
      (RSEEN? <>)
      (RLIGHT? <>)
      (NORTH TO STREA)
      (EAST TO EGYPT)
      (WEST TO RUBYR IF GLACIER-FLAG)
      (RACTION GLACIER-ROOM)
      (RVARS 0)
      (RVAL 0)>

<ROOM RUBYR
      (IN ROOMS)
      (RDESC1 
"You are in a small chamber behind the remains of the Great Glacier.")
      (RDESC2 "Ruby Room")
      (RSEEN? <>)
      (RLIGHT? <>)
      (SOUTH TO ICY)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM CAVE1
      (IN ROOMS)
      (RDESC1 
"You are in a small cave with an entrance to the north and a stairway|
leading down.")
      (RDESC2 "Cave")
      (RSEEN? <>)
      (RLIGHT? <>)
      (NORTH TO MIRR1)
      (DOWN TO ATLAN)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM DAM-R             ;"Was DAM"
      (IN ROOMS)
      (RDESC1 <>)
      (RDESC2 "Dam")
      (RSEEN? <>)
      (RLIGHT? <>)
      (SOUTH TO CANY1)
      (EAST TO CAVE3)
      (NORTH TO LOBBY)
      (RACTION DAM-ROOM)
      (RVARS 0)
      (RVAL 0)>

<ROOM CHAS3
      (IN ROOMS)
      (RDESC1 
"A chasm, evidently produced by an ancient river, runs through the|
cave here.  Passages lead off in all directions.")
      (RDESC2 "Ancient Chasm")
      (RSEEN? <>)
      (RLIGHT? <>)
      (SOUTH TO ECHO)
      (EAST TO CHAS3)
      (NORTH TO DEAD5)
      (WEST TO DEAD6)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM PASS5
      (IN ROOMS)
      (RDESC1 
"You are in a high north-south passage, which forks to the northeast.")
      (RDESC2 "North-South Passage")
      (RSEEN? <>)
      (RLIGHT? <>)
      (NORTH TO CHAS1)
      (NE TO ECHO)
      (SOUTH TO CAROU)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM CAVE3
      (IN ROOMS)
      (RDESC1 
"You are in a cave.  Passages exit to the south and to the east, but the|
cave narrows to a tiny crack to the west.  The earth is particularly|
damp here.")
      (RDESC2 "Damp Cave")
      (RSEEN? <>)
      (RLIGHT? <>)
      (SOUTH TO ECHO)
      (EAST TO DAM-R)
      (WEST "It is too narrow for most insects.")
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM ECHO
      (IN ROOMS)
      (RDESC1 
"You are in a large room with a ceiling which cannot be detected from|
the ground. There is a narrow passage from east to west and a stone|
stairway leading upward.  The room is extremely noisy.  In fact, it is|
difficult to hear yourself think.")
      (RDESC2 "Loud Room")
      (RSEEN? <>)
      (RLIGHT? <>)
      (EAST TO CHAS3)
      (WEST TO PASS5)
      (UP TO CAVE3)
      (RACTION ECHO-ROOM)
      (RVARS 0)
      (RVAL 0)>

<ROOM PASS3
      (IN ROOMS)
      (RDESC1 
"You are in a cold and damp corridor where a long east-west passageway|
intersects with a northward path.")
      (RDESC2 "Cold Passage")
      (RSEEN? <>)
      (RLIGHT? <>)
      (EAST TO MIRR1)
      (WEST TO SLIDE)
      (NORTH TO CRAW2)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM CRAW2
      (IN ROOMS)
      (RDESC1 
"You are in a steep and narrow crawlway.  There are two exits nearby to|
the south and southwest.")
      (RDESC2 "Steep Crawlway")
      (RSEEN? <>)
      (RLIGHT? <>)
      (SOUTH TO MIRR1)
      (SW TO PASS3)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM MIRR1
      (IN ROOMS)
      (RDESC1 <>)
      (RDESC2 "Mirror Room")
      (RSEEN? <>)
      (RLIGHT? <>)
      (WEST TO PASS3)
      (NORTH TO CRAW2)
      (EAST TO CAVE1)
      (RACTION MIRROR-ROOM)
      (RVARS 0)
      (RVAL 0)>

<ROOM PASS4
      (IN ROOMS)
      (RDESC1 
"You are in a winding passage.  It seems that there is only an exit on the|
east end although the whirring from the carousel room can be heard faintly|
to the north.")
      (RDESC2 "Winding Passage")
      (RSEEN? <>)
      (RLIGHT? <>)
      (EAST TO MIRR2)
      (NORTH "You can hear the whir of the carousel room here but can find no entrance.")
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM CRAW3
      (IN ROOMS)
      (RDESC1 
"You are in a narrow crawlway.  The crawlway leads from north to south.|
However the south passage divides to the south and southwest.")
      (RDESC2 "Narrow Crawlway")
      (RSEEN? <>)
      (RLIGHT? <>)
      (SOUTH TO CAVE2)
      (SW TO MIRR2)
      (NORTH TO MGRAI)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM CAVE2
      (IN ROOMS)
      (RDESC1 
"You are in a tiny cave with entrances west and north, and a dark,|
forbidding staircase leading down.")
      (RDESC2 "Cave")
      (RSEEN? <>)
      (RLIGHT? <>)
      (NORTH TO CRAW3)
      (WEST TO MIRR2)
      (DOWN TO LLD1)
      (RACTION CAVE2-ROOM)
      (RVARS 0)
      (RVAL 0)>

<ROOM MIRR2
      (IN ROOMS)
      (RDESC1 <>)
      (RDESC2 "Mirror Room")
      (RSEEN? <>)
      (RLIGHT? T)
      (WEST TO PASS4)
      (NORTH TO CRAW3)
      (EAST TO CAVE2)
      (RACTION MIRROR-ROOM)
      (RVARS 0)
      (RVAL 0)>

<ROOM LLD1
      (IN ROOMS)
      (RDESC1 <>)
      (RDESC2 "Entrance to Hades")
      (RSEEN? <>)
      (RLIGHT? T)
      (EAST TO LLD2 IF LLD-FLAG ELSE "Some invisible force prevents you from passing through the gate.")
      (UP TO CAVE2)
      (ENTER TO LLD2 IF LLD-FLAG ELSE "Some invisible force prevents you from passing through the gate.")
      (RACTION LLD-ROOM)
      (RVARS 0)
      (RVAL 0)>

<ROOM MGRAI
      (IN ROOMS)
      (RDESC1
"You are standing in a small circular room with a pedestal.  A set of|
stairs leads up, and passages leave to the east and west.")
      (RDESC2 "Grail Room")
      (RSEEN? <>)
      (RLIGHT? <>)
      (WEST TO CAROU)
      (EAST TO CRAW3)
      (UP TO TEMP1)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM SLIDE
      (IN ROOMS)
      (RDESC1
"You are in a small chamber, which appears to have been part of a coal|
mine. On the south wall of the chamber the letters \"Granite Wall\" are|
etched in the rock. To the east is a long passage and there is a steep|
metal slide twisting downward. From the appearance of the slide, an|
attempt to climb up it would be impossible.")
      (RDESC2 "Slide Room")
      (RSEEN? <>)
      (RLIGHT? <>)
      (EAST TO PASS3)
      (DOWN TO CELLA)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM MTORC
      (IN ROOMS)
      (RDESC1 <>)
      (RDESC2 "Torch Room")
      (RSEEN? <>)
      (RLIGHT? <>)
      (WEST TO MTORC)
      (DOWN TO CRAW4)
      (RACTION TORCH-ROOM)
      (RVARS 0)
      (RVAL 0)>

<ROOM STUDI
      (IN ROOMS)
      (RDESC1 
"You are in what appears to have been an artist's studio.  The walls and|
floors are splattered with paints of 69 different colors.  Strangely|
enough, nothing of value is hanging here.  At the north and northwest of|
the room are open doors (also covered with paint).  An extremely dark|
and narrow chimney leads up from a fireplace; although you might be able|
to get up it, it seems unlikely you could get back down.")
      (RDESC2 "Studio")
      (RSEEN? <>)
      (RLIGHT? <>)
      (NORTH TO CRAW4)
      (NW TO GALLE)
      (UP TO KITCH IF LIGHT-LOAD ELSE "The chimney is too narrow for you and all of your baggage.")
      (RACTION STUDIO-FUNCTION)
      (RVARS 0)
      (RVAL 0)>

<ROOM GALLE
      (IN ROOMS)
      (RDESC1 
"You are in an art gallery (apparently the painter generated more than|
mess).  Most of the paintings which were here have been stolen by|
vandals with exceptional taste.  The vandals left through either the|
north or south exits.")
      (RDESC2 "Gallery")
      (RSEEN? <>)
      (RLIGHT? T)
      (NORTH TO CHAS2)
      (SOUTH TO STUDI)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM CAVE4
      (IN ROOMS)
      (RDESC1 
"You have entered a cave with passages leading north and southeast.  There|
are old engravings on the walls here.")
      (RDESC2 "Engravings Cave")
      (RSEEN? <>)
      (RLIGHT? <>)
      (NORTH TO CAROU)
      (SE TO RIDDL)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM DEAD5
      (IN ROOMS)
      (RDESC1 "Dead end")
      (RDESC2 "Dead end")
      (RSEEN? <>)
      (RLIGHT? <>)
      (SW TO CHAS3)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM DEAD6
      (IN ROOMS)
      (RDESC1 "Dead end")
      (RDESC2 "Dead end")
      (RSEEN? <>)
      (RLIGHT? <>)
      (EAST TO CHAS3)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM RIDDL
      (IN ROOMS)
      (RDESC1 
"This is a room which is bare on all sides.  There is an exit down.  To the east is a|
great door made of stone.  Above the stone, the following words are written:|
'No man shall enter this room without solving this riddle:|
  What is tall as a house,|
          round as a cup,|
          and all the king's horses can't draw it up?'")
      (RDESC2 "Riddle Room")
      (RSEEN? <>)
      (RLIGHT? <>)
      (DOWN TO CAVE4)
      (EAST TO MPEAR IF RIDDLE-FLAG ELSE "Your way is blocked by an invisible force.")
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM MPEAR
      (IN ROOMS)
      (RDESC1 
"This is a room the size of a broom closet which appears to be|
a dead end.  The only exit is to the west.")
      (RDESC2 "Pearl Room")
      (RSEEN? <>)
      (RLIGHT? <>)
      (EXIT TO RIDDL)
      (WEST TO RIDDL)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM LLD2
      (IN ROOMS)
      (RDESC1 
"You have entered the Land of the Living Dead, a large desolate room.|
Although it is apparently uninhabited, you can hear the sounds of|
thousands of lost souls weeping and moaning.  In the east corner are|
stacked the remains of dozens of previous adventurers who were less|
fortunate than yourself (so far).")
      (RDESC2 "Land of the Living Dead")
      (RSEEN? <>)
      (RLIGHT? T)
      (EXIT TO LLD1)
      (WEST TO LLD1)
      (RACTION <>)
      (RVARS 0)
      (RVAL 30)>

<ROOM TEMP1
      (IN ROOMS)
      (RDESC1 
"You are in the west end of a large temple.  On the south wall is an|
ancient inscription, probably a prayer in a long-forgotten language.|
The north wall is granite.  The entrance at the west end of the room is|
through huge marble pillars.")
      (RDESC2 "Temple")
      (RSEEN? <>)
      (RLIGHT? T)
      (WEST TO MGRAI)
      (EAST TO TEMP2)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM TEMP2
      (IN ROOMS)
      (RDESC1 
"You are in the east end of a large temple.  In front of you is what|
appears to be an altar.")
      (RDESC2 "Altar")
      (RSEEN? <>)
      (RLIGHT? T)
      (WEST TO TEMP1)
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM LOBBY
      (IN ROOMS)
      (RDESC1 
"This room appears to have been the waiting room for groups touring|
the dam.  There are exits here to the north and east marked 'Private',|
though the doors are open, and an exit to the south.")
      (RDESC2 "Dam Lobby")
      (RSEEN? <>)
      (RLIGHT? T)
      (SOUTH TO DAM-R)
      (NORTH TO MAINT IF NOT-DROWNED ELSE "The room is full of water:  if you enter, you'll drown.")
      (EAST TO MAINT IF NOT-DROWNED ELSE "The room is full of water:  if you enter, you'll drown.")
      (RACTION <>)
      (RVARS 0)
      (RVAL 0)>

<ROOM MAINT
      (IN ROOMS)
      (RDESC1 
"You are in what appears to have been the maintenance room for Flood|
Control Dam #3, judging by the assortment of tool chests around the|
room.  Apparently, this room has been ransacked recently, for most of|
the valuable equipment is gone. On the wall in front of you is a panel|
of buttons, which are labelled in EBCDIC. However, they are of different|
color: Red, Brown, Yellow, and Blue. The doors to this room are in the|
west and south ends.")
      (RDESC2 "Maintenance Room")
      (RSEEN? <>)
      (RLIGHT? <>)
      (SOUTH TO LOBBY)
      (WEST TO LOBBY)
      (RACTION MAINT-ROOM)
      (RVARS 0)
      (RVAL 0)>

<ROOM TREAS-R           ;"Was TREAS"
      (IN ROOMS)
      (RDESC1 
"This is a large room, whose north wall is solid granite.  A number of|
discarded bags, which crumble at your touch, are scattered about on the|
floor.")
      (RDESC2 "Treasure Room")
      (RSEEN? <>)
      (RLIGHT? <>)
      (DOWN TO CYCLO-R)
      (RACTION TREASURE-ROOM)
      (RVARS 0)
      (RVAL 25)>

;"OBJECT DEFINITIONS
  The order they are defined affects the order they will be listed in room 
  description when untouched."
  
<OBJECT WINDO 
    (IN EHOUS)
    (SYNONYM WINDO)
    (ODESC1 <>)
    (ODESC2 <>)
    (ODESC0 <>)
    (OACTION OBJECT-ZORK)
    (OFLAGS 0)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT FOOD 
    (IN KITCH)
    (SYNONYM FOOD SANDW LUNCH DINNE SNACK PEPPE SACK)
    (ODESC1 "Sack smelling of hot peppers, is here.")
    (ODESC2 ".lunch")
    (ODESC0 "On the table is a elongated brown sack, smelling of hot peppers.")
    (OACTION <>)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>
    
<OBJECT BOTTL 
    (IN KITCH)
    (SYNONYM BOTTL CONTA PITCH)
    (ODESC1 "A clear glass bottle is here.")
    (ODESC2 "bottle")
    (ODESC0 "A bottle is sitting on the table.")
    (OACTION BOTTLE-FUNCTION)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT TROPH 
    (IN LROOM)
    (SYNONYM TROPH CASE)
    (ODESC1 "There is a trophy case here.")
    (ODESC2 "trophy case")
    (ODESC0 <>)
    (OACTION TROPHY-CASE)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT WATER 
    (IN BOTTL)
    (SYNONYM WATER LIQUI H2O)
    (ODESC1 "Water")
    (ODESC2 "water")
    (ODESC0 "There is some water here")
    (OACTION WATER-FUNCTION)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT ROPE 
    (IN ATTIC)
    (SYNONYM ROPE HEMP COIL)
    (ODESC1 "There is a large coil of rope here.")
    (ODESC2 "rope")
    (ODESC0 "A large coil of rope is lying in the corner.")
    (OACTION ROPE-FUNCTION)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT KNIFE
    (IN ATTIC)
    (SYNONYM KNIFE BLADE)
    (ODESC1 "There is a nasty-looking knife lying here.")
    (ODESC2 "knife")
    (ODESC0 "On a table is a nasty-looking knife.")
    (OACTION <>)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT DOOR
    (IN LROOM)
    (SYNONYM DOOR TRAPD TRAP- PORTA)
    (ODESC1 <>)
    (ODESC2 <>)
    (ODESC0 <>)
    (OACTION OBJECT-ZORK)
    (OFLAGS 0)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT LAMP
    (IN LROOM)
    (SYNONYM LAMP LANTE)
    (ODESC1 "There is a brass lantern here.")
    (ODESC2 "lamp")
    (ODESC0 "A brass lantern is on the trophy case.")
    (OACTION LANTERN)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? -1)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT RUG
    (IN LROOM)
    (SYNONYM RUG ORIEN CARPE)
    (ODESC1 <>)
    (ODESC2 "carpet")
    (ODESC0 <>)
    (OACTION RUG-F)         ;"Was RUG"
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT PILE 
    (IN CLEAR)
    (SYNONYM PILE LEAF GREEN LEAVE PLANT)
    (ODESC1 "There is a pile of leaves on the ground.")
    (ODESC2 "pile of leaves")
    (ODESC0 "There is a pile of leaves on the ground.")
    (OACTION <>)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT TROLL
    (IN MTROL)
    (SYNONYM TROLL)
    (ODESC1 
"A nasty-looking troll, brandishing a bloody axe, blocks all passages|
out of the room.")
    (ODESC2 <>)
    (ODESC0 <>)
    (OACTION TROLL-F)           ;"Was TROLL"
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT BONES
    (IN MAZE5)
    (SYNONYM BONES BODY SKELE)
    (ODESC1 "A skeleton is lying here, beside a burned-out lantern and a rusty knife.")
    (ODESC2 <>)
    (ODESC0 <>)
    (OACTION SKELETON)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT KEYS
    (IN MAZE5)
    (SYNONYM KEYS)
    (ODESC1 "There is a set of skeleton keys here.")
    (ODESC2 "set of skeleton keys")
    (ODESC0 <>)
    (OACTION <>)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT BAGCO
    (IN MAZE5)
    (SYNONYM BAGCO BAG COINS)
    (ODESC1 "An old leather bag, bulging with coins, is here.")
    (ODESC2 "bag of coins")
    (ODESC0 <>)
    (OACTION <>)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 10)
    (OTVAL 5)
    (ORAND <>)
    (OREAD <>)>

<OBJECT BAR
    (IN ECHO)
    (SYNONYM BAR PLATI)
    (ODESC1 "There is a large platinum bar here.")
    (ODESC2 "platinum bar")
    (ODESC0 <>)
    (OACTION <>)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 12)
    (OTVAL 10)
    (ORAND <>)
    (OREAD <>)>
    
<OBJECT PEARL
    (IN MPEAR)
    (SYNONYM PEARL NECKL)
    (ODESC1 "There is a pearl necklace here with hundreds of large pearls.")
    (ODESC2 "pearl necklace")
    (ODESC0 <>)
    (OACTION <>)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 9)
    (OTVAL 5)
    (ORAND <>)
    (OREAD <>)>

<OBJECT GRATE
    (IN CLEAR)
    (SYNONYM GRATE GRATI)
    (ODESC1 <>)
    (ODESC2 <>)
    (ODESC0 <>)
    (OACTION OBJECT-ZORK)
    (OFLAGS 0)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT TRUNK
    (IN RESES)
    (SYNONYM TRUNK CHEST JEWEL)
    (ODESC1 "There is an old trunk here, bulging with assorted jewels.")
    (ODESC2 "trunk with jewels")
    (ODESC0 "Lying half buried in the mud is an old trunk, bulging with jewels.")
    (OACTION <>)
    (OFLAGS 0)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 15)
    (OTVAL 8)
    (ORAND <>)
    (OREAD <>)>

<OBJECT COFFI
    (IN EGYPT)
    (SYNONYM COFFI CASKE)
    (ODESC1 "There is a solid-gold (heavy) coffin, used for the burial of Ramses II, here.")
    (ODESC2 "gold coffin")
    (ODESC0 <>)
    (OACTION COFFIN)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 3)
    (OTVAL 7)
    (ORAND <>)
    (OREAD <>)>

<OBJECT ICE 
    (IN ICY)
    (SYNONYM ICE GLACI)
    (ODESC1 "A mass of ice fills the western half of the room.")
    (ODESC2 <>)
    (ODESC0 <>)
    (OACTION GLACIER)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT REFLE
    (IN MIRR2)
    (SYNONYM REFLE MIRRO)
    (ODESC1 <>)
    (ODESC2 <>)
    (ODESC0 <>)
    (OACTION MIRROR-MIRROR)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT GHOST 
    (IN LLD1)
    (SYNONYM GHOST SPIRI FIEND)
    (ODESC1 <>)
    (ODESC2 <>)
    (ODESC0 <>)
    (OACTION GHOST-FUNCTION)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT RUBY 
    (IN RUBYR)
    (SYNONYM RUBY)
    (ODESC1 "There is a moby ruby lying on the floor.")
    (ODESC2 "ruby")
    (ODESC0 <>)
    (OACTION <>)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 15)
    (OTVAL 8)
    (ORAND <>)
    (OREAD <>)>
    
<OBJECT TRIDE 
    (IN ATLAN)
    (SYNONYM TRIDE DIAMO FORK)
    (ODESC1 "Neptune's own diamond trident is here.")
    (ODESC2 "diamond trident")
    (ODESC0 "On the shore lies Neptune's own diamond trident.")
    (OACTION <>)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 4)
    (OTVAL 11)
    (ORAND <>)
    (OREAD <>)>

<OBJECT TORCH 
    (IN MTORC)
    (SYNONYM TORCH FIRE FLAME IVORY)
    (ODESC1 "There is an ivory torch here.")
    (ODESC2 "torch")
    (ODESC0 "Sitting on the pedestal is a flaming torch, made of ivory.")
    (OACTION <>)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 1)
    (OFVAL 14)
    (OTVAL 6)
    (ORAND <>)
    (OREAD <>)>

<OBJECT GRAIL 
    (IN MGRAI)
    (SYNONYM GRAIL)
    (ODESC1 "There is an extremely valuable (perhaps original) grail here.")
    (ODESC2 "grail")
    (ODESC0 <>)
    (OACTION <>)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 1)
    (OFVAL 2)
    (OTVAL 5)
    (ORAND <>)
    (OREAD <>)>

<OBJECT BELL 
    (IN TEMP1)
    (SYNONYM BELL)
    (ODESC1 "There is a small brass bell here.")
    (ODESC2 "bell")
    (ODESC0 "Lying in a corner of the room is a small brass bell.")
    (OACTION <>)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT BOOK 
    (IN TEMP2)
    (SYNONYM BOOK)
    (ODESC1 "There is a large black book here.")
    (ODESC2 "book")
    (ODESC0 "On the altar is a large black book, open to page 569.")
    (OACTION <>)
    (OFLAGS 3)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD 
"               COMMANDMENT #12592|
Say to all ye who go about on the face of our land|
intoning unto all ye meet:   \"Hello sailor\",|
now and even unto the ends of the earth. For verily|
by the wrath of the gods shalt thou repent thy sin.|
And surely thy eye shall be put out with a sharp stick.|
Depart hence thou monster with bad breath.")>

<OBJECT CANDL 
    (IN TEMP2)
    (SYNONYM CANDL)
    (ODESC1 "There are two candles here.")
    (ODESC2 "pair of candles")
    (ODESC0 "On the two sides of the black book are burning candles.")
    (OACTION CANDLES)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 1)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT DAM 
    (IN DAM-R)
    (SYNONYM DAM SLUIC GATES GATE)
    (ODESC1 <>)
    (ODESC2 <>)
    (ODESC0 <>)
    (OACTION OBJECT-ZORK)
    (OFLAGS 0)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT BOLT 
    (IN DAM-R)
    (SYNONYM BOLT NUT)
    (ODESC1 <>)
    (ODESC2 <>)
    (ODESC0 <>)
    (OACTION OBJECT-ZORK)
    (OFLAGS 0)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT BUBBL 
    (IN DAM-R)
    (SYNONYM BUBBL)
    (ODESC1 <>)
    (ODESC2 <>)
    (ODESC0 <>)
    (OACTION OBJECT-ZORK)
    (OFLAGS 0)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT MATCH 
    (IN LOBBY)
    (SYNONYM MATCH FLINT)
    (ODESC1 "There is a matchbook whose cover says 'Visit Beautiful FCD#3' here.")
    (ODESC2 "matchbook")
    (ODESC0 <>)
    (OACTION <>)
    (OFLAGS 3)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD "")>

<OBJECT GUIDE 
    (IN LOBBY)
    (SYNONYM GUIDE)
    (ODESC1 "There are tour guidebooks here.")
    (ODESC2 "guidebook")
    (ODESC0 "Some guidebooks entitled 'Flood Control Dam #3' are on reception desk.")
    (OACTION <>)
    (OFLAGS 3)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD 
"\"                Guide Book to|
                Flood Control Dam #3|
|
  Flood Control Dam #3 (FCD#3) was constructed in year 783|
of the Great Underground Empire to harness the destructive|
power of the Frigid River.  This work was supported by a grant|
of 37 million zorkmids from the Central Bureaucracy and|
your omnipotent local tyrant Lord Dimwit Flathead the Excessive.|
This impressive structure is composed of 3.7 cubic feet|
of concrete, is 256 feet tall from the center, and 193 feet|
wide at the top.  The reservoir created behind the dam has|
a volume of 37 million cubic feet, an area of 12 million|
square feet, and a shore line of 3.6 million feet.|
  The construction of FCD#3 took 112 days from ground|
breaking to the dedication. It required a work force of|
384 slaves, 34 slave drivers, 12 engineers, 2 turtle doves,|
and a partridge in a pear tree. The work was managed by|
a command team composed of 2345 bureaucrats, 2347 secretaries|
(at least two of which can type), 12,256 paper shufflers,|
52,469 rubber stampers, 245,193 red tape processors, and|
nearly one million dead trees.|
  We will now point out some of the more interesting features|
of FCD#3 as we conduct you on a guided tour of the facilities:|
        1) You start your tour here in the Dam Lobby.|
           You will notice on your right that .........")>

<OBJECT BUTTO
    (IN MAINT)
    (SYNONYM BUTTO SWITC)
    (ODESC1 <>)
    (ODESC2 <>)
    (ODESC0 <>)
    (OACTION OBJECT-ZORK)
    (OFLAGS 0)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)   
    (ORAND <>)
    (OREAD <>)>

<OBJECT LEAK
    (IN MAINT)
    (SYNONYM LEAK HOLE DRIP)
    (ODESC1 <>)
    (ODESC2 <>)
    (ODESC0 <>)
    (OACTION OBJECT-ZORK)
    (OFLAGS 0)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)   
    (ORAND <>)
    (OREAD <>)>

;"Add these as adjectives. In the original they are only defined as ATOMs 
  in the OBJECTS OBLIST."
<VOC "RED" ADJECTIVE>
<VOC "BLUE" ADJECTIVE>
<VOC "YELLO" ADJECTIVE>
<VOC "BROWN" ADJECTIVE>

<OBJECT SCREW
    (IN MAINT)
    (SYNONYM SCREW)
    (ODESC1 "There is a screwdriver here.")
    (ODESC2 "screwdriver")
    (ODESC0 <>)
    (OACTION <>)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)>

<OBJECT WRENC
    (IN MAINT)
    (SYNONYM WRENC)
    (ODESC1 "There is a wrench here.")
    (ODESC2 "wrench")
    (ODESC0 <>)
    (OACTION <>)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)   
    (ORAND <>)
    (OREAD <>)>

<OBJECT PUTTY
    (IN MAINT)
    (SYNONYM PUTTY TUBE GUNK)
    (ODESC1 "There is an object which looks like a tube of toothpaste here.")
    (ODESC2 "tube")
    (ODESC0 <>)
    (OACTION <>)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)   
    (ORAND <>)
    (OREAD <>)>

<OBJECT CYCLO 
    (IN CYCLO-R)
    (SYNONYM CYCLO MONST ONE-E)
    (ODESC1 <>)
    (ODESC2 <>)
    (ODESC0 <>)
    (OACTION CYCLOPS)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)   
    (ORAND <>)
    (OREAD <>)>

<OBJECT CHALI
    (IN TREAS-R)
    (SYNONYM CHALI CUP GOBLE)
    (ODESC1 "There is a silver chalice, intricately engraved, here.")
    (ODESC2 "chalice")
    (ODESC0 <>)
    (OACTION <>)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 10)
    (OTVAL 10)  
    (ORAND <>)
    (OREAD <>)>

<OBJECT PAINT 
    (IN GALLE)
    (SYNONYM PAINT ART MASTE CANVA)
    (ODESC1 "A masterpiece by a neglected genius is here.")
    (ODESC2 "painting")
    (ODESC0 
"Fortunately, there is still one chance for you to be a vandal, for on|
the far wall is a work of unparalleled beauty.")
    (OACTION <>)
    (OFLAGS 1)
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 4)
    (OTVAL 7)   
    (ORAND <>)
    (OREAD <>)>

;"LISTS OF CRUFT:  WEAPONS, AND IMMOVABLE OBJECTS"

<GLOBAL DEMONS 
    <LTABLE ROBBER>>

<OBJECT THIEF
    (IN CAROU)  ;"Start. Thief should be in MPEAR after 5 moves."
    (SYNONYM THIEF MAN ROBBE THUG BANDI CRIME CROOK MAFIA BAGMA SHADY CRIMI)
    (ODESC1 
"There is a suspicious-looking individual, holding a bag, leaning against|
one wall.")
    (ODESC2 <>)
    (ODESC0 <>)
    (OACTION ROBBER-FUNCTION)
    (OFLAGS 0)  ;"Thief moves around invisible"
    (OTOUCH? <>)
    (OLIGHT? 0)
    (OFVAL 0)
    (OTVAL 0)
    (ORAND <>)
    (OREAD <>)> 

<GLOBAL RANDOM-LIST
  <LTABLE (PURE) LROOM KITCH CLEAR FORE3 FORE2 SHOUS FORE2 KITCH EHOUS>>

;"VERBS"

<SYNTAX JUMP = LEAPER>
<SYNONYM JUMP VAULT LEAP>

<SYNTAX MUNG = ACT-HACK>
<SYNONYM MUNG BREAK POKE ATTAC DAMAG INJUR FROB JAB CLOBB KICK TAUNT HIT BITE KILL HURT HACK>

<SYNTAX LOOK = ROOM-DESC>
<SYNONYM LOOK DESCR>

<SYNTAX TAKE = TAKE>
<SYNONYM TAKE GET CARRY HOLD>

<SYNTAX THROW = DROP>
<SYNONYM THROW CHUCK HURL>

<SYNTAX WALK = WALK>
<SYNONYM WALK GO RUN>

<SYNTAX WELL = WELL>

<SYNTAX PRAY = PRAYER>

<SYNTAX UNTIE = ACT-HACK>
<SYNONYM UNTIE FREE RELEA>

<SYNTAX GIVE = DROP>
<SYNONYM GIVE DONAT HAND>

<SYNTAX PUSH = ACT-HACK>
<SYNONYM PUSH PRESS SHOVE>

<SYNTAX MOVE = MOVE>
<SYNONYM MOVE PULL LIFT>

<SYNTAX ON = LAMP-ON>
<SYNONYM ON LIGHT>

<SYNTAX POUR = DROP>
<SYNONYM POUR SPILL>

<SYNTAX OFF = LAMP-OFF>
<SYNONYM OFF EXTIN>

<SYNTAX READ = READER>
<SYNONYM READ SCAN SKIM>

<SYNTAX FILL = FILL>

<SYNTAX RUB = ACT-HACK>
<SYNONYM RUB FONDL CARES TOUCH>

<SYNTAX QUIT = FINISH>

<SYNTAX SCORE = SCORE>

<SYNTAX WAVE = ACT-HACK>

<SYNTAX PLUG = ACT-HACK>
<SYNONYM PLUG STOP CORK PATCH CLOSE>

<SYNTAX TREAS = TREAS>

<SYNTAX SINBA = SINBAD>

<SYNTAX EXORC = ACT-HACK>
<SYNONYM EXORC XORCI>

<SYNTAX TEMPL = TREAS>

<SYNTAX TIE = ACT-HACK>
<SYNONYM TIE KNOT>

<SYNTAX INVEN = INVENT>
<SYNONYM INVEN LIST>

<SYNTAX HELP = HELP>

<SYNTAX INFO = INFO>

<SYNTAX OPEN = ACT-HACK>

<SYNTAX DROP = DROP>

;"Special verb used internally to fire a RACTION when entering a room.
  Because it's longer than 5 chars, the player can't trigger it with
  input."
<SYNTAX WALK-IN = TIME>    

;"Much simpler than in MDL. Basically only accumulates the score.
  AROOM are barely used."
<OBJECT WINNER
    (AROOM <>)
    (ASCORE 0)>

;"VOCABULARY, ACTION FUNCTIONS, MAZE (NORMALLY ENCODED)"

;"ROOM FUNCTIONS"

<ROUTINE EAST-HOUSE ("AUX" (PRSACT <1 ,PRSVEC>) (OBJ <2 ,PRSVEC>))
    <DOOR-FIX>
    <COND (<AND <W=? .PRSACT ,W?LOOK> <OR <NOT ,PATCHED> <LIT? ,HERE>>>
            <OR ,PATCHED <CRLF>>
            <AND <NOT ,PATCHED> <W=? .OBJ ,W?EAST> <GETP ,HERE ,P?RSEEN?> <CRLF>> ;"Extra CR if we are coming from the east 2nd time onward."
            <TELL
"You are behind the white house.  In one corner of the house there|
is a small window which is ">
            <COND (,KITCHEN-WINDOW
                    <TELL "open." CR>)
                  (T <TELL "slightly ajar." CR>)>)
          (<W=? .PRSACT ,W?OPEN>
            <COND (<OR <NOT .OBJ> <W=? .OBJ ,W?WINDO>>
                    <AND <NOT ,PATCHED> <NOT .OBJ> <CRLF>>
                    <TELL 
"After great effort, the window opens enough for you to enter." CR>
                    <SETG KITCHEN-WINDOW T>)>)>>

; "KITCHEN -- CHECK THE WINDOW"

<ROUTINE KITCHEN ("AUX" (PRSACT <1 ,PRSVEC>))
    <DOOR-FIX>
    <COND (<AND <W=? .PRSACT ,W?LOOK> <OR <NOT ,PATCHED> <LIT? ,HERE>>>
            <OR ,PATCHED <CRLF>>
            <TELL
"You are in the kitchen of the white house.  A table seems to have been|
used recently for the preparation of food.  A passage leads to the west|
and a dark staircase can be seen leading upward.  To the east is a small" CR>
            <COND (,PATCHED <TELL "window which is ">)
                  (T <TELL "window  which is ">)>
            <COND (,KITCHEN-WINDOW
                    <TELL "open." CR>)
                  (T <TELL "slightly ajar." CR>)>)>>

<CONSTANT RESDESC 
"However, with the water level lowered, there is merely a wide stream|
running through the center of the room.">

<ROUTINE GLACIER-ROOM ("AUX" (PRSACT <1 ,PRSVEC>))
    <IFFLAG (DEBUG <TELL "GLACIER-ROOM" CR>)>
    <COND (<AND <W=? .PRSACT ,W?LOOK> <OR <NOT ,PATCHED> <LIT? ,HERE>>>
            <TELL 
"You are in a large room, with giant icicles hanging from the walls|
and ceiling." CR>
            <COND (,GLACIER-FLAG
                    <TELL 
"There is a large passageway leading westward." CR>)>)>>

<ROUTINE TROPHY-CASE ("AUX" (PRSACT <1 ,PRSVEC>))
    <IFFLAG (DEBUG <TELL "TROPHY-CASE" CR>)>
    <COND (<W=? .PRSACT ,W?TAKE>
            <COND (<W=? <2 ,PRSVEC> ,W?TROPH>
                    <TELL
"The trophy case is securely fastened to the wall (perhaps to foil any|
attempt by robbers to remove it)." CR>)
                   (T 
                    <TELL "I can't see one here." CR>
                    <RTRUE>)>)>>

<ROUTINE GLACIER ("AUX" (PRSVEC ,PRSVEC) (PRSACT <1 .PRSVEC>))
    <IFFLAG (DEBUG <TELL "GLACIER" CR>)>
    <COND (<W=? .PRSACT ,W?THROW>
            <COND (<W=? <2 .PRSVEC> ,W?TORCH>
                    <TELL 
"The torch hits the glacier and explodes into a great ball of flame,|
devouring the glacier.  The water from the melting glacier rushes|
downstream, carrying the torch with it.  In the place of the glacier,|
there is a passageway leading west." CR>
                    <REMOVE ,ICE>
                    <MOVE ,TORCH ,STREA>
                    <SETG GLACIER-FLAG T>)
                  (T <TELL
"The glacier is unmoved by your ridiculous attempt." CR>
                    <RFALSE>)>)
          (<W=? .PRSACT ,W?TAKE>
            <TELL <PICK-ONE ,YUKS> CR>)>>

<GLOBAL YUKS
    <LTABLE
"Nice try."
"You can't be serious."
"Chomp, Chomp."
"What would you do if you succeeded?">>

<ROUTINE RESERVOIR-SOUTH ("AUX" (PRSACT <1 ,PRSVEC>)) 
    <IFFLAG (DEBUG <TELL "RESERVOIR-SOUTH" CR>)>
    <COND (<AND <W=? .PRSACT ,W?LOOK> <OR <NOT ,PATCHED> <LIT? ,HERE>>>
            <COND (,LOW-TIDE
                    <TELL 
"You are in the south end of a large cavernous room which was formerly|
a reservoir." CR>
                    <TELL ,RESDESC CR>)
                  (T 
                    <TELL "You are at the south end of a large reservoir." CR>)>
            <TELL 
"There is a western exit, a passageway south, and a steep pathway|
climbing up along the edge of a cliff." CR>)>>

<ROUTINE RESERVOIR-NORTH ("AUX" (PRSACT <1 ,PRSVEC>)) 
    <IFFLAG (DEBUG <TELL "RESERVOIR-NORTH" CR>)>
    <COND (<AND <W=? .PRSACT ,W?LOOK> <OR <NOT ,PATCHED> <LIT? ,HERE>>>
            <COND (,LOW-TIDE
                    <TELL 
"You are in the north end of a large cavernous room which was formerly|
a reservoir." CR>
              <TELL ,RESDESC CR>)
             (T 
                <TELL "You are at the north end of a large reservoir." CR>)>
           <TELL "There is a tunnel leaving the room to the north." CR>)>>

;"LIVING-ROOM -- FUNCTION TO ENTER THE DUNGEON FROM THE HOUSE"

<ROUTINE LIVING-ROOM ("AUX" (PRSACT <1 ,PRSVEC>) (OBJ <2 ,PRSVEC>))
    <DOOR-FIX>
    <COND (<AND <W=? .PRSACT ,W?LOOK> <OR <NOT ,PATCHED> <LIT? ,HERE>>>
            <COND (,MAGIC-FLAG <TELL 
"You are in the living room.  There is a door to the east.  To the west|
is a cyclops-shaped hole in an old wooden door, above which is some|
strange gothic lettering ">)
                  (T 
                    <OR ,PATCHED <TELL CR CR>>
                    <TELL 
"You are in the living room.  There is a door to the east, a wooden door|
with strange gothic lettering to the west, which appears to be nailed|
shut, ">)>
            <COND (<AND ,RUG-MOVED ,TRAP-DOOR>
                <TELL "and a rug lying on the floor beside an open trap-door.">)
              (,RUG-MOVED
                <TELL "and what appears to be a closed trap-door at your feet.">)
              (,TRAP-DOOR
                <TELL "and an open trap-door at your feet.">)
              (T <TELL "and a large oriental rug in the center of the room.">)>
            <CRLF>)
          (<W=? .PRSACT ,W?OPEN>
            <COND (<AND <OR ,RUG-MOVED ,RUG-MOVED-ERROR> <OR <NOT .OBJ> <W=? .OBJ ,W?DOOR>>> 
                    <AND <NOT ,PATCHED> <NOT .OBJ> <CRLF>>
                    <TELL 
"The door reluctantly opens to reveal a rickety staircase descending|
into darkness." CR>
                    <SETG TRAP-DOOR T>)>)
          (<AND <W=? .PRSACT ,W?DROP> <G? <GETP <FIRST? ,HERE> ,P?OTVAL> 0>>
            <MOVE <FIRST? ,HERE> ,TROPH>
            <TELL "The trophy case accepts another contribution." CR>)>>

<GLOBAL RUG-MOVED <>>

<ROUTINE CLEARING ("AUX" (PRSACT <1 ,PRSVEC>) (RM ,HERE) (RV <GETP .RM ,P?RVARS>))
    <DOOR-FIX>
    <COND (<AND <W=? .PRSACT ,W?LOOK> <OR <NOT ,PATCHED> <LIT? ,HERE>>>
            <TELL 
"You are in a clearing, with a forest surrounding you on the west|
and south." CR>
            <COND (,KEY-FLAG
                    <TELL "There is an open grating, descending into darkness." CR>)
                  (<NOT <0? .RV>>
                    <TELL "There is a grating securely fastened into the ground." CR>)>)
          (<AND <0? .RV>
            <W=? .PRSACT ,W?TAKE>
            <W=? <2 ,PRSVEC> ,W?PILE>>
            <TELL "A grating appears on the ground." CR>
            <PUTP .RM ,P?RVARS 1>)>>

; "CELLAR--FIRST ROOM IN BASEMENT."

<ROUTINE CELLAR ("AUX" (WIN ,WINNER) (PRSACT <1 ,PRSVEC>)
                       (DOOR <FIND-OBJ ,W?DOOR>))
    <DOOR-FIX>
    <COND (<AND <W=? .PRSACT ,W?LOOK> <OR <NOT ,PATCHED> <LIT? ,HERE>>>
            <TELL 
"You are in a dark and damp cellar with a narrow passageway leading|
east, and a crawlway to the south.  On the west is the bottom of a steep|
metal ramp which is unclimbable." CR>)
          (<AND <W=? .PRSACT ,W?WALK-IN>
                ,TRAP-DOOR
                <NOT <GETP .DOOR ,P?OTOUCH?>>>
            <SETG TRAP-DOOR <>>
            ;"<PUTP .DOOR ,P?OTOUCH? T>"  ;"The trap-door always slams shut in the original version"
            <TELL 
"The trap door crashes shut behind you, and you hear someone barring it." CR>)>>

;"STUDIO:  LET PEOPLE UP THE CHIMNEY IF THEY DON'T HAVE MUCH STUFF
  Lets you carry the lamp + one other object up the chimney."

<ROUTINE STUDIO-FUNCTION ("AUX" (WIN ,WINNER))
  <COND (<AND <L=? <LENGTH .WIN> 2>
          <IN? <FIND-OBJ ,W?LAMP> .WIN>>
     <SETG LIGHT-LOAD T>
     ;"Door will slam shut next time, too, since this way up don't count."
     <COND (<NOT ,TRAP-DOOR>
        <PUTP <FIND-OBJ ,W?DOOR> ,P?OTOUCH? <>>)>
     <>)
    (T
     <SETG LIGHT-LOAD <>>)>>

; "OBJECT FUNCTIONS"

<ROUTINE RUG-F ("AUX" (PRSVEC ,PRSVEC) (PRSA <1 .PRSVEC>))  ;"Was RUG"
    <IFFLAG (DEBUG <TELL "RUG-F" CR>)>
    <COND (<NOT <IN? ,RUG ,HERE>> <RFALSE>)>
    <COND (<W=? .PRSA ,W?MOVE>
            <COND (,RUG-MOVED <TELL 
"Having lifted the carpet previously, you find it impossible to move|
it again." CR>)
                  (T 
                    <TELL "With a great effort, the carpet is moved to one side of the room." CR>
                    <COND (<NOT ,RUG-MOVED-ERROR> 
                            <TELL "With the rug removed, the dusty cover of a closed trap-door appears." CR>)>
                     <SETG RUG-MOVED T>)>)
          (<W=? .PRSA ,W?TAKE>
            <TELL "The rug is extremely heavy and cannot be carried." CR>
            <RTRUE>)
          (T <RFALSE>)>>

<ROUTINE SKELETON ()
    <IFFLAG (DEBUG <TELL "SKELETON" CR>)>
    <TELL
"A ghost appears in the room and is appalled at your having desecrated|
the remains of the skeleton.  He casts a curse on all of your valuables|
and orders them banished to the Land of the Living Dead.  The ghost|
leaves, muttering obscenities." CR>
    <ROB ,HERE ,LLD2 100>
    <ROB ,WINNER ,LLD2>
    T>

<ROUTINE TROLL-F ("AUX" (VEC ,PRSVEC) (PRSACT <1 .VEC>) (OBJ <2 .VEC>)  ;"Was TROLL" 
                        (RM ,HERE) (T <FIND-OBJ ,W?TROLL>))  
    <IFFLAG (DEBUG <TELL "TROLL-F" CR>)>
    <COND (<AND <W=? .PRSACT ,W?THROW> .OBJ>
            <COND (<W=? .OBJ ,W?KNIFE>
                    <COND (<OR <GET .T ,P?ORAND> <PROB 80>>
                            <TELL
"The troll eats the knife and develops an internal hemorrhage.  He|
disappears along with his axe, and the way is clear.  The bloody knife|
remains behind." CR>
                            <SETG TROLL-FLAG T>
                            <REMOVE .T>
                            <MOVE ,KNIFE .RM>)
                          (T
                            <TELL
"The troll catches the knife, and being for the moment sated, throws it|
back. Fortunately, the troll has poor control, and the knife falls to|
the floor." CR>
                            <PUTP .T ,P?ORAND T>
                            <MOVE ,KNIFE .RM>)>)
                  (T 
                    <TELL 
"The troll, whose tastes are not the most disocriminating, gleefully|
eats it." CR>
                    <REMOVE <FIND-OBJ .OBJ>>)>)
          (<OR <W=? .PRSACT ,W?TAKE> <W=? .PRSACT ,W?MOVE>>
            <TELL 
"The troll spits in your face, saying \"Better luck next time.\"" CR>)>>

;"MIRROR ROOM HACKERY"

<ROUTINE MIRROR-ROOM ("AUX" (PRSACT <1 ,PRSVEC>))
    <IFFLAG (DEBUG <TELL "MIRROR-ROOM" CR>)>
    <DOOR-FIX>
    <COND (<AND <W=? .PRSACT ,W?LOOK> <OR <NOT ,PATCHED> <LIT? ,HERE>>>
            <TELL 
"You are in a large square room with tall ceilings.  On the south wall|
is an enormous mirror which fills the entire wall.  There are exits|
on the other three sides of the room." CR>
           <COND (,MIRROR-MUNG
                    <TELL
"Unfortunately, you have managed to destroy it by your reckless|
actions." CR>)>)>>

<GLOBAL MIRROR-MUNG <>>

<ROUTINE MIRROR-MIRROR ("AUX" (PRSACT <1 ,PRSVEC>) RM1 RM2 L1 L2 N)
    <COND (<AND <NOT ,MIRROR-MUNG>
                <W=? .PRSACT ,W?RUB>>
            <SET RM1 ,HERE>
            <COND (<=? .RM1 ,MIRR1> <SET RM2 ,MIRR2>)
                  (T <SET RM2 ,MIRR1>)>
            <SET L1 <FIRST? ,HERE>>
            <SET L2 <FIRST? .RM2>>
            <REPEAT ()
                <COND (<NOT .L1> <RETURN>)>
                <SET N <NEXT? .L1>>
                <MOVE .L1 .RM2>
                <SET L1 .N>>
            <REPEAT ()
                <COND (<NOT .L2> <RETURN>)>
                <SET N <NEXT? .L2>>
                <MOVE .L2 ,HERE>
                <SET L2 .N>>
            <GOTO .RM2>
            <TELL 
"There is a rumble from deep within the earth and the room shakes." CR>)
          (<W=? .PRSACT ,W?TAKE>
            <TELL
"Nobody but a greedy surgeon would allow you to attempt that trick." CR>)
          (<OR <W=? .PRSACT ,W?MUNG>
               <W=? .PRSACT ,W?THROW>>
            <COND (,MIRROR-MUNG
                    <TELL "Haven't you done enough already." CR>)
                  (<SETG MIRROR-MUNG T>
                    <TELL
"You have broken the mirror.  I hope you have a seven years supply of|
good luck handy.">)>)>>

<ROUTINE CAROUSEL-ROOM ((VEC ,PRSVEC) (PRSACT <1 .VEC>) (RM ,HERE)) 
    <IFFLAG (DEBUG <TELL "CAROUSEL-ROOM" CR>)>
    <COND (<AND <W=? .PRSACT ,W?WALK> <NOT ,FROBOZZ>>
            <COND (<GETPT .RM <GETB <2 .VEC> 7>>  ;"Is it a valid direction in this room?"
                    <AND <NOT ,PATCHED> <W=? <2 .VEC> ,W?SE> <TELL "2">> 
                    <AND <NOT ,PATCHED> <NOT <W=? <2 .VEC> ,W?OUT>> <CRLF>>
                    <COND (<AND <NOT ,PATCHED> <W=? <2 .VEC> ,W?OUT>>
                            <TELL "There is no way to go in this direction." CR>)
                          (T 
                            <OR ,PATCHED <CRLF>>
                            <TELL 
"Unfortunately, it is impossible to tell which direction is which|
in here." CR>)>
                    <PUT .VEC 2 <GET ,EIGHT-DIRECTIONS <- <RANDOM 8> 1>>>)>)>>

<CONSTANT EIGHT-DIRECTIONS
    <TABLE W?NORTH W?SOUTH W?EAST W?WEST W?NW W?NE W?SE W?SW>>

<ROUTINE TORCH-ROOM ("AUX" (PRSACT <1 ,PRSVEC>))
    <IFFLAG (DEBUG <TELL "TORCH-ROOM" CR>)>
    <COND (<AND <W=? .PRSACT ,W?LOOK> <OR <NOT ,PATCHED> <LIT? ,HERE>>>
            <TELL
"You are in a large room with a prominent doorway leading to a down|
staircase. To the west is a narrow twisting tunnel.  Above you is|
a large dome painted with scenes depicting elfen hacking rites.|
Up around the edge of the dome (20 feet up) is a wooden railing.|
In the center of this room there is a white marble pedestal." CR>
            <COND (,DOME-FLAG
                    <TELL
"A large piece of rope descends from the railing above, ending|
some five feet above your head." CR>)>)>>

<ROUTINE DOME-ROOM ("AUX" (PRSACT <1 ,PRSVEC>))
    <IFFLAG (DEBUG <TELL "DOME-ROOM" CR>)>
    <COND (<AND <W=? .PRSACT ,W?LOOK> <OR <NOT ,PATCHED> <LIT? ,HERE>>>
            <TELL 
"You are at the periphery of a large dome, which forms the ceiling|
of another room below.  Protecting you from a precipitous drop is a|
wooden railing which circles the dome." CR>
            <COND (,DOME-FLAG
                <TELL 
"Hanging down from the railing is a rope which ends about ten feet from|
the floor below." CR>)>)
          ;"This text is in the original but because LEAPER takes precedence 
            this handle for JUMP is never reached."
          (<W=? .PRSACT ,W?JUMP>
            <JIGS-UP 
"I'm afraid that the leap you attempted has done you in.">)
          (<AND <NOT ,PATCHED> <W=? .PRSACT ,W?DROP> <W=? <2 ,PRSVEC> ,W?ROPE>>
            <COND (<IN? ,ROPE ,HERE> <ROPE-FUNCTION>)
                  (T 
                    <TELL 
"|
*ERROR*|
NTH-REST-PUT-OUT-OF-RANGE|
#WORD *000000000000*|
DOME-ROOM|
LISTENING-AT-LEVEL 2 PROCESS 1|" CR>
                    <QUIT>)>)>>

<ROUTINE COFFIN ()
    <IFFLAG (DEBUG <TELL "COFFIN" CR>)>
    <COND (<IN? ,COFFI ,WINNER>
            <SETG EGYPT-FLAG <>>)
          (T 
            <SETG EGYPT-FLAG T>)>
    <RFALSE>>

<ROUTINE LLD-ROOM ("AUX" (VEC ,PRSVEC) (WIN ,WINNER) 
            (PRSACT <1 .VEC>) (C <FIND-OBJ ,W?CANDL>))
    <COND (<AND <W=? .PRSACT ,W?LOOK> <OR <NOT ,PATCHED> <LIT? ,HERE>>>
            <TELL 
"You are outside a large gateway, on which is inscribed|
\"Abandon every hope, all ye who enter here.\"  The gate|
is open; through it you can see a desolation, with a pile|
of mangled corpses in one corner.  Thousands of voices,|
lamenting some hideous fate, can be heard." CR>
            <COND (<NOT ,LLD-FLAG>
              <TELL 
"The way through the gate is barred by evil spirits, who|
jeer at your attempts to pass." CR>)>)
          (<W=? .PRSACT ,W?EXORC>
            <COND (<AND <IN? ,BELL .WIN>
                        <IN? ,BOOK .WIN>
                        <IN? .C .WIN>
                        <G? <GETP .C ,P?OLIGHT?> 0>>
                    <OR ,PATCHED <CRLF>>
                    <TELL 
"There is a clap of thunder, and a voice echoes through the|
cavern:  \"Begone, fiends!\"  The spirits, sensing the presence|
of a greater power, flee through the walls." CR>
                    <COND (<AND <NOT ,PATCHED> ,LLD-FLAG>
                            <TELL 
"|
*ERROR*|
NTH-REST-PUT-OUT-OF-RANGE|
#WORD *000000000000*|
LLD-ROOM|
LISTENING-AT-LEVEL 2 PROCESS 1" CR>
                            <QUIT>)
                          (T 
                            <REMOVE ,GHOST>
                            <SETG LLD-FLAG T>)>)
                  (<TELL "You are not equipped for an exorcism." CR>)>)>>

<ROUTINE GHOST-FUNCTION ("AUX" (PV ,PRSVEC) (G ,W?GHOST))
    <IFFLAG (DEBUG <TELL "TIME" CR>)>
    <COND (<W=? <3 .PV> .G>
            <TELL "How can you attack a spirit with material objects?" CR>
            <RFALSE>)
          (<W=? <2 .PV> .G>
            <TELL "You seem unable to affect these spirits." CR>)>>

<ROUTINE MAZE-11 ("AUX" (PRSACT <1 ,PRSVEC>) (OBJ <2 ,PRSVEC>)
                        (IOBJ <3 ,PRSVEC>)) 
    <IFFLAG (DEBUG <TELL "MAZE-11" CR>)>
    <DOOR-FIX>
    <COND (<AND <W=? .PRSACT ,W?LOOK> <OR <NOT ,PATCHED> <LIT? ,HERE>>>
            <TELL 
"You are in a small room near the maze. There are twisty passages|
about." CR>
            <COND (,KEY-FLAG
                    <TELL "Above you is an open grating with sunlight pouring in from above." CR>)
                  (T 
                    <TELL "Above you is a grating locked with a skull-and-crossbones lock." CR>)>)
          (<W=? .PRSACT ,W?OPEN>
            <COND (<AND <NOT ,PATCHED> <W=? .OBJ ,W?GRATI>>
                    <TELL
"|
*ERROR*|
UNASSIGNED-VARIABLE|
GRATE!-WORDS|
GVAL|
LISTENING-AT-LEVEL 2 PROCESS 1" CR>
                    <QUIT>)>
            <COND (<AND <OR <NOT .OBJ> <W=? .OBJ ,W?GRATI>>
                        <OR <NOT .IOBJ> <W=? .IOBJ ,W?KEYS>>
                        <IN? ,KEYS ,WINNER>>
                    <TELL "The grating lock opens to reveal trees above you." CR>
                    <SETG KEY-FLAG T>)
                  (<AND <OR <NOT .OBJ> <W=? .OBJ ,W?GRATI>>>
                    <TELL "With what?" CR>)>)>>

<ROUTINE TREASURE-ROOM ("AUX" (PRSACT <1 ,PRSVEC>) (RM ,HERE) X N)
    <IFFLAG (DEBUG <TELL "TREASURE-ROOM" CR>)>
    <COND (<AND <W=? .PRSACT ,W?WALK-IN> <NOT ,THIEF-DEAD>>
        <TELL 
"You hear a scream of anguish as you violate the robber's hideaway.|
Using passages unknown to you, he rushes to its defense, only to expire|
on the threshold.  He and his bag dissolve." CR>
        <COND (<FIRST? ,THIEF> <TELL
"The thief's ill-gotten gains remain, mingled with the dust that is his|
only monument." CR>)
              (T <TELL "Alas, the robber was carrying nothing." CR>)>
        <REMOVE ,THIEF>
        <SETG THIEF-DEAD T>
        <SET X <FIRST? ,THIEF>>
        <REPEAT ()
            <COND (<NOT .X> <RETURN>)>
            <SET N <NEXT? .X>>
            <MOVE .X .RM>
            <SET X .N>>)>>  

<ROUTINE TREAS () 
    <IFFLAG (DEBUG <TELL "TREAS" CR>)>
    <COND (<AND <W=? <1 ,PRSVEC> ,W?TREAS>
                <=? ,HERE ,TEMP1>>
            <GOTO ,TREAS-R>
            <ROOM-DESC>)
          (<AND <=? <1 ,PRSVEC> ,W?TEMPL>
                <=? ,HERE ,TREAS-R>>
            <GOTO ,TEMP1>
            <ROOM-DESC>)
          (T <TELL "Nothing happens." CR>)>>
          
<ROUTINE PRAYER () 
    <IFFLAG (DEBUG <TELL "PRAYER" CR>)>
    <COND (<AND <=? ,HERE ,TEMP2>
                <GOTO ,FORE1>>
            <ROOM-DESC>)
          (<TELL
"If you pray enough, your prayers may be answered." CR>)>>

<GLOBAL GATE-FLAG <>>

<ROUTINE DAM-ROOM ("AUX" (PRSACT <1 ,PRSVEC>) (PRSO <2 ,PRSVEC>) (WRENCH? <IN? ,WRENC ,WINNER>)
                         (SCREW? <IN? ,SCREW ,WINNER>)  (DAM? <W=? .PRSO ,W?DAM>)
                         (O? <W=? .PRSACT ,W?OPEN>) (C? <W=? .PRSACT ,W?CLOSE>)) 
    <IFFLAG (DEBUG <TELL "DAM-ROOM" CR>)>

    <COND (<AND <W=? .PRSACT ,W?LOOK> <OR <NOT ,PATCHED> <LIT? ,HERE>>>
            <TELL 
"You are standing on the top of the Flood Control Dam #3, which was quite|
a tourist attraction in times far distant." CR>
            <COND (,LOW-TIDE
                    <TELL 
"It appears that the dam has been opened since the water level behind it|
is low and the sluice gate has been opened.  Water is rushing downstream|
through the gates." CR>)
                  (T 
                    <TELL 
"The sluice gates on the dam are closed.  Behind the dam, there can be|
seen a wide lake.  A small stream is formed by the runoff from the|
lake." CR>)>
            <TELL 
"Below you is a panel with a large metal bolt and a small green plastic|
bubble." CR>
            <COND (,GATE-FLAG 
                    <TELL "The green bubble is glowing." CR>)>)
                     
          (<AND .C? ,GATE-FLAG ,LOW-TIDE .WRENCH? .DAM?>
            <TELL
"The sluice gates have closed and water starts to accumulate behind the|
dam." CR>
            <SETG LOW-TIDE <>>)
          (<AND .O? ,GATE-FLAG <NOT ,LOW-TIDE> .WRENCH? .DAM?>
            <TELL "The sluice gates have opened and water pours through the dam." CR>
            <PUTP ,TRUNK ,P?OFLAGS 1>
            <SETG LOW-TIDE T>)
          (<AND <OR .O? .C?> ,GATE-FLAG .WRENCH? .DAM?>
            <TELL "Look around you." CR>)         
          (<AND <OR .O? .C?> .WRENCH? .DAM?>
            <TELL "The large bolt refuses to turn with your best effort." CR>)         
          (<AND <OR .O? .C?> .SCREW? .DAM?>
            <TELL "Do you expect to turn a large bolt with a screwdriver?" CR>)           
          (<AND <OR .O? .C?> .DAM?>
            <TELL "The large bolt is very tight and you are unable to turn it." CR>)              
          (<OR .O? .C?>
            <COND (<AND ,PATCHED .C?> <TELL "Close what?" CR>)
                  (T <TELL "Open what?" CR>)>)>>

<GLOBAL DROWNINGS
    <LTABLE
    "up to your ankles." 
    "up to your shin." 
    "up to your knees." 
    "up to your thigh." 
    "up to your hips." 
    "up to your waist." 
    "up to your chest." 
    "up to your shoulders." 
    "up to your neck." 
    "over your head." 
    "high in your lungs.">>

<ROUTINE MAINT-ROOM ("AUX" (PV ,PRSVEC) (PRSACT <1 .PV>) (PRSO <2 .PV>)
              (PRSI <3 .PV>) (MNT ,MAINT) (HERE? <=? ,HERE .MNT>) HACK)
    <IFFLAG (DEBUG <TELL "MAINT-ROOM" CR>)>

    <SET HACK <GETP .MNT ,P?RVARS>>
    <COND (<AND <G? .HACK 0> ,NOT-DROWNED>
           <PUTP .MNT ,P?RVARS <+ 1 .HACK>>
           <COND (.HERE?
                    <TELL "The water level here is now " <GET ,DROWNINGS .HACK> CR>)>
           <COND (<OR <G=? .HACK <0 ,DROWNINGS>> <AND <NOT ,PATCHED> <G=? .HACK <- <0 ,DROWNINGS> 1>>>>
                    <SET NOT-DROWNED <>>
                    <AND .HERE?
                         <JIGS-UP "I'm afraid you have done drowned yourself.">>)>)>

    <COND (<W=? .PRSACT ,W?PUSH>
            <AND <NOT ,PATCHED> <WT? .PRSO ,PS?ADJECTIVE> <NOT <W=? <3 .PV> ,W?BUTTO>> <CRLF>>
            <COND (<W=? .PRSO ,W?BLUE>
                    <COND (<0? .HACK>
                            <TELL 
"There is a rumbling sound and a stream of water appears to burst from|
the east wall of the room (apparently, a leak has occurred in a pipe.)" CR>
                            <PUTP ,HERE ,P?RVARS 1>
                            <RTRUE>)
                          (T <TELL "The blue button appears to be jammed." CR>)>)
                  (<W=? .PRSO ,W?RED>
                    <PUTP ,HERE ,P?RLIGHT? <NOT <GETP ,HERE ,P?RLIGHT?>>>
                    <COND (<GETP ,HERE ,P?RLIGHT?>
                            <TELL "The lights within the room come on." CR>)
                          (T <TELL "The lights within the room shut off." CR>)>)
                  (<W=? .PRSO ,W?BROWN>
                    <SETG GATE-FLAG <>>
                    <TELL "Click." CR>)
                  (<W=? .PRSO ,W?YELLO>
                    <SETG GATE-FLAG T>
                    <TELL "Click." CR>)>)>>

<ROUTINE CAVE2-ROOM ("AUX" (PRSACT <1 ,PRSVEC>) C)
    <IFFLAG (DEBUG <TELL "CAVE2-ROOM" CR>)>
    <COND (<W=? .PRSACT ,W?WALK-IN>
        <AND <IN? <SET C <FIND-OBJ ,W?CANDL>> ,WINNER>
             <PROB 50>
             <1? <GETP .C ,P?OLIGHT?>>
             <PUTP .C ,P?OLIGHT? -1>
             <TELL 
"The cave is very windy at the moment and your candles have blown out." CR>>)>>

<ROUTINE BOTTLE-FUNCTION ("AUX" (PRSACT <1 ,PRSVEC>))
    <IFFLAG (DEBUG <TELL "BOTTLE-FUNCTION" CR>)>
    <COND (<W=? .PRSACT ,W?THROW>
            <TELL "The bottle hits the far wall and is decimated." CR>
            <REMOVE ,BOTTL>)
          (<W=? .PRSACT ,W?MUNG>
            <COND (<IN? ,BOTTL ,WINNER>
                    <TELL "You have destroyed the bottle.  Well done." CR>)
                  (<IN? ,BOTTL ,HERE>
                    <TELL "A brilliant maneuver destroys the bottle." CR>)>
            <REMOVE ,BOTTL>)>>  

<ROUTINE FILL () T>

<ROUTINE WATER-FUNCTION ("AUX" (PRSVEC ,PRSVEC) (PRSACT <1 .PRSVEC>) (ME ,WINNER)
                               (W <2 .PRSVEC>) (CAN <3 .PRSVEC>))
    <IFFLAG (DEBUG <TELL "WATER-FUNCTION" CR>)>
    <COND (<W=? .PRSACT ,W?TAKE>
            <COND (<IN? ,BOTTL .ME>
                    <TELL "The bottle is now full of water." CR>
                    <MOVE ,WATER ,BOTTL>)
                  (T <TELL "The water slips through your fingers." CR>)>)
          (<OR <W=? .PRSACT ,W?DROP>
               <W=? .PRSACT ,W?POUR>
               <AND ,PATCHED <W=? .PRSACT ,W?THROW>>
               <AND ,PATCHED <W=? .PRSACT ,W?GIVE>>>
            <TELL "The water spills to the floor and evaporates immediately." CR>
            <REMOVE ,WATER>)>>

<ROUTINE ROPE-FUNCTION ("AUX" (PRSACT <1 ,PRSVEC>) (DROOM ,DOME)
               (ROPE ,ROPE) (WIN ,WINNER))
    <COND (<N=? ,HERE .DROOM> <SETG DOME-FLAG <>>)
          (<W=? .PRSACT ,W?TIE>
            <OR ,PATCHED <CRLF>>
            <TELL 
"The rope drops over the side and comes within five feet of the floor." CR>
            <COND (<AND ,DOME-FLAG <NOT ,PATCHED>>
                    <TELL
"|
*ERROR*|
NTH-REST-PUT-OUT-OF-RANGE|
#WORD *000000000000*|
DOME-ROOM|
LISTENING-AT-LEVEL 2 PROCESS 1" CR>
                    <QUIT>)>
            <SETG DOME-FLAG T>
            <MOVE .ROPE ,HERE>)
          (<W=? .PRSACT ,W?UNTIE>
            <COND (,DOME-FLAG
                <SETG DOME-FLAG <>>
                <OR ,PATCHED <CRLF>>
                <TELL 
"Although you tied it incorrectly, the rope becomes free." CR>)
                  (T <TELL "It is not tied to anything." CR>)>)
          (<AND <W=? .PRSACT ,W?DROP> <NOT ,DOME-FLAG>>
            <MOVE .ROPE ,MTORC>
            <TELL "The rope drops gently to the floor below." CR>)
          (<AND <W=? .PRSACT ,W?TAKE> ,DOME-FLAG>
            <TELL "The rope is tied to the railing." CR>)>>

<ROUTINE CYCLOPS ("AUX" (PRSACT <1 ,PRSVEC>) (PRSOB1 <2 ,PRSVEC>) (RM ,HERE)
                 (COUNT <GETP .RM ,P?RVARS>)) 
    <IFFLAG (DEBUG <TELL "CYCLOPS" CR>)>
    <COND (,CYCLOPS-FLAG <RTRUE>) 
          (<W=? .PRSACT ,W?GIVE>
            <COND (<W=? .PRSOB1 ,W?FOOD>
                    <COND (<G=? .COUNT 0>
                            <REMOVE ,FOOD>
                            <TELL 
"The cyclops says 'Mmm Mmm.  I love hot peppers!  But oh, could I use|
a drink.  Perhaps I could drink the blood of that thing'.  From the|
gleam in his eye, it could be surmised that you are 'that thing'." CR>
                            <PUTP .RM ,P?RVARS <MIN -1 <- .COUNT>>>)>)
                  (<W=? .PRSOB1 ,W?WATER>
                    <COND (<L? .COUNT 0>
                            <REMOVE ,WATER>
                            <TELL 
"The cyclops looks tired and quickly falls fast asleep (what did you|
put in that drink, anyway?)." CR>
                            <SETG CYCLOPS-FLAG T>)
                          (T <TELL 
"The cyclops apparently was not thirsty at the time and refuses your|
generous gesture." CR>
                            <>)>)
          (T <TELL "The cyclops is not so stupid as to eat THAT!" CR>
                <COND (<AND <NOT ,PATCHED> <G=? <ABS .COUNT> 4>>
                        <TELL
"|
*ERROR*|
OUT-OF-BOUNDS|
CYCLOPS|
LISTENING-AT-LEVEL 2 PROCESS 1" CR>
                        <QUIT>)>
                <PUTP .RM ,P?RVARS <AOS-SOS .COUNT>>)>)
          (<AND <PUTP .RM ,P?RVARS <AOS-SOS .COUNT>> <>>)
          (<G? <ABS .COUNT> 5>
           <JIGS-UP
"The cyclops, tired of all of your games and trickery, eats you.|
The cyclops says 'Mmm.  Just like mom used to make 'em.'">)
          
          (<OR <W=? .PRSACT ,W?THROW>
            <W=? .PRSACT ,W?MUNG>>
            <COND (<PROB 50>
                    <TELL
"Your actions don't appear to be doing much harm to the cyclops, but they|
do not exactly lower your insurance premiums, either." CR>)
                  (T <TELL
"The cyclops ignores all injury to his body with a shrug." CR>)> <>)
          (<W=? .PRSACT ,W?TAKE>
            <TELL 
"The cyclops is rather heavy and doesn't take kindly to being grabbed." CR>)>>

<ROUTINE CYCLOPS-ROOM ("AUX" (VEC ,PRSVEC) (RM ,HERE) (VARS <GETP .RM ,P?RVARS>)) 
    <COND (<AND <W=? <1 .VEC> ,W?LOOK> <OR <NOT ,PATCHED> <LIT? .RM>>>
            <TELL 
"You are in a room with an exit on the west side, and a staircase|
leading up." CR>
            <COND (<AND ,CYCLOPS-FLAG <NOT ,MAGIC-FLAG>>
                    <TELL 
"The cyclops, perhaps affected by a drug in your drink, is sleeping|
blissfully at the foot of the stairs." CR>)
                  (,MAGIC-FLAG
                    <TELL 
"On the north of the room is a wall which used to be solid, but which|
now has a cyclops-sized hole in it." CR>)
                  (<0? .VARS>
                    <TELL 
"A cyclops, who looks prepared to eat horses (much less mere|
adventurers), blocks the staircase.  From his state of health, and|
the bloodstains on the walls, you gather that he is not very friendly,|
though he likes people." CR>)
                  (<G? .VARS 0>
                    <TELL 
"The cyclops is standing in the corner, eyeing you closely.  I don't|
think he likes you very much.  He looks extremely hungry even for a|
cyclops." CR>)
                  (<L? .VARS 0>
                    <TELL 
"The cyclops, having eaten the hot peppers, appears to be gasping.|
His enflamed tongue protrudes from his man-sized mouth." CR>)>
            <COND (<AND <NOT ,CYCLOPS-FLAG> <NOT <0? .VARS>>>
                    <TELL <NTH ,CYCLOMAD <- <ABS .VARS> 1>> CR>)>)>>

<GLOBAL CYCLOMAD
    <TABLE (PURE)
      "The cyclops seems somewhat agitated."
      "The cyclops appears to be getting more agitated."
      "The cyclops is moving about the room, looking for something."
      "The cyclops was looking for salt and pepper.  I think he is gathering|
condiments for his upcoming snack."
      "The cyclops is moving toward you in an unfriendly manner."
      "You have two choices: 1. Leave  2. Become dinner.">>

<ROUTINE AOS-SOS (FOO)
    <COND (<L? .FOO 0> <SET FOO <- .FOO 1>>)
          (T <SET FOO <+ .FOO 1>>)>
    <COND (<NOT ,CYCLOPS-FLAG>
            <COND (<G? .FOO 6> <RETURN <- .FOO 1>>)
                  (<L? .FOO -6> <RETURN <+ .FOO 1>>)
                  (T <TELL <NTH ,CYCLOMAD <- <ABS .FOO> 1>> CR>)>)>
    <RETURN .FOO>>

<GLOBAL ECHO-FLAG <>>

<ROUTINE ECHO-ROOM ("AUX" (B ,RAWBUF) (RM ,ECHO) VERB (WALK ,W?WALK)) 
    <COND (<OR ,ECHO-FLAG <W=? <1 ,PRSVEC> .WALK>>)
          (T
            <PROG ()
                <REPEAT ((PRSVEC ,PRSVEC) RANDOM-ACTION)
                    <LEX>
                    <SETG MOVES <+ ,MOVES 1>>
                    <COND (<AND <EPARSE ,LEXV T>
                                <W=? <SET VERB <1 .PRSVEC>> .WALK>
                                <2 .PRSVEC>
                                <GETPT .RM <GETB <2 ,PRSVEC> 7>>>  ;"Valid direction?"
                            <SET RANDOM-ACTION <VFCN .VERB>>
                            <APPLY .RANDOM-ACTION>
                            <RTRUE>)
                        (T 
                            <OR ,PATCHED <CRLF>>
                            <PRINTSTRING .B>
                            <SETG TELL-FLAG T>
                            <CRLF>
                            ;"ZIL can't search for a string, instead we checks
                            if the first four characters in buffer are 'ECHO'."
                            <COND (<AND <=? <GETB .B 2> 101>    ;"e"
                                        <=? <GETB .B 3> 99>     ;"c"
                                        <=? <GETB .B 4> 104>    ;"h"
                                        <=? <GETB .B 5> 111>>   ;"o"
                                    <TELL "The acoustics of the room change subtly." CR>
                                    <SETG ECHO-FLAG T>
                                    <RTRUE>)>)>>>)>>

;"Fatal if DOWN is a NEXIT or a closed CEXIT.
  There is probably an error from the original here. The VALUE of the CEXIT flag is 
  not examined only that there is a flag. This always results that CEXITs evaluates 
  to <> and JUMPLOSS only applies to NEXITs. All other rooms with DOWN directions
  results in 'Nothing happens!' being printed."
<ROUTINE LEAPER ("AUX" (RM ,HERE) S (TX <GETPT .RM ,P?DOWN>) (WHEEEEE ,WHEEEEE))
    <IFFLAG (DEBUG <TELL " LEAPER" CR>)>
    <COND (,PATCHED <SET WHEEEEE ,WHEEEEE2>)>
    <COND (.TX
            <SET S <PTSIZE .TX>>
            <COND (<OR <=? .S ,NEXIT>
                       <AND <=? .S ,CEXIT>
                            <NOT <GETB .TX ,CEXITFLAG>>>>  
                    <JIGS-UP <PICK-ONE ,JUMPLOSS>>)>)      
          (T <TELL <PICK-ONE .WHEEEEE> CR>)>> 

<GLOBAL WHEEEEE
    <LTABLE 
           "You have jumped.  Very good.  Now you can go to second grade."
           "Have you tried skipping around the dungeon, too?"
           "Do you expect jumping to accompish something?">>

<GLOBAL WHEEEEE2
    <LTABLE
           "You have jumped.  Very good.  Now you can go to second grade."
           "Have you tried skipping around the dungeon, too?"
           "Do you expect jumping to accomplish something?">>

<GLOBAL JUMPLOSS
    <LTABLE
           "You should have looked before you leaped."
           "I'm afraid that leap was a bit much for your weak frame."
           "In the movies, your life would be passing in front of your eyes."
           "Geronimo.....">>

<ROUTINE READER ("AUX" (VEC ,PRSVEC) (PRSOBJ <2 .VEC>) (OBJ <FIND-OBJ .PRSOBJ>))
    <IFFLAG (DEBUG <TELL "READER" CR>)>
    <COND (<NOT <IN? .OBJ ,WINNER>> <TELL "You don't have that." CR>)
          (<NOT <READABLE? .OBJ>> <TELL "How do I read THAT?" CR>)
          (T <TELL <GETP .OBJ ,P?OREAD> CR>)>>

<ROUTINE WELL ()
    <COND (,RIDDLE-FLAG <TELL "Well what?" CR>)
          (<=? ,HERE ,RIDDL>
            <SETG RIDDLE-FLAG T>
            <TELL "There is a clap of thunder and the east door opens." CR>)
          (<TELL "Well what?" CR>)>>

<ROUTINE SINBAD () 
    <IFFLAG (DEBUG <TELL " SINBAD" CR>)>
    <COND (<AND <=? ,HERE ,CYCLO-R>
                <IN? ,CYCLO ,HERE>>
            <SETG CYCLOPS-FLAG T>
            <TELL
"The cyclops, hearing the name of his deadly nemesis, flees the room|
by knocking down the wall on the north of the room." CR>
            <SETG MAGIC-FLAG T>
            <REMOVE ,CYCLO>)
          (<TELL "Wasn't he a sailor?" CR>)>>

;"ROBBER"

<ROUTINE ROBBER ("AUX" (RM <LOC ,THIEF>) (HERE? <OVIS? ,THIEF>) (SEEN? <GETP .RM ,P?RSEEN?>)
                        (WIN ,WINNER) (WROOM ,HERE) (HACK ,THIEF) (ROB-ROOM <>) (ROB-ADV <>)
                        X N)
        <IFFLAG (DEBUG <TELL "Thief LOC (pre demon) = " <GETP .RM ,P?RDESC2> CR>)>

        ;"Winner and thief in the same room"
        <COND (<=? .RM .WROOM>  ;"Adventurer is in room:  CHOMP, CHOMP"
            <COND (<=? .RM ,TREAS-R>)   ; "Don't move, Gertrude"
                  (<NOT ,THIEF-HERE>
                    <COND (<AND <NOT .HERE?> <PROB 30>>
                            <TELL 
"Someone carrying a large bag is casually leaning against one of the|
walls here.  He does not speak, but it is clear from his aspect that|
the bag will be taken only over his dead body." CR>
                            <SETG ,THIEF-HERE T>
                            <PUTP ,THIEF ,P?OFLAGS 1>
                            <RTRUE>)
                          (<AND <> .HERE? <PROB 30>> ;"Can't get this to trigger in original (therefore the <>)."
                            <TELL 
"The holder of the large bag just left, looking disgusted.|
Fortunately, he took nothing." CR>
                            <PUTP ,THIEF ,P?OFLAGS 0>)
                          (<PROB 70> <RTRUE>)
                          (T
                            <SET ROB-ROOM <ROB-ROOM .RM 100>>
                            <SET ROB-ADV <ROB-ADV ,WINNER>>
                            <COND (<AND .ROB-ROOM .ROB-ADV>
                                <TELL 
"A seedy-looking individual with a large bag just wandered through|
the room.  On the way through, he quietly abstracted all valuables|
from the room and from your possession, mumbling something about|
\"Doing unto others before..\"" CR>)
                                  (<OR .ROB-ROOM .ROB-ADV>
                                <TELL 
"The other occupant just left, still carrying his large bag.  You may|
not have noticed that he robbed you blind first." CR>)
                            (T
                                <TELL
"A 'lean and hungry' gentleman just wandered through.  Finding|
nothing of value, he left disgruntled." CR>)>
                            <SETG THIEF-HERE <>>
                            <PUTP ,THIEF ,P?OFLAGS 0>)>)
                  (T
                    <COND (.HERE?
                        <COND (<PROB 30>
                            <SET ROB-ROOM <ROB-ROOM .RM 100>>
                            <SET ROB-ADV <ROB-ADV ,WINNER>>
                            <COND (<NOT <OR .ROB-ROOM .ROB-ADV>>
                                <TELL
"The other occupant (he of the large bag), finding nothing of value,|
left disgusted." CR>)
                                  (T
                                <TELL
"The other occupant just left, still carrying his large bag.  You may|
not have noticed that he robbed you blind first." CR>)>
                            <SETG THIEF-HERE <>>
                            <PUTP ,THIEF ,P?OFLAGS 0>)
                              (T <RTRUE>)>)>)>)     ;"EXIT FUNC (DON'T MOVE TO NEXT ROOM)"
              (<AND <IN? .HACK .RM>  ;"Leave if victim left. This always eval to <>."
                    <OVIS? .HACK>
                    <PUTP ,THIEF ,P?OFLAGS 0>
                    <SETG THIEF-HERE <>> <>>)

              ;"Thief in a room that the winner have visited."
              (.SEEN?                    ;"Hack the adventurer's belongings"
                <ROB-ROOM .RM 75>
                <COND (<AND <INTBL? .RM ,MAZE-PLACES <+ <0 ,MAZE-PLACES> 1>> 
                            <INTBL? .WROOM ,MAZE-PLACES <+ <0 ,MAZE-PLACES> 1>>>
                        <SET X <FIRST? .RM>>
                        <REPEAT ()
                            <COND (<NOT .X> <RETURN>)>
                            <SET N <NEXT? .X>>
                            <COND (<AND <CAN-TAKE? .X> <OVIS? .X> <PROB 40>>
                                <TELL
"You hear, off in the distance, someone saying \"My, I wonder what
this fine " <GETP .X ,P?ODESC2> " is doing here.\"" CR>
                                <COND (<PROB 60>
                                    <MOVE .X ,THIEF>)>
                                <RETURN>)>
                            <SET X .N>>)
                      (T
                        <SET X <FIRST? .RM>>
                        <REPEAT ()
                            <COND (<NOT .X> <RETURN>)>
                            <SET N <NEXT? .X>>
                            <COND (<AND <0? <GETP .X ,P?OTVAL>> <CAN-TAKE? .X> <OVIS? .X> <PROB 20>>
                                <MOVE .X ,THIEF>
                                <COND (<=? .RM .WROOM>  ;"This will never happen, thief and winner in same room is handled above."
                                    <TELL "You suddenly notice that the " <GETP .X ,P?ODESC2> " vanished." CR>)>
                                <RETURN>)>
                            <SET X .N>>
                        <COND (<IN? ,ROPE .HACK> <SETG DOME-FLAG <>>)>)>)>  ;"If thief takes rope, reset this flag"

        ;"Move to next room"
        <COND (<NOT ,THIEF-DEAD>
            <REPEAT ()
                <COND (<AND .RM <SET RM <NEXT? .RM>>>)
                    (T <SET RM <FIRST? ,ROOMS>>)>
                <COND (<NOT <INTBL? .RM ,SACRED-PLACES <+ <0 ,SACRED-PLACES> 1>>>
                        <MOVE ,THIEF .RM>
                        <RETURN>)>>)>

        ;"Drop worthless cruft, sometimes"
        ;"Because there's no check on SEEN? it's possible that he drops objects in unreachable locations."
        <COND (<NOT <=? .RM ,TREAS-R>>
                <SET X <FIRST? .HACK>>
                <REPEAT ()
                    <COND (<NOT .X> <RETURN>)>
                    <SET N <NEXT? .X>>
                    <COND (<AND <0? <GETP .X ,P?OTVAL>> <PROB 30>>
                        <MOVE .X .RM>
                        <COND (<=? .RM .WROOM>  ;"This is extremely rare. He often dropped valueless things out of sigth."
                            <TELL 
"The robber, rummaging through his bag, dropped a few items he found|
valueless." CR>)>)>
                    <SET X .N>>)>
        
        <COFFIN>  ;"Update EGYPT-FLAG, in case the thief stole it and to be sure that it's up to date."

        <IFFLAG (DEBUG <TELL "Thief LOC (post demon) = " <GETP .RM ,P?RDESC2> CR>)>>

<ROUTINE ROBBER-FUNCTION ("AUX" (PV ,PRSVEC) (PRSACT <1 .PV>)
                                (PRSOBJ <2 .PV>) (RM ,HERE)
                                (LEAVE-CONT <>) X N OBJ)
    <IFFLAG (DEBUG <TELL "ROBBER-FUNCTION" CR>)>
    <COND (<W=? .PRSACT ,W?THROW>
            <COND (<W=? .PRSOBJ ,W?KNIFE>
                    <COND (<PROB 30>
                            <TELL
"Your knife strikes the robber in a vital spot.  He vanishes, along with|
his bag, but the contents remain." CR>
                            <REMOVE ,THIEF>
                            <SETG THIEF-DEAD T>
                            <SET .LEAVE-CONT T>)
                          (<PROB 10>
                            <TELL
"You evidently frightened the robber, though you didn't hit him.  He|
flees, but the contents of his bag fall on the floor." CR>
                            <SET THIEF-HERE <>>
                            <PUTP ,THIEF ,P?OFLAGS 0>
                            <MOVE ,THIEF <NEXT? <LOC ,THIEF>>> 
                            <SET .LEAVE-CONT T>)
                          (T 
                            <TELL 
"You missed.  The thief makes no attempt to take the knife, however." CR>
                            <MOVE ,KNIFE .RM> 
                            <RTRUE>)>
                    <COND (.LEAVE-CONT 
                            <SET X <FIRST? ,THIEF>>
                            <REPEAT ()
                                <COND (<NOT .X> <RETURN>)>
                                <SET N <NEXT? .X>>
                                <MOVE .X .RM>
                                <SET X .N>>)>)
                  (T
                    <SET OBJ <FIND-OBJ .PRSOBJ>>
                    <TELL 
"The thief places the " <GETP .OBJ ,P?ODESC2> " in his bag and|
thanks you politely." CR>
                    <MOVE .OBJ ,THIEF>)>)
          (<W=? .PRSACT ,W?MUNG>
            <TELL "Your victim doesn't seem to mind being such blows." CR>)
          (<W=? .PRSACT ,W?TAKE>
            <TELL "Once you got him, what would you do with him?" CR>)>>

<GLOBAL THIEF-HERE <>>
<GLOBAL THIEF-DEAD <>>

<CONSTANT SACRED-PLACES
    <LTABLE WHOUS NHOUS EHOUS SHOUS KITCH LROOM FORE1 FORE2 FORE3 CLEAR TEMP1 TEMP2>>

<CONSTANT MAZE-PLACES
    <LTABLE MAZE1 MAZE2 MAZE3 MAZE4 MAZE5 MAZE6 MAZE7 MAZE8 MAZE9 MAZ10 MAZ11 MAZ12 MAZ13 MAZ14 MAZ15>>

<ROUTINE LANTERN ("AUX" (VEC ,PRSVEC) (PRSACT <1 .VEC>) (RM ,HERE))
    <IFFLAG (DEBUG <TELL "LANTERN" CR>)>
    <COND (<W=? .PRSACT ,W?THROW>
            <TELL 
"The lamp has smashed into the floor and shattered|
into many little pieces." CR>
            <REMOVE ,LAMP>)>>

<ROUTINE CANDLES ("AUX" (PRSACT <1 ,PRSVEC>) (WIN ,WINNER) (C <FIND-OBJ ,W?CANDL>)) 
    <IFFLAG (DEBUG <TELL "CANDLES" CR>)>
    <COND (<AND <W=? .PRSACT ,W?ON> <IN? ,TORCH .WIN>>
        <COND (<1? <GETP .C ,P?OLIGHT?>>
            <TELL "You realize, just in time, that the candles are alread lighted." CR>)
        (T
            <TELL "The heat from the torch is so intense that the candles are vaporised." CR>
            <REMOVE .C>)>)>>

;"This is an internal MDL function that returns current time, in practice T.
  Probably this is only used as a placeholder function."
<ROUTINE TIME ()
    <IFFLAG (DEBUG <TELL "TIME" CR>)>
    T>

;"Returns the OBJECT in <2 ,PRSVEC> if it's present in room, otherwise
  tells 'There is none for the taking.'. Always returns T."
<ROUTINE OBJECT-ZORK ("AUX" (OBJ <FIND-OBJ <2 ,PRSVEC>>)) 
    <COND (<AND .OBJ <IN? .OBJ ,HERE>> 
            <RETURN .OBJ>)
          (<NOT ,PATCHED>
            <TELL "There is none for the taking." CR>
            <RTRUE>)
          (T <RTRUE>)>>

