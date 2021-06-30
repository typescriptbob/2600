#!/bin/sh
./dasm std_kernel.asm  -f3 -v0 -lbob.txt  -obob.bin
cp bob.bin ../Library/Application\ Support/OpenEmu/Game\ Library/roms/Atari\ 2600/