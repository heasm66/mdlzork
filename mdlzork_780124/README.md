# Mainframe Zork from 1978-01-24

## 81prim.mud
The "prim"-file is missing so I used the file from the 1981-version. This version has a different definition of FLAGWORD that will require changes in "defs".

Other changes to this file:
~~~
* Change EOL to "(Windows CR LF)"
* Change line 54 from:
	(<LENGTH? .ELEM 1> <ERROR NEWSTRUC>)>
  to
	(<LENGTH? .ELEM 1> <PRINT .ELEM> <ERROR NEWSTRUC>)>
~~~

## defs.89 --> 78defs.mud
The "defs"-file builds, among other things, FLAGWORDs. The 1978 version of FLAGWORD could take a second argument to each bit and if this second argument was something other than <>, FLAGWORD created a bit-tester MACRO. This functionality is no longer available so I removed all bit-testers in call to FLAGWORD and replaced them with new MACROs at the end of the file.

Example (for OVIS?):
~~~
<DEFMAC OVIS? ('OBJ) <FORM TRNN .OBJ ,OVISON>>
~~~
Other changes to this file:
~~~
* Change EOL to "(Windows CR LF)"
* Remove all \[FF] & [FF]
* Change OFFSET to NOFFSET on row 4, 5, 307, 546, 552 & 553
* Remove all "bit-testers" from calls to FLAGWORD
* Create "bit-testers" for:
	RSEEN?			RSEENBIT
	RLIGHT?			RLIGHTBIT
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
	OOPEN?			OPENBIT
	OTOUCH?			TOUCHBIT
  and place last in the file.
~~~

## makstr.25 --> 78makstr.mud
* Change EOL to "(Windows CR LF)"
* Change OFFSET to NOFFSET

## 09tell-repl.mud
* File is MTRs replacement version of TELL from Confusion.
* Change EOL to "(Windows CR LF)"
* Change row 33 to
    <PRINTSTRING <CHTYPE .S1 STRING> .OUTCHAN .L>

## act1.71 --> 78act1.mud
* Change EOL to "(Windows CR LF)"
* Change !\[ESC] on row 5 to <ASCII 27>
* Remove all [FF] & [NUL]
* Change OFFSET to NOFFSET

## act2.37 --> 78act2.mud
* Change EOL to "(Windows CR LF)"
* Remove all [FF] & [NUL]

## act3.18 --> 78act3.mud
* Change EOL to "(Windows CR LF)"
* Remove all [FF] & [NUL]

## rooms.165 --> 78rooms.mud
* Change EOL to "(Windows CR LF)"
* Remove all [FF] & [NUL]
* Change row 280 to:
	<AND <GET PACKAGE OBLIST> <LOOKUP "GLUE" <GET PACKAGE OBLIST>>> <LOOKUP "GROUP-GLUE" <GET INITIAL OBLIST>>
* Change OFFSET to NOFFSET
* Remark/change row 631-632 to:
	;"<READCHR ,INCHAN>
	  <OR ,ALT-FLAG <READCHR ,INCHAN>>"

## 78patch.mud
* This is a new file that includes som additions to make this Zork run under Confusion

## np.168 --> 78np.mud
* Change EOL to "(Windows CR LF)"
* Remove all [FF] & [NUL]
* Change #PREP OF!-WORDS to <FIND-PREP "OF"> on line 164 & 175
* change row 492 from
	      (<AND <NOT .OBJ> <NOT <EMPTY? .OBJ>>> <RETURN ,NEFALS .GET-OBJ>)>
	to
	      (<AND <LIT? .HERE> <NOT .OBJ> <NOT <EMPTY? .OBJ>>> <RETURN ,NEFALS .GET-OBJ>)>
  Without this the game crashes when you do things in dark rooms. The fix is from 81 version
  but I think the 77 alternative will also work.
  
## melee.105 --> 78melee.mud
* Change EOL to "(Windows CR LF)"
* Remove all [FF] & [NUL]
* Change OFFSET to NOFFSET

## dung.129 --> 78dung.mud
* Change EOL to "(Windows CR LF)"
* Remove all [FF] & [NUL]
* #OBJECT {arg} is the same as a function call like <OBJECT arg>, but Confusion doesn't understand that syntax.
  So change all occurances of (search-and-replace):
	#ROOM {			<ROOM 
	#OBJECT {		<OBJECT 
	#FIND-OBJ {		<FIND-OBJ 
	#CEXIT {		<CEXIT
	#EXIT {			<EXIT
	#DOOR {			<DOOR 
	}				>
* Change "\.lunch" to "lunch" on line 219

## mrf.65 --> 78mrf.mud
* Change EOL to "(Windows CR LF)"
* Remove all [FF] & [NUL]
* Add <GUNASSIGN TURNTO> to line 981 to release TURNTO and reattach it to new routine

## mrr.56 --> 78mrr.mud
* Change EOL to "(Windows CR LF)"
* Remove all [FF] & [NUL]
* #OBJECT {arg} is the same as a function call like <OBJECT arg>, but Confusion doesn't understand that syntax.
  So change all occurances of (search-and-replace):
	#ROOM {			<ROOM 
	#OBJECT {		<OBJECT 
	#FIND-OBJ {		<FIND-OBJ 
	#CEXIT {		<CEXIT
	#EXIT {			<EXIT
	#DOOR {			<DOOR 
	}				>

## 78mrf-patch.mud
* Adds things to make end-game work, sort of...
	- Added questions for "the Spanish Inquisition"
	- OFFSET for index of QUESTION and ANSWERs
	- Redefine NUMS for numbers up to 8
