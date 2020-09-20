<SET REDEFINE T>

<DEFINE VFLOAD (X) <FLOAD .X> <PRINTSTRING <STRING .X " loaded">> <TERPRI>>
<FLOAD "81prim.mud">
<FLOAD "77defs.mud">
<FLOAD "77makstr.mud">
<FLOAD "81tell-repl.mud">
<FLOAD "77act1.mud">
<FLOAD "77act2.mud">
<FLOAD "77act3.mud">
<SETG OBJECTS ()>
<FLOAD "77np.mud">
<FLOAD "77rooms.mud">
<FLOAD "78melee.mud">
<FLOAD "77dung.mud">
        
;"BITS FOR 2ND ARG OF CALL TO TELL (DEFAULT IS 1)"

<MSETG LONG-TELL *400000000000*>

<MSETG PRE-CRLF 2>

<MSETG POST-CRLF 1>

<MSETG NO-CRLF 0>

<MSETG LONG-TELL1 <+ ,LONG-TELL ,POST-CRLF>>

<PSETG NULL-DESC "">

<PSETG NULL-EXIT <CHTYPE [] EXIT>>

<PSETG NULL-SYN ![!]>

<SAVE-IT>
