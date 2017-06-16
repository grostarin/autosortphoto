# autosortphoto

move photo from ORIGIN_DIRECTORY to DESTINATION_DIRECTORY\YYYY\MM
Not sorted photo are moved in DESTINATION_DIRECTORY_ERROR

Requirement : exiftool

Parameter, in "sort_photo.nas.script.sh". set your own, example :
ORIGIN_DIRECTORY=`echo "/volume1/upload/photo"`
DESTINATION_DIRECTORY=`echo "/volume1/photo"`
DESTINATION_DIRECTORY_ERROR=`echo "/volume1/photo/error"`
