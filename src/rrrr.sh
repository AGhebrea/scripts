#!/usr/bin/bash

parse_args(){
    set -- $FIRST
    OPTIND=1
    while getopts ":lct:a" opt; do
        case "$opt" in
            l) RUNLAST=1 ;;
            c) RUNCONTINUE=1 ;;
            t) RRTARGET="$OPTARG" ;;
            a) break ;;
        esac
    done
    shift $((OPTIND - 1))
    RRARGS=$@
}

ARGS="$@"
FIRST=""
SECOND=""
RUNLAST=0
RUNCONTINUE=0
RRTARGET=""
RRARGS=""

if [[ $ARGS == *' -- '* ]]; then
    FIRST="${ARGS% --*}"
    SECOND="${ARGS#* -- }"
else
    FIRST=${ARGS}
fi
parse_args
if [ "$#" -eq 0 ]; then
    printf 'Usage: \n\t%s [-l] [-c] -t <executable> -a <executable-arguments> -- <rr-replay-arguments (essentially gdb-arguments)>\n' $0
    printf 'Where: \n\t-c: automatically inputs the char "c" in STDIN\n\t-l: runs last recording made with rrrr\n\t-t: the target binary\n\ta: the arguments for the target binary, if -l is supplied then -a is ignored.\n'
    exit 1
fi
read -ra args <<< "${FIRST}"
RRTARGETBASENAME=$(basename $RRTARGET)
RRDIRBASE=${HOME}/.local/share/rr/${RRTARGETBASENAME}
RRDIR=${RRDIRBASE}-0
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
set -x
if [[ ${RUNCONTINUE} == 1 ]]; then
    expect -c "spawn rr replay ${RRDIR} ${SECOND}; send c\r; interact"
else
    rr replay ${RRDIR} ${SECOND}
fi