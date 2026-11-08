#!/bin/bash
# Double-click launcher for macOS. Opens in Terminal and runs update.sh.
cd "$(dirname "$0")" || exit 1
./update.sh "$@"
status=$?
echo
read -r -p "Press Enter to close this window..." _
exit $status
