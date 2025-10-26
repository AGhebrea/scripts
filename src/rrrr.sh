#!/usr/bin/bash

parse_args(){
    set -- $FIRST
    OPTIND=1
    while getopts ":lct:" opt; do
        case "$opt" in
            l) RUNLAST=1 ;;
            c) RUNCONTINUE=1 ;;
            t) RRTARGET="$OPTARG" ;;
        esac
    done
}

ARGS="$@"
FIRST=""
SECOND=""
RUNLAST=0
RUNCONTINUE=0
RRTARGET=""

if [[ $ARGS == *' -- '* ]]; then
    FIRST="${ARGS% --*}"
    SECOND="${ARGS#* -- }"
else
    FIRST=${ARGS}
fi
parse_args
if [ "$#" -eq 0 ]; then
    printf 'Usage: \n\t%s [-l] [-c] -t <executable> -- <rr-replay-arguments (essentially gdb-arguments)>\n' $0
    printf 'Where: \n\t-c: automatically inputs the char "c" in STDIN\n\t-l: runs last recording made with rrrr\n'
    exit 1
fi
read -ra args <<< "${FIRST}"
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
if [[ ${RUNCONTINUE} == 1 ]]; then
    (echo -e "c\n"; cat /dev/tty) | rr replay ${RRDIR} ${SECOND}
else
    rr replay ${RRDIR} ${SECOND}
fi