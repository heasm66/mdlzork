
<DEFINE CEVENT-PRINT (EV "AUX" (OUTCHAN .OUTCHAN))
    #DECL ((EV) CEVENT)
    <PRINC "#CEVENT [">
    <COND (<CFLAG .EV> <PRINC "ENABLED">)
          (<PRINC "DISABLED">)>
    <PRINC " @ ">
    <PRIN1 <CTICK .EV>>
    <PRINC " -> ">
    <FUNCTION-PRINT <CACTION .EV>>
    <PRINC "]">>

<PRINTTYPE CEVENT ,CEVENT-PRINT>

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

<DEFINE OFF-APPLY (FOO "TUPLE" ARGS)
        #DECL ((FOO) NOFFSET)
        <COND (<G? <LENGTH .ARGS> 1>
               <ERROR TOO-MANY-ARGS OFF-APPLY>)
              (<OR <EMPTY? .ARGS>
                   <NOT <1 .ARGS>>>
               <DISPATCH .FOO>)
              (T
               <DISPATCH .FOO <1 .ARGS>>)>>

<DEFINE OFF-PRINT (FOO)
        #DECL ((FOO) NOFFSET)
        <PRINC "#NOFFSET ">
        <PRIN1 <GET-ATOM .FOO>>>

<APPLYTYPE NOFFSET ,OFF-APPLY>

<PRINTTYPE NOFFSET ,OFF-PRINT>

<DEFINE ROOM-PRINT (ROOM) 
        #DECL ((ROOM) ROOM)
        <PRINC "#ROOM [">
        <PSTRING-PRINT <RID .ROOM> <>>
        <PRINC " \\\"">
        <PRINC <RDESC2 .ROOM>>
        <PRINC "\\\"">
        <COND (<EMPTY? <REXITS .ROOM>>)
              (<PRINC " ">
               <REPEAT ((EX <REXITS .ROOM>))
                       <PRINC <1 .EX>>
                       <COND (<EMPTY? <SET EX <REST .EX 2>>> <RETURN>)
                             (<PRINC " ">)>>)>
        <COND (<EMPTY? <ROBJS .ROOM>>)
              (<MAPF <>
                     <FUNCTION (X) 
                             #DECL ((X) OBJECT)
                             <PRINC " ">
                             <PRINC <OID .X>>>
                     <ROBJS .ROOM>>)>
        <PRINC " ">
        <FUNCTION-PRINT <RACTION .ROOM>>
        <PRINC "]">>

<PRINTTYPE ROOM ,ROOM-PRINT>

<DEFINE OBJ-PRINT (OBJ) 
        #DECL ((OBJ) OBJECT)
        <PRINC "#OBJECT [">
        <COND (<EMPTY? <ONAMES .OBJ>> <PRINC !\?>)
              (<PSTRING-PRINT <OID .OBJ> <>>)>
        <PRINC " ">
        <PRINC <ODESC2 .OBJ>>
        <COND (<NOT <EMPTY? <OCONTENTS .OBJ>>>
               <PRINC " ">
               <MAPF <>
                     <FUNCTION (X) <PRINC <OID .X>> <PRINC " ">>
                     <OCONTENTS .OBJ>>)
              (<OCAN .OBJ> <PRINC " in "> <PRINC <OID <OCAN .OBJ>>> <PRINC " ">)
              (<PRINC " ">)>
        <FUNCTION-PRINT <OACTION .OBJ>>
        <PRINC "]">>

<PRINTTYPE OBJECT ,OBJ-PRINT>

<DEFINE HACK-PRINT (HACK)
  #DECL ((HACK) HACK)
  <PRINC "#HACK [">
  <FUNCTION-PRINT <HACTION .HACK>>
  <PRINC !\ >
  <PRIN1 <HOBJS .HACK>>
  <PRINC !\]>>

<PRINTTYPE HACK ,HACK-PRINT>

<DEFINE ACTION-PRINT (ACT "AUX" (OUTCHAN .OUTCHAN))
    #DECL ((ACT) ACTION (OUTCHAN) CHANNEL)
    <PRINC "#ACTION ">
    <PRINC <VSTR .ACT>>>
    
<PRINTTYPE ACTION ,ACTION-PRINT>

<DEFINE PSTRING-PRINT (OBJ "OPTIONAL" (TYPE-PRINT T) "AUX" (BP 36) C) 
   #DECL ((OBJ) <PRIMTYPE WORD> (BP C) FIX (TYPE-PRINT) <OR ATOM FALSE>)
   <COND (.TYPE-PRINT <PRINC !\#> <PRIN1 <TYPE .OBJ>> <PRINC !\ >)>
   <MAPF <>
    <FUNCTION () 
            <COND (<G? <SET BP <- .BP 7>> 0>
                   <COND (<N==? <SET C <CHTYPE <GETBITS .OBJ <BITS 7 .BP>> FIX>>
                                0>
                          <PRINC <ASCII .C>>)>)
                  (T <MAPLEAVE .OBJ>)>>>>

<PRINTTYPE PSTRING ,PSTRING-PRINT>

<PRINTTYPE PREP ,PSTRING-PRINT>

<PRINTTYPE DIRECTION ,PSTRING-PRINT>

<PRINTTYPE ADJECTIVE ,PSTRING-PRINT>

<PRINTTYPE BUZZ ,PSTRING-PRINT>

