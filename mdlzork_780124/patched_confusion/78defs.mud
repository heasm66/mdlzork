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
<DEFMAC GTRNN ('RM 'BIT)
  <FORM N==? <FORM CHTYPE <FORM ANDB .BIT <FORM RGLOBAL .RM>> FIX> 0>>
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
<DEFMAC RTRC ('RM 'BIT)
  <FORM PUT .RM ,RBITS <FORM XORB <FORM RBITS .RM> .BIT>>>



; "room definition"

<NEWSTRUC
 ROOM VECTOR
  RID     ATOM                  ;"room id"
  RDESC1  STRING                ;"long description"
  RDESC2  STRING                ;"short description"
  REXITS  EXIT                  ;"list of exits"
  ROBJS   <LIST [REST OBJECT]>  ;"objects in room"
  RACTION RAPPLIC               ;"room-action"
  RVARS   <PRIMTYPE WORD>       ;"slot for use of room function"
  RVAL    FIX                   ;"value for visiting"
  RBITS   <PRIMTYPE WORD>       ;"random flags"
  RRAND   ANY                   ;"random slot"
  RGLOBAL <PRIMTYPE WORD>>      ;"slot for globals"

;"flagword for <RBITS room>:
          bit-name   bit-tester"

<FLAGWORD RSEENBIT      ;"visited?"
          RLIGHTBIT             ;"endogenous light source?"
          RLANDBIT              ;"on land"
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
         '<<PRIMTYPE VECTOR> [REST ATOM <OR ROOM CEXIT DOOR NEXIT>]>>

; "conditional exit"
   
<NEWSTRUC
 CEXIT VECTOR
  CXFLAG   ATOM                 ;"condition flag"
  CXROOM   ROOM                 ;"room it protects"
  CXSTR    <OR FALSE STRING>    ;"description"
  CXACTION RAPPLIC              ;"exit function">

<NEWSTRUC
 DOOR VECTOR
  DOBJ     OBJECT               ;"the door"
  DROOM1   ROOM                 ;"one of the rooms"
  DROOM2   ROOM                 ;"the other one"
  DSTR     <OR FALSE STRING>    ;"what to print if closed"
  DACTION  RAPPLIC              ;"what to call to decide">

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
  SFLAGS  FIX   ;"flag bits for this verb">

; "SFLAGS of a SYNTAX"

<FLAGWORD SFLIP         ;"T -- flip args (for verbs like PICK)"
          SDRIVER       ;"T -- default syntax for gwimming and orphanery">

; "STRNN -- test a bit in the SFLAGS slot of a SYNTAX"

<DEFMAC STRNN ('S 'BIT)
        <FORM N==? <FORM CHTYPE <FORM ANDB .BIT <FORM SFLAGS .S>> FIX> 0>>

; "VARG -- types and locations of objects acceptable as args to verbs,
   these go in the SYN1 and SYN2 slots of a SYNTAX."

<NEWSTRUC
 VARG VECTOR
  VBIT  FIX             ;"acceptable object characteristics (default any)"
  VFWIM FIX             ;"spec for fwimming"
  VPREP <OR PREP FALSE> ;"preposition that must precede(?) object"
  VWORD FIX             ;"locations object may be looked for in">

; "flagbit definitions for VWORD of a VARG"

<FLAGWORD VABIT         ;"AOBJS -- look in AOBJS"
          VRBIT         ;"ROBJS -- look in ROBJS"
          VTBIT         ;"1 => try to take the object"
          VCBIT         ;"1 => care if can't take object">

; "VTRNN -- test a bit in the VWORD slot of a VARG"

<DEFMAC VTRNN ('V 'BIT) 
        <FORM N==? <FORM CHTYPE <FORM ANDB .BIT <FORM VWORD .V>> FIX> 0>>

"VTBIT & VCBIT interact as follows:
    vtbit
      vcbit

    1 1 = TAKE -- try to take, care if can't ('TURN WITH x')
    1 0 = TRY -- try to take, don't care if can't ('READ x')
    0 1 = MUST -- must already have object ('ATTACK TROLL WITH x') 
    0 0 = NO-TAKE (default) -- don't try, don't care ('TAKE x')
"

; "VERB -- name and function to apply to handle verb"

<NEWSTRUC
 VERB VECTOR
  VNAME ATOM
  VFCN RAPPLIC>

; "ORPHANS -- mysterious vector of orphan data"

<NEWSTRUC
 (ORPHANS) VECTOR
 OFLAG <OR FALSE ATOM>
 OVERB <OR FALSE VERB>
 OSLOT1 <OR FALSE OBJECT>
 OPREP <OR FALSE PREP>
 ONAME <OR FALSE ATOM>>

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
  OFLAGS    <PRIMTYPE WORD>             ;"flags THIS MUST BE SAME NOFFSET AS AFLAGS!"
  OFVAL     FIX                         ;"value for finding"
  OTVAL     FIX                         ;"value for putting in trophy case"
  ORAND     ANY                         ;"random slot"
  OGLOBAL   FIX                         ;"if obj is global, this holds bit"
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
          NO-CHECK-BIT          ;"no checks (put & drop):  for EVERY and VALUA"
          OPENBIT               ;"object is open"
          TOUCHBIT              ;"has this been touched?"
          ONBIT                         ;"light on?">

"extra stuff for flagword for objects"

"can i be opened?"
<DEFMAC OPENABLE? ('OBJ) <FORM TRNN .OBJ <FORM + ,DOORBIT ,CONTBIT>>>

"complement of the bit state" 
<DEFMAC DESCRIBABLE? ('OBJ) <FORM NOT <FORM TRNN .OBJ ,NDESCBIT>>>

"if object is a light or aflame, then flaming"
<DEFMAC FLAMING? ('OBJ)
    <FORM AND
          <FORM TRNN .OBJ ,FLAMEBIT>
          <FORM TRNN .OBJ ,LIGHTBIT>
          <FORM TRNN .OBJ ,ONBIT>>>

"if object visible and open or transparent, can see inside it"
<DEFMAC SEE-INSIDE? ('OBJ)
    <FORM AND <FORM OVIS? .OBJ>
          <FORM OR <FORM TRANSPARENT? .OBJ> <FORM OOPEN? .OBJ>>>>

<DEFMAC STAR? ('OBJ)
  <FORM NOT <FORM 0? <FORM CHTYPE <FORM ANDB ',STAR-BITS <FORM OGLOBAL .OBJ>> FIX>>>>



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
        #DECL ((EL) <<PRIMTYPE VECTOR> ATOM DOOR>)
        <FORM TRO <FORM DOBJ <FORM 2 <FORM LVAL EL>>> ,OPENBIT>>>

<DEFMAC COND-CLOSE ('DIR 'RM)
  <FORM PROG <LIST <LIST EL <FORM MEMQ .DIR <FORM REXITS .RM>>>>
        #DECL ((EL) <<PRIMTYPE VECTOR> ATOM DOOR>)
        <FORM TRZ <FORM DOBJ <FORM 2 <FORM LVAL EL>>> ,OPENBIT>>>

<DEFMAC GET-DOOR-ROOM ('RM 'LEAVINGS)
        <FORM PROG <LIST <LIST EL <FORM DROOM1 .LEAVINGS>>>
              <FORM COND
                    (<FORM ==? .RM <FORM LVAL EL>>
                          <FORM DROOM2 .LEAVINGS>)
                    (<FORM LVAL EL>)>>>

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
          #DECL ((X) STRING (Y) OBJECT)
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
             <TRO .X ,TOUCHBIT>
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
  #DECL ((ADV) ADV (WEAPONS) <LIST [REST OBJECT]>)
  <MAPF <>
    <FUNCTION (X) #DECL ((X) OBJECT)
      <COND (<MEMQ .X .WEAPONS>
             <MAPLEAVE T>)>>
    <AOBJS .ADV>>>

<DEFINE LIGHT-SOURCE (ME)
        #DECL ((ME) ADV)
        <MAPF <>
              <FUNCTION (X)
                 #DECL ((X) OBJECT)
                 <COND (<NOT <TRNN .X ,LIGHTBIT>>
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
        #DECL ((INBUF) STRING (NO-IS-BAD?) <OR ATOM FALSE> (INCHAN) CHANNEL)
        <RESET .INCHAN>
        <READSTRING .INBUF .INCHAN ,READER-STRING>
        <RESET .INCHAN>
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
                                          ,NULL-EXIT () <> 0 0 0 T 0>
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
                                   <> () <> 0 0 0 <> 0 5 0 ,NULL-SYN <> <>]
                                  OBJECT>>>
               <SETG OBJECTS (.OBJ !,OBJECTS)>
               .OBJ)>>

<DEFINE FIND-DOOR (RM OBJ)
        #DECL ((RM) ROOM (OBJ) OBJECT)
        <REPEAT ((L <REXITS .RM>) TD)
          #DECL ((L) <<PRIMTYPE VECTOR> [REST ATOM <OR DOOR ROOM CEXIT NEXIT>]>)
          <COND (<EMPTY? .L>
                 <RETURN <>>)
                (<AND <TYPE? <SET TD <2 .L>> DOOR>
                      <==? <DOBJ .TD> .OBJ>>
                 <RETURN .TD>)>
          <SET L <REST .L 2>>>>

<DEFINE FUNCTION-PRINT (FROB "AUX" (OUTCHAN .OUTCHAN))
  #DECL ((FROB) <OR ATOM NOFFSET APPLICABLE FALSE> (OUTCHAN) CHANNEL)
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


<DEFINE CONS-OBJ ("TUPLE" OBJS "AUX" (WINNER ,WINNER))
  #DECL ((OBJS) <TUPLE [REST STRING]> (WINNER) ADV)
  <MAPF <>
        <FUNCTION (X "AUX" (Y <FIND-OBJ .X>))
          #DECL ((Y) OBJECT (X) STRING)
          <OR <MEMQ .Y <AOBJS .WINNER>>
              <TAKE-OBJECT <FIND-OBJ .X> .WINNER>>>
        .OBJS>>

<DEFINE IN-ROOM? (OBJ "OPTIONAL" (HERE ,HERE) "AUX" TOBJ)
  #DECL ((OBJ) OBJECT (HERE) ROOM (TOBJ) <OR OBJECT FALSE>)
  <COND (<SET TOBJ <OCAN .OBJ>>
         <COND (<==? <OROOM .TOBJ> .HERE>)
               (<TRNN .TOBJ ,SEARCHBIT>
                <IN-ROOM? .TOBJ .HERE>)>)
        (<==? <OROOM .OBJ> .HERE>)>>
        
<DEFMAC RSEEN? ('OBJ) <FORM TRNN .OBJ ,RSEENBIT>>
<DEFMAC RLIGHT? ('OBJ) <FORM TRNN .OBJ ,RLIGHTBIT>>
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
<DEFMAC OOPEN? ('OBJ) <FORM TRNN .OBJ ,OPENBIT>>
<DEFMAC OTOUCH? ('OBJ) <FORM TRNN .OBJ ,TOUCHBIT>>

