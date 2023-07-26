#!/usr/bin/bash

NJOBS=$(getconf _NPROCESSORS_ONLN)
TIMEOUT=1

echo "${NJOBS} jobs"

# raspios
if [[ -f "/usr/bin/vcgencmd" ]]; then
    while true
    do
        stress -c $NJOBS -t $TIMEOUT
        vcgencmd measure_temp
    done
fi


