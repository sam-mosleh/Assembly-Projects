#!/bin/bash

echo "Usage: $0 [Number of tries]"

MY_SUM=0
TRIES=2

if [ "$1" != "" ]
then
    if [ $1 -eq $1 2> /dev/null ]
    then
        TRIES=$1
    else
        echo 'Not a valid number!'
        exit 2
    fi
fi

for i in $(seq 1 $TRIES)
do
    TIME_RESULT="$(./run | tail -n 1)"
    MY_SUM=$(( $MY_SUM + $TIME_RESULT ))
    echo $TIME_RESULT
done

echo "Summation is ${MY_SUM}"
echo "And Average = $(( $MY_SUM / $TRIES ))"
