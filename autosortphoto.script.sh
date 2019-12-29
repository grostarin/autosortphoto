#!/bin/bash

# exit on first error
set -e

files_moved=0
old_IFS=$IFS
IFS=$'\n'

echo "$(date) - SORT PHOTO NAS STARTING..."

ORIGIN_DIRECTORY="/volume1/upload/photo"
DESTINATION_DIRECTORY="/volume1/photo"
DESTINATION_DIRECTORY_ERROR="/volume1/photo/error"
EXIFTOOL_BINARY_PATH="/volume1/homes/autosortphoto/exiftool/exiftool"

DO_SYNOINDEX=true

echo "Removing @eaDir in $ORIGIN_DIRECTORY"
find $ORIGIN_DIRECTORY -type d -name "@eaDir" -print0 | xargs -0 rm -rf

for FILE in `find "$ORIGIN_DIRECTORY" -type f -not -path "**/@eaDir/*"` ; do
	echo "----------------------------------------------------------------------"
	echo "FILE : $FILE"
	if [ "$DO_SYNOINDEX" = true ] ; then
		#echo "synoindex will be executed"
		DO_SYNOINDEX_ON_FILE=true
	fi

	chown autosortphoto $FILE
	chgrp administrators $FILE
	chmod 744 $FILE

	EXT=`echo ${FILE/*./}`
	#echo "EXT : $EXT"

	# MD5SUM du fichier
	MD5SUM=`cksum $FILE | cut -d " " -f 1`
	#echo "MD5SUM : $MD5SUM"
	
	EXIFTOOL_CREATION_DATE=$($EXIFTOOL_BINARY_PATH $FILE | grep -m1 --text "Create Date" || true)
	#echo "EXIFTOOL_CREATION_DATE : $EXIFTOOL_CREATION_DATE"
	EXIFTOOL_MODIFICATION_DATE=$($EXIFTOOL_BINARY_PATH $FILE | grep -m1 --text "Date/Time Original" || true)
	#echo "EXIFTOOL_MODIFICATION_DATE : $EXIFTOOL_MODIFICATION_DATE"
	DESTINATION_DIRECTORY_YEAR=''

	# Compute directories and file name
	FILENAME_ON_ERROR="FALSE"
	if [ ! -z "$EXIFTOOL_MODIFICATION_DATE" ]; then 
		# echo "Trying EXIFTOOL_MODIFICATION_DATE"
		YEAR=`echo ${EXIFTOOL_MODIFICATION_DATE:34:4}`
		MONTH=`echo ${EXIFTOOL_MODIFICATION_DATE:39:2}`
		DAY=`echo ${EXIFTOOL_MODIFICATION_DATE:42:2}`
		HOUR=`echo ${EXIFTOOL_MODIFICATION_DATE:45:2}`
		MINUTE=`echo ${EXIFTOOL_MODIFICATION_DATE:48:2}`
		SECOND=`echo ${EXIFTOOL_MODIFICATION_DATE:51:2}`

		# echo "CREATION DATE : $YEAR $MONTH $DAY $HOUR $MINUTE $SECOND"
		DESTINATION_DIRECTORY_YEAR=`echo "$DESTINATION_DIRECTORY/$YEAR"`	
		DESTINATION_DIRECTORY_MONTH=`echo "$DESTINATION_DIRECTORY_YEAR/$MONTH"`
		DESTINATION_FILENAME=`echo "$YEAR$MONTH$DAY-$HOUR$MINUTE$SECOND.$EXT"`
	fi
	if [ -z "$DESTINATION_DIRECTORY_YEAR" ]; then
	if [ ! -z "$EXIFTOOL_CREATION_DATE" ]; then
		# echo "Trying EXIFTOOL_CREATION_DATE"
		YEAR=`echo ${EXIFTOOL_CREATION_DATE:34:4}`
		MONTH=`echo ${EXIFTOOL_CREATION_DATE:39:2}`
		DAY=`echo ${EXIFTOOL_CREATION_DATE:42:2}`
		HOUR=`echo ${EXIFTOOL_CREATION_DATE:45:2}`
		MINUTE=`echo ${EXIFTOOL_CREATION_DATE:48:2}`
		SECOND=`echo ${EXIFTOOL_CREATION_DATE:51:2}`

		#echo "CREATION DATE : $YEAR $MONTH $DAY $HOUR $MINUTE $SECOND"
		DESTINATION_DIRECTORY_YEAR=`echo "$DESTINATION_DIRECTORY/$YEAR"`	
		DESTINATION_DIRECTORY_MONTH=`echo "$DESTINATION_DIRECTORY_YEAR/$MONTH"`
		DESTINATION_FILENAME=`echo "$YEAR$MONTH$DAY-$HOUR$MINUTE$SECOND.$EXT"`
	fi
	fi
	if [ -z "DESTINATION_DIRECTORY_YEAR" ]; then
		echo "ERROR in CREATION DATE --> ouput in $DESTINATION_DIRECTORY_ERROR with same name"
		FILENAME_ON_ERROR="TRUE"
		DESTINATION_DIRECTORY_YEAR=`echo "$DESTINATION_DIRECTORY_ERROR"`	
		DESTINATION_DIRECTORY_MONTH=`echo "$DESTINATION_DIRECTORY_ERROR"`
		DESTINATION_FILENAME=`basename $FILE`
    fi

	if [ ! -d "$DESTINATION_DIRECTORY" ]; then
		echo "CREATING $DESTINATION_DIRECTORY"
		mkdir $DESTINATION_DIRECTORY
		chown autosortphoto $DESTINATION_DIRECTORY
		chgrp administrators $DESTINATION_DIRECTORY
		chmod 744 $DESTINATION_DIRECTORY
	fi
	if [ ! -d "$DESTINATION_DIRECTORY_YEAR" ]; then
		echo "CREATING $DESTINATION_DIRECTORY_YEAR"
		mkdir $DESTINATION_DIRECTORY_YEAR
		chown autosortphoto $DESTINATION_DIRECTORY_YEAR
		chgrp administrators $DESTINATION_DIRECTORY_YEAR
		chmod 744 $DESTINATION_DIRECTORY_YEAR
	fi
	if [ ! -d "$DESTINATION_DIRECTORY_MONTH" ]; then
		echo "CREATING $DESTINATION_DIRECTORY_MONTH"
		mkdir $DESTINATION_DIRECTORY_MONTH
		chown autosortphoto $DESTINATION_DIRECTORY_MONTH
		chgrp administrators $DESTINATION_DIRECTORY_MONTH
		chmod 744 $DESTINATION_DIRECTORY_MONTH
	fi

	DESTINATION_COMPLETE=$DESTINATION_DIRECTORY_MONTH/$DESTINATION_FILENAME
	echo "DESTINATION_COMPLETE : $DESTINATION_COMPLETE"

	if [ ! -f "$DESTINATION_COMPLETE" ]; then
		echo "MOVING TO $DESTINATION_COMPLETE"
		mv $FILE $DESTINATION_COMPLETE
		files_moved=$((files_moved+1))
		echo "File moved to $DESTINATION_COMPLETE"
	else
		#echo "CHECKING MD5SUM OF $DESTINATION_COMPLETE"
		MD5SUM2=`cksum $DESTINATION_COMPLETE | cut -d " " -f 1`
		if [ $MD5SUM = $MD5SUM2 ]; then
			echo "File already exists AND same checksum... Skipping..."
			rm -f $FILE
			DO_SYNOINDEX_ON_FILE=false
		else
			echo "Searching for a file name..."
			j=1
			FINISHED=0
			while [ $FINISHED -ne 1 ]; do
				#echo "j = $j,  FINISHED = $FINISHED"
				if [ $FILENAME_ON_ERROR="FALSE" ]; then
					DESTINATION_FILENAME=`echo "$YEAR$MONTH$DAY-$HOUR$MINUTE$SECOND-$j.$EXT"`
				else
					BASENAME= basename $FILE .$EXT
					DESTINATION_FILENAME= $BASENAME-$j.$EXT
				fi
				DESTINATION_COMPLETE=$DESTINATION_DIRECTORY_MONTH/$DESTINATION_FILENAME
				echo "TRYING DESTINATION_COMPLETE : $DESTINATION_COMPLETE"
				if [ ! -f "$DESTINATION_COMPLETE" ]; then
					echo "MOVING TO $DESTINATION_COMPLETE"
					mv $FILE $DESTINATION_COMPLETE
					files_moved=$((files_moved+1))
					let "FINISHED = 1"
					echo "file moved to $DESTINATION_COMPLETE"
				else 
					MD5SUM2=`cksum $DESTINATION_COMPLETE | cut -d " " -f 1`
					if [ $MD5SUM = $MD5SUM2 ]; then
						echo "File already exists AND same checksum... Skipping..."
						rm -f $FILE
						let "FINISHED = 1"
					else
						echo "Try again..."
					fi
				fi
				j=$((j+1))
			done
		fi
	fi
	if [ "$DO_SYNOINDEX_ON_FILE" = true ] ; then
		#echo "synoindex"
		synoindex -a $DESTINATION_COMPLETE
	fi
done

# Remove unused directories
echo "Removing directories in $ORIGIN_DIRECTORY"
ORIGIN_SUBDIRS="$ORIGIN_DIRECTORY"
find $ORIGIN_SUBDIRS -mindepth 1 -type d | while IFS= read -r directory; do
	echo "Removing $directory"
	rmdir $directory
done

# Reindex origin directory
echo "Reindexing $ORIGIN_DIRECTORY"
synoindex -R $ORIGIN_DIRECTORY

# Closing
echo "TOTAL FILES MOVED = $files_moved"
echo "$(date) - SORT PHOTO NAS STOPING"

IFS=$old_IFS
