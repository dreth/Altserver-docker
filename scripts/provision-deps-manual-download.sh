#!/bin/bash

# download the applemusic.apk file
mkdir tmp && cd tmp
wget "https://apps.mzstatic.com/content/android-apple-music-apk/applemusic.apk"

# unzip and decompress it
mv applemusic.apk applemusic.zip

# unzip the file
pwd
sudo unzip applemusic.zip -d ./applemusic

# create a new lib dir
mkdir lib && cd lib
ARCHS=("arm64-v8a" "armeabi-v7a" "x86" "x86_64")
for arch in "${ARCHS[@]}"; do
    mkdir -p "$arch"
    cp ../applemusic/lib/$arch/libstoreservicescore.so "$arch/libstoreservicescore.so"
    cp ../applemusic/lib/$arch/libCoreADI.so "$arch/libCoreADI.so"
done

# create a new lib.tar.xz
cd ..
tar -cvf lib.tar.xz lib

# move the lib.tar.xz to the altserver dir
mv lib.tar.xz ../
cd ..
sudo rm -rf tmp
