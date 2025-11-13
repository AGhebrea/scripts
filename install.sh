#!/usr/bin/bash

# alias entest='source entest.sh'
# alias rrrr='rrrr.sh'

remindSource=0

for file in ./src/*.sh; do
    chmod +x $file
    bname=$(basename $file)
    bnameStripped="${bname%.*}"
    if [ ! -L "/usr/bin/$bname" ]; then
        sudo ln -s "$PWD/src/$bname" "/usr/bin/$bname"
    fi
    grep "alias $bnameStripped=" ~/.bashrc &>/dev/null
    if [ $? != 0 ]; then
        remindSource=1
        echo "alias $bnameStripped=$bname" >> ~/.bashrc
    fi
done

if [ $remindSource -eq 1 ]; then
    echo "Don't forget to source ~/.bashrc"
fi