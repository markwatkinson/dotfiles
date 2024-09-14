#!/bin/bash

#################
# Sets the power profile based on running processes.
################

declare -a processes=("FalloutNV.exe" "Fallout4.exe" "gamescope")

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

if [[ "$profile" == "power-saver" ]] then
    pgrep -f '/opt/google/chrome' -u gfn
    if [[ $? == 0 ]] then
        process="chrome on gfn"
        profile="balanced"
        break
    fi
fi

current=$(powerprofilesctl get)

if [[ "$current" != "$profile" ]] then
    powerprofilesctl set "$profile"
    if [[ "$process" != "" ]] then
        echo "Set power profile $profile due to process $process";
    else
        echo "Set default power profile $profile";
    fi
fi
