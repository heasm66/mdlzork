# Mainframe Zork from 1977-12-12

These are the changes that was done to the files to be able to run them under Confusion.

~~~
81prim.mud
==========
* File is from 1981-version.
* Change EOL to "(Windows CR LF)"
* Change row 54 to:
	(<LENGTH? .ELEM 1> <PRINT .ELEM> <ERROR NEWSTRUC>)>

defs.63 --> 77defs.mud
======================
* Change EOL to "(Windows CR LF)"
* Remove all \[FF]
* Change OFFSET to NOFFSET on row 4, 5, 275, 504, 510 & 511
* Remove all [FF] & [NUL]
* Remove all "bit-testers" from calls to FLAGWORD
* Create "bit-testers" for:
	STAGGERED?		ASTAGGERED
	OVIS?			OVISION
	READABLE?		READBIT
	CAN-TAKE?		TAKEBIT
	DOOR?			DOORBIT
	TRANSPARENT?		TRANSBIT
	EDIBLE?			FOODBIT
	DRINKABLE?		DRINKBIT
	BURNABLE?		BURNBIT
	FIGHTING?		FIGHTBIT
  and place last in the file.
	
makstr.7 --> 77makstr.mud
=========================
* Change EOL to "(Windows CR LF)"
* Change OFFSET to NOFFSET

81tell-repl.mud
===============
* File is MTRs replacement version of TELL from Confusion.
* Change EOL to "(Windows CR LF)"
* Change row 33 to
    <PRINTSTRING <CHTYPE .S1 STRING> .OUTCHAN .L>

act1.38 --> 77act1.mud
======================
* Change EOL to "(Windows CR LF)"
* Change !\[ESC] on row 5 to <ASCII 27>
* Remove all [FF] & [NUL]
* Change OFFSET to NOFFSET
* Change line 1075-76 to:
	;"<READCHR ,INCHAN>
	<OR ,ALT-FLAG <READCHR ,INCHAN>>"
* Change line 1964 to:
	<PUT .ORPHANS ,OVERB LIGHT!-ACTIONS>

act2.27 --> 77act2.mud
======================
* Change EOL to "(Windows CR LF)"
* Remove all [FF] & [NUL]
* Add missing space on line 21 (issue #51) 

act3.17 --> 77act3.mud
======================
* Change EOL to "(Windows CR LF)"
* Remove all [FF] & [NUL]

rooms.99 --> 77rooms.mud
========================
* Change EOL to "(Windows CR LF)"
* Remove all [FF] & [NUL]
* Change row 259 to:
	<AND <GET PACKAGE OBLIST> <LOOKUP "GLUE" <GET PACKAGE OBLIST>>> <LOOKUP "GROUP-GLUE" <GET INITIAL OBLIST>>
* Change OFFSET to NOFFSET
* Remark/change row 617-618 to:
	;"<READCHR ,INCHAN>
	  <OR ,ALT-FLAG <READCHR ,INCHAN>>"
* Remark/change row 26-27 to:
	<COND (<=? <SAVE .FN> "SAVED"> <INT-LEVEL 0> ;"T)
	      (T"
* Change !\[NUL] on row 55 to <ASCII 0>

77patch.mud
===========
* This is a new file that includes som additions to make this Zork run under Confusion

np.93 --> 77np.mud
======================
* Change EOL to "(Windows CR LF)"
* Remove all [FF] & [NUL]
* Change line 205 from
   <OR <CAN-TAKE? .OBJ> <NOT <VTRNN .VRB ,VTBIT>>>>
to
   <AND <CAN-TAKE? .OBJ> <NOT <VTRNN .VRB ,VTBIT>>>>
This is probably an original bug. The OR makes the game always TAKE takable items and ignoring the NO-TAKE flag. This makes the game unwinnable because you can't BOARD the boat.

melee.105 --> 78melee.mud
=========================
* File is from 1978-version
* Change EOL to "(Windows CR LF)"
* Remove all [FF] & [NUL]
* Change OFFSET to NOFFSET

dung.56 --> 77dung.mud
======================
* Change EOL to "(Windows CR LF)"
* Remove all [FF] & [NUL]
* #OBJECT {arg} is the same as a function call like <OBJECT arg>, but Confusion doesn't understand that syntax.
  So change all occurances of (search-and-replace):
	#ROOM {			<ROOM 
	#OBJECT {		<OBJECT 
	#FIND-OBJ {		<FIND-OBJ 
	#CEXIT {		<CEXIT
	#EXIT {			<EXIT
	}				>
* Add words IN! and OUT!
	<SADD-ACTION "IN!" TIME>	;"villain regains consciousness"
	<SADD-ACTION "OUT!" TIME>	;"villain loses consciousness"
~~~

The original release contains two different versions of act1 and np. For this release the latest of the files where used. Below are the differences between the files listed. 
## Difference between act1.37 and act1.38
~~~
1964c1964
<                     <PUT .ORPHANS ,OACTION .PRSACT>
---
>                     <PUT .ORPHANS ,OVERB .PRSACT>
~~~
## Difference between np.92 and np.93
~~~
259c259
<                   SAVOBJ (AV <AVEHICLE ,WINNER>))
---
>                   SAVOBJ (AV <AVEHICLE ,WINNER>) SF)
271a272
>                                 <OR <SET SF <1 .PV>> T>
275a277
>                                 <PUT .PV 1 .SF>
~~~

Timestamps of the original madadv.help and madadv.info are 771215 and 770614.
