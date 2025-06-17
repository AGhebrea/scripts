#!/usr/bin/bash

if [ "$#" -eq 0 ]; then
    printf 'Usage: \n\t%s <executable>\n' $0
    exit 1
fi

RRTARGET=$(basename "$1")
RRFILE=/home/alex/.local/share/rr/${RRTARGET}-0

randomize_va_space=$(cat /proc/sys/kernel/randomize_va_space)
echo 0 | sudo tee /proc/sys/kernel/randomize_va_space
if -f ${RRFILE}; then
    rm ${RRFILE}
fi
rr record ${RRTARGET}
echo $randomize_va_space | sudo tee /proc/sys/kernel/randomize_va_space
clear
rr replay ${RRFILE}