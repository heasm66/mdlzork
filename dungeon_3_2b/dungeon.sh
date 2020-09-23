#!/bin/bash
set -e
# TODO make this script smarter
make
clear
cd ./build && ./dungeon
