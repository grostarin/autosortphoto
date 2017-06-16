#!/bin/sh

LOG_FILE="/var/services/homes/admin/sort_photo.nas.log"

./sort_photo.nas.script.sh | tee -a $LOG_FILE
