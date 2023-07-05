#!/bin/sh

CPUTEMPFILE="/share/homes/monitoring/monitoring/cputemp.txt"

if [ -s "$CPUTEMPFILE" ];then
        cat "$CPUTEMPFILE"
        exit 0
else
        echo "No CPUTempfile received!"
        exit 2
fi
