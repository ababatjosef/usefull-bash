#!/bin/bash

<<COMMENT
# Basic
cat <<ADDTEXT
The quick
brown fox
jumps over
the lazy
Dog!
ADDTEXT
COMMENT

#<<COMMENT
# Disables TAB character
cat <<ADDTEXT2
	the
	quick
		brown
		fox
			jumps
			over
the
	lazy
		Dog!
ADDTEXT2
#COMMENT
