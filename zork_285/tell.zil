;"TELL - TELL.35 Jun 28, 1977
  This is built into ZIL. The only addition is that the TELL token CR also
  sets the TELL-FLAG."

;"Modified token for CR that sets the TELL-FLAG."
<TELL-TOKENS 
    (CR CRLF)   <CRLF-AND-TELL-FLAG>
    D *         <PRINTD .X>
    N *         <PRINTN .X>
    C *         <PRINTC .X>
    B *         <PRINTB .X>>

<ROUTINE CRLF-AND-TELL-FLAG ()
    <SETG TELL-FLAG T> <CRLF>>

