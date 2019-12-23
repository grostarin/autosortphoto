# autosortphoto

BASH script which move photo from ORIGIN_DIRECTORY to DESTINATION_DIRECTORY\YYYY\MM
unsorted photo are moved in DESTINATION_DIRECTORY_ERROR

Requirement : exiftool

Parameters, in "autosortphoto.script.sh". set your owns, example :

```bash
ORIGIN_DIRECTORY="/volume1/upload/photo"
DESTINATION_DIRECTORY="/volume1/photo"
DESTINATION_DIRECTORY_ERROR="/volume1/photo/error"
EXIFTOOL_BINARY_PATH="./exiftool/exiftool"
```
