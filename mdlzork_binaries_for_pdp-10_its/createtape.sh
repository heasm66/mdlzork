#!/bin/bash

# This file needs to be in its_installation_dir/madman/
FILE=madman.tape

#Remove tape file
if test -f "$FILE"; then
    rm $FILE
fi

#touch files to get right timestamp
#timestamp inside pdp-10 its becomes
#this times converted to Boston times
#I'm in Sweden, so the time is subtracted
#by 6 hours.
touch -t 197706130346.51 madman/madadv.jun12
touch -t 197706140829.10 madman/madadv.jun14
touch -t 197707010501.02 madman/madadv.jul1
touch -t 197712130448.06 madman/madadv.dec12
touch -t 197801230626.53 madman/madadv.jan23
touch -t 197801250521.37 madman/madadv.jan24
touch -t 197801260647.30 madman/madadv.jan26
touch -t 197801282045.07 madman/madadv.jan28

#Create tape
../tools/itstar/itstar.exe -cf madman.tape madman

#To import into ITS:
#	 1. ./start
#	 2. Ctrl-\ to get the "sim>" prompt
#	 3. attach tu0 madman/madman.tape
#	 4. continue
#	 5. its<CR>$G
#	 6. Ctrl-z
#	 7. :login <user>
#	 8. :dump
#	 9. load
#	10. madman;*<CR><CR>
#	11. quit
#	12. :logout
#	13. Ctrl-\
#	14. detach tu0
#	15. continue