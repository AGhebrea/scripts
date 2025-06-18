#!/usr/bin/bash

if [ "$#" -eq 0 ]; then
    printf 'Usage: \n\t%s <executable>\n' $0
    exit 1
fi


RRTARGET="$1"
RRTARGETBASENAME=$(basename $RRTARGET)
RRDIRBASE=/home/alex/.local/share/rr/${RRTARGETBASENAME}
RRDIR=${RRDIRBASE}-0
shift 
RRARGS="$@"

randomize_va_space=$(cat /proc/sys/kernel/randomize_va_space)
echo 0 | sudo tee /proc/sys/kernel/randomize_va_space &> /dev/null
for DIR in $RRDIRBASE-*; do
    if [ -d ${DIR} ] ; then
        rm -rf ${DIR}
    fi
done
rr record ${RRTARGET} ${RRARGS}
echo $randomize_va_space | sudo tee /proc/sys/kernel/randomize_va_space &> /dev/null
rr replay ${RRDIR}