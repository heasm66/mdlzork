# Confusion ver 0.2 patched to compile with latest gcc
I made some small changes to make it able to build with the latest version of gcc. 
I have tried building it on CygWin and on Ubuntu 20.04 LTS, both 64-bit. Bevare that there are some warnings.
On CygWin I had the following packages, which might or might not be needed, installed:
~~~
gcc-g++ (version 10.2.0-1)
perl (version 5.30.3-1)
libgc-devel (version 8.0.4-1)
make (version 4.3-1)
~~~
and on Ubuntu 20.04 LTS (sudo apt-get install *package*):
~~~
build-essential
libgc-dev (version 7.6.4)
~~~
If you want to run Confusion in Windows, outside CygWin the following files must be in the same directory as "mdli.exe":
~~~
cygwin1.dll
cyggc-1.dll
cyggcc_s-seh-1.dll
cyggccpp-1
cygstdc++-6
~~~

## README from orginal package
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
