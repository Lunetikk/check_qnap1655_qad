#!/bin/bash

# Read the input from a file
VOLFILE="/share/homes/monitoring/monitoring/vol.txt"

if [ -s "$VOLFILE" ];then

# Initialize variables
VOL_NR=""
VOL_DESC=""
VOL_STATUS=""
VOL_FILESYSTEM=""
VOL_TOTALSIZE=""
VOL_FREESIZE=""
CHECK_STATUS_SPACE=""
CHECK_STATUS_HEALTH=""
CHECK_STATUS_OVERALL=""

# Read the input file line by line
    while IFS= read -r LINE
    do
        if [[ $LINE == "### Volnr"* ]]; then

            # Reset variables
            VOL_NR=""
            VOL_DESC=""
            VOL_STATUS=""
            VOL_FILESYSTEM=""
            VOL_TOTALSIZE=""
            VOL_FREESIZE=""

            # Extract the volume number
            VOL_NR=$(echo "$LINE" | awk '{print $3}')
        elif [[ $LINE == "Description:"* ]]; then
            VOL_DESC=$(echo "$LINE" | cut -d':' -f2-)
        elif [[ $LINE == "Status:"* ]]; then
            VOL_STATUS=$(echo "$LINE" | cut -d':' -f2-)
        elif [[ $LINE == "Filesystem:"* ]]; then
            VOL_FILESYSTEM=$(echo "$LINE" | cut -d':' -f2-)
        elif [[ $LINE == "Totalsize:"* ]]; then
            VOL_TOTALSIZE=$(echo "$LINE" | cut -d':' -f2-)
        elif [[ $LINE == "Freesize:"* ]]; then
            VOL_FREESIZE=$(echo "$LINE" | cut -d':' -f2-)

            echo "VolumeNr: $VOL_NR"
            echo "Description: $VOL_DESC"
            echo "Totalsize: $VOL_TOTALSIZE"
            echo "Freesize: $VOL_FREESIZE"

            VOL_STATUS_MESSAGE=$(echo "$VOL_STATUS" | tr '[:upper:]' '[:lower:]')

            if [[ $VOL_STATUS_MESSAGE == *"ready"* ]]; then
                echo "Status is Ready"
            elif [[ $VOL_STATUS_MESSAGE == *"warning"* && $VOL_STATUS_MESSAGE == *"degraded"* ]]; then
                echo "Status is Warning - Degraded"
                CHECK_STATUS_HEALTH="2"
                CHECK_STATUS_OVERALL="2"
            elif [[ $VOL_STATUS_MESSAGE == *"warning"* && $VOL_STATUS_MESSAGE == *"rebuilding"* ]]; then
                echo "Status is Warning - Rebuilding"
                CHECK_STATUS_HEALTH="2"
                CHECK_STATUS_OVERALL="2"
            elif [[ $VOL_STATUS_MESSAGE == *"warning"* && $VOL_STATUS_MESSAGE == *"read-only"* ]]; then
                echo "Status is Warning - Readonly"
                CHECK_STATUS_HEALTH="2"
                CHECK_STATUS_OVERALL="2"
            elif [[ -z "${VOL_STATUS_MESSAGE// }" ]]; then
                echo "Status is empty - Volume might be invalid"
            else
                echo "Status is Unknown"
                CHECK_STATUS_HEALTH="2"
                CHECK_STATUS_OVERALL="2"
            fi


            if [[ -z "${VOL_TOTALSIZE// }" ]] || [[ -z "${VOL_FREESIZE// }" ]]; then
                 echo "No disksize available - Volume might be invalid"
            else
                SIZE_RATIO=$(awk -v t="$VOL_TOTALSIZE" -v f="$VOL_FREESIZE" 'BEGIN { printf "%.2f", f / t * 100 }')
                if (( $(awk -v RATIO="$SIZE_RATIO" 'BEGIN { printf (RATIO <= 10) }') )); then
                    if (( $(awk -v RATIO="$SIZE_RATIO" 'BEGIN { printf (RATIO <= 5) }') )); then
                        echo "Free disk space below 5%! - CRITICAL"
                        CHECK_STATUS_SPACE="2"
                        CHECK_STATUS_OVERALL="2"
                    fi
                    echo "Free disk space below 10%! - WARNING"
                    CHECK_STATUS_SPACE="1"
                else
                    echo "Free disk space above 10% - GOOD"
                fi
            fi	


            # New line after block
            echo

            # Reset variables
            VOL_NR=""
            VOL_DESC=""
            VOL_STATUS=""
            VOL_FILESYSTEM=""
            VOL_TOTALSIZE=""
            VOL_FREESIZE=""
        fi

    done < "$VOLFILE"


    if [ -n "$CHECK_STATUS_HEALTH" ] || [ -n "$CHECK_STATUS_SPACE" ]; then
        if [[ "$CHECK_STATUS_HEALTH" -eq "2" ]]; then
            echo "Status of one or more volume is unhealthy!"
    		CHECK_STATUS_OVERALL="2"
        fi
        if [[ "$CHECK_STATUS_SPACE" -eq "1" ]]; then
            echo "Freespace of one or more pools is lower than 10%!"
        elif [[ "$CHECK_STATUS_SPACE" -eq "2" ]]; then
            echo "Freespace of one or more pools is lower than 5%!"
    		CHECK_STATUS_OVERALL="2"
        fi
		if [[ "$CHECK_STATUS_OVERALL" -eq "2" ]]; then
		    exit 2
		else
		    exit 1
        fi
    else
	
        echo "Overallstatus: GOOD"
        exit 0
    fi 
else
    echo "No system volumes found!"
    exit 2
fi
