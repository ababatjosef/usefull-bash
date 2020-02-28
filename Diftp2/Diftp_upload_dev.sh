#!/bin/bash
if [ -z $1 ]; then
	cat <<EOF
	    =======================================================================================================
	    What can this script do?:
	    - Remove characters present in "*.dat" files such as: {, }, [, and ].
	    - Relocate files hidden under ".ssh" directory.
	    - Update the timestamp of all the "dat" files it finds.
	    - Shows you a list of files that were successfully uploaded(cleared) and files that needs manual check.
	    - Sends email of the processing results.
	    =======================================================================================================
EOF
fi
