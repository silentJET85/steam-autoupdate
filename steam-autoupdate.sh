#!/bin/bash

echo "Looking for Steam libraries..."
set -o pipefail
readarray -t libraries < <( grep  "\"path\"" "${STEAM_DIR}/config/libraryfolders.vdf" | sed -E 's|([[:blank:]]*"path"[[:blank:]]*")(.*)(")|\2|' || echo -n "${STEAM_DIR}" )
set +o pipefail

keepgoing=0
for currentlibrary in "${libraries[@]}"; do
    if [[ -d "$currentlibrary" ]]; then
        keepgoing=1
        echo "Found Steam Library: ${currentlibrary}"
    fi
done

if [[ $keepgoing == 0 ]]; then
    echo "Couldn't find Steam library. Exiting..."
else
    theprompt="\n\n\nThis script will change the auto-update settings of all of your Steam games.\
    \n\nWhat do you want to do? \
    \n\n1. Download updates whenever Steam feels like it.\
    \n2. Only update games when you launch them.\
    \n3. Download updates as soon as they are available.\
    \n\n4. Exit without making any changes."

    mychoice=""
    while [[ "$mychoice" != [1-4] ]]; do
        #clear
        echo -e "$theprompt"
        read -r mychoice
    done
    mychoice=$(( "$mychoice"-1 ))

    if [[ "$mychoice" == [0-2] ]]; then
        echo "Checking if Steam is running..."
        pgrep -x steam && echo "Closing Steam..." && killall --wait steam
        echo "Editing Manifest files..."

        for currentlibrary in "${libraries[@]}"; do
            echo -e "\nEditing files in library: $currentlibrary \n"
            for currentfile in "${currentlibrary}"/steamapps/appmanifest_*.acf; do
                echo "Editing file: \"${currentfile}\""
                sed -E -i 's|("AutoUpdateBehavior"[[:blank:]]*)"[[:digit:]]"|\1"'"${mychoice}"'"|' "$currentfile"
            done
        done
        echo -e "\nFinished."

    else
        echo "Exiting without making any changes..."
    fi

fi
