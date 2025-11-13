#!/usr/bin/bash

# we need command
# we need to select if stdout or stderr + stdout
# we need to mktemp and then open it in code

ARGS=$@
COMMAND=""
STREAM=""

usage(){
    printf "Usage: %s: -s <STDOUT/STDERR> -c <command>\n" $0
    exit 1
}

parse_args(){
    set -- $ARGS
    OPTIND=1
    while getopts ":c:s:" opt; do
        case "${opt}" in
            c) break ;;
            s) STREAM="$OPTARG" ;;
            ?) usage
        esac
    done
    shift $((OPTIND - 2))
    COMMAND=$@
}

parse_args
if [[ "$COMMAND" == "" || "$STREAM" == "" ]]; then
    usage
fi
STREAM=${STREAM^^}
TMP=$(mktemp)
case "${STREAM}" in
    STDOUT) eval "${COMMAND}" > $TMP ;;
    STDERR) eval "${COMMAND}" &> $TMP ;;
    ?) usage ;;
esac
code $TMP