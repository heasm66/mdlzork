# Mainframe Zork for Confusion
These are the currently known MDL sources of the mainframe Zork. I have slightly changed the code to make it runnable in Matthew Russottos's 
Confusion, the MDL emulator, “a MDL interpreter which works just well enough to play the original Zork all the way through”. The status of the different
versions here are listed below.
## 1977-12-12
There is a couple of files missing from this version, most notably the "melee"-file. I have tried to modify and use the "melee"-file from the 1978-version. But there is still 
bugs in this version. You can play it all the way until you encounter the troll, when the game crashes.
## 1978-01-24
This is a more complete version. I've patched it up and I believe it's playable all the way to the end. There was one strange bug that made the game crash if you tried
doing something in a dark room (like LIGHT LAMP). This could be a bug in the original source, but it's not present in the compiled game of this version that is 
playable on the PDP-10 ITS emulator. I have fixed with he fix that's used in the later versions.
## 1979-12-11
This version is almost identical with the 1981 version. The 1981 version have three small bugfixes and another issue of the US NEWS & DUNGEON REPORT.
## 1981-07-22
This is the source files that Bob Supnik released 2003. The version here is with Matthew Russotto's patches to make it work under Confusion.
## Dungeon 3.2b
This is not MDL, actually it's the Fortran version that Bob Supnik wrote that closely follows the 1981 version.
## Playing the games
To play the games you'll need Confusion. There is a patched version in this repository that should compile with the latest gcc. The orginal can be found at [IF-Archive](http://www.ifarchive.org/indexes/if-archive/programming/mdl/interpreters/confusion/), Matthew Russotto's
[homepage](http://www.russotto.net/git/mrussotto/confusion) or Benjamin Slade's [patched version](https://gitlab.com/emacsomancer/confusion-mdl). Benjamin Slade also have a
[blog post](https://babbagefiles.xyz/zork-confusion/) about compiling it. The Win32-version (by David Kinder) contains a precompiled version that works fine on these Windows 
versions that I tried: Windows7 (32-bit) and Windows10 (64-bit).

When you have Confusion running in the same directory as the source, you type (in Confusion):
~~~
<FLOAD "run.mud">
~~~
This loads all the code, compiles, save a copy of "/MDL/MADADV.SAVE" and starts the game. You can always start the game this way, but when you have the "MADADV.SAVE" 
or another "*.SAVE"-file you can start it directly from the prompt by (for example):
~~~
mdli -r SAVEFILE/ZORK.SAVE
~~~
or from inside Confusion:
~~~
<RESTORE "<SAVEFILE>ZORK.SAVE">
~~~
There is only one save slot in Zork, but you can always make your own copies in the OS. If you find this cumbersome, remember that originaly on PDP-10 ITS the game quit 
when you saved and you had to wait 24h before you could restore and continue playing.

Thanks to Tim Anderson, Marc Blank, Bruce Daniels and Dave Lebling for creating the original Zork and to Matthew Russotto for building Confusion. 
