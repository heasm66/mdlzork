<AND <L? ,MUDDLE 100> <USE "LSRTNS">>

; "applicables"
<NEWTYPE NOFFSET WORD>
<PUT RAPPLIC DECL '<OR ATOM FALSE NOFFSET>>

; "newtypes for parser"

<NEWTYPE BUZZ STRING>
<NEWTYPE DIRECTION ATOM>
<NEWTYPE ADJECTIVE ATOM>
<NEWTYPE PREP ATOM>



;"generalized oflags tester"

<DEFMAC TRNN ('OBJ 'BIT)
  <FORM N==? <FORM CHTYPE <FORM ANDB .BIT <FORM OFLAGS .OBJ>> FIX> 0>>
<DEFMAC RTRNN ('RM 'BIT)
  <FORM N==? <FORM CHTYPE <FORM ANDB .BIT <FORM RBITS .RM>> FIX> 0>>
<DEFMAC RTRZ ('RM 'BIT)
  <FORM PUT .RM ,RBITS <FORM ANDB <FORM RBITS .RM> <FORM XORB .BIT -1>>>>
<DEFMAC TRC ('OBJ 'BIT)
  <FORM PUT .OBJ ,OFLAGS <FORM XORB <FORM OFLAGS .OBJ> .BIT>>>
<DEFMAC TRZ ('OBJ 'BIT)
  <FORM PUT .OBJ ,OFLAGS <FORM ANDB <FORM OFLAGS .OBJ> <FORM XORB .BIT -1>>>>
<DEFMAC TRO ('OBJ 'BIT)
  <FORM PUT .OBJ ,OFLAGS <FORM ORB <FORM OFLAGS .OBJ> .BIT>>>
<DEFMAC RTRO ('RM 'BIT)
  <FORM PUT .RM ,RBITS <FORM ORB <FORM RBITS .RM> .BIT>>>



; "room definition"

<NEWSTRUC
 ROOM VECTOR
  RID     ATOM                  ;"room id"
  RDESC1  STRING                ;"long description"
  RDESC2  STRING                ;"short description"
  RSEEN?  <OR ATOM FALSE>       ;"visited?"
  RLIGHT? <OR ATOM FALSE>       ;"endogenous light source?"
  REXITS  EXIT                  ;"list of exits"
  ROBJS   <LIST [REST OBJECT]>  ;"objects in room"
  RACTION RAPPLIC               ;"room-action"
  RVARS   <PRIMTYPE WORD>       ;"slot for use of room function"
  RVAL    FIX                   ;"value for visiting"
  RBITS   <PRIMTYPE WORD>       ;"random flags"
  RRAND   ANY                   ;"random slot">

;"flagword for <RBITS room>:
          bit-name   bit-tester"

<FLAGWORD RLANDBIT              ;"on land"
          RWATERBIT             ;"water room"
          RAIRBIT               ;"mid-air room"
          RSACREDBIT            ;"thief not allowed"
          RFILLBIT              ;"can fill bottle here"
          RMUNGBIT              ;"room has been munged"
          RBUCKBIT              ;"this room is a bucket"
          RHOUSEBIT             ;"This room is part of the house">

; "exit"

<NEWTYPE EXIT 
         VECTOR
         '<<PRIMTYPE VECTOR> [REST ATOM <OR ROOM CEXIT NEXIT>]>>

; "conditional exit"
   
<NEWSTRUC
 CEXIT VECTOR
  CXFLAG   ATOM                 ;"condition flag"
  CXROOM   ROOM                 ;"room it protects"
  CXSTR    <OR FALSE STRING>    ;"description"
  CXACTION RAPPLIC              ;"exit function">

<NEWTYPE NEXIT STRING>          ;"unusable exit description"



; "PARSER related types"

; "ACTION -- top level type for verbs"

<NEWSTRUC
 ACTION VECTOR
  VNAME ATOM    ;"atom associated with this action"
  VDECL VSPEC   ;"syntaxes for this verb (any number)"
  VSTR STRING   ;"string to print when talking about this verb">

; "VSPEC -- uvector of syntaxes for a verb"

<NEWTYPE
 VSPEC UVECTOR
  '<<PRIMTYPE UVECTOR> [REST SYNTAX]>>

; "SYNTAX -- a legal syntax for a sentence involving this verb"

<NEWSTRUC
 SYNTAX VECTOR
  SYN1    VARG  ;"direct object, more or less"
  SYN2    VARG  ;"indirect object, more or less"
  SFCN    VERB  ;"function to handle this action"
  SFLIP   <OR ATOM FALSE>       ;"(?)"
  SDRIVER <OR ATOM FALSE>       ;"(?)">

; "VARG -- types and locations of objects acceptable as args to verbs,
   these go in the SYN1 and SYN2 slots of a SYNTAX."

<NEWSTRUC
 VARG VECTOR
  VBIT  FIX             ;"acceptable object characteristics"
  VPREP <OR PREP FALSE> ;"preposition that must precede(?) object"
  VWORD FIX             ;"locations object may be looked for in">

; "flagbit definitions for VWORD of a VARG"

<FLAGWORD VABIT         ;"look in AOBJS"
          VRBIT         ;"look in ROBJS"
          VTBIT         ;"no-take"
          VXBIT         ;"(?) turned on by '=' in VARG spec">

; "VTRNN -- test a bit in the VWORD slot of a VARG"

<DEFMAC VTRNN ('V 'BIT) 
        <FORM N==? <FORM CHTYPE <FORM ANDB .BIT <FORM VWORD .V>> FIX> 0>>

; "VERB -- name and function to apply to handle verb"

<NEWSTRUC
 VERB VECTOR
  VNAME ATOM
  VFCN RAPPLIC>

; "ORPHANS -- mysterious vector of orphan data"

<GDECL (ORPHANS)
       <VECTOR <OR FALSE ATOM>
               <OR FALSE VERB>
               <OR FALSE OBJECT>
               <OR FALSE PREP>
               <OR FALSE ATOM>>>

<AND? <MSETG OFLAG 1>
      <MSETG OVERB 2>
      <MSETG OSLOT1 3>
      <MSETG OPREP 4>
      <MSETG ONAME 5>>

; "prepositional phrases"

<NEWSTRUC
 PHRASE VECTOR
  PPREP PREP
  POBJ  OBJECT>



; "adventurer"

<NEWSTRUC
 ADV VECTOR
  AROOM     ROOM                        ;"where he is"
  AOBJS     <LIST [REST OBJECT]>        ;"what he's carrying"
  ASCORE    FIX                         ;"score"
  AVEHICLE  <OR FALSE OBJECT>           ;"what he's riding in"
  AOBJ      OBJECT                      ;"what he is"
  AACTION   RAPPLIC                     ;"special action for robot, etc."
  ASTRENGTH FIX                         ;"fighting strength"
  ARAND     ANY                         ;" ** reserved for future expansion ** "
  AFLAGS    <PRIMTYPE WORD>             ;"flags THIS MUST BE SAME NOFFSET AS OFLAGS!">

"bits in <AFLAGS adv>:
          bit-name  bit-tester"

<FLAGWORD ASTAGGERED            ;"staggered?">

; "object"

<NEWSTRUC
 OBJECT VECTOR
  OID       ATOM                        ;"unique name, SETG'd to this"
  ONAMES    <UVECTOR [REST ATOM]>       ;"synonyms"
  ODESC1    STRING                      ;"description when not carried"
  ODESC2    STRING                      ;"short description"
  ODESCO    <OR STRING FALSE>           ;"description when untouched"
  OACTION   RAPPLIC                     ;"object-action"
  OCONTENTS <LIST [REST OBJECT]>        ;"list of contents"
  OCAN      <OR FALSE OBJECT>           ;"what contains this"
  OFLAGS    <PRIMTYPE WORD>             ;"flags THIS MUST BE SAME OFFSET AS AFLAGS!"
  OTOUCH?   <OR ATOM FALSE>             ;"has this been touched?"
  OLIGHT?   FIX                         ;"light producer?"
  OFVAL     FIX                         ;"value for finding"
  OTVAL     FIX                         ;"value for putting in trophy case"
  ORAND     ANY                         ;"random slot"
  OOPEN?    <OR ATOM FALSE>             ;"is this open?"
  OSIZE     FIX                         ;"how big is it?"
  OCAPAC    FIX                         ;"how much can it hold?"
  OADJS     <UVECTOR [REST ADJECTIVE]>  ;"adjectives for this"
  OROOM     <OR FALSE ROOM>             ;"what room its in"
  OREAD     <OR FALSE STRING>           ;"reading material">

"bits in <OFLAGS object>:
          bit-name  bit-tester"

<FLAGWORD OVISON                ;"visible?"
          READBIT               ;"readable?"
          TAKEBIT               ;"takeable?"
          DOORBIT               ;"object is door"
          TRANSBIT      ;"object is transparent"
          FOODBIT               ;"object is food"
          NDESCBIT                      ;"object not describable"
          DRINKBIT              ;"object is drinkable"
          CONTBIT                       ;"object can be opened/closed"
          LIGHTBIT                      ;"object can provide light"
          VICBIT                        ;"object is victim"
          BURNBIT               ;"object is flammable"
          FLAMEBIT                      ;"object is on fire"
          TOOLBIT                       ;"object is a tool"
          TURNBIT                       ;"object can be turned"
          VEHBIT                        ;"object is a vehicle"
          FINDMEBIT                     ;"can be reached from a vehicle"
          SLEEPBIT                      ;"object is asleep"
          SEARCHBIT                     ;"allow multi-level access into this"
          SACREDBIT                     ;"thief can't take this"
          TIEBIT                        ;"object can be tied"
          ECHO-ROOM-BIT                 ;"nothing can be taken in echo room"
          ACTORBIT                      ;"object is an actor"
          WEAPONBIT                     ;"object is a weapon"
          FIGHTBIT              ;"object is in melee"
          VILLAIN                       ;"object is a bad guy"
          STAGGERED                     ;"object can't fight this turn"
          TRYTAKEBIT                    ;"object wants to handle not being taken"
          NO-CHECK-BIT          ;"ignore checks (in put & drop):  for EVERY and VALUA">
          
"extra stuff for flagword for objects"

"complement of the visible bit"
<MSETG OVISOFF *777777777776*>

"can i be opened?"
<DEFMAC OPENABLE? ('OBJ) <FORM TRNN .OBJ <FORM + ,DOORBIT ,CONTBIT>>>

"complement of the bit state" 
<DEFMAC DESCRIBABLE? ('OBJ) <FORM NOT <FORM TRNN .OBJ ,NDESCBIT>>>

"if object is a light or aflame, then flaming"
<DEFMAC FLAMING? ('OBJ)
    <FORM AND <FORM TRNN .OBJ ,FLAMEBIT> <FORM 1? <FORM OLIGHT? .OBJ>>>>

"if object visible and open or transparent, can see inside it"
<DEFMAC SEE-INSIDE? ('OBJ)
    <FORM AND <FORM OVIS? .OBJ>
          <FORM OR <FORM TRANSPARENT? .OBJ> <FORM OOPEN? .OBJ>>>>



; "demons"

<NEWSTRUC HACK VECTOR
          HACTION RAPPLIC
          HOBJS   <LIST [REST ANY]>
          "REST"
          HROOMS  <LIST [REST ROOM]>
          HROOM   ROOM
          HOBJ    OBJECT
          HFLAG   ANY>

; "Clock interrupts"

<NEWSTRUC CEVENT VECTOR
          CTICK   FIX
          CACTION <OR APPLICABLE NOFFSET>
          CFLAG   <OR ATOM FALSE>
          CID ATOM>




<SETG LOAD-MAX 100>
<SETG SCORE-MAX 0>

<GDECL (RAW-SCORE LOAD-MAX SCORE-MAX) FIX
       (RANDOM-LIST ROOMS SACRED-PLACES) <LIST [REST ROOM]>
       (STARS OBJECTS WEAPONS NASTIES) <LIST [REST OBJECT]>
       (PRSVEC) <VECTOR <OR FALSE VERB> <OR FALSE OBJECT DIRECTION>
                                        <OR FALSE OBJECT>>
       (WINNER PLAYER) ADV (HERE) ROOM (INCHAN OUTCHAN) CHANNEL (DEMONS) LIST
       (MOVES DEATHS) FIX (DUMMY YUKS) <VECTOR [REST STRING]>
       (SWORD-DEMON) HACK>



"UTILITY FUNCTIONS"

"TO OPEN DOORS"

<DEFMAC COND-OPEN ('DIR 'RM)
  <FORM PROG <LIST <LIST EL <FORM MEMQ .DIR <FORM REXITS .RM>>>>
        #DECL ((EL) <<PRIMTYPE VECTOR> ATOM CEXIT>)
        <FORM SETG <FORM CXFLAG <FORM 2 <FORM LVAL EL>>> T>>>

<DEFMAC COND-CLOSE ('DIR 'RM)
  <FORM PROG <LIST <LIST EL <FORM MEMQ .DIR <FORM REXITS .RM>>>>
        #DECL ((EL) <<PRIMTYPE VECTOR> ATOM CEXIT>)
        <FORM SETG <FORM CXFLAG <FORM 2 <FORM LVAL EL>>> <>>>>

"APPLY AN OBJECT FUNCTION"

<DEFMAC APPLY-OBJECT ('OBJ)
    <FORM PROG ((FOO <FORM OACTION .OBJ>))
          <FORM COND (<FORM NOT <FORM LVAL FOO>> <>)
                (<FORM TYPE? <FORM LVAL FOO> ATOM>
                 <FORM APPLY <FORM GVAL <FORM LVAL FOO>>>)
                (<FORM DISPATCH <FORM LVAL FOO>>)>>>

"FLUSH AN OBJECT FROM A ROOM"

<DEFINE REMOVE-OBJECT (OBJ "AUX" OCAN OROOM)
        #DECL ((OBJ) OBJECT (OCAN) <OR OBJECT FALSE> (OROOM) <OR FALSE ROOM>)
        <COND (<SET OCAN <OCAN .OBJ>>
               <PUT .OCAN ,OCONTENTS <SPLICE-OUT .OBJ <OCONTENTS .OCAN>>>)
              (<SET OROOM <OROOM .OBJ>>
               <PUT .OROOM ,ROBJS <SPLICE-OUT .OBJ <ROBJS .OROOM>>>)
              (<MEMQ .OBJ <ROBJS ,HERE>>
               <PUT ,HERE ,ROBJS <SPLICE-OUT .OBJ <ROBJS ,HERE>>>)>
        <PUT .OBJ ,OROOM <>>
        <PUT .OBJ ,OCAN <>>>

<DEFMAC INSERT-OBJECT ('OBJ 'ROOM)
        <FORM PUT
              .ROOM
              ,ROBJS
              (<FORM PUT .OBJ ,OROOM .ROOM> <CHTYPE <FORM ROBJS .ROOM> SEGMENT>)>>

<DEFMAC TAKE-OBJECT ('OBJ "OPTIONAL" ('WINNER ',WINNER))
        <FORM PUT
              .WINNER
              ,AOBJS
              (<FORM PUT .OBJ ,OROOM <>> <CHTYPE <FORM AOBJS .WINNER> SEGMENT>)>>

<DEFMAC DROP-OBJECT ('OBJ "OPTIONAL" ('WINNER ',WINNER))
        <FORM PUT .WINNER ,AOBJS <FORM SPLICE-OUT .OBJ <FORM AOBJS .WINNER>>>>

<DEFINE KILL-OBJ (OBJ WINNER)
        #DECL ((OBJ) OBJECT (WINNER) ADV)
        <COND (<MEMQ .OBJ <AOBJS .WINNER>>
               <PUT .WINNER ,AOBJS <SPLICE-OUT .OBJ <AOBJS .WINNER>>>)
              (<REMOVE-OBJECT .OBJ>)>>

<DEFINE FLUSH-OBJ ("TUPLE" OBJS "AUX" (WINNER ,WINNER))
  #DECL ((OBJS) <TUPLE [REST STRING]> (WINNER) ADV)
  <MAPF <>
        <FUNCTION (X "AUX" (Y <FIND-OBJ .X>))
          #DECL ((Y) OBJECT)
          <AND <MEMQ .Y <AOBJS .WINNER>>
               <DROP-OBJECT <FIND-OBJ .X> .WINNER>>>
        .OBJS>>

"ROB-ADV:  TAKE ALL OF THE VALUABLES A HACKER IS CARRYING"

<DEFINE ROB-ADV (WIN NEWLIST)
  #DECL ((WIN) ADV (NEWLIST) <LIST [REST OBJECT]>)
  <MAPF <>
    <FUNCTION (X) #DECL ((X) OBJECT)
      <COND (<AND <G? <OTVAL .X> 0> <NOT <TRNN .X ,SACREDBIT>>>
             <PUT .WIN ,AOBJS <SPLICE-OUT .X <AOBJS .WIN>>>
             <SET NEWLIST (.X !.NEWLIST)>)>>
    <AOBJS .WIN>>
  .NEWLIST>

"ROB-ROOM:  TAKE VALUABLES FROM A ROOM, PROBABILISTICALLY"

<DEFINE ROB-ROOM (RM NEWLIST PROB)
  #DECL ((RM) ROOM (NEWLIST) <LIST [REST OBJECT]> (PROB) FIX)
  <MAPF <>
    <FUNCTION (X) #DECL ((X) OBJECT)
      <COND (<AND <G? <OTVAL .X> 0>
                  <NOT <TRNN .X ,SACREDBIT>>
                  <OVIS? .X>
                  <PROB .PROB>>
             <REMOVE-OBJECT .X>
             <PUT .X ,OTOUCH? T>
             <SET NEWLIST (.X !.NEWLIST)>)
            (<TYPE? <ORAND .X> ADV>
             <SET NEWLIST <ROB-ADV <ORAND .X> .NEWLIST>>)>>
    <ROBJS .RM>>
  .NEWLIST>

<DEFINE VALUABLES? (ADV)
  #DECL ((ADV) ADV)
  <MAPF <>
    <FUNCTION (X) #DECL ((X) OBJECT)
      <COND (<G? <OTVAL .X> 0> <MAPLEAVE T>)>>
    <AOBJS .ADV>>>

<DEFINE ARMED? (ADV "AUX" (WEAPONS ,WEAPONS))
  #DECL ((ADV) ADV)
  <MAPF <>
    <FUNCTION (X) #DECL ((X) OBJECT)
      <COND (<MEMQ .X .WEAPONS>
             <MAPLEAVE T>)>>
    <AOBJS .ADV>>>

<DEFINE LIGHT-SOURCE (ME)
        #DECL ((ME) ADV)
        <MAPF <>
              <FUNCTION (X)
                 <COND (<NOT <0? <OLIGHT? .X>>>
                        <MAPLEAVE .X>)>>
              <AOBJS .ME>>>

<DEFINE GET-DEMON (ID "AUX" (OBJ <FIND-OBJ .ID>) (DEMS ,DEMONS))
  #DECL ((ID) STRING (OBJ) OBJECT (DEMS) <LIST [REST HACK]>)
  <MAPF <>
    <FUNCTION (X) #DECL ((X) HACK)
      <COND (<==? <HOBJ .X> .OBJ> <MAPLEAVE .X>)>>
    .DEMS>>

<DEFMAC PICK-ONE ('VEC) 
        <FORM NTH .VEC <FORM + 1 <FORM MOD <FORM RANDOM> <FORM LENGTH .VEC>>>>>

<DEFMAC CLOCK-DISABLE ('EV)
    <FORM PUT .EV ,CFLAG <>>>

<DEFMAC CLOCK-ENABLE ('EV)
    <FORM PUT .EV ,CFLAG T>>

<DEFINE YES/NO (NO-IS-BAD? "AUX" (INBUF ,INBUF) (INCHAN ,INCHAN)) 
        #DECL ((INBUF) STRING (NO-IS-BAD?) <OR ATOM FALSE>)
        <RESET .INCHAN>
        <READSTRING .INBUF .INCHAN ,READER-STRING>
        <COND (.NO-IS-BAD?
               <NOT <MEMQ <1 .INBUF> "NnfF">>)
              (T
               <MEMQ <1 .INBUF> "TtYy">)>>

<DEFMAC APPLY-RANDOM ('FROB "OPTIONAL" ('MUMBLE <>))
        <FORM COND
              (<FORM TYPE? .FROB ATOM>
               <COND (.MUMBLE
                      <FORM APPLY <FORM GVAL .FROB> .MUMBLE>)
                     (<FORM APPLY <FORM GVAL .FROB>>)>)
              (T <FORM DISPATCH .FROB .MUMBLE>)>>

<DEFINE DA (FN "OPTIONAL" (FOO <>)) #DECL ((FN) <OR APPLICABLE ATOM FIX>)
  <PROG ()
    <COND (<TYPE? .FN FIX> <DISPATCH .FN .FOO>)
          (<APPLICABLE? .FN>
           <COND (.FOO
                  <APPLY .FN .FOO>)
                 (<APPLY .FN>)>)
          (<GASSIGNED? .FN>
           <SET FN ,.FN>
           <AGAIN>)
          (<ERROR UNASSIGNED-VARIABLE!-ERRORS .FN DA>)>>>

"OLD MAZER"

<MOBLIST FLAG 17>

<PSETG NULL-DESC "">

<PSETG NULL-EXIT <CHTYPE [] EXIT>>

<PSETG NULL-SYN ![]>

<DEFINE FIND-ROOM (ID "AUX" ATM ROOM)
        #DECL ((ID) <OR ATOM STRING> (VALUE) ROOM
               (ROOM) ROOM (ATM) <OR ATOM FALSE>)
        <COND (<TYPE? .ID ATOM> <SET ID <SPNAME .ID>>)>
        <COND (<AND <SET ATM <LOOKUP .ID ,ROOM-OBL>>
                    <GASSIGNED? .ATM>>
                    ,.ATM)
              (<OR .ATM
                   <SET ATM <INSERT .ID ,ROOM-OBL>>>
               <SETG .ATM
                     <SET ROOM
                          <CHTYPE <VECTOR .ATM ,NULL-DESC ,NULL-DESC
                                          <> <> ,NULL-EXIT () <> 0 0 0 T>
                                 ROOM>>>
               <SETG ROOMS (.ROOM !,ROOMS)>
               .ROOM)>>

<DEFINE FIND-OBJ (ID "AUX" OBJ ATM)
        #DECL ((ID) <OR ATOM STRING> (OBJ) OBJECT (ATM) <OR ATOM FALSE> (VALUE) OBJECT)
        <COND (<TYPE? .ID ATOM> <SET ID <SPNAME .ID>>)>
        <COND (<AND <SET ATM <LOOKUP .ID ,OBJECT-OBL>>
                    <GASSIGNED? .ATM>>
               ,.ATM)
              (<OR .ATM
                   <SET ATM <INSERT .ID ,OBJECT-OBL>>>
               <SETG .ATM
                     <SET OBJ
                          <CHTYPE [.ATM ,NULL-SYN ,NULL-DESC ,NULL-DESC <>
                                   <> () <> 0 <> 0 0 0 <> <> 5 0 ,NULL-SYN <> <>]
                                  OBJECT>>>
               <SETG OBJECTS (.OBJ !,OBJECTS)>
               .OBJ)>>

<DEFINE FUNCTION-PRINT (FROB)
  #DECL ((FROB) <OR ATOM NOFFSET APPLICABLE FALSE>)
  <COND (<NOT .FROB> <PRINC "<>">)
        (<TYPE? .FROB RSUBR RSUBR-ENTRY>
         <PRIN1 <2 .FROB>>)
        (<TYPE? .FROB ATOM>
         <PRIN1 .FROB>)
        (<TYPE? .FROB NOFFSET>
         <PRINC "#NOFFSET ">
         <PRIN1 <GET-ATOM .FROB>>)
        (<PRINC "#FUNCTION ">
         <PRIN1 <GET-ATOM .FROB>>)>>

;"BIT-TESTERS"
<DEFMAC STAGGERED? ('OBJ) <FORM TRNN .OBJ ,ASTAGGERED>>
<DEFMAC OVIS? ('OBJ) <FORM TRNN .OBJ ,OVISON>>
<DEFMAC READABLE? ('OBJ) <FORM TRNN .OBJ ,READBIT>>
<DEFMAC CAN-TAKE? ('OBJ) <FORM TRNN .OBJ ,TAKEBIT>>
<DEFMAC DOOR? ('OBJ) <FORM TRNN .OBJ ,DOORBIT>>
<DEFMAC TRANSPARENT? ('OBJ) <FORM TRNN .OBJ ,TRANSBIT>>
<DEFMAC EDIBLE? ('OBJ) <FORM TRNN .OBJ ,FOODBIT>>
<DEFMAC DRINKABLE? ('OBJ) <FORM TRNN .OBJ ,DRINKBIT>>
<DEFMAC BURNABLE? ('OBJ) <FORM TRNN .OBJ ,BURNBIT>>
<DEFMAC FIGHTING? ('OBJ) <FORM TRNN .OBJ ,FIGHTBIT>>
