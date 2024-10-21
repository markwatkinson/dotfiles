#!/usr/bin/env bash

data=`cpupower frequency-info -l | sed -n 2p`
fields=($data)

limited=${fields[0]}
unlimited=${fields[1]}

target=""

function print_usage() {
    echo "Usage: $(basename $BASH_SOURCE) [--limit [freq]|--unlimit]"
    echo ""
    echo "      --limit [freq]     Sets the limit. freq is optional and"
    echo "                         if not given will default to the lowest"
    echo "                         freq supported by the CPU."
    echo "                         freq can be given in any format accepted"
    echo "                         by cpupower, e.g. 1000Mhz, 1Ghz"
    echo ""
    echo "      --unlimit          Removes any limit"
}

if [ "${1}" == "" ] || [ "${1}" == "--help" ]; then
    cpupower frequency-info -p
    echo ""
    print_usage
    exit 0
elif [ "${1}" = "--unlimit" ]; then
    target="$unlimited"
elif [ "${1}" = "--limit" ] && [ "${2}" == "" ]; then
    target="$limited"
elif [ "${1}" = "--limit" ]; then
    target="${2}"
else
    print_usage
    exit 1
fi

echo "Got limits as: low: $limited, high: $unlimited"

sudo cpupower frequency-set --max $target
if [ $? -ne 0 ]; then
    echo "Failed to set frequency to $target"
    exit 1
fi
echo "Set limit to $target"
cpupower frequency-info -f -m
