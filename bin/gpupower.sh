#!/usr/bin/env zsh

# Displays:
#       Power draw        | Time remaining until battery 0%
#       GPU Power status  | Screen refresh rate
#
# Intended to be displayed by Plasma's command output widget

readonly BAT_PATH="/sys/class/power_supply/BAT1"
readonly LENOPOW_PATH=$(realpath ~/bin/lenopow)
readonly BATTERY_CONSERVATION_STATUS_PATH="/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode"

usage() {
    # Prints general usage of the script.

    cat <<EOF
    usage: ${0##*/} [operation]
    operations:
    -h, --help        Show this message.
    -v, --version     Show script version.
    -w, --widget      Show widget text
EOF
}

die() {
    local exit_code=1
    local error_message="$1"

    echo "${0##*/}: ${error_message}" 1>&2

    exit "${exit_code}"
}


widget () {
    local watts=$(awk '{printf("%.2fW", $1*10^-6)}' "$BAT_PATH/power_now")
    local cstatus=$(cat "$BAT_PATH/status")
    local symbol="-"

    local pnow=$(cat "$BAT_PATH/power_now")
    local enow=$(cat "$BAT_PATH/energy_now")
    local remaining=$(($enow / "$pnow.0"))
    local efull=""

    if [[ "$cstatus" == "Charging" ]]; then
        local efull=$(cat "$BAT_PATH/energy_full")
        symbol="+"
        remaining=$(( ($efull - $enow) / "$pnow.0"  ))
    fi

    if [[ $pnow = 0 ]]; then
        remaining=0
    fi;


    local remaining_h=$(($remaining|0))
    local remaining_m_f=$((($remaining - $remaining_h)*60))
    local remaining_m=$(($remaining_m_f|0))
    local remaining_m_padded=${(l:2::0:)remaining_m}

    local gpu_status=$(cat /sys/class/drm/card0/device/power_state)

    local rrate=$(xrandr | grep '*+' | sed -r -e 's/(^\s+\S+\s+)|([^0-9\.])//g' | head -1)
    local rrate_hz=$(printf "%.0fHz" "$rrate")

    local c1_1="${symbol}${watts}"
    local c1_2="$remaining_h:$remaining_m_padded"
    if [[ "$cstatus" == "Charging" ]]; then
        # c1_2="Charging"
    fi
    local c2_1="$gpu_status"
    local c2_2="$rrate_hz"

    local col1_len=${#c1_1}
    local col2_len=${#c1_2}

    if [[ ${#c2_1} -ge $col1_len ]]; then
        col1_len=${#c2_1}
    fi
    if [[ ${#c2_2} -ge $col2_len ]]; then
        col2_len=${#c2_2}
    fi

    local col1_pad=$(( (col1_len + 1) / 2))
    local col2_pad=$(( (col2_len + 1) / 2))

    local cells=($c1_1 $c1_2 $c2_1 $c2_2)

    for ((i = 1; i <= $#cells; i++)); do

        local mod=$(( (i - 1) % 2 ))
        local target=$col1_len
        if [[ $mod -eq 1 ]]; then
            target=$col2_len
        fi

        local s=$cells[$i]

        while (( ${#s} < $target )); do
            s=" $s"
            if [[ ${#s} < $target ]]; then
                s="$s "
            fi
        done

        cells[$i]=$s
    done;


    local line1="$cells[1] | $cells[2]"
    local line2="$cells[3] | $cells[4]"

    echo $line1
    echo $line2
}

conservation_mode () {

    local stat="unknown"
    if [ -f $BATTERY_CONSERVATION_STATUS_PATH ]; then
        local s=$(cat "$BATTERY_CONSERVATION_STATUS_PATH")
        if [[ "$s" == "1" ]]; then
            stat="enabled"
        elif [[ "$s" == "0" ]]; then
            stat="disabled"
        fi
    fi

    kdialog --title "Battery Conservation Mode" --yes-label "Enable" --no-label "Disable" --yesno "Battery conservation mode is currently $stat. Enable?"
    local response=$?
    echo "Got response $response"
    if [[ "$response" == "0" ]]; then
        echo "Enabling battery conservation"
        kdesu -c "$LENOPOW_PATH -e"
    elif [[ "$response" == "1" ]]; then
        echo "Disabling battery conservation"
        kdesu -c "$LENOPOW_PATH -d"
    fi

}


main() {
    local key="$1"

    case "${key}" in
    -h | --help)
        usage
        ;;
    -v | --version)
        echo "${0##*/} v${VERSION}"
        ;;
    -w | --widget)
        widget
        ;;
    -c | --conservation-mode)
        conservation_mode
        ;;
    "")
        die "No operation specified. See '${0##*/} --help'."
        ;;
    *)
        die "Invaild operation '${key}'. See '${0##*/} --help'."
        ;;
    esac
}

main "$@"

