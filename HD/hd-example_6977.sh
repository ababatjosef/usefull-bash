#!/bin/bash

Newfile=Output.sh
(
cat <<'ADDTEXT4'

echo "This script creates a new file."

Var1 = 10
Var2 = 20

((Result=${Var1}*${Var2}))

echo "The result is: $Result"
ADDTEXT4
) > $Newfile
if [ -e $Newfile ]; then echo "$Newfile created"; fi
