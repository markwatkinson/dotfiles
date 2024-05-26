#!/bin/bash

#################
# Sets the power profile based on running processes.
################

declare -a processes=("FalloutNV.exe")

profile="power-saver"
process=""

for i in "${processes[@]}"
do
    pgrep -f "$i" >> /dev/null

    if [[ $? == 0 ]] then
        process="$i"
        profile="balanced"
        break
    fi
done

current=$(powerprofilesctl get)

if [[ "$current" != "$profile" ]] then
    powerprofilesctl set "$profile"
    if [[ "$process" != "" ]] then
        echo "Set power profile $profile due to process $process";
    else
        echo "Set default power profile $profile";
    fi
fi
