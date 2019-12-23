#!/bin/bash

LOG_DIRECTORY="./log/"
LOG_FILE="autosortphoto.log"

mkdir -p $LOG_DIRECTORY

./autosortphoto.script.sh | tee -a "$LOG_DIRECTORY/$LOG_FILE"
