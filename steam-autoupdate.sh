#!/bin/bash

manifestfiles="${HOME}/desktop/testacf/*.acf"
#manifestfiles="${STEAM_DIR}/steamapps/*.acf"
theprompt="\nThis script will change the auto-update settings of all of your Steam games.\
\n\nWhat do you want to do? \
\n\n1. Download updates whenever Steam feels like it.\
\n2. Only update games when you launch them.\
\n3. Download updates as soon as they are available.\
\n\n4. Exit without making any changes."

mychoice=""
while [[ "$mychoice" != [1-4] ]]; do
    clear
    echo -e "$theprompt"
    read -r mychoice
done
mychoice=$(( "$mychoice"-1 ))

if [[ "$mychoice" == [0-2] ]]; then
    pgrep -x steam && echo "Closing Steam..." && killall --wait steam
    echo "Editing Manifest files..."
    for currentfile in ${manifestfiles}; do
        echo "Editing file: \"${currentfile}\""
        sed -E -i 's|("AutoUpdateBehavior"[[:blank:]]*)"[[:digit:]]"|\1"'"${mychoice}"'"|' "$currentfile"
    done
    echo -e "\nFinished."
fi
