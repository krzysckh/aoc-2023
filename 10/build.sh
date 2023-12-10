#!/bin/sh

[ -f tg.c ] || wget https://raw.githubusercontent.com/tidwall/tg/main/tg.c
[ -f tg.h ] || wget https://raw.githubusercontent.com/tidwall/tg/main/tg.h

clang -O2 -Wall -Wextra tg.c 10.c -lm
