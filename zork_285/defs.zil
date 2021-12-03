;"DEFS - DEFS.81 Jun 30, 1977
  The MDL version of this file contains a lot of type definitions and some functions
  to manipulate these types and the lists and the vectors they contain. Much of it
  is predefined in ZIL and its object structure and isn't needed.
  In some cases routines is needed to extract the same information from the new 
  types as is stored in the MDL ones. This is especially true for the verb-type."

;"ROOM DEFINITIONS
  Good practice is to define new object properties with PROPDEF. It's not
  requiered but you then could have a default value for them and wouldn't
  need to specify the property when they have the default value."
  
<PROPDEF RDESC1 <>>     ;"LONG DESCRIPTION"
<PROPDEF RDESC2 <>>     ;"SHORT DESCRIPTION"
<PROPDEF RSEEN? <>>     ;"VISITED SWITCH"
<PROPDEF RLIGHT? <>>    ;"ENDOGENOUS LIGHT SOURCE SWITCH"
<PROPDEF RACTION <>>    ;"ROOM-ACTION FUNCTION"
<PROPDEF RVARS 0>       
<PROPDEF RVAL 0>        ;"VALUE FOR VISITING"

;"ADVENTURER"

<PROPDEF AROOM <>>
<PROPDEF ASCORE 0>

;"OBJECT DEFINITIONS"

<PROPDEF ODESC1 <>>     ;"DESCRIPTION WHEN ON GROUND"
<PROPDEF ODESC2 <>>     ;"SHORT DESCRIPTION"
<PROPDEF ODESC0 <>>     ;"DESCRIPTION WHEN UNTOUCHED"
<PROPDEF OACTION <>>    ;"APPLICABLE"
<PROPDEF OFLAGS 0>      ;"RANDOM FLAGS
                            1 VISIBLE
                            2 READABLE"
<PROPDEF OTOUCH? <>>    ;"HAS THIS BEEN TOUCHED?"
<PROPDEF OLIGHT? 0>     ;"LIGHT PRODUCER?
                           -1 OFF
                            1 ON
                            0 NO LIGHT PRODUCER"
<PROPDEF OFVAL 0>       ;"VALUE FOR FINDING IT"
<PROPDEF OTVAL 0>       ;"VALUE FOR PUTTING IN TROPHY CASE"
<PROPDEF ORAND <>>      ;"RANDOM SLOT"
<PROPDEF OREAD <>>      ;"TEXT WHEN READING"

;"BITS IN OFLAGS"

;"OBJECT visible if bit 1 is set on OFLAGS and ODESC1 have text."
<ROUTINE OVIS? (OBJ)
    <IFFLAG (DEBUG <TELL "OVIS?" CR>)>
    <AND <BTST <GETP .OBJ ,P?OFLAGS> 1>
         <GETP .OBJ ,P?ODESC1>>>

<ROUTINE READABLE? (OBJ)
    <IFFLAG (DEBUG <TELL "READABLE?" CR>)>
    <AND <BTST <GETP .OBJ ,P?OFLAGS> 2>
         <GETP .OBJ ,P?OREAD>>>

; "VERB DECLARATIONS"

;"The VERB number (position 7 in the vocabulary entry for the verb)
  points, through the VERBS (reversed ordered), to the SYNTAX entries
  for the verb.The SYNTAX-table starts with a byte containing the number
  of SYNTAX lines for this verb then follows records of 8 bytes for each
  SYNTAX-line  contains 8 bytes:
  
     0     1     2     3     4     5     6     7     8     9    10    11    ...
  -------------------------------------------------------------------------------
  |     |     |     |     |     |     |     |     |     |     |     |     |     |
  | #SL |  NO |  P1 |  P2 |  F1 |  F2 |  O1 |  O2 | ACT |  NO |  P1 |  P2 | ... |
  |     |  #1 |  #1 |  #1 |  #1 |  #1 |  #1 |  #1 |  #1 |  #2 |  #2 |  #2 | ... |
  -------------------------------------------------------------------------------  

    #SL         Number of SYNTAX lines for this verb
    NO  NOBJ    0   Number of OBJECT
    P1  PREP1   1   First preposition
    P2  PREP2   2   Second preposition
    F1  FIND1   3   1st OBJECTs FIND
    F2  FIND2   4   2nd OBJECTs FIND
    O1  OPTS1   5   1st OBJECTs oprions
    O2  OPTS2   6   2st OBJECTs options
    ACT ACTION  7   Points to row in ,ACTIONS/,PREACTIONS with right action/preaction-routine 
  The last one (ACTION) points, through the ACTIONS, to the right 
  action-routine for this verb."
<ROUTINE VFCN (V "AUX" SYNTAX-PTR)
    <COND (<WT? .V PS?VERB>
        <SET SYNTAX-PTR <GET ,VERBS <- 255 <GETB .V 7>>>>
        <SET SYNTAX-PTR <+ .SYNTAX-PTR 1>>
        <RETURN <GET ,ACTIONS <GETB .SYNTAX-PTR 7>>>)>
    <RETURN 0>>

;"VARGS, VSTR, VACTION?, VMAX

  In MDL this is stored along with the verb. ZIL has a more sophisticated
  way of handling syntax. These routines returns the right value for the
  different verbs as defined in the original."
<ROUTINE VARGS (V)
    <COND (<OR <VNO=? .V ,W?WALK ,W?UNTIE ,W?PUSH ,W?POUR ,W?READ> 
               <VNO=? .V ,W?WAVE ,W?TIE>> 
             <RETURN 1>)
          (T <RETURN 0>)>>

<ROUTINE VMAX (V)
    <COND (<VNO=? .V ,W?WALK> <RETURN 1>)
          (T <RETURN 2>)>>
          
<ROUTINE VACTION? (V)
    <COND (<VNO=? .V ,W?WALK> <RFALSE>)
          (T <RTRUE>)>>

<ROUTINE VSTR (V)
    <COND (<VNO=? .V ,W?TAKE> <TELL "Take what?" CR>)
          (<VNO=? .V ,W?THROW> <TELL "Throw what?" CR>)
          (<VNO=? .V ,W?UNTIE> <TELL "Untie what?" CR>)
          (<VNO=? .V ,W?GIVE> <TELL "Give what?" CR>)
          (<VNO=? .V ,W?PUSH> <TELL "Push what?" CR>)
          (<VNO=? .V ,W?MOVE> <TELL "Move what?" CR>)
          (<VNO=? .V ,W?POUR> <TELL "Pour what?" CR>)
          (<VNO=? .V ,W?READ> <TELL "Read what?" CR>)
          (<VNO=? .V ,W?WAVE> <TELL "Wave what?" CR>)
          (<VNO=? .V ,W?TIE> <TELL "Tie what?" CR>)
          (<VNO=? .V ,W?DROP> <TELL "Drop what?" CR>)
          (T <RFALSE>)>>

<ROUTINE VNO (V) <RETURN <GETB .V 7>>>

<ROUTINE VNO=? (V1 V2 "OPT" V3 V4 V5 V6 V7) 
    <COND (<OR <=? <VNO .V1> <VNO .V2>>
               <AND <N=? .V3 0> <=? <VNO .V1> <VNO .V3>>>
               <AND <N=? .V4 0> <=? <VNO .V1> <VNO .V4>>>
               <AND <N=? .V5 0> <=? <VNO .V1> <VNO .V5>>>
               <AND <N=? .V6 0> <=? <VNO .V1> <VNO .V6>>>
               <AND <N=? .V7 0> <=? <VNO .V1> <VNO .V7>>>>
             <RTRUE>)
          (T <RFALSE>)>>

<CONSTANT LOAD-MAX 8>
<CONSTANT SCORE-MAX 285>

; "UTILITY FUNCTIONS"

; "APPLY AN OBJECT FUNCTION"

<ROUTINE APPLY-OBJECT (OBJ "AUX" (OACTION <GETP .OBJ ,P?OACTION>))
    <COND (.OACTION <APPLY .OACTION>)>>

; "ROB-ADV:  TAKE ALL OF THE VALUABLES A HACKER IS CARRYING"

<ROUTINE ROB-ADV (WIN)
    <ROB .WIN ,THIEF>>

<ROUTINE ROB (WHAT WHERE "OPTIONAL" (PROB <>) "AUX" N X (ROBBED? <>))
    <SET X <FIRST? .WHAT>>
    <REPEAT ()
        <COND (<NOT .X> <RETURN .ROBBED?>)>
        <SET N <NEXT? .X>>
        <COND (<AND <G? <GETP .X ,P?OTVAL> 0>
                    <OR <NOT .PROB> <PROB .PROB>>>
                <MOVE .X .WHERE>
                <PUTP .X ,P?OTOUCH? T>
                <SET ROBBED? T>)>
        <SET X .N>>>

; "ROB-ROOM:  TAKE VALUABLES FROM A ROOM, PROBABILISTICALLY"

<ROUTINE ROB-ROOM (RM PROB)
    <ROB .RM ,THIEF .PROB>>

<ROUTINE LIGHT-SOURCE (ME)
    <MAP-CONTENTS (X .ME)
        <COND (<NOT <0? <GETP .X ,P?OLIGHT?>>>
                <RETURN <GET <GETPT .X ,P?SYNONYM> 0>>)>>
    <RFALSE>>
          
<ROUTINE PICK-ONE (VEC)
     <GET .VEC <RANDOM <GET .VEC 0>>>>

<ROUTINE GOTO (RM)
    <SETG HERE .RM>
    <PUTP ,WINNER ,P?AROOM ,HERE>                       ;"Update WINNERs room"
    <PUTP ,WINNER ,P?ASCORE <+ <GETP ,WINNER ,P?ASCORE> ;"Update SCORE with ROOM value"
                               <GETP .RM ,P?RVAL>>>
    <PUTP .RM ,P?RVAL 0>>                               ;"Set ROOM value to 0"

