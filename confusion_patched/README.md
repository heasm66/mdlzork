# Confusion ver 0.2 patched to compile with latest GCC and Visual Studio
There are some small changes to these files to make it build with the latest version of GCC and Visual Studio. 
The instructions are tested on CygWin, Ubuntu 20.04 LTS and Visual Studio 2022.
## Compiling on Ubuntu 22.04.4 LTS
~~~
Packages (sudo apt-get install package):
	build-essentials (12.9ubuntu3)
	libgc-dev (1:8.0.6-1.1build1)

Compile:
git clone https://github.com/heasm66/mdlzork.git
cd mdlzork/confusion_patched
make
~~~
## Compiling on CygWin
~~~
Packages (all may or may not be needed):
	gcc-g++ (version 11.4.0-1)
	perl (version 5.36.3-1)
	libgc-devel (version 8.2.6-1)
	make (version 4.4.1-1)
	
Compile:
git clone https://github.com/heasm66/mdlzork.git
cd mdlzork/confusion_patched
make
~~~
## Running CygWin files on Windows
If you want to run Confusion in Windows, compile for *CygWin* as above and distrubute the following files from the *CygWin* `bin` folder together in the same directory as `mdli.exe`:
~~~
cygwin1.dll
cyggc-1.dll
cyggcc_s-seh-1.dll
cyggccpp-1.dll
cygstdc++-6.dll
~~~
## Compiling on Windows with Visual Studio 2022
The following steps lean heavy on David Kinder's instructions for his [win32 version](https://www.ifarchive.org/indexes/if-archive/programming/mdl/interpreters/confusion/).
~~~
1. Get version 6.8 of Hans-J. Boehm's conservative garbage collector for C and C++
   from IF Archive (https://www.ifarchive.org/indexes/if-archive/programming/mdl/interpreters/confusion/).

2. Copy all Confusion files from \confusion_patched\ into \confusion_win32\confusion\. The files

    copying.c
    mdl_builtin_types.cpp
    mdl_builtin_types.h
    mdl_builtins.cpp
    mdl_builtins.h

   are pre-saved but can be regenerated with perl and awk during a compilation on CygWin
   and copied here.
   
   The files mdl_win32.h & mdl_win32.cpp are by David Kinder (slightly modified by me) and
   mimics some POSIX behaviour not supported in MSVC.

3. Copy the following 34 files from version 6.8 of Hans-J. Boehm's GC into confusion_winew\gc\

    \private\dbg_mlc.h
    \private\gc_pmark.h
    \private\gc_priv.h
    \allchblk.c
    \alloc.c
    \blacklst.c
    \dbg_mlc.c
    \dyn_load.c
    \finalize.c
    \gc.h
    \gc_allocator.h
    \gc_config_macros.h
    \gc_cpp.c
    \gc_cpp.h
    \gc_hdrs.h
    \gc_locks.h
    \gc_mark.h
    \gc_typed.h
    \gcconfig.h
    \headers.c
    \mach_dep.c
    \malloc.c
    \mallocx.c
    \mark.c
    \mark_rts.c
    \misc.c
    \new_hblk.c
    \obj_map.c
    \os_dep.c
    \ptr_chck.c
    \reclaim.c
    \stubborn.c
    \typd_mlc.c
    \version.h

   (You can also use David Kinder's more direct approach, described in step 2 in his
    instructions below.)

4. Open the solution (.sln) in Visual Studio and compile a release for x86 (be sure you
   compile for "release" and not !"debug" because the latter can run into memory problem
   when loading Zork.
~~~
## Compiling on MacOS
These are notes from a compilation done by Andrew Plotkin.

"I gave it a shot on a current Mac (ARM architecture). Got it to build.

I had to install the garbage-collector package via homebrew:
```
brew install bdw-gc
```
Then I added `-I/opt/homebrew/include` to `COPTFLAGS` in the `Makefile`. (Homebrew packages were on `/usr/local` on Intel MacOS, but `/opt/homebrew` on ARM MacOS.) Then `make` worked."

To link the `bdw-gc` library statically, instead of dynamically, you also need to change the `LIBS` in `Makefile` to:
```
LIBS = /opt/homebrew/lib/libgc.a /opt/homebrew/lib/libgccpp.a
```
## Precompiled binaries for win32 and Linux
There are precompiled binaries of *Confusion* for Win32, Linux and MacOS (ARM) available at this [link](https://drive.google.com/drive/folders/1zt2q_Tlz-GAKQvcgU9ibVRwb13X9Qrn3?usp=drive_link).
## README from orginal package
Note that the link GC is outdated and it now is at: https://www.hboehm.info/gc/
~~~
Confusion: A MDL interpreter
(or, "How to Fit a Small Program into a Large Machine")

For those poor souls still stuck in dawn of IF history, I present 
"Confusion" -- a MDL interpreter which works just well enough to play 
the original Zork all the way through.  The original Zork isn't for the 
faint of heart, and neither is Confusion; it is only available in 
source form, with minimal instruction (which follows).

Confusion is written in C++, though about 99% is pure C. To build it, you 
will need the Boehm-Demers-Weiser conservative garbage collector for 
C.  <http://www.hpl.hp.com/personal/Hans_Boehm/gc/> 
Some Linux distros have this as a package, called "gc-dev" or 
similar.  For the Mac, you'll need what is at this writing the very latest
version (7.2alpha2), for Linux, 6.8 appears to work.  For Windows... I 
recommend running Linux in a virtual machine.  It might build under 
cygwin, but I wouldn't bet on it. 

Once you have the GC, a simple "make" will build the interpreter. 
The Zork sources, somewhat modified for the limitations of this 
interpreter, are available at 
<http://www.russotto.net/~mrussotto/confusion/mdlzork.tgz> 

To play Zork, unpack this directory, change directory to the new 
"mdlzork" directory", run the interpreter with the parameter "-r 
MDL/MADADV.SAVE" e.g. "../confusion-src/mdli -r MDL/MADADV.SAVE". 
You should be at the white house: 
$ ../confusion-src/mdli -r MDL/MADADV.SAVE 
This Zork created July 6, 2009. 
West of House 
This is an open field west of a white house, with a boarded front 
door. 
There is a small mailbox here. 
A rubber mat saying 'Welcome to Zork!' lies by the door. 

The HELP, DOC and INFO commands do not work, as I do not have those files. 
I have played Zork all the way through, however, I have made some 
changes to the intepreter since then, so I cannot guarantee success.  If the 
interpreter crashes, let me know.  (note that there are bugs in the 
game; if you get dumped to a MDL LISTEN prompt, this might not be an 
interpreter bug) 
If you modify the MDL sources, you can re-build the game by running 
the interpreter with no parameters in the mdlzork directory, and 
typing 
<FLOAD "run.mud"> 
This will rebuild the MDL/MADADV.SAVE file and start the game. 

Confusion probably won't be developed further.

Notable features not supported: proper SAVE/RESTORE (an incompatible but
useful version is provided), GC-DUMP/GC-READ,  interrupts, processes, 
overflow, compiled code.
~~~
## README from David Kinder's win32 version
Note that the link GC is outdated and it now is at: https://www.hboehm.info/gc/
~~~
The following steps describe how to replicate what I did to build the
Confusion MDLI interpreter on Windows, using Microsoft's Visual Studio.

1) Get the Confusion sources from the same web location as you downloaded
   this archive. This should also be available from the IF-Archive and
   mirrors:

    http://www.ifarchive.org/indexes/if-archiveXprogrammingXmdlXinterpretersXconfusion.html

   Unpack the source so that the sources files are in a sub-directory
   of this directory called "confusion".

2) Get the sources for the Boehm garbage collector, at least version 6.8.
   This is available both from the IF-Archive, and Hans Boehm's web site:

    http://www.ifarchive.org/indexes/if-archiveXprogrammingXmdlXinterpretersXconfusion.html
    http://www.hpl.hp.com/personal/Hans_Boehm/gc/

   Unpack the source so that the sources files are in a sub-directory
   of this directory called "gc". Copy the contents (including sub-
   directories) of the directory "gc\include" into "gc".

3) Apply the patches in "diffs.txt" to the Confusion sources using a
   Windows build of "patch" (for example, such as the one that comes with
   Cygwin).

4) Generate these files and copy into the "confusion" directory:

    copying.c
    mdl_builtin_types.cpp
    mdl_builtin_types.h
    mdl_builtins.cpp
    mdl_builtins.h

   This is somewhat awkward: these files are generated as part of Matthew's
   Linux makefile, using perl and awk. To get round this I first did a build
   of Confusion using Cygwin, a Linux-like environment for Windows, then
   copied the above files from there.

5) Start Visual Studio and load the solution "mdli.sln". Rebuild the
   solution, which should produce a fully functioning "mdli.exe"
~~~
## MDL F/SUBR Implementet in Confusion and comparison with ZILF
~~~
F/SUBR         Name            Type    Routine                           In ZILF   Comment             
------         ----            ----    -------                           -------   -------
-              subtract        SUBR    mdl_builtin_eval_subtract         Yes       Only FIX            
*              multiply        SUBR    mdl_builtin_eval_multiply         Yes       Only FIX            
/              divide          SUBR    mdl_builtin_eval_divide           Yes       Only FIX            
+              add             SUBR    mdl_builtin_eval_add              Yes       Only FIX            
=?             equalp          SUBR    mdl_builtin_eval_equalp           Yes                           
==?            double_equalp   SUBR    mdl_builtin_eval_double_equalp    Yes                           
0?             zerop           SUBR    mdl_builtin_eval_zerop            Yes                           
1?             onep            SUBR    mdl_builtin_eval_onep             Yes                           
ABS            abs             SUBR    mdl_builtin_eval_abs                                            
ACCESS         access          SUBR    mdl_builtin_eval_access                                         
AGAIN          again           SUBR    mdl_builtin_eval_again            Yes                           
ALLTYPES       alltypes        SUBR    mdl_builtin_eval_alltypes         Yes                           
AND            and             FSUBR   mdl_builtin_eval_and              Yes                           
AND?           andp            SUBR    mdl_builtin_eval_andp             Yes                           
ANDB           andb            SUBR    mdl_builtin_eval_andb             Yes                           
APPLICABLE?    applicablep     SUBR    mdl_builtin_eval_applicablep      Yes                           
APPLY          apply           SUBR    mdl_builtin_eval_apply            Yes                           
APPLYTYPE      applytype       SUBR    mdl_builtin_eval_applytype        Yes                           
ARGS           args            SUBR    mdl_builtin_eval_args                                           
ASCII          ascii           SUBR    mdl_builtin_eval_ascii            Yes                           
ASSIGNED?      assigned        SUBR    mdl_builtin_eval_assigned         Yes                           
ATOM           atom            SUBR    mdl_builtin_eval_atom             Yes                           
BACK           back            SUBR    mdl_builtin_eval_back             Yes                           
BIND           bind            FSUBR   mdl_builtin_eval_bind             Yes                           
BITS           bits            SUBR    mdl_builtin_eval_bits                                           
BLOAT          bloat           SUBR    mdl_builtin_eval_bloat            Yes                           
BLOCK          block           SUBR    mdl_builtin_eval_block            Yes                           
BOUND?         bound           SUBR    mdl_builtin_eval_bound            Yes                           
CHANNEL        channel         SUBR    mdl_builtin_eval_channel                                        
CHTYPE         chtype          SUBR    mdl_builtin_eval_chtype           Yes                           
CHUTYPE        chutype         SUBR    mdl_builtin_eval_chutype                                        
CLOSE          close           SUBR    mdl_builtin_eval_close            Yes                           
COND           cond            FSUBR   mdl_builtin_eval_cond             Yes                           
CONS           cons            SUBR    mdl_builtin_eval_cons             Yes                           
COPYING        copying         SUBR    mdl_builtin_eval_copying                    Not used in Zork    
CRLF           crlf            SUBR    mdl_builtin_eval_crlf             Yes                           
DECL?          declp           SUBR    mdl_builtin_eval_declp            Yes                           
DEFINE         define          FSUBR   mdl_builtin_eval_define           Yes                           
DEFMAC         defmac          FSUBR   mdl_builtin_eval_defmac           Yes                           
DISABLE        disable         SUBR    mdl_builtin_eval_disable                    Not used in Zork    
EMPTY?         emptyp          SUBR    mdl_builtin_eval_emptyp           Yes                           
ENABLE         enable          SUBR    mdl_builtin_eval_enable                                         
ENDBLOCK       endblock        SUBR    mdl_builtin_eval_endblock         Yes                           
EQVB           eqvb            SUBR    mdl_builtin_eval_eqvb             Yes                           
ERRET          erret           SUBR    mdl_builtin_eval_erret                                          
ERROR          error           SUBR    mdl_builtin_eval_error            Yes                           
EVAL           eval            SUBR    mdl_builtin_eval_eval             Yes                           
EVALTYPE       evaltype        SUBR    mdl_builtin_eval_evaltype         Yes                           
EVENT          event           SUBR    mdl_builtin_eval_event                                          
EXPAND         expand          SUBR    mdl_builtin_eval_expand           Yes                           
FFRAME         fframe          SUBR    mdl_builtin_eval_fframe                                         
FILE-EXISTS?   file_existsp    SUBR    mdl_builtin_eval_file_existsp               Not used in Zork    
FILE-LENGTH    file_length     SUBR    mdl_builtin_eval_file_length      Yes                           
FIX            fix             SUBR    mdl_builtin_eval_fix              Yes                           
FLATSIZE       flatsize        SUBR    mdl_builtin_eval_flatsize                   Not used in Zork    
FLOAD          fload           SUBR    mdl_builtin_eval_fload            Yes                           
FLOAT          float           SUBR    mdl_builtin_eval_float                                          
FORM           form            SUBR    mdl_builtin_eval_form             Yes                           
FRAME          frame           SUBR    mdl_builtin_eval_frame                                          
FREEZE         freeze          SUBR    mdl_builtin_eval_freeze                                         
FUNCT          funct           SUBR    mdl_builtin_eval_funct                                          
FUNCTION       function        FSUBR   mdl_builtin_eval_function         Yes                           
G?             greaterp        SUBR    mdl_builtin_eval_greaterp         Yes                           
G=?            greaterequalp   SUBR    mdl_builtin_eval_greaterequalp    Yes                           
GASSIGNED?     gassigned       SUBR    mdl_builtin_eval_gassigned        Yes                           
GBOUND?        gbound          SUBR    mdl_builtin_eval_gbound           Yes                           
GC             gc              SUBR    mdl_builtin_eval_gc               Yes                           
GDECL          gdecl           FSUBR   mdl_builtin_eval_gdecl            Yes                           
GET            get             SUBR    mdl_builtin_eval_get                                            
GETBITS        getbits         SUBR    mdl_builtin_eval_getbits                                        
GETPROP        getprop         SUBR    mdl_builtin_eval_getprop          Yes                           
GETTIMEDATE    gettimedate     SUBR    mdl_builtin_eval_gettimedate                                    
GETTIMEOFDAY   gettimeofday    SUBR    mdl_builtin_eval_gettimeofday               Not used in Zork    
GUNASSIGN      gunassign       SUBR    mdl_builtin_eval_gunassign        Yes                           
GVAL           gval            SUBR    mdl_builtin_eval_gval             Yes                           
HANDLER        handler         SUBR    mdl_builtin_eval_handler                                        
IFORM          iform           SUBR    mdl_builtin_eval_iform                      Not used in Zork    
ILIST          ilist           SUBR    mdl_builtin_eval_ilist            Yes                           
IMAGE          image           SUBR    mdl_builtin_eval_image            Yes                           
INSERT         insert          SUBR    mdl_builtin_eval_insert           Yes                           
INT-LEVEL      int_level       SUBR    mdl_builtin_eval_int_level                                      
ISTRING        istring         SUBR    mdl_builtin_eval_istring          Yes                           
IUVECTOR       iuvector        SUBR    mdl_builtin_eval_iuvector                                       
IVECTOR        ivector         SUBR    mdl_builtin_eval_ivector          Yes                           
L?             lessp           SUBR    mdl_builtin_eval_lessp            Yes                           
L=?            lessequalp      SUBR    mdl_builtin_eval_lessequalp       Yes                           
LENGTH         length          SUBR    mdl_builtin_eval_length           Yes                           
LENGTH?        lengthp         SUBR    mdl_builtin_eval_lengthp          Yes                           
LIST           list            SUBR    mdl_builtin_eval_list             Yes                           
LISTEN         listen          SUBR    mdl_builtin_eval_listen                                         
LOAD           load            SUBR    mdl_builtin_eval_load                       Not used in Zork    
LOGOUT         logout          SUBR    mdl_builtin_eval_logout                     Not used in Zork    
LOOKUP         lookup          SUBR    mdl_builtin_eval_lookup           Yes                           
LSH            lsh             SUBR    mdl_builtin_eval_lsh              Yes                           
LVAL           lval            SUBR    mdl_builtin_eval_lval             Yes                           
MANIFEST       manifest        SUBR    mdl_builtin_eval_manifest                                       
MAPF           mapf            SUBR    mdl_builtin_eval_mapf             Yes                           
MAPLEAVE       mapleave        SUBR    mdl_builtin_eval_mapleave         Yes                           
MAPR           mapr            SUBR    mdl_builtin_eval_mapr             Yes                           
MAPRET         mapret          SUBR    mdl_builtin_eval_mapret           Yes                           
MAPSTOP        mapstop         SUBR    mdl_builtin_eval_mapstop          Yes                           
MAX            max             SUBR    mdl_builtin_eval_max              Yes                           
MEMBER         member          SUBR    mdl_builtin_eval_member           Yes                           
MEMQ           memq            SUBR    mdl_builtin_eval_memq             Yes                           
MIN            min             SUBR    mdl_builtin_eval_min              Yes                           
MOBLIST        moblist         SUBR    mdl_builtin_eval_moblist          Yes                           
MOD            mod             SUBR    mdl_builtin_eval_mod              Yes                           
MONAD?         monadp          SUBR    mdl_builtin_eval_monadp                                         
N=?            nequalp         SUBR    mdl_builtin_eval_nequalp          Yes                           
N==?           double_nequalp  SUBR    mdl_builtin_eval_double_nequalp   Yes                           
NEWTYPE        newtype         SUBR    mdl_builtin_eval_newtype          Yes                           
NEXTCHR        nextchr         SUBR    mdl_builtin_eval_nextchr                    Not used in Zork    
NOT            not             SUBR    mdl_builtin_eval_not              Yes                           
NTH            nth             SUBR    mdl_builtin_eval_nth              Yes                           
OBLIST?        oblistp         SUBR    mdl_builtin_eval_oblistp          Yes                           
OFF            off             SUBR    mdl_builtin_eval_off                                            
ON             on              SUBR    mdl_builtin_eval_on                                             
OPEN           open            SUBR    mdl_builtin_eval_open             Yes                           
OR             or              FSUBR   mdl_builtin_eval_or               Yes                           
OR?            orp             SUBR    mdl_builtin_eval_orp              Yes                           
ORB            orb             SUBR    mdl_builtin_eval_orb              Yes                           
PARSE          parse           SUBR    mdl_builtin_eval_parse            Yes                           
PNAME          pname           SUBR    mdl_builtin_eval_pname            Yes                           
PRIMTYPE       primtype        SUBR    mdl_builtin_eval_primtype         Yes                           
PRIN1          prin1           SUBR    mdl_builtin_eval_prin1            Yes                           
PRINC          princ           SUBR    mdl_builtin_eval_princ            Yes                           
PRINT          print           SUBR    mdl_builtin_eval_print            Yes                           
PRINTB         printb          SUBR    mdl_builtin_eval_printb                                         
PRINTSTRING    printstring     SUBR    mdl_builtin_eval_printstring                                    
PRINTTYPE      printtype       SUBR    mdl_builtin_eval_printtype        Yes                           
PROG           prog            FSUBR   mdl_builtin_eval_prog             Yes                           
PUT            put             SUBR    mdl_builtin_eval_put              Yes                           
PUTBITS        putbits         SUBR    mdl_builtin_eval_putbits                                        
PUTPROP        putprop         SUBR    mdl_builtin_eval_putprop          Yes                           
PUTREST        putrest         SUBR    mdl_builtin_eval_putrest          Yes                           
QUIT           quit            SUBR    mdl_builtin_eval_quit             Yes                           
QUOTE          quote           FSUBR   mdl_builtin_eval_quote            Yes                           
RANDOM         random          SUBR    mdl_builtin_eval_random                                         
READ           read            SUBR    mdl_builtin_eval_read                                           
READB          readb           SUBR    mdl_builtin_eval_readb                                          
READCHR        readchr         SUBR    mdl_builtin_eval_readchr                    Not used in Zork    
READSTRING     readstring      SUBR    mdl_builtin_eval_readstring       Yes       Only from file      
REMOVE         remove          SUBR    mdl_builtin_eval_remove           Yes                           
REP            rep             SUBR    mdl_builtin_eval_rep                        Not used in Zork    
REPEAT         repeat          FSUBR   mdl_builtin_eval_repeat           Yes                           
RESET          reset           SUBR    mdl_builtin_eval_reset                                          
REST           rest            SUBR    mdl_builtin_eval_rest             Yes                           
RESTORE        restore         SUBR    mdl_builtin_eval_restore                                        
RETRY          retry           SUBR    mdl_builtin_eval_retry                                          
RETURN         return          SUBR    mdl_builtin_eval_return           Yes                           
ROOT           root            SUBR    mdl_builtin_eval_root             Yes                           
SAVE           save            SUBR    mdl_builtin_eval_save                                           
SAVE-EVAL      save_eval       SUBR    mdl_builtin_eval_save_eval                                      
SET            set             SUBR    mdl_builtin_eval_set              Yes                           
SETG           setg            SUBR    mdl_builtin_eval_setg             Yes                           
SLEEP          sleep           SUBR    mdl_builtin_eval_sleep                                          
SNAME          sname           SUBR    mdl_builtin_eval_sname                                          
SORT           sort            SUBR    mdl_builtin_eval_sort             Yes                           
SPNAME         spname          SUBR    mdl_builtin_eval_spname           Yes                           
STRCOMP        strcomp         SUBR    mdl_builtin_eval_strcomp                    Not used in Zork    
STRING         string          SUBR    mdl_builtin_eval_string           Yes                           
STRUCTURED?    structuredp     SUBR    mdl_builtin_eval_structuredp      Yes                           
SUBSTRUC       substruc        SUBR    mdl_builtin_eval_substruc         Yes                           
TERPRI         terpri          SUBR    mdl_builtin_eval_terpri                                         
TFFRAME        tfframe         SUBR    mdl_builtin_eval_tfframe                    Not used in Zork    
TIME           time            SUBR    mdl_builtin_eval_time             Yes                           
TOP            top             SUBR    mdl_builtin_eval_top              Yes                           
TUPLE          tuple           SUBR    mdl_builtin_eval_tuple            Yes                           
TYPE           type            SUBR    mdl_builtin_eval_type             Yes                           
TYPE?          typep           SUBR    mdl_builtin_eval_typep            Yes                           
TYPEPRIM       typeprim        SUBR    mdl_builtin_eval_typeprim         Yes                           
UNPARSE        unparse         SUBR    mdl_builtin_eval_unparse          Yes                           
UNWIND         unwind          FSUBR   mdl_builtin_eval_unwind                                         
UTYPE          utype           SUBR    mdl_builtin_eval_utype                      Not used in Zork    
UVECTOR        uvector         SUBR    mdl_builtin_eval_uvector                                        
VALID-TYPE?    valid_typep     SUBR    mdl_builtin_eval_valid_typep      Yes                           
VALUE          value           SUBR    mdl_builtin_eval_value            Yes                           
VECTOR         vector          SUBR    mdl_builtin_eval_vector           Yes                           
WARRANTY       warranty        SUBR    mdl_builtin_eval_warranty                   Not used in Zork    
XORB           xorb            SUBR    mdl_builtin_eval_xorb             Yes                           
~~~

## Known issues in Confusion
~~~
* The token ANY isn't recognized in DECL-statements.
    <DECL? 56 ANY>

    *ERROR*
    "BAD-TYPE-SPECIFICATION1"
  This is because ANY is missing from ROOT OBLIST. A fix to this is to add ANY to ROOT by:
    ANY!-ROOT
  Do this before ANY is used for the first time, otherwise ANY will end up on another OBLIST. 

* User-defined TYPEs can't use the # syntax to CHTYPE.
    <NEWTYPE NT ATOM>
    <CHTYPE FOO NT>   -->   #NT FOO
    #NT BAR           -->   "Something not an atom in the oblist"

* Muddle56 recognizes this syntax as a call to a FUNCTION.
    #+ {1 2 3}
    
    *ERROR*
    "#ATOM does not name a type"
~~~

    
