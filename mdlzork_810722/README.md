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

Change line 396 in dung.mud to fix typo:
	Fovnder --> Founder
	
Changed more typos in dung.mud:
	Line 164, 572 & 2028: Removed double-space in sentence.
	Line 424: Added "." at end of sentence.
	Line 1969 & 2045: accomodate --> accommodate
