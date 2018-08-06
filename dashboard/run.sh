#!/bin/sh
SCRIPTPATH=$(cd "$(dirname "$0")"; pwd)
"$SCRIPTPATH/recon-pi-db" -importPath github.com/x1mdev/recon-pi-db -srcPath "$SCRIPTPATH/src" -runMode dev
