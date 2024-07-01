# Dungeon (Zork)
This is patched to compile with latest gcc. I have tried building it on CygWin and on Ubuntu 20.04 LTS, both 64-bit. Bevare that there are some warnings. On CygWin I had the following packages, which might or might not be needed, installed:
~~~
make (version 4.3-1)
gcc-g++ (version 10.2.0-1)
gcc-fortran (version 10.2.0-1)
~~~
and on Ubuntu 20.04 LTS (sudo apt-get install *package*):
~~~
build-essential 
gfortan (version 9.3.0)
~~~
If the version of gfortran is lower than 10 (check with: gfortran --version) you must remove the "-fallow-invalid-boz" from the Makefile.

If you want to run Dungeon in Windows, outside CygWin the following files must be in the same directory as "dungeon.exe":
~~~
cygwin1.dll
cygquadmath-0.dll
cyggcc_s-seh-1.dll
cyggfortran-5.dll
~~~
## Differences between Zork and Dungeon
There are some small differences in the gameplay. Among them are:
- The diamond making machine can be referred to as a "VAX". (Zork already have "PDP10" as a synonym for it.)
- "Up a Tree" (TREE), "Cage" (CAGED) and the "note of warning" (WARNI) are sacred (have RSACREDBIT or SACREDBIT) and won't be visited or snatched by the thief.
- There is a new room, the Translator's Annex, added south of the Tomb of the Unknown Implementer. The only exit is back north. The south exit, the "Entrance To MLO-6B", is blocked because "You are not wearing your badge."

There are also small textual differences. These have been collected in a Google Doc [here](https://docs.google.com/spreadsheets/d/1tE66brvL_eBK8HN_MZYyNLf2HFIoO6fDS6vAReG2uDg/edit?usp=sharing) by [eriktorbjorn](https://github.com/eriktorbjorn) (there is a pdf-capture from 2024-07-01 of this document in this folder).
## README from orginal package

DUNGEON (Zork)
==============

This is Robert Supnik's Dungeon V3.2B for various DEC Fortrans, ported to MS-DOS
by Volker Blasius, then ported to work with g77 by David Kinder, and then ported
to work with gfortran by RJ Miller.

I've made changes to the code so that it will compile using gfortran on Linux.
If you have gfortran and make already installed, you can build and run with
```
# in project root
./dungeon.sh
```

If you find any bugs or problems, please feel free to open an issue describing
your problem. I'll try to help out as best as I can. I'm specifically targeting
Arch Linux and Ubuntu 14.04 at this point, but ultimately, I want it to work on
all major operating systems.


### Roadmap

- [x] get it running on modern Linux
- [x] convert from the non-standard tab format to standard fixed format
- [ ] streamline build process
  - [x] Makefile
  - [x] script to build and run the project in one go
  - [ ] more scripts
- [ ] beef up docs
- [ ] put it into a docker container
- [ ] decrypt the game files
- [ ] update the in-game text
- [ ] turn the game into an API
- [ ] integrate game with SMS for Zork to go


### To Build

```
# in project root
make
```


### To Run

```
cd build
./dungeon
```


### Tools you need to build

Any FORTRAN77 compatible compiler can be used, but the consensus is to use the
GNU compler as it runs a good balance of strictness and flexibility.
- [gfortran](https://gcc.gnu.org/wiki/GFortranBinaries)
- make
