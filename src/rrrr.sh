#!/usr/bin/bash

ARGS="$@"
FIRST=""
SECOND=""
RUNLAST=0

if [[ $ARGS == *' -- '* ]]; then
    FIRST="${ARGS% --*}"
    SECOND="${ARGS#* -- }"
else
    FIRST=${ARGS}
fi
if [ "$#" -eq 0 ]; then
    printf 'Usage: \n\t%s <OPTIONS> <executable> -- <rr-replay-arguments (essentially gdb-arguments)>\n' $0
    echo 'OR'
    printf 'Usage: \n\t%s <OPTIONS> --last -- <rr-replay-arguments (essentially gdb-arguments)>\n' $0
    exit 1
fi
read -ra args <<< "${FIRST}"
if [ ${args[0]} == "--last" ]; then
    RRTARGET="${args[1]}"
    RUNLAST=1
else
    RRTARGET="${args[0]}"
fi
RRTARGETBASENAME=$(basename $RRTARGET)
RRDIRBASE=${HOME}/.local/share/rr/${RRTARGETBASENAME}
RRDIR=${RRDIRBASE}-0
RRARGS="${args[@]:1}"
randomize_va_space=$(cat /proc/sys/kernel/randomize_va_space)
if [ ${RUNLAST} == 0 ]; then
    echo 0 | sudo tee /proc/sys/kernel/randomize_va_space &> /dev/null
    for DIR in $RRDIRBASE-*; do
        if [ -d ${DIR} ] ; then
            rm -rf ${DIR}
        fi
    done
    rr record ${RRTARGET} ${RRARGS}
    echo $randomize_va_space | sudo tee /proc/sys/kernel/randomize_va_space &> /dev/null
fi
rr replay ${RRDIR} ${SECOND}