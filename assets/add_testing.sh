#!/bin/bash

until [ -f test-main.js ]
do
     sleep 1
done

npx node test-main.js &>/dev/null &
PID2=$!

cleanup() {
    CPIDS2=`pstree -p $PID2 | grep -oP '\(\K[^\)]+'`
    for cpid in $CPIDS2 ; do kill $cpid &>/dev/null ; done
}
trap cleanup EXIT

rlwrap npx shadow-cljs cljs-repl test