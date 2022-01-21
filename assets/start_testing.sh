#!/bin/bash

if [ -f test-main.js ] ; then
    rm test-main.js
fi

npx shadow-cljs watch test &>/dev/null &
PID1=$!

until [ -f test-main.js ]
do
     sleep 1
done
echo "test-main.js found! Continuing .."

npx node test-main.js &>/dev/null &
PID2=$!

CPIDS1=`pgrep -P $PID1`
CPIDS2=`pgrep -P $PID2`

cleanup() {
    for cpid in $CPIDS2 ; do kill $cpid ; done
    for cpid in $CPIDS2 ; do kill $cpid ; done
}
trap cleanup EXIT

rlwrap npx shadow-cljs cljs-repl test
