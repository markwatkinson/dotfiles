#!/usr/bin/env bash

data=`cpupower frequency-info -l | sed -n 2p`
fields=($data)

limited=${fields[0]}
unlimited=${fields[1]}


target=""

if [ "${1}" == "" ]; then
    cpupower frequency-info -p
    echo ""
    echo "Usage: ${0} [--limit|--unlimit]"
    exit 0
elif [ "${1}" = "--unlimit" ]; then
    #sudo systemctl start power-profiles-daemon.service
    #systemctl start --user power-profile.timer
    target="$unlimited"

elif [ "${1}" = "--limit" ]; then
    #sudo systemctl stop power-profiles-daemon.service
    #systemctl stop --user power-profile.timer
    target="$limited"
else
    echo "Usage: ${0} [--limit|--unlimit]"
    exit 1
fi

echo "Got limits as: low: $limited, high: $unlimited"

sudo cpupower frequency-set --max $target
echo "Set limit to $target"

