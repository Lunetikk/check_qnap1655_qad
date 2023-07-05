#!/bin/bash

HDFILE="/share/homes/monitoring/monitoring/hd.txt"
CHECK_STATUS_TEMP=""
CHECK_STATUS_HEALTH=""
CHECK_STATUS_SMART=""
CHECK_STATUS_OVERALL=""

if [ -s "$HDFILE" ];then
    
    # Read the file line by line
    while IFS= read -r LINE; do
    
        # Check if the LINE starts with "### DiskNr"
        if [[ $LINE == "### DiskNr"* ]]; then
            # Extract the disk number using pattern matching
            DISK_NUMBER=$(echo "$LINE" | sed 's/### DiskNr \([0-9]\+\):/\1/')
            echo "DiskNr: $DISK_NUMBER"
    
            continue
        fi
    
        # Check if the line starts with "Model"
        if [[ $LINE == "Model"* ]]; then
            # Extract the disk model
            DISK_MODEL="${LINE#*: }"  # Extract the model from line without the label
            echo "Model: $DISK_MODEL"
    
            continue
        fi
    
        # Check if the line starts with "Model"
        if [[ $LINE == "Capacity"* ]]; then
            # Extract the disk capacity
            DISK_CAPACITY="${LINE#*: }"  # Extract the capacity from line without the label
            echo "Capacity: $DISK_CAPACITY"
    
            continue
        fi
    
        # Check if the line starts with "Temperature"
        if [[ $LINE == "Temperature"* ]]; then
            DISK_TEMPERATURE_LINE="${LINE#*: }"  # Extract the temperature from line without the label
            DISK_TEMPERATURE="${DISK_TEMPERATURE_LINE%% *}"  # Extract the temperature value before the first space
    
            # Remove any non-digit characters from the temperature value
            DISK_TEMPERATURE="${DISK_TEMPERATURE//[!0-9]/}"
    
            # Check if the temperature is higher than 60
            if (( DISK_TEMPERATURE > 60 )); then
                if (( DISK_TEMPERATURE > 70 )); then
                    echo "Temperature is higher than 70! => $DISK_TEMPERATURE_LINE - Check temperature of disk $DISK_NUMBER"
                    CHECK_STATUS_TEMP="2"
                    CHECK_STATUS_OVERALL="2"
                fi
                echo "Temperature is higher than 60! => $DISK_TEMPERATURE_LINE - Check temperature of disk $DISK_NUMBER"
                CHECK_STATUS_TEMP="1"
            else
                echo "Temperature: $DISK_TEMPERATURE_LINE"
            fi
    
            continue
        fi
    
        # Check if the line starts with "Status"
        if [[ $LINE == "Status"* ]]; then
            DISK_STATUS="${LINE#*: }"  # Extract the status value from the line
    
            # Check if the disk status is 0
            if [[ $DISK_STATUS -eq "0" ]]; then
                echo "Status: $DISK_STATUS"
            elif [[ $DISK_STATUS -eq "-5" ]]; then
                echo "Status is $DISK_STATUS! Disk is missing!"
            else
                echo "Status is $DISK_STATUS! Disk $DISK_NUMBER might be faulty!"
                CHECK_STATUS_HEALTH="2"
		        CHECK_STATUS_OVERALL="2"
            fi
    
            continue
        fi
    
        # Check if the line starts with "SMART:"
        if [[ $LINE == "SMART:"* ]]; then
            DISK_SMART="${LINE#*: }"  # Extract the value after "SMART:"
    
            # Check if the SMART is GOOD
            if [[ $DISK_SMART == "GOOD" ]]; then
                echo "SMART: GOOD"
                echo  # New LINE between blocks
            elif [[ $DISK_SMART == "--" ]]; then
                echo "SMART: $DISK_SMART"
                echo  # New LINE between blocks
            else
                echo "SMART is $DISK_SMART - Disk $DISK_NUMBER might be faulty!"
		        CHECK_STATUS_SMART="2"
                CHECK_STATUS_OVERALL="2"
            fi
    
            continue
        fi
    
    done < "$HDFILE"
    
    if [ -n "$CHECK_STATUS_HEALTH" ] || [ -n "$CHECK_STATUS_SMART" ] || [ -n "$CHECK_STATUS_TEMP" ]; then
        if [[ "$CHECK_STATUS_HEALTH" -eq "2" ]]; then
            echo "Status of one or more disks is unhealthy!"
    		CHECK_STATUS_OVERALL="2"
        fi
        if [[ "$CHECK_STATUS_TEMP" -eq "1" ]]; then
            echo "Temperature of one or more disks is above 60 C!"
        elif [[ "$CHECK_STATUS_TEMP" -eq "2" ]]; then
            echo "Temperature of one or more disks is above 70 C!"
    		CHECK_STATUS_OVERALL="2"
        fi
    	if [[ "$CHECK_STATUS_SMART" -eq "2" ]]; then
		    echo "SMART of one or more disks is unhealthy!"
    	    CHECK_STATUS_OVERALL="2"
		fi
		if [[ "$CHECK_STATUS_OVERALL" -eq "2" ]]; then
		    exit 2
		else
		    exit 1
        fi
    else 
        echo "Overall disk status: GOOD"
        exit 0
    fi
else
   echo "No disks received!"
   exit 2
fi
