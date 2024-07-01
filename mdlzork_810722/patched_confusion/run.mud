"User name is used as seed in RANDOM and as name on the directory where SAVE- and SCRIPT-files are saved.
 Full name is used inside the game once for flavour.
 Change them for your own amusement."
<SETG XUNM "MTRZORK">                    ;"Username, traditionally 3-6 characters."
<PUT ,OUTCHAN 10 "Intrepid Adventurer">  ;"Full name"

<FLOAD "loadall.mud">

<CRLF>
<TELL "This copy is built with username '" 0 ,XUNM "' and with full name '"> 
<TELL <GET-NAME> 1 "'.">
<TELL "(See 'run.mud' what they do and on how to change them.)">
<CRLF>

<SAVE-IT>
