
<GDECL (GLOHI STAR-BITS) FIX>

<DEFINE MPOBLIST (ATM LEN)
    #DECL ((ATM) ATOM (LEN) FIX)
    <SETG .ATM <CHTYPE <IUVECTOR .LEN ()> POBLIST>>>

<DEFINE PINSERT (NAME OBL VAL "AUX" BUCKET BUCK TL)
        #DECL ((NAME) <OR STRING <PRIMTYPE WORD>> (OBL) POBLIST (VAL) ANY (BUCK) FIX
               (TL) <OR LIST FALSE>)
        <COND (<TYPE? .NAME STRING>
               <SET NAME <PSTRING .NAME>>)
              (<NOT <TYPE? .NAME PSTRING>>
               <SET NAME <CHTYPE .NAME PSTRING>>)>
        <SET BUCK <HASH .NAME .OBL>>
        <COND (<SET TL <MEMQ .NAME <SET BUCKET <NTH .OBL .BUCK>>>>
               <PUT .TL 2 .VAL>)
              (T
               <PUT .OBL .BUCK (.NAME .VAL !.BUCKET)>)>
        .VAL>

<DEFINE CEVENT (TICK APP FLG NAME "OPTIONAL" (DEATH <>)
                         "AUX" (OBL <GET INITIAL OBLIST>) ATM)
        #DECL ((TICK) FIX (APP) <OR ATOM NOFFSET> (FLG DEATH) <OR ATOM FALSE>
               (OBL) OBLIST (NAME) <OR ATOM STRING> (ATM) <OR ATOM FALSE>)
        <COND (<TYPE? .NAME STRING>
               <COND (<SET ATM <LOOKUP .NAME .OBL>>)
                     (T <SET ATM <INSERT .NAME .OBL>>)>)
              (<SET ATM .NAME>)>
        <SETG .ATM <CHTYPE [.TICK .APP .FLG .ATM .DEATH] CEVENT>>>

<DEFINE CEXIT (FLID RMID "OPTIONAL" (STR <>) (FLAG <>) (FUNCT <>) "AUX" ATM)
        #DECL ((STR) <OR FALSE STRING> (FLID RMID) <OR ATOM STRING>
               (ATM FUNCT) <OR ATOM FALSE> (FLAG) <OR ATOM FALSE>)
        <COND (<TYPE? .FLID ATOM> <SET FLID <SPNAME .FLID>>)>
        <SET ATM <OR <LOOKUP .FLID <GET FLAG OBLIST>>
                     <INSERT .FLID <GET FLAG OBLIST>>>>
        <SETG .ATM .FLAG>
        <CHTYPE <VECTOR .ATM <GET-ROOM .RMID> .STR .FUNCT> CEXIT>>

<DEFINE DOOR (OID RM1 RM2 "OPTIONAL" (STR <>) (FN <>) "AUX" (OBJ <GET-OBJ .OID>))
        #DECL ((OID) STRING (STR) <OR STRING FALSE> (FN) <OR ATOM FALSE>
               (OBJ) OBJECT (RM1 RM2) <OR STRING ROOM>)
        <COND (<FIND-DOOR <SET RM1 <GET-ROOM .RM1>> .OBJ>)
              (<FIND-DOOR <SET RM2 <GET-ROOM .RM2>> .OBJ>)
              (<CHTYPE [.OBJ .RM1 .RM2 .STR .FN] DOOR>)>>

<DEFINE EXIT ("TUPLE" PAIRS
              "AUX" (DOBL ,DIRECTIONS-POBL) (FROB <IVECTOR <LENGTH .PAIRS>>)
              DIR)
        #DECL ((PAIRS) <TUPLE [REST STRING <OR DOOR NEXIT CEXIT STRING ATOM>]>
               (DIR) DIRECTION (FROB) VECTOR (DOBL) POBLIST)
        <REPEAT ((F .FROB))
                #DECL ((F) VECTOR)
                <COND (<SET DIR <PLOOKUP <1 .PAIRS> .DOBL>>
                       <PUT .F 1 .DIR>
                       <COND (<TYPE? <2 .PAIRS> STRING>
                              <PUT .F 2 <GET-ROOM <2 .PAIRS>>>)
                             (<PUT .F 2 <2 .PAIRS>>)>
                       <SET F <REST .F 2>>)>
                <COND (<EMPTY? <SET PAIRS <REST .PAIRS 2>>> <RETURN>)>>
        <CHTYPE .FROB EXIT>>

<DEFINE ROOM (ID D1 D2 EX
              "OPTIONAL" (OBJS ()) (APP <>) (BIT ,RLANDBIT) (PROPS ())
              "AUX" (RM <GET-ROOM .ID>) VAL M)
        #DECL ((ID D1 D2) STRING (EX) EXIT (APP) <OR FALSE ATOM> (BIT VAL) FIX
               (RM) ROOM (PROPS) <LIST [REST ATOM ANY]>
               (M) <OR FALSE <LIST ATOM FIX>>)
        <SET VAL <COND (<SET M <MEMQ RVAL .PROPS>> <2 .M>) (0)>>
        <COND (<NOT <0? <CHTYPE <ANDB .BIT ,RENDGAME> FIX>>>
               <SETG EG-SCORE-MAX <+ ,EG-SCORE-MAX .VAL>>)
              (<SETG SCORE-MAX <+ ,SCORE-MAX .VAL>>)>
        <COND (<SET M <MEMQ RGLOBAL .PROPS>> <PUT .M 2 <+ <2 .M> ,STAR-BITS>>)>
        <PUT .RM ,ROBJS .OBJS>
        <PUT .RM ,RDESC1 .D1>
        <PUT .RM ,RDESC2 .D2>
        <PUT .RM ,REXITS .EX>
        <PUT .RM ,RACTION .APP>
        <PUT .RM ,RPROPS .PROPS>
        <MAPF <>
              <FUNCTION (X) #DECL ((X) OBJECT) <PUT .X ,OROOM .RM>>
              <ROBJS .RM>>
        <PUT .RM ,RBITS .BIT>
        .RM>

<DEFINE FIND-PREP (STR "AUX" VAL)
    #DECL ((STR) STRING)
    <COND (<SET VAL <PLOOKUP .STR ,WORDS-POBL>>
           <COND (<TYPE? .VAL PREP> .VAL)
                 (<ERROR NO-PREP!-ERRORS>)>)
          (<PINSERT .STR ,WORDS-POBL <CHTYPE <PSTRING .STR> PREP>>)>>

<DEFINE ADD-ACTION (NAM STR "TUPLE" DECL "AUX" (ACTIONS ,ACTIONS-POBL))
    #DECL ((NAM STR) STRING (DECL) <TUPLE [REST VECTOR]> 
           (ACTIONS) POBLIST)
    <PINSERT .NAM .ACTIONS <CHTYPE [<PSTRING .NAM> <MAKE-ACTION !.DECL> .STR] ACTION>>>

<DEFINE ADD-DIRECTIONS ("TUPLE" NMS "AUX" (DIR ,DIRECTIONS-POBL)) 
        #DECL ((NMS) <TUPLE [REST STRING]> (DIR) POBLIST)
        <MAPF <>
              <FUNCTION (X) <PINSERT .X .DIR <CHTYPE <PSTRING .X> DIRECTION>>>
              .NMS>>

<DEFINE DSYNONYM (STR
                  "TUPLE" NMS
                  "AUX" (DIR ,DIRECTIONS-POBL) (VAL <PLOOKUP .STR .DIR>))
        #DECL ((STR) STRING (NMS) <TUPLE [REST STRING]> (VAL) DIRECTION (DIR) POBLIST)
        <MAPF <> <FUNCTION (X) <PINSERT .X .DIR .VAL>> .NMS>>

<DEFINE VSYNONYM (N1 "TUPLE" N2 "AUX" VAL (ACTIONS ,ACTIONS-POBL)) 
        #DECL ((N1) STRING (N2) <TUPLE [REST STRING]> (VAL) ANY (ACTIONS) POBLIST)
        <COND (<SET VAL <PLOOKUP .N1 .ACTIONS>>
               <MAPF <> <FUNCTION (X) <PINSERT .X .ACTIONS .VAL>> .N2>)>>

"STUFF FOR ADDING TO VOCABULARY, ADDING TO LISTS (OF DEMONS, FOR EXAMPLE)."

<DEFINE ADD-BUZZ ("TUPLE" W) 
        #DECL ((W) <TUPLE [REST STRING]>)
        <ADD-ZORK BUZZ !.W>>

<DEFINE ADD-ZORK (NM "TUPLE" W) 
        #DECL ((NM) ATOM (W) <TUPLE [REST STRING]>)
        <MAPF <>
              <FUNCTION (X) 
                      #DECL ((X) STRING)
                      <PINSERT .X ,WORDS-POBL <CHTYPE <PSTRING .X> .NM>>>
              .W>>

<DEFINE SYNONYM (N1 "TUPLE" N2 "AUX" VAL (WORDS ,WORDS-POBL)) 
        #DECL ((N1) STRING (N2) <TUPLE [REST STRING]> (VAL) ANY (WORDS) POBLIST)
        <COND (<SET VAL <PLOOKUP .N1 .WORDS>>
               <MAPF <> <FUNCTION (X) <PINSERT .X .WORDS .VAL>> .N2>)>>

<DEFINE ADD-DEMON (X) #DECL ((X) HACK)
  <COND (<MAPR <>
          <FUNCTION (Y) #DECL ((Y) <LIST [REST HACK]>)
            <COND (<==? <HACTION <1 .Y>> <HACTION .X>>
                   <PUT .Y 1 .X>
                   <MAPLEAVE T>)>>
          ,DEMONS>)
        (<SETG DEMONS (.X !,DEMONS)>)>>

<DEFINE ADD-ACTOR (ADV "AUX" (ACTORS ,ACTORS))
  #DECL ((ADV) ADV (ACTORS) <LIST [REST ADV]>)
  <COND (<MAPF <>
               <FUNCTION (X) #DECL ((X) ADV)
                 <COND (<==? <AOBJ .X> <AOBJ .ADV>>
                        <MAPLEAVE T>)>>
               .ACTORS>)
        (<SETG ACTORS (.ADV !.ACTORS)>)>
  .ADV>

<DEFINE SADD-ACTION (STR1 ATM)
    <ADD-ACTION .STR1 "" [[.STR1 .ATM]]>>

<DEFINE 1ADD-ACTION (STR1 STR2 ATM)
    <ADD-ACTION .STR1 .STR2 [OBJ [.STR1 .ATM]]>>

<DEFINE 1NRADD-ACTION (STR1 STR2 ATM)
    <ADD-ACTION .STR1 .STR2 [NROBJ [.STR1 .ATM]]>>

"MAKE-ACTION:  Function for creating a verb.  Takes;

        vspec => [objspec {\"prep\"} {objspec} [pstring fcn] extras]

        objspec => OBJ | objlist

        objlist => ( objbits {fwimbits} {NO-TAKE} {MUST-HAVE} {TRY-TAKE} {=} )

        extras => DRIVER FLIP

Creates a VSPEC.
"

<DEFINE MAKE-ACTION ("TUPLE" SPECS "AUX" VV SUM (PREP <>) ATM VERB) 
   #DECL ((SPECS) TUPLE (VV) <PRIMTYPE VECTOR> (SUM) FIX (PREP ATM) ANY
          (VERB) VERB)
   <CHTYPE
    <MAPF ,UVECTOR
     <FUNCTION (SP "AUX" (SYN <VECTOR <> <> <> 0>) (WHR 1)) 
        #DECL ((SP) VECTOR (SYN) VECTOR (WHR) FIX)
        <MAPF <>
              <FUNCTION (ITM) 
                      #DECL ((ITM) ANY)
                      <COND (<TYPE? .ITM STRING> <SET PREP <FIND-PREP .ITM>>)
                            (<AND <==? .ITM OBJ>
                                  <SET ITM '(-1 REACH ROBJS AOBJS)>
                                  <>>)
                            (<AND <==? .ITM NROBJ>
                                  <SET ITM '(-1 ROBJS AOBJS)>
                                  <>>)
                            (<TYPE? .ITM LIST>
                             <SET VV <IVECTOR 4>>
                             <PUT .VV ,VBIT <1 .ITM>>
                             <COND (<AND <NOT <LENGTH? .ITM 1>>
                                         <TYPE? <2 .ITM> FIX>>
                                    <PUT .VV ,VFWIM <2 .ITM>>)
                                   (ELSE
                                    <PUT .VV ,VBIT -1>
                                    <PUT .VV ,VFWIM <1 .ITM>>)>
                             <AND <MEMQ = .ITM> <PUT .VV ,VBIT <VFWIM .VV>>>
                             <PUT .VV ,VPREP .PREP>
                             <SET SUM 0>
                             <SET PREP <>>
                             <AND <MEMQ AOBJS .ITM> <SET SUM <+ .SUM ,VABIT>>>
                             <AND <MEMQ ROBJS .ITM> <SET SUM <+ .SUM ,VRBIT>>>
                             <AND <MEMQ NO-TAKE .ITM> <SET SUM .SUM>>
                             <AND <MEMQ HAVE .ITM> <SET SUM <+ .SUM ,VCBIT>>>
                             <AND <MEMQ REACH .ITM> <SET SUM <+ .SUM ,VFBIT>>>
                             <AND <MEMQ TRY .ITM> <SET SUM <+ .SUM ,VTBIT>>>
                             <AND <MEMQ TAKE .ITM>
                                  <SET SUM <+ .SUM ,VTBIT ,VCBIT>>>
                             <PUT .VV ,VWORD .SUM>
                             <PUT .SYN .WHR <CHTYPE .VV VARG>>
                             <SET WHR <+ .WHR 1>>)
                            (<TYPE? .ITM VECTOR>
                             <SET VERB <FIND-VERB <1 .ITM>>>
                             <COND (<==? <VFCN .VERB> T>
                                    <PUT .VERB ,VFCN <2 .ITM>>)>
                             <PUT .SYN ,SFCN .VERB>)
                            (<==? .ITM DRIVER>
                             <PUT .SYN
                                  ,SFLAGS
                                  <CHTYPE <ORB <SFLAGS .SYN> ,SDRIVER> FIX>>)
                            (<==? .ITM FLIP>
                             <PUT .SYN
                                  ,SFLAGS
                                  <CHTYPE <ORB <SFLAGS .SYN> ,SFLIP> FIX>>)>>
              .SP>
        <OR <SYN1 .SYN> <PUT .SYN ,SYN1 ,EVARG>>
        <OR <SYN2 .SYN> <PUT .SYN ,SYN2 ,EVARG>>
        <CHTYPE .SYN SYNTAX>>
     .SPECS>
    VSPEC>>

"Default value for syntax slots not specified"

<SETG EVARG <CHTYPE [0 0 <> 0] VARG>>

<GDECL (EVARG) VARG>

;"To add VERBs to the BUNCHERS list"

<DEFINE ADD-BUNCHER ("TUPLE" STRS) 
        #DECL ((STRS) <TUPLE [REST STRING]>)
        <MAPF <>
              <FUNCTION (STR) 
                      #DECL ((STR) STRING)
                      <SETG BUNCHERS
                            (<FIND-VERB .STR> !,BUNCHERS)>>
              .STRS>>

; "For making end game questions"

<DEFINE ADD-QUESTION (STR VEC)
    #DECL ((STR) STRING (VEC) VECTOR)
    <PUT <SETG QVEC <BACK ,QVEC>>
         1
         <CHTYPE [.STR .VEC] QUESTION>>
    <AND <TYPE? <1 .VEC> OBJECT>
         <ADD-INQOBJ <1 .VEC>>>>

<DEFINE ADD-INQOBJ (OBJ)
    #DECL ((OBJ) OBJECT)
    <SETG INQOBJS (.OBJ !,INQOBJS)>>

<GDECL (GLOBAL-OBJECTS) <LIST [REST OBJECT]>>

<DEFINE GOBJECT (NAM IDS ADJS STR FLAGS
                 "OPTIONAL" (APP <>) (CONTS ()) (PROPS (OGLOBAL 0))
                 "AUX" OBJ BITS)
        #DECL ((IDS ADJS) <VECTOR [REST STRING]> (STR) STRING (FLAGS) FIX
               (APP) <OR ATOM FALSE> (OBJ) OBJECT 
               (NAM) <OR FALSE ATOM> (CONTS) LIST (PROPS) LIST)
        <SET OBJ <OBJECT .IDS .ADJS .STR .FLAGS .APP .CONTS .PROPS>>
        <COND (.NAM
               <COND (<GASSIGNED? .NAM> <SET BITS ,.NAM>)
                     (<SETG GLOHI <SET BITS <* ,GLOHI 2>>>
                      <SETG .NAM .BITS>)>)
              (<SETG GLOHI <SET BITS <* ,GLOHI 2>>>
               <SETG STAR-BITS <+ ,STAR-BITS .BITS>>)>
        <OGLOBAL .OBJ .BITS>
        <COND (<NOT <GASSIGNED? GLOBAL-OBJECTS>>
               <SETG GLOBAL-OBJECTS ()>)>
        <COND (<NOT <MEMQ .OBJ ,GLOBAL-OBJECTS>>
               <SETG GLOBAL-OBJECTS (.OBJ !,GLOBAL-OBJECTS)>)>
        .OBJ>

<DEFINE OBJECT (NAMES ADJS DESC FLAGS
                "OPTIONAL" (ACTION <>) (CONTENTS ()) (PROPS ())
                "AUX" (OBJ <GET-OBJ <1 .NAMES>>) (OBJS ,OBJECT-POBL))
        #DECL ((NAMES ADJS) <VECTOR [REST STRING]> (DESC) STRING (FLAGS) FIX
               (ACTION) <OR FALSE RAPPLIC> (CONTENTS) <LIST [REST OBJECT]>
               (PROPS) <LIST [REST ATOM ANY]> (OBJ) OBJECT (OBJS) POBLIST)
        <PUT .OBJ ,ONAMES
             <MAPF ,UVECTOR
                   <FUNCTION (X) #DECL ((X) STRING)
                     <COND (<PLOOKUP .X .OBJS>
                            <PSTRING .X>)
                           (T
                            <PINSERT .X .OBJS .OBJ>
                            <PSTRING .X>)>>
                   .NAMES>>
        <PUT .OBJ
             ,OADJS
             <MAPF ,UVECTOR <FUNCTION (W) <ADD-ZORK ADJECTIVE .W>> .ADJS>>
        <CHUTYPE <OADJS .OBJ> ADJECTIVE>
        <PUT .OBJ ,ODESC2 .DESC>
        <PUT .OBJ ,OFLAGS .FLAGS>
        <PUT .OBJ ,OACTION .ACTION>
        <PUT .OBJ ,OCONTENTS .CONTENTS>
        <MAPF <> <FUNCTION (X) <PUT .X ,OCAN .OBJ>> .CONTENTS>
        <PUT .OBJ ,OPROPS .PROPS>
        <SETG SCORE-MAX <+ ,SCORE-MAX <OTVAL .OBJ> <OFVAL .OBJ>>>
        .OBJ>

<DEFINE GET-OBJ (STR "AUX" ATM OBJ O)
    #DECL ((STR) STRING (ATM) <OR FALSE ATOM> (OBJ) OBJECT (O) <OR FALSE OBJECT>)
    <COND (<AND <SET O <PLOOKUP .STR ,OBJECT-POBL>>
                <==? <PSTRING .STR> <OID .O>>> .O)
          (<PINSERT .STR ,OBJECT-POBL
                 <SET OBJ <CHTYPE [<UVECTOR <PSTRING .STR>>
                                   '![] "" 0 <> () <> <> ()] OBJECT>>>
           <SETG OBJECTS (.OBJ !,OBJECTS)>
           .OBJ)>>

<DEFINE GET-ROOM (ID "AUX" ROOM) 
        #DECL ((ID) <OR ATOM STRING> (VALUE) ROOM (ROOM) ROOM)
        <COND (<PLOOKUP .ID ,ROOM-POBL>)
              (<PINSERT .ID
                        ,ROOM-POBL
                        <SET ROOM
                             <CHTYPE <VECTOR <PSTRING .ID>
                                             ,NULL-DESC
                                             ,NULL-DESC
                                             ,NULL-EXIT
                                             ()
                                             <>
                                             0
                                             ()>
                                     ROOM>>>
               <SETG ROOMS (.ROOM !,ROOMS)>
               .ROOM)>>

