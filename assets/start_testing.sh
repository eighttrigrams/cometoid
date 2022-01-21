#!/bin/bash

if [ -f test-main.js ]
then
    rm test-main.js
fi

npx shadow-cljs watch test &
PID1=$!

until [ -f test-main.js ]
do
     sleep 1
done

npx node test-main.js &>/dev/null &
PID2=$!

cleanup() {
    # https://stackoverflow.com/a/69168523
    CPIDS1=`pstree -p $PID1 | grep -oP '\(\K[^\)]+'`
    CPIDS2=`pstree -p $PID2 | grep -oP '\(\K[^\)]+'`
    for cpid in $CPIDS1 ; do kill $cpid &>/dev/null ; done
    for cpid in $CPIDS2 ; do kill $cpid &>/dev/null ; done
}
trap cleanup EXIT

rlwrap npx shadow-cljs cljs-repl test