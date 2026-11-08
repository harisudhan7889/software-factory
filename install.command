#!/bin/bash
# Double-click launcher for macOS. Opens in Terminal and runs install.sh.
cd "$(dirname "$0")" || exit 1
./install.sh "$@"
status=$?
echo
read -r -p "Press Enter to close this window..." _
exit $status
