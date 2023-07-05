#!/bin/bash

INFOFOLDER="/share/homes/monitoring/monitoring"
FILE_STATUS=""

# Get the current timestamp
CURRENT_TIMESTAMP=$(date +%s)

# Loop through all .txt files in the folder
for FILE in "$INFOFOLDER"/*.txt; do
    # Check if the file was modified within the last hour
    if [[ $(stat -c %Y "$FILE") -lt $((CURRENT_TIMESTAMP - 3600)) ]]; then
        echo "CRITICAL: $FILE has not been modified for over an hour!"
        FILE_STATUS="1"
    fi
done

if [[ "$FILE_STATUS" -eq "1" ]]; then
    echo "CRITICAL - One or more files have not been modified for over an hour!"
    exit 2
else
    echo "GOOD - All files have been modified in the last hour."
    exit 0
fi
