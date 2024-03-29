
"Create the oblists for the vocabulary, if necessary"

<SETG WORDS <OR <GET WORDS OBLIST> <MOBLIST WORDS 23>>>

<SETG OBJECT-OBL <OR <GET OBJECTS OBLIST> <MOBLIST OBJECTS 23>>>

<SETG ACTIONS <MOBLIST ACTIONS 17>>

<SETG DIRECTIONS <MOBLIST DIRECTIONS>>

"Create the structure in which prepositional phrases are stored at parse
time.  Don't bother when COMPILEing or GLUEing."

<SETG LAST-IT <FIND-OBJ "#####">>

<GDECL (LAST-IT) OBJECT>

<COND (<OR <LOOKUP "COMPILE" <ROOT>> <GASSIGNED? GROUP-GLUE>>)
      (T
       <SETG PREPVEC
             [<CHTYPE [<FIND-PREP "WITH"> <FIND-OBJ "#####">] PHRASE>
              <CHTYPE [<FIND-PREP "WITH"> <FIND-OBJ "#####">] PHRASE>]>
       <SETG PREP2VEC
             [<CHTYPE [<FIND-PREP "WITH"> <FIND-OBJ "#####">] PHRASE>
              <CHTYPE [<FIND-PREP "WITH"> <FIND-OBJ "#####">] PHRASE>]>)>

"Randomness"

<SETG NEFALS #FALSE (1)>

;"funny falses for SEARCH-LIST and FWIM"

<SETG NEFALS2 #FALSE (2)>

<SETG SSV <IVECTOR 10 <>>>

;"Uvector for BUNCHing"

<SETG BUNUVEC <REST <IUVECTOR 8 <FIND-OBJ "#####">> 8>>

;"BUNCH object"

<TRO <SETG BUNCH-OBJ <FIND-OBJ "BUNCH">> ,OVISON>

;"VERBs which take BUNCHes"

<SETG BUNCHERS ()>

;"Current BUNCH"

<SETG BUNCH ,BUNUVEC>

<GDECL (BUNUVEC BUNCH) <UVECTOR [REST OBJECT]> (BUNCHERS) <LIST [REST VERB]>>



"EPARSE -- top level entry to parser.  calls SPARSE to set up the
parse-vector, then, calls SYN-MATCH to see if the sentence matches any
syntax of the verb given.  If a syntax matches, the orphan vector is
cleared out.  If no syntax matches, the appropriate message is printed
in SYN-MATCH (or below).  Only the T/Fness of the value is interesting."

<DEFINE EPARSE (PV VB "AUX" VAL) 
   #DECL ((VAL) ANY (PV) <VECTOR [REST STRING]> (VB) <OR ATOM FALSE>)
   <SETG PARSE-CONT <>>
   <COND
    (<SET VAL <SPARSE .PV .VB>>
     <COND (<OR .VB <==? .VAL WIN>> <ORPHAN <>>)
           (<SYN-MATCH .VAL>
            <ORPHAN <>>
            <COND (<==? <2 .VAL> ,BUNCH-OBJ>
                   <COND (<MEMQ <1 .VAL> ,BUNCHERS>
                          <PUT <2 .VAL> ,ORAND <1 .VAL>>
                          <PUT .VAL 1 ,BUNCHER>)
                         (<OR .VB
                              <TELL "Multiple inputs cannot be used with '"
                                    1
                                    <SPNAME <VNAME <1 .VAL>>>
                                    "'.">>
                          <>)>)
                  (T)>)>)>>

"SPARSE -- set up parse vector.  This is done in two steps.
        In the first, each word of the input is looked up in the various
interesting oblists. If a DIRECTION is seen before an ACTION, the parse
wins.  Also, if any word is not found, the parse fails.  As various parts
of speech are found, variables are set up saying so
        In the second, the vector and variables resulting are checked.  Any
missing are (attempted to be) set up from the orphans of the last parse.
If they can't be new orphans are generated.
        There are three possible results of all this:  WIN, which means the
parse is done and no syntax checking is needed; the Parse-Vector, meaning
the parse needs to have syntax checking done; and a FALSE, meaning the parse
has failed."

<DEFINE SPARSE SPAROUT (SV VB
                        "AUX" (WORDS ,WORDS) (OBJOB ,OBJECT-OBL) (PV ,PRSVEC)
                              (PVR <PUT <PUT <REST .PV> 1 <>> 2 <>>)
                              (ACTIONS ,ACTIONS) (DIRS ,DIRECTIONS)
                              (ORPH ,ORPHANS) (ORFL <OFLAG .ORPH>) (CONTIN <>)
                              (PRV ,PREPVEC) (HERE ,HERE) (ACTION <>) (PREP <>)
                              (ADJ <>) (BOBJS ,BUNUVEC) (INBUNCH <>) ATM NPREP
                              PPREP OBJ LOBJ VAL AVAL)
   #DECL ((SV) <VECTOR [REST STRING]> (VB ORFL INBUNCH CONTIN) <OR ATOM FALSE>
          (ACTIONS WORDS OBJOB DIRS) OBLIST (PV ORPH PRV PVR) VECTOR
          (ATM) <OR ATOM FALSE> (HERE) ROOM (ACTION) <OR FALSE ACTION>
          (NPREP PREP) <OR FALSE PREP> (ADJ) <OR FALSE ADJECTIVE> (AVAL) ANY
          (LOBJ) ANY (OBJ) <OR FALSE OBJECT> (PPREP) PHRASE
          (BOBJS) <UVECTOR [REST OBJECT]>)
   <SET VAL
    <MAPR <>
     <FUNCTION (VV "AUX" (X <1 .VV>)) 
        #DECL ((VV) <VECTOR [REST STRING]> (X) STRING)
        <COND
         (<EMPTY? .X> <MAPLEAVE T>)
         (<==? <1 .X> !\#>)
         (<AND <NOT .ACTION> <SET ATM <LOOKUP .X .ACTIONS>>>      ;"first verb?"
          <SET ACTION ,.ATM>)
         (<AND <NOT .ACTION> <SET ATM <LOOKUP .X .DIRS>>>
                                                       ;"direction before verb?"
          <PUT .PV 1 ,WALK!-WORDS>
          <PUT .PV 2 ,.ATM>
          <RETURN WIN .SPAROUT>                            ;"parse is a winner")
         (<PROG ()
            <COND
             (<EMPTY? .X> <MAPLEAVE T>)
             (<AND <SET ATM <LOOKUP .X .WORDS>>     ;"preposition or adjective?"
                   <COND (<AND .INBUNCH <PUT <1 .VV> 1 !\#> <>>)
                         (<TYPE? <SET AVAL ,.ATM> PREP>          ;"preposition?"
                          <COND (.PREP              ;"if already have one, lose"
                                 <OR .VB <TELL "Double preposition?">>
                                 <MAPLEAVE <>>)
                                (<SET PREP .AVAL>         ;"else set up prep")>)
                         (<TYPE? .AVAL ADJECTIVE>                  ;"adjective?"
                          <SET ADJ .AVAL>
                          <NOT <AND .ORFL        ;"if had ambig. noun, snarf it"
                                    <SET ATM <ONAME .ORPH>>
                                                ;"bad if 'take x','take red y'?"
                                    <OR <EMPTY? <2 .VV>> <PUT <2 .VV> 1 !\#>>
                                    <SET X <SPNAME .ATM>>>>)
                         (T                      ;"what else could it be???")>>)
             (<SET ATM <LOOKUP .X .OBJOB>>                            ;"object?"
              <COND
               (<SET OBJ <GET-OBJECT .ATM .ADJ>>        ;"is object accessible?"
                <AND <==? .OBJ ,IT-OBJECT>
                     <SET OBJ ,LAST-IT>>
                <SETG LAST-IT .OBJ>
                <COND (<AND <NOT <LENGTH? .VV 2>>
                            <=? <2 .VV> "AND">
                            <NOT <EMPTY? <SET X <3 .VV>>>>
                            <NOT <SET CONTIN <LOOKUP .X .ACTIONS>>>>
                       <PUT <1 .VV> 1 !\#>
                       <PUT <2 .VV> 1 !\#>
                       <PUT <SET BOBJS <BACK .BOBJS>> 1 .OBJ>
                       <SET ADJ <>>
                       <SET INBUNCH T>
                       <SET X <1 <SET VV <REST .VV 2>>>>
                       <AGAIN>)
                      (.CONTIN
                       <PUT .VV 2 <REST <2 .VV> 3>>
                       <SETG PARSE-CONT <REST .VV 2>>)
                      (<NOT <EMPTY? .BOBJS>>
                       <COND (<AND <2 .PV> <==? .PREP <FIND-PREP "OF">>>
                              <SET PVR <BACK .PVR>>)>
                       <PUT <1 .VV> 1 !\#>
                       <SET PREP <>>
                       <SETG BUNCH <PUT <BACK .BOBJS> 1 .OBJ>>
                       <SET OBJ ,BUNCH-OBJ>
                       <SET INBUNCH <>>
                       <SET BOBJS ,BUNUVEC>)>
                <COND (<EMPTY? .PVR>
                       <OR .VB <TELL "Too many objects specified?">>
                       <MAPLEAVE <>>)
                      (<==? .PREP <FIND-PREP "OF">>
                       <SET PREP <>>
                       <COND (<==? <2 .PV> .OBJ>)
                             (<OR .VB <TELL "That doesn't make sense!">>
                              <MAPLEAVE <>>)>)
                      (<PUT .PVR
                            1
                            <COND (.PREP
                                        ;"if hanging prep., make a prep. phrase"
                                   <SET PPREP <1 .PRV>>
                                   <SET PRV <REST .PRV>>
                                   <PUT .PPREP 1 .PREP>
                                   <SET PREP <>>
                                   <PUT .PPREP 2 .OBJ>)
                                  (.OBJ)>>
                       <SET PVR <REST .PVR>>)>
                                       ;"lose, mentioned more than two objects")
               (ELSE     ;"interpret why can't find/see/access object for loser"
                <COND
                 (<EMPTY? .OBJ>
                  <OR .VB
                      <COND (<LIT? .HERE>
                             <TELL "I can't see any" 0>
                             <COND (.ADJ
                                    <TELL " " 0 <PRSTR <CHTYPE .ADJ ATOM>>>)>
                             <TELL " " 1 <PRSTR .ATM> " here.">)
                            (<TELL "It is too dark in here to see.">)>>)
                 (<==? .OBJ ,NEFALS2>
                  <OR .VB
                      <TELL "I can't reach that from inside the "
                            1
                            <ODESC2 <AVEHICLE ,WINNER>>
                            ".">>)
                 (T
                  <ORPHAN T ;"ambiguous, set up orphan (ONAME slot is giveaway)"
                          <SET AVAL <OR .ACTION <AND .ORFL <OVERB .ORPH>>>>
                          <2 .PV>
                          .PREP
                          .ATM>
                  <COND (<NOT .VB>
                         <TELL "Which " 0 <PRSTR .ATM>>
                         <COND (.AVAL
                                <TELL " should I "
                                      1
                                      <PRLCSTR <VSTR .AVAL>>
                                      "?">)
                               (<TELL "?">)>)>)>
                <MAPLEAVE <>>)>
              <SET ADJ <>>
              T)
             (ELSE                                     ;"inform of unknown word"
              <OR .VB <TELL "I don't know the word " 1 .X>>
              <MAPLEAVE <>>)>>)>>
     .SV>>
   <COND (.VAL                               ;"second phase starts if first won"
          <COND (<AND <NOT .ACTION>                        ;"no verb specified?"
                      <NOT <SET ACTION        ;"here try to pick up orphan verb"
                                <AND .ORFL <OVERB .ORPH>>>>>
                 <OR .VB                                    ;"tsk, tsk, no verb"
                     <COND (<TYPE? <2 .PV> OBJECT>    ;"ask about orphan object"
                            <TELL "What should I do with the "
                                  1
                                  <ODESC2 <2 .PV>>
                                  "?">)
                           (<TELL "Huh?">
                                     ;"brilliant response to brilliant input")>>
                 <ORPHAN T <> <2 .PV>>
                 <>)
                (<AND <PUT .PV 1 .ACTION>                  ;"stuff winning verb"
                      .ADJ                ;"is there still an adjective about?">
 <OR .VB <TELL "Huh?">> <>)
                (<AND .ORFL
                      <SET NPREP <OPREP .ORPH>>                 ;"orphan prep.?"
                      <NOT <3 .PV>>
                      <NOT .PREP>
                      <==? <1 .PV> <OVERB .ORPH>>
                      <SET OBJ
                           <COND (<TYPE? <SET AVAL <2 .PV>> OBJECT> .AVAL)
                                 (<2 .AVAL>)>>
                      <PUT <SET PPREP <1 .PRV>> 1 .NPREP>
                      <PUT .PPREP 2 .OBJ>
                      <COND (<SET OBJ <OSLOT1 .ORPH>>           ;"orphan object"
                             <PUT .PV 2 .OBJ>
                             <PUT .PV 3 .PPREP>)
                            (<PUT .PV 2 .PPREP>)>
                      <>>)
                (.PREP  ;"handle case of 'pick frob up': make it 'pick up frob'"
                 <AND <TYPE? <SET LOBJ <1 <BACK .PVR>>> OBJECT>
                      <TOP <PUT <BACK .PVR>
                                1
                                <PUT <PUT <1 .PRV> 1 .PREP> 2 .LOBJ>>>>)
                (.PV                                              ;"win!!!")>)>>



"SYN-MATCH -- checks to see if the objects supplied match any of the
syntaxes of the sentence's verb.  if none do, and there are several
possibilities, the one marked 'DRIVER' is used to try to snarf orphans
or if all else fails, to make new orphans for next time."

<DEFINE SYN-MATCH SYN-ACT (PV
                   "AUX" (ACTION <1 .PV>) (OBJS <REST .PV>) (O1 <1 .OBJS>)
                         (O2 <2 .OBJS>) (DFORCE <>) (DRIVE <>) (GWIM <>) SYNN)
   #DECL ((ACTION) ACTION (PV OBJS) VECTOR (DRIVE DFORCE) <OR FALSE SYNTAX>
          (O1 O2) <OR FALSE OBJECT PHRASE> (SYNN) VARG (GWIM) <OR FALSE OBJECT>
          (SYN-ACT) ACTIVATION)
   <MAPF <>
      <FUNCTION (SYN) 
         #DECL ((SYN) SYNTAX)
         <COND
          (<SYN-EQUAL <SYN1 .SYN> .O1>                      ;"direct object ok?"
           <COND (<SYN-EQUAL <SYN2 .SYN> .O2>             ;"indirect object ok?"
                  <AND <STRNN .SYN ,SFLIP>
                              ;"make 'give dog bone' become 'give bone to dog'"
                       <PUT .OBJS 1 .O2> <PUT .OBJS 2 .O1>>
                  <RETURN                 ;"syntax a winner, try taking objects"
                            <TAKE-IT-OR-LEAVE-IT .SYN <PUT .PV 1 <SFCN .SYN>>>
                            .SYN-ACT>)
                 (<NOT .O2>           ;"no indirect object? might still be okay"
                  <COND (<STRNN .SYN ,SDRIVER> <SET DFORCE .SYN>)
                        (ELSE <SET DRIVE .SYN>
                                         ;"last tried is default if no driver")>)>)
          (<NOT .O1>                   ;"no direct object?  might still be okay"
           <COND (<STRNN .SYN ,SDRIVER> <SET DFORCE .SYN>) (ELSE <SET DRIVE .SYN>)>)>>
      <VDECL .ACTION>>
   <COND
    (<SET DRIVE <OR .DFORCE .DRIVE>>                      ;"lost for bad syntax"
     <COND (<AND <SET SYNN <SYN1 .DRIVE>> ;"here try to fill direct object slot"
                 <NOT .O1>
                 <NOT <0? <VBIT .SYNN>>>
                 <NOT <ORFEO .SYNN .OBJS>>       ;"try to fill slot from orphan"
                 <NOT <SET O1    ;"try to fill unspecified slot from room, etc."
                           <SET GWIM <GWIM-SLOT 1 .SYNN .ACTION .OBJS>>>>>
            <ORPHAN T .ACTION <> <VPREP .SYNN>>
                                        ;"all failed, orphan the verb and prep."
            <ORTELL .SYNN .ACTION .GWIM>)
           (<AND <SET SYNN <SYN2 .DRIVE>>
                                        ;"here try to fill indirect object slot"
                 <NOT .O2>
                 <NOT <0? <VBIT .SYNN>>>
                 <NOT <GWIM-SLOT 2 .SYNN .ACTION .OBJS>
                                                ;"fill empty from room if can">>
            <ORPHAN T .ACTION .O1 <VPREP .SYNN>> ;"all failed, orphan the world"
            <ORTELL .SYNN .ACTION .GWIM>)
           (ELSE                          ;"filled both slots, try syntax again"
            <TAKE-IT-OR-LEAVE-IT .DRIVE <PUT .PV 1 <SFCN .DRIVE>>>)>)
    (ELSE                                                        ;"total chomp!"
     <TELL "I can't make sense out of that."> <>)>>

"SYN-EQUAL -- takes a VARG and an object or phrase.  is the object
acceptable? That is, is the prep. (if any) a match, and is the object ok
(meaning do the OFLAGS slot of the object and the VBIT slot of the verb
agree.  Example: the object you  ATTACK must be a 'victim').  The VFWIM
slot is used to determine what objects to try to take."

<DEFINE SYN-EQUAL (VARG POBJ "AUX" (VBIT <VBIT .VARG>)) 
        #DECL ((VARG) VARG (POBJ) <OR FALSE PHRASE OBJECT> (VBIT) FIX)
        <COND (<TYPE? .POBJ PHRASE>
               <AND <==? <VPREP .VARG> <1 .POBJ>> <TRNN <2 .POBJ> .VBIT>>)
              (<TYPE? .POBJ OBJECT>
               <AND <NOT <VPREP .VARG>> <TRNN .POBJ .VBIT>>)
              (<AND <NOT .POBJ> <0? .VBIT>>)>>



"TAKE-IT-OR-LEAVE-IT -- finish setup of parse-vector.  take objects from room if
allowed, flush prepositions from prepositional phrases.  Its value is more or less
ignored by everyone."

<DEFINE TAKE-IT-OR-LEAVE-IT (SYN PV "AUX" (PV1 <2 .PV>) (PV2 <3 .PV>) OBJ) 
        #DECL ((SYN) SYNTAX (PV) VECTOR (PV1 PV2) <OR FALSE OBJECT PHRASE>
               (OBJ) <OR FALSE OBJECT>)
        <PROG ()
              <PUT .PV
                   2
                   <SET OBJ
                        <COND (<TYPE? .PV1 OBJECT> .PV1)
                              (<TYPE? .PV1 PHRASE> <2 .PV1>)>>>
              <COND (<==? .OBJ ,BUNCH-OBJ> <SETG BUNCH-SYN .SYN>)
                    (.OBJ <OR <TAKE-IT .OBJ <SYN1 .SYN>> <RETURN <>>>)>
              <PUT .PV
                   3
                   <SET OBJ
                        <COND (<TYPE? .PV2 OBJECT> .PV2)
                              (<TYPE? .PV2 PHRASE> <2 .PV2>)>>>
              <AND .OBJ <RETURN <TAKE-IT .OBJ <SYN2 .SYN>>>>
              T>>

"TAKE-IT -- takes object, parse-vector, and syntax bits, tries to perform a TAKE of
the object from the room.  Its value is more or less ignored."

<DEFINE TAKE-IT (OBJ VARG) 
        #DECL ((OBJ) OBJECT (VARG) VARG)
        <COND (<NOT <0? <CHTYPE <ANDB <OGLOBAL .OBJ> ,STAR-BITS> FIX>>>)
              (<NOT <VTRNN .VARG ,VRBIT>> <NOT <IN-ROOM? .OBJ>>)
              (<NOT <VTRNN .VARG ,VTBIT>>
               <COND (<NOT <VTRNN .VARG ,VCBIT>>) (<NOT <IN-ROOM? .OBJ>>)>)
              (<NOT <IN-ROOM? .OBJ>>)
              (<AND <CAN-TAKE? .OBJ> <SEARCH-LIST <OID .OBJ> <ROBJS ,HERE> <>>>
               <DO-TAKE .OBJ>)
              (<NOT <VTRNN .VARG ,VCBIT>>)
              (<TELL "You can't take the " 1 <ODESC2 .OBJ> "."> <>)>>

"DO-TAKE -- perform a take, returning whether you won"

<DEFINE DO-TAKE (OBJ "AUX" RES (PV ,PRSVEC) (SAV1 <1 .PV>) (SAV2 <2 .PV>)) 
        #DECL ((OBJ) OBJECT (PV) VECTOR (SAV1 SAV2) ANY)
        <PUT .PV 1 ,TAKE!-WORDS>
        <PUT .PV 2 .OBJ>
        <SET RES <TAKE T>>
        <PUT .PV 1 .SAV1>
        <PUT .PV 2 .SAV2>
        .RES>



"---------------------------------------------------------------------
GWIM & FWIM -- all this idiocy is used when the loser didn't specify
part of the command because it was 'obvious' what he meant.  GWIM is
used to try to fill it in by searching for the right object in the
adventurer's possessions and the contents of the room.
---------------------------------------------------------------------"

"GWIM-SLOT -- 'get what i mean' for one slot of the parse-vector.  takes
a slot number, a syntax spec, an action, and the parse-vector.  returns
the object, if it won.  seems a lot of pain for so little, eh?"

<DEFINE GWIM-SLOT (FX VARG ACTION OBJS "AUX" OBJ) 
        #DECL ((FX) FIX (VARG) VARG (ACTION) ACTION (OBJS) VECTOR
               (OBJ) <OR FALSE OBJECT>)
        <COND (<SET OBJ <GWIM <VFWIM .VARG> .VARG .ACTION>>
               <PUT .OBJS .FX .OBJ>
               .OBJ)>>

"GWIM -- 'get what i mean'.  takes attribute to check, what to check in
(adventurer and/or room), and verb.  does a 'TAKE' of it if found,
returns the object."

<DEFINE GWIM (BIT FWORD ACTION
              "AUX" (AOBJ? <VTRNN .FWORD ,VABIT>)
                    (ROBJ? <VTRNN .FWORD ,VRBIT>)
                    (DONT-CARE? <NOT <VTRNN .FWORD ,VCBIT>>)
                    (AOBJ <>) ROBJ (AV <AVEHICLE ,WINNER>))
        #DECL ((BIT) FIX (FWORD) VARG (ACTION) ACTION
               (AOBJ? ROBJ? CARE?) <OR ATOM FALSE>
               (AOBJ ROBJ AV) <OR OBJECT FALSE>)
        <AND .AOBJ? <SET AOBJ <FWIM .BIT <AOBJS ,WINNER> .DONT-CARE?>>>
        <COND (.ROBJ?
               <COND (<AND <SET ROBJ <FWIM .BIT <ROBJS ,HERE> .DONT-CARE?>>
                           <OR <NOT .AV>
                               <==? .AV .ROBJ>
                               <MEMQ .ROBJ <OCONTENTS .AV>>
                               <TRNN .ROBJ ,FINDMEBIT>>>
                      <COND (<AND <NOT .AOBJ>
                                  <TAKE-IT .ROBJ .FWORD>
                                  .ROBJ>)>)
                     (<OR .ROBJ <NOT <EMPTY? .ROBJ>>> ,NEFALS)
                     (.AOBJ)>)
              (.AOBJ)>>

"FWIM -- takes object specs, list of objects to look in, and whether or
not we care if can take object.  find one that can be manipulated (visible
and takeable, or visible and in something that's visible and open)"

<DEFINE FWIM DWIM (BIT OBJS NO-CARE "AUX" (NOBJ <>)) 
   #DECL ((NO-CARE) <OR ATOM FALSE> (BIT) FIX (OBJS) <LIST [REST OBJECT]>
          (NOBJ) <OR FALSE OBJECT>)
   <MAPF <>
    <FUNCTION (X) 
            #DECL ((X) OBJECT)
            <COND (<AND <OVIS? .X>
                        <OR .NO-CARE <CAN-TAKE? .X>>
                        <TRNN .X .BIT>>
                   <COND (.NOBJ <RETURN ,NEFALS .DWIM>)>
                   <SET NOBJ .X>)>
            <COND
             (<AND <OVIS? .X> <OOPEN? .X>>
              <MAPF <>
                    <FUNCTION (X) 
                            #DECL ((X) OBJECT)
                            <COND (<AND <OVIS? .X> <TRNN .X .BIT>>
                                   <COND (.NOBJ <RETURN ,NEFALS .DWIM>)
                                         (<SET NOBJ .X>)>)>>
                    <OCONTENTS .X>>)>>
    .OBJS>
   .NOBJ>



"GET-OBJECT -- used to see if an object is accessible.  it looks for
an object that can be described by an adjective-noun pair.
        Takes atom (from objects oblist), adjective, and verbosity flag. 
grovels over: ,STARS; ,HERE; ,WINNER looking for object (looks down to
one level of containment).
        returns:
               #FALSE () -- if fails because can't find it or it's dark in room
     NEFALS  = #FALSE (1) -- ambiguous object
     NEFALS2 = #FALSE (2) -- can't reach from in vehicle
        or
     object -- if found it.
"

<DEFINE GET-OBJECT GET-OBJ (OBJNAM ADJ
                            "AUX" OBJ (OOBJ <>) (HERE ,HERE)
                                  (AV <AVEHICLE ,WINNER>) (CHOMP <>))
        #DECL ((OOBJ OBJ AV) <OR OBJECT FALSE> (OBJNAM) ATOM (HERE) ROOM
               (ADJ) <OR ADJECTIVE FALSE> (CHOMP) <OR ATOM FALSE>
               (OBJL) <OR FALSE <LIST [REST OBJECT]>>)
        <COND (<AND <LIT? .HERE>
                    <SET OBJ <SEARCH-LIST .OBJNAM <ROBJS ,HERE> .ADJ>>>
               <COND (<AND .AV
                           <N==? .OBJ .AV>
                           <NOT <MEMQ .OBJ <OCONTENTS .AV>>>
                           <NOT <TRNN .OBJ ,FINDMEBIT>>>
                      <SET CHOMP T>)
                     (.OOBJ <RETURN ,NEFALS .GET-OBJ>)
                     (<SET OOBJ .OBJ>)>)
              (<AND <LIT? .HERE> <NOT .OBJ> <NOT <EMPTY? .OBJ>>> <RETURN ,NEFALS .GET-OBJ>)>
        <COND (.AV
               <COND (<SET OBJ <SEARCH-LIST .OBJNAM <OCONTENTS .AV> .ADJ>>
                      <SET CHOMP <>>
                      <SET OOBJ .OBJ>)
                     (<NOT <EMPTY? .OBJ>> <RETURN ,NEFALS .GET-OBJ>)>)>
        <COND (<SET OBJ <SEARCH-LIST .OBJNAM <AOBJS ,WINNER> .ADJ>>
               <COND (.OOBJ ,NEFALS) (.OBJ)>)
              (<NOT <EMPTY? .OBJ>>
               ,NEFALS)
              (.CHOMP ,NEFALS2)
              (.OOBJ)
              (<AND <GASSIGNED? .OBJNAM>
                    <SET OBJ ,.OBJNAM>
                    <TYPE? .OBJ OBJECT>
                    <GTRNN .HERE <OGLOBAL .OBJ>>
                    .OBJ>)>>

"SEARCH-LIST -- search room, or adventurer, or stars, or whatever.
        takes object name, list of objects, and verbosity. if finds one
frob under that name on list, returns it.  search is to one level of
containment.
"

<DEFINE SEARCH-LIST SL (OBJNAM SLIST ADJ
                        "OPTIONAL" (FIRST? T)
                        "AUX" (OOBJ <>) (NEFALS ,NEFALS) NOBJ)
   #DECL ((OBJNAM) ATOM (SLIST) <LIST [REST OBJECT]>
          (OOBJ NOBJ) <OR FALSE OBJECT> (ADJ) <OR FALSE ADJECTIVE>
          (FIRST?) <OR ATOM FALSE> (NEFALS) FALSE)
   <MAPF <>
         <FUNCTION (OBJ) 
                 #DECL ((OBJ) OBJECT)
                 <COND (<THIS-IT? .OBJNAM .OBJ .ADJ>
                        <COND (.OOBJ <RETURN .NEFALS .SL>) (<SET OOBJ .OBJ>)>)>
                 <COND (<AND <OVIS? .OBJ>
                             <OR <OOPEN? .OBJ> <TRANSPARENT? .OBJ>>
                             <OR .FIRST? <TRNN .OBJ ,SEARCHBIT>>>
                        <COND (<SET NOBJ
                                    <SEARCH-LIST .OBJNAM
                                                 <OCONTENTS .OBJ>
                                                 .ADJ
                                                 <>>>
                               <COND (.OOBJ <RETURN .NEFALS .SL>)
                                     (<SET OOBJ .NOBJ>)>)
                              (<==? .NOBJ .NEFALS> <RETURN .NEFALS .SL>)>)>>
         .SLIST>
   .OOBJ>



<SETG ORPHANS [<> <> <> <> <>]>

<DEFINE ORPHAN ("OPTIONAL" (FLAG <>) (ACTION <>) (SLOT1 <>) (PREP <>) (NAME
                                                                       <>)) 
        #DECL ((FLAG) <OR ATOM FALSE> (NAME) <OR ATOM FALSE>)
        <PUT <PUT <PUT <PUT <PUT ,ORPHANS ,ONAME .NAME> ,OPREP .PREP>
                       ,OSLOT1
                       .SLOT1>
                  ,OVERB
                  .ACTION>
             ,OFLAG
             .FLAG>>

<DEFINE ORFEO (SYN OBJS "AUX" (ORPH ,ORPHANS) (ORFL <OFLAG .ORPH>) SLOT1) 
        #DECL ((SYN) VARG (OBJS ORPH) VECTOR (ORFL) <OR ATOM FALSE>
               (SLOT1) <OR FALSE PHRASE OBJECT>)
        <COND (<NOT .ORFL> <>)
              (<SET SLOT1 <OSLOT1 .ORPH>>
               <AND <SYN-EQUAL .SYN .SLOT1> <PUT .OBJS 1 .SLOT1>>)>>

<DEFINE ORTELL (VARG ACTION GWIM "AUX" (PREP <VPREP .VARG>) SP) 
        #DECL ((VARG) VARG (ACTION) ACTION (PREP) <OR FALSE PREP> (SP) STRING
               (GWIM) <OR FALSE OBJECT>)
        <COND (.PREP
               <AND .GWIM
                    <TELL <VSTR .ACTION> 0 " ">
                    <TELL <ODESC2 .GWIM> 0 " ">>
               <TELL <PRSTR <CHTYPE .PREP ATOM>> 1 " what?">)
              (<TELL <VSTR .ACTION> 1 " what?">)>
        <>>



"PRSTR -- printing routine to print uc/lc atom pname"

<DEFINE PRSTR (ATM "AUX" SP) 
        #DECL ((ATM) ATOM (SP) STRING)
        <FOOSTR <SET SP <SPNAME .ATM>> <BACK ,SCRSTR <LENGTH .SP>> <>>>

<DEFINE PRLCSTR (STR) 
        #DECL ((STR) STRING)
        <FOOSTR .STR <BACK ,LSCRSTR <LENGTH .STR>> T T>>

<SETG SCRSTR <REST <ISTRING 5> 5>>

<SETG LSCRSTR <REST <ISTRING 15> 15>>

<DEFINE FOOSTR (NAM STR "OPTIONAL" (1ST T) (LC <>)) 
        #DECL ((STR NAM) STRING (1ST LC) <OR ATOM FALSE>)
        <MAPR <>
              <FUNCTION (X Y "AUX" (A <ASCII <1 .X>>)) 
                      #DECL ((X Y) STRING (A) FIX)
                      <COND (<AND <NOT .LC> .1ST <==? .X .NAM>>
                             <PUT .Y 1 <1 .X>>)
                            (<OR <L? .A <ASCII !\A>> <G? .A <ASCII !\Z>>>
                             <PUT .Y 1 <1 .X>>)
                            (<PUT .Y 1 <ASCII <+ .A 32>>>)>>
              .NAM
              .STR>
        .STR>



;"Here is some code for handling BUNCHes."

<SETG BUNCHER <CHTYPE [BUNCH!-WORDS BUNCHEM] VERB>>

<GDECL (BUNCHER) VERB>

;
"Action function for BUNCHing.
   ,BUNCH = UVECTOR of OBJECTS in the bunch
   ,BUNCH-SYN = SYNTAX for this call (for TAKE-IT-OR-LEAVE-IT)
   BUNCHEM sets up PRSVEC for each object in the bunch, tries to
do the TAKE, etc. if necessary and calls the VERB function.
"

<DEFINE BUNCHEM ("AUX" (VERB <ORAND ,BUNCH-OBJ>) (VFCN <VFCN .VERB>)
                       (PV ,PRSVEC) (OBJS ,BUNCH) (SYN ,BUNCH-SYN) (HERE ,HERE))
        #DECL ((VERB) VERB (VFCN) RAPPLIC (PV) VECTOR (HERE) ROOM
               (OBJS) <UVECTOR [REST OBJECT]> (SYN) SYNTAX)
        <PUT .PV 1 .VERB>
        <REPEAT ((BUN <REST .OBJS <LENGTH .OBJS>>) OBJ)
                #DECL ((BUN) <UVECTOR [REST OBJECT]> (OBJ) OBJECT)
                <SET OBJ <1 <SET BUN <BACK .BUN>>>>
                <TELL <ODESC2 .OBJ> 0 ":
 ">
                <PUT .PV 2 .OBJ>
                <COND (<TAKE-IT-OR-LEAVE-IT .SYN .PV> <APPLY-RANDOM .VFCN>)>
                <OR <==? ,HERE .HERE> <RETURN>>
                <AND <==? .OBJS .BUN> <RETURN>>>>


"PARSER AUXILIARIES"

<SETG INBUF <ISTRING 100>>

;"SET UP INPUT ERROR HANDLER TO CAUSE EPARSE TO FALSE OUT"

<SETG PRSVEC <IVECTOR 3 #FALSE ()>>

<DEFINE THIS-IT? (OBJNAM OBJ ADJ) 
        #DECL ((OBJNAM) ATOM (OBJ) OBJECT (ADJ) <OR FALSE ADJECTIVE>)
        <COND (<AND <OVIS? .OBJ>
                    <OR <==? .OBJNAM <OID .OBJ>> <MEMQ .OBJNAM <ONAMES .OBJ>>>>
               <COND (<NOT .ADJ>) (<MEMQ .ADJ <OADJS .OBJ>>)>)>>

<SETG LEXV <IVECTOR 18 '<REST <ISTRING 5> 5>>>

<GDECL (LEXV) <VECTOR [REST STRING]> (BRKS) STRING>

<DEFINE LEX (S
             "OPTIONAL" (SX <REST .S <LENGTH .S>>) (SILENT? <>)
             "AUX" (BRKS ,BRKS) (V ,LEXV) (TV .V) (S1 .S) (QUOT <>) (BRK !\ ))
   #DECL ((S S1 SX BRKS) STRING (SILENT? QUOT) <OR ATOM FALSE>
          (VALUE) <OR FALSE VECTOR> (TV V) <VECTOR [REST STRING]>
          (BRK) CHARACTER)
   <MAPR <>
         <FUNCTION (X "AUX" (STR <1 .X>)) 
                 #DECL ((X) <VECTOR [REST STRING]> (STR) STRING)
                 <PUT .X 1 <REST .STR <LENGTH .STR>>>>
         .V>
   <COND
    (<==? <1 .S> !\?> <PUT .V 1 <SUBSTRUC "HELP" 0 4 <BACK <1 .V> 4>>>)
    (<REPEAT (SLEN)
       #DECL ((SLEN) FIX)
       <COND
        (<OR <AND <==? <LENGTH .S1> <LENGTH .SX>> <SET BRK !\ >>
             <AND <MEMQ <1 .S1> .BRKS> <SET BRK <1 .S1>>>>
         <AND <G? <LENGTH .S1> <LENGTH .SX>>
              <OR <==? <1 .S1> !\'> <==? <1 .S1> !\">>
              <NOT .QUOT>
              <SET QUOT T>
              <SET V <REST .V>>>
         <COND
          (<N==? .S .S1>
           <COND
            (<EMPTY? .V> <OR .SILENT? <TELL "I'm too simple-minded for that.">>)
            (<PUT .V
                  1
                  <UPPERCASE <SUBSTRUC .S
                                       0
                                       <SET SLEN
                                            <MIN <- <LENGTH .S> <LENGTH .S1>>
                                                 5>>
                                       <BACK <1 .V> .SLEN>>>>
             <SET V <REST .V>>
             <AND <==? .BRK !\,>
                  <PUT .V 1 <SUBSTRUC "AND" 0 3 <BACK <1 .V> 3>>>
                  <SET V <REST .V>>>
             <AND <L? <LENGTH .V> 17>
                  <=? <1 <BACK .V>> "AND">
                  <=? <1 <BACK .V 2>> "AND">
                  <PUT <SET V <BACK .V>> 1 <REST <1 .V> 3>>>)>)>
         <COND (<==? <LENGTH .S1> <LENGTH .SX>>
                <COND (<AND <N==? .V ,LEXV> <=? <1 <SET V <BACK .V>>> "AND">>
                       <PUT .V 1 <REST <1 .V> <LENGTH <1 .V>>>>)>
                <RETURN .V>)>
         <SET S <REST .S1>>)>
       <SET S1 <REST .S1>>>)>
   ,LEXV>


<PSETG BRKS "\"'        :;.,?!
">

<DEFINE ANYTHING (S SX) 

        #DECL ((S SX) STRING)
        <MAPR <>
              <FUNCTION (X) 
                      <COND (<==? .X .SX> <MAPLEAVE <>>)
                            (<NOT <MEMQ <1 .X> ,BRKS>> <MAPLEAVE .X>)>>
              .S>>

<DEFINE UPPERCASE (STR) 
        #DECL ((STR) STRING)
        <MAPR <>
              <FUNCTION (S "AUX" (C <ASCII <1 .S>>)) 
                      <COND (<AND <G? .C 96> <L=? .C 122>>
                             <PUT .S 1 <ASCII <- .C 32>>>)>>
              .STR>
        .STR>
