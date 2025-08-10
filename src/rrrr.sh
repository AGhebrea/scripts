#!/usr/bin/bash

ARGS="$@"
FIRST=""
SECOND=""

if [[ $ARGS == *' -- '* ]]; then
    FIRST="${ARGS% --*}"
    SECOND="${ARGS#* -- }"
else
    FIRST=${ARGS}
fi

if [ "$#" -eq 0 ]; then
    printf 'Usage: \n\t%s <executable>\n' $0
    exit 1
fi

read -ra args <<< "${FIRST}"
RRTARGET="${args[0]}"

RRTARGETBASENAME=$(basename $RRTARGET)
RRDIRBASE=${HOME}/.local/share/rr/${RRTARGETBASENAME}
RRDIR=${RRDIRBASE}-0
RRARGS="${args[@]:1}"

randomize_va_space=$(cat /proc/sys/kernel/randomize_va_space)
echo 0 | sudo tee /proc/sys/kernel/randomize_va_space &> /dev/null
for DIR in $RRDIRBASE-*; do
    if [ -d ${DIR} ] ; then
        rm -rf ${DIR}
    fi
done
rr record ${RRTARGET} ${RRARGS}
echo $randomize_va_space | sudo tee /proc/sys/kernel/randomize_va_space &> /dev/null
rr replay ${RRDIR} ${SECOND}