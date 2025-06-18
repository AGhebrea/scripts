#!/usr/bin/bash

if [ "$#" -eq 0 ]; then
    printf 'Usage: \n\t%s <executable>\n' $0
    exit 1
fi

RRTARGET=$(basename "$1")
RRDIRBASE=/home/alex/.local/share/rr/${RRTARGET}
RRDIR=${RRDIRBASE}-0

randomize_va_space=$(cat /proc/sys/kernel/randomize_va_space)
echo 0 | sudo tee /proc/sys/kernel/randomize_va_space &> /dev/null
for DIR in $RRDIRBASE-*; do
    if [ -d ${DIR} ] ; then
        rm -rf ${DIR}
    fi
done
rr record "$1"
echo $randomize_va_space | sudo tee /proc/sys/kernel/randomize_va_space &> /dev/null
rr replay ${RRDIR}