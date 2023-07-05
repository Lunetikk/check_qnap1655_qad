#!/bin/bash

FANFILE="/share/homes/lunetikk/monitoring/fan.txt"
CHECK_STATUS_FANSPEED=""

if [ -s "$FANFILE" ];then
    while IFS= read -r LINE; do
        FAN_NUMBER=$(echo "$LINE" | sed 's/Systemfan Nr \([0-9]\+\):.*/\1/')
        if [[ $LINE =~ Systemfan\ Nr\ [0-9]+:\ ([0-9]+)\ RPM ]]; then
            # BASH_REMATCH gets the most recent successful regular expression match
            FAN_SPEED=${BASH_REMATCH[1]}
            if (( $FAN_SPEED < 300 )); then
                echo "FanNr $FAN_NUMBER is too slow! Current speed is $FAN_SPEED RPM"
                CHECK_STATUS_FANSPEED="2"
            else
                echo "FanNr $FAN_NUMBER: $FAN_SPEED RPM"
            fi
        fi
    done < "$FANFILE"

    if [[ -n "$CHECK_STATUS_FANSPEED" ]]; then
        echo "One or more fans are running to slow! - CRITICAL"
        exit 2
    else
       echo "All fans are working fine!"
       exit 0
    fi

else
    echo "No fans received!"
    exit 2
fi
