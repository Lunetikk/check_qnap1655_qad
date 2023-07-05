#!/bin/sh

SYSTEMPFILE="/share/homes/monitoring/monitoring/systemp.txt"

if [ -s "$SYSTEMPFILE" ];then
        cat "$SYSTEMPFILE"
        exit 0
else
        echo "No SYSTempfile received!"
        exit 2
fi
