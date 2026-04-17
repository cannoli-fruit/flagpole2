#!/bin/sh
# only works on linux and probably some other unix-likes
mkdir -p /usr/lib/flagpole
cp ./setup.ll /usr/lib/flagpole/setup.ll
cp ./end.ll /usr/lib/flagpole/end.ll
cp ./lib/* /usr/lib/flagpole/
chmod +x /usr/lib/flagpole/fpcc
cp ./llvm.py /usr/lib/flagpole/fpcc
chmod +x /usr/bin/fpc
cp ./build.sh /usr/bin/fpc
