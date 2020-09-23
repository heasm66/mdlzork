DUNGEON (Zork I)
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
