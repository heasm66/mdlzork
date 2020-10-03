# Mainframe Zork from 1981-07-22
Patched by Matthew T Russotto to run under Confusion plus all unprintable charecters are removed.

Changes in this version:
~~~~
Change line 1381 in act3.mud to make "play violin" respond "An amazingly offensive noise issues from the violin.":
	<COND (<AND <NOT <EMPTY? <PRSI>>> <TRNN <PRSI> ,WEAPONBIT>>

Change line 153 in parser.mud to:
	<COND (<N=? <PRSO> <>> <SET ANDFLG T>)> ;"AND is only allowed between NOUN-phrases"

Change line 1386-88 in act3.mud to:
	   <JIGS-UP <STRING
"You are so engrossed in the role of the " <ODESC2 <PRSO>> " that
you kill yourself, just as he would have done!">>)>>
