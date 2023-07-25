#!/usr/bin/bash

NJOBS=4
TIMEOUT=1

while true
do
	stress -c $NJOBS -t $TIMEOUT
    vcgencmd measure_temp
done


