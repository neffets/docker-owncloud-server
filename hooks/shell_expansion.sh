#!/usr/bin/env bash
echo 'cat <<END_OF_TEXT' >  temp.sh
cat "$1"                 >> temp.sh
echo 'END_OF_TEXT'       >> temp.sh
source temp.sh > "$2"
rm -f temp.sh
