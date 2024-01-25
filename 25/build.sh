#!/bin/sh

clang -Wall -Wextra -g -I/usr/local/include -L/usr/local/lib -o 25 25.c -lraylib -lm

win() {
  [ -f "libraylib.a" ] || wget -O libraylib.a https://pub.krzysckh.org/libraylib.a
  x86_64-w64-mingw32-gcc -D_BSD_SOURCE -D_DEFAULT_SOURCE \
                         -O2 -I/usr/local/include 25.c -L. -l:libraylib.a \
                         -lm -lwinmm -lgdi32 \
                         -static -o aoc-2023-d25.exe
}

win
