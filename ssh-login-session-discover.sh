#!/bin/bash
LOG_FILE="/var/log/auth.log"

# Extract all unique session IDs from the log file
sessions=$(grep -o "session [0-9]\+" "$LOG_FILE" | awk '{print $2}' | sort -u)

printf "[\n"
first=1
for s in $sessions; do
    [ $first -ne 1 ] && printf ",\n"
    printf "  { \"sessionid\": \"%s\" }" "$s"
    first=0
done
printf "\n]\n"
