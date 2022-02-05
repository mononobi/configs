#!/bin/bash

# preventing multiple init-catalog calls.
if [ -d "../../src/demo/locale" ]
then
   echo "There is already a locale directory in the application folder."
   echo "If you want to init-catalog again, you must delete the old locale directory first."
   exit 1
fi

mkdir ../../src/demo/locale
pybabel extract -o ../../src/demo/locale/messages.pot ../../src/demo/
