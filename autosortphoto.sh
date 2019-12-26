#!/bin/bash

DIRECTORY=$(cd `dirname $0` && pwd)
echo "Running in $DIRECTORY"
LOG_DIRECTORY="$DIRECTORY/log"
LOG_FILE="autosortphoto.log"

mkdir -p $LOG_DIRECTORY

$DIRECTORY/autosortphoto.script.sh | tee -a "$LOG_DIRECTORY/$LOG_FILE"
