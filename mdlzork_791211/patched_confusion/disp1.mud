<DEFINE DISPATCH-HACK ("AUX" Y)
  <MAPF <>
    <FUNCTION (X) #DECL ((X) OBJECT)
      <PUT .X ,OACTION <DISP-FROB <OACTION .X>>>>
    ,OBJECTS>
  <MAPF <>
    <FUNCTION (X) #DECL ((X) ROOM)
      <PUT .X ,RACTION <DISP-FROB <RACTION .X>>>
      <MAPF <>
        <FUNCTION (X)
          <COND (<TYPE? .X CEXIT>
                 <PUT .X ,CXACTION <DISP-FROB <CXACTION .X>>>)
                (<TYPE? .X DOOR>
                 <PUT .X ,DACTION <DISP-FROB <DACTION .X>>>)>>
        <REXITS .X>>>
    ,ROOMS>
  <MAPF <>
    <FUNCTION (X) #DECL ((X) HACK)
      <PUT .X ,HACTION <DISP-FROB <HACTION .X>>>>
    ,DEMONS>
  <MAPF <>
    <FUNCTION (X)
      #DECL ((X) LIST)
      <MAPF <>
        <FUNCTION (X)
          <COND (<TYPE? .X VERB>
                 <PUT .X ,VFCN <DISP-FROB <VFCN .X>>>)>>
        .X>>
    ,WORDS-POBL>
  <MAPF <>
    <FUNCTION (X)
      #DECL ((X) LIST)
      <MAPF <>
        <FUNCTION (X) #DECL ((X) ATOM)
          <COND (<AND <GASSIGNED? .X>
                      <TYPE? <SET Y ,.X> CEVENT>>
                 <PUT .Y ,CACTION <DISP-FROB <CACTION .Y>>>)>>
        .X>>
    <GET INITIAL OBLIST>>
  <MAPF <>
    <FUNCTION (X)
      #DECL ((X) ADV)
      <PUT .X ,AACTION <DISP-FROB <AACTION .X>>>>
    ,ACTORS>
  <SETG DISPATCH-TABLE <UVECTOR !<REST ,OFFL>>>
  <GUNASSIGN OFFL>
  <GUNASSIGN OFFLT>
  <GUNASSIGN COFFSET>
  "DONE">

<SETG COFFSET 0>
<GDECL (COFFSET) FIX (OFFL OFFLT) LIST>
<SETG OFFL (-1)>
<SETG OFFLT ,OFFL>
<DEFINE DISP-FROB (MUMBLE "AUX" TL X (CF ,COFFSET))
  #DECL ((TL) LIST (CF) FIX)
  <COND (<AND <TYPE? .MUMBLE ATOM>
              <GASSIGNED? .MUMBLE>>
         <COND (<TYPE? <SET X ,.MUMBLE> RSUBR-ENTRY>
                <COND (<L? .CF 0>
                       <SETG COFFSET <+ <- .CF> 2>>)
                      (<SETG COFFSET <+ .CF 1>>)>
                <SET TL <INST-GEN .X>>
                <SETG OFFLT <REST <PUTREST ,OFFLT .TL> <LENGTH .TL>>>
                <SETG .MUMBLE <CHTYPE ,COFFSET NOFFSET>>)
               (<TYPE? .X NOFFSET>
                .X)
               (.MUMBLE)>)
        (.MUMBLE)>>

<DEFINE INST-GEN (RENTRY "AUX" CV CV1 IOFFS)
  #DECL ((RENTRY) RSUBR-ENTRY (CV CV1) <<PRIMTYPE UVECTOR> [REST <PRIMTYPE WORD>]>)
  <SET IOFFS <ENTRY-LOC .RENTRY>>
  <SET CV <REST <SET CV1 <1 <1 .RENTRY>>> .IOFFS>>
  <REPEAT FOO (INST)
    <SET INST <1 .CV>>
    <COND (<==? <GOPCODE .INST> ,PUSHJ>
           <COND (<NOT <INDIRECT? .INST>>
                  <SET IOFFS <GETADR .INST>>
                  <RETURN (<CHTYPE <ORB ,BASE-INST .IOFFS> WORD>)>)
                 (<SETG COFFSET <- ,COFFSET>>
                  <REPEAT (TOFFS)
                    <SET INST <1 <SET CV <BACK .CV>>>>
                    <COND (<==? <GOPCODE .INST> ,ADDI>
                           <SET TOFFS <GETADR .INST>>
                           <SET IOFFS <GETADR <NTH .CV1 <+ .TOFFS 1>>>>
                           <RETURN
                            (<CHTYPE <ORB ,BASE-INST .IOFFS> WORD>
                             <CHTYPE <ORB ,BASE-INST <GETADR <NTH .CV1 .TOFFS>>> WORD>)
                            .FOO>)>>)>)>
    <SET CV <REST .CV>>>>

<DEFMAC GETADR ('FROB)
        <FORM CHTYPE <FORM GETBITS .FROB <BITS 18 0>> FIX>>

<DEFMAC GOPCODE ('FROB)
        <FORM CHTYPE <FORM GETBITS .FROB <BITS 9 27>> FIX>>

<DEFMAC INDIRECT? ('FROB)
        <FORM 1? <FORM CHTYPE <FORM GETBITS .FROB <BITS 1 22>> FIX>>>

<SETG PUSHJ *260*>
<SETG ADDI *271*>
<SETG BASE-INST *260755000000*> ; " PUSHJ P,(M)"
<MANIFEST PUSHJ ADDI BASE-INST>

