@echo off
ghc -c StartEnd.c
ghc -shared -o HsSaori.dll HsSaori.hs StartEnd.o -loleaut32
