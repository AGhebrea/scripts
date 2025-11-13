#!/usr/bin/bash

ARGS=$@
PROGRAM=""
DIR=""

usage(){
    printf "Usage: %s: -p <target program> -d <output directory>\n" $0
}

parse_args(){
    set -- $ARGS
    OPTIND=1
    while getopts ":p:d:" opt; do
        case "${opt}" in
            p) PROGRAM="$OPTARG" ;;
            d) DIR="$OPTARG" ;;
            ?) usage
        esac
    done
}

parse_args
if [[ "$PROGRAM" == "" || "$DIR" == "" ]]; then
    usage
    exit 1
fi
NAME=$(basename $PROGRAM)
readelf -a --wide $PROGRAM > "${DIR}/${NAME}.re"
objdump -d -M intel $PROGRAM > "${DIR}/${NAME}.objd"