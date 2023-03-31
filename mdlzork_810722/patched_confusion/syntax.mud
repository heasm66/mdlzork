
<DEFINE SYNTAX-CREATE (ARGL "AUX" (PREP <>) (PRSO ,EVARG) (PRSI ,EVARG)) 
        #DECL ((ARGL) LIST (PREP) <OR FALSE PREP> (PRSO PRSI) VARG)
        <MAPF <>
              <FUNCTION (ITEM "AUX" OPER) 
                      #DECL ((ITEM OPER) ANY)
                      <COND (<AND <TYPE? .ITEM ATOM>
                                  <TYPE? <SET VAL
                                              <PLOOKUP <ZSTR .ITEM>
                                                       ,WORDS-POBL>>
                                         PREP>
                                  <SET PREP .VAL>>)
                            (<AND <TYPE? .ITEM LIST> <NOT <LENGTH? .ITEM 1>>>
                             <COND (<==? <SET OPER <1 .ITEM>> verb>
                                    <SET VERB <2 .ITEM>>)
                                   (<==? .OPER objo>
                                    <SET PRSO <FWIM-ANA <REST .ITEM> .PREP>>)
                                   (<==? .OPER obji>
                                    <SET PRSI <FWIM-ANA <REST .ITEM> .PREP>>)
                                   (<==? .OPER name> <SET NAME <2 .ITEM>>)
                                   (<==? .OPER run>
                                    <SET ACTION <2 .ITEM>>
                                    <COND (<TYPE? .ACTION ATOM>
                                           <OR <GASSIGNED? .ACTION>
                                               <SETG .ACTION ,ZFALSE>>)
                                          (<ILLEGAL "Bad run/CREATE">)>)
                                   (<ILLEGAL "Unknown foo/CREATE">)>
                             <SET PREP <>>)
                            (<ILLEGAL "Bad syntax/CREATE">)>>
              .ARGL>
        <COND (<NOT .ACTION> <ILLEGAL "No routine specified/CREATE">)
              (<TYPE? <SET VAL <PLOOKUP <SET STR <ZSTR .NAME>> ,WORDS-POBL>>
                      VERB>
               <PUT .VAL 2 .ACTION>)
              (<PINSERT .STR
                        ,WORDS-POBL
                        <SET VAL <CHTYPE [<PSTRING .STR> .ACTION] VERB>>>)>
        <SET SYN <CHTYPE [.PRSO .PRSI .VAL 0] SYNTAX>>
        <COND
         (<TYPE? <SET VAL <PLOOKUP <SET STR <ZSTR .VERB>> ,ACTIONS-POBL>>
                 ACTION>
          <COND (<MAPR <>
                       <FUNCTION (SL "AUX" (X <1 .SL>)) 
                               #DECL ((SL) <UVECTOR [REST SYNTAX]> (X) SYNTAX)
                               <COND (<AND <==? <VPREP <1 .X>> <VPREP .PRSO>>
                                           <==? <VPREP <2 .X>> <VPREP .PRSI>>>
                                      <MAPLEAVE <PUT .SL 1 .SYN>>)>>
                       <2 .VAL>>)
                (<PUT .VAL 2 <UVECTOR .SYN !<2 .VAL>>>)>)
         (<PINSERT .STR
                   ,ACTIONS-POBL
                   <SET VAL
                        <CHTYPE [<PSTRING .STR>
                                 <UVECTOR .SYN>
                                 <PNAME .VERB>] ACTION>>>)>
        .VAL>

<DEFINE ZSTR (ATM "AUX" (STR <SPNAME .ATM>))
    #DECL ((ATM) ATOM (STR) STRING)
    <UPPERCASE <SUBSTRUC .STR 0 <MIN <LENGTH .STR> 5>>>>

<DEFINE FWIM-ANA (ARGL PREP "AUX" (V <IVECTOR 4>) (FWIM 0) (SUM 0) BIT)
    #DECL ((ARGL) LIST (PREP) <OR FALSE PREP> (FWIM) FIX (BIT) <OR FALSE FIX>)
    <PUT .V ,VPREP .PREP>
    <PUT .V ,VBIT -1>
    <COND (<EMPTY? .ARGL>
           <SET ARGL (-1 hand room)>)>
    <MAPF <>
          <FUNCTION (ITEM)
                    #DECL ((ITEM) ANY)
                    <COND (<TYPE? .ITEM ATOM>
                           <COND (<SET BIT <ZLOOKUP <SPNAME .ITEM> ,ZOBITS-POBL>>
                                  <SET FWIM <+ .FWIM .BIT>>)
                                 (<==? .ITEM take>
                                  <SET SUM <+ .SUM ,VTBIT ,VCBIT>>)
                                 (<==? .ITEM try>
                                  <SET SUM <+ .SUM ,VTBIT>>)
                                 (<==? .ITEM have>
                                  <SET SUM <+ .SUM ,VCBIT>>)
                                 (<==? .ITEM room>
                                  <SET SUM <+ .SUM ,VRBIT>>)
                                 (<==? .ITEM hand>
                                  <SET SUM <+ .SUM ,VABIT>>)>)
                          (<ILLEGAL "Bad syntax/CREATE">)>>
          .ARGL>
    <PUT .V ,VWORD .SUM>
    <CHTYPE <PUT .V ,VFWIM .FWIM> VARG>>

